//
//  Data-Race-Condition-Prevention.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 26/10/26.
//

import Foundation
import os
import Synchronization

/*
 ╔══════════════════════════════════════════════════════════════════════════════╗
 ║  DATA RACE CONDITIONS IN SWIFT - WHAT THEY ARE & HOW TO PREVENT THEM         ║
 ╚══════════════════════════════════════════════════════════════════════════════╝

 DATA RACE (precise definition)
 ──────────────────────────────
 A data race happens when ALL THREE are true at the same time:
   1. Two or more threads access the SAME memory location
   2. At least ONE of those accesses is a WRITE
   3. There is NO synchronization (lock / queue / actor / atomic) ordering them

 Result: undefined behaviour -> lost updates, torn reads, corrupted collections,
 random crashes (EXC_BAD_ACCESS, malloc double free), bugs that vanish in debug.

 WHY `count += 1` IS NOT SAFE
 ────────────────────────────
 It is really three steps:  (1) READ count   (2) ADD 1   (3) WRITE count
 Thread A and B can both read 5, both write 6 -> one increment is LOST.

 Thread A: read(5) ──────── add ──── write(6)
 Thread B:       read(5) ── add ──────────── write(6)     <- expected 7, got 6

 DATA RACE  vs  RACE CONDITION  (very common interview follow-up)
 ───────────────────────────────────────────────────────────────
 • Data race       = unsynchronized memory access (low level, always a bug, UB).
 • Race condition  = outcome depends on timing/order of operations (logic level).
 You can have a race condition WITHOUT a data race (every access locked, but a
 check-then-act sequence is not atomic) and a data race WITHOUT a visible
 race condition (benign-looking, but still undefined behaviour in Swift).
 Locks/actors fix data races. Only correct *design* fixes race conditions.
*/

// MARK: - Shared Demo Plumbing

/// Every counter below conforms to this so one harness can hammer them all.
protocol CounterDR: AnyObject {
    func increment()
    var value: Int { get }
}

enum DataRaceHarnessDR {
    static let iterations = 100_000

    /// Fires `iterations` increments from many threads simultaneously.
    static func hammer(_ name: String, _ counter: CounterDR) {
        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            counter.increment()
        }
        let ok = counter.value == iterations
        print("\(ok ? "✅" : "❌") \(name): expected \(iterations), got \(counter.value)")
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MARK: - PART 1: WHAT IS A DATA RACE? (examples of the problem)
// ═══════════════════════════════════════════════════════════════════════════════

// MARK: 1.1 Lost updates - the classic counter
final class UnsafeCounterDR: CounterDR {
    private var count = 0

    func increment() {
        count += 1          // ❌ read -> add -> write: NOT atomic
    }

    var value: Int { count } // ❌ unsynchronized read racing with writes
}

// MARK: 1.2 Corrupted collections - the dangerous one
/// Swift collections are value types with copy-on-write storage. Appending from
/// two threads at once can corrupt the buffer / free it twice -> hard crash.
/// ⚠️ NOT called from the runner on purpose. Run it only to see the crash
/// (turn on Thread Sanitizer first to get a clean report instead).
enum UnsafeCollectionDemoDR {
    static func crashOrCorrupt() {
        var numbers: [Int] = []

        DispatchQueue.concurrentPerform(iterations: 100_000) { i in
            numbers.append(i)   // ❌ concurrent mutation of one array
        }

        // Typically < 100_000, or the app crashes before reaching this line.
        print("Array count: \(numbers.count)")
    }
}

// MARK: 1.3 Hidden data race - the "thread-safe singleton" myth
/// `static let shared` is initialised lazily and thread-safely (dispatch_once
/// semantics) - but that protects ONLY the creation of the instance.
/// The mutable properties inside it are still wide open.
final class UnsafeSessionManagerDR {
    static let shared = UnsafeSessionManagerDR()   // creation is thread-safe ✅
    private init() {}

    var authToken: String?                          // ❌ unprotected shared state
    var requestLog: [String] = []                   // ❌ unprotected shared state
}

// MARK: 1.4 Hidden data race - completion handlers on background queues
/// URLSession / Core Data / custom callbacks usually fire on arbitrary
/// background threads. Appending to one shared array from each = data race.
final class UnsafeAggregatorDR {
    private var results: [Int] = []

    func fetchAll(ids: [Int], completion: @escaping ([Int]) -> Void) {
        let group = DispatchGroup()

        for id in ids {
            group.enter()
            DispatchQueue.global().async {           // stand-in for a network call
                self.results.append(id * 10)          // ❌ concurrent append
                group.leave()
            }
        }

        group.notify(queue: .main) { completion(self.results) }
    }
}

// MARK: 1.5 Data race vs RACE CONDITION (check-then-act)
/// NO data race here: every single access to `_balance` is locked.
/// STILL a bug: the CHECK and the ACT are two separate critical sections,
/// so two threads can both pass the check and overdraw the account.
final class BankAccountRaceConditionDR {
    private let lock = NSLock()
    private var _balance = 100

    var balance: Int {
        lock.lock(); defer { lock.unlock() }
        return _balance
    }

    func withdrawBroken(_ amount: Int) -> Bool {
        if balance >= amount {                       // (1) CHECK (lock released after read)
            Thread.sleep(forTimeInterval: 0.001)     //     <- another thread slips in here
            lock.lock()
            _balance -= amount                       // (2) ACT   (balance may now be negative!)
            lock.unlock()
            return true
        }
        return false
    }

    // ✅ FIX: hold ONE lock across the whole check-then-act sequence.
    func withdrawFixed(_ amount: Int) -> Bool {
        lock.lock(); defer { lock.unlock() }
        guard _balance >= amount else { return false }
        _balance -= amount
        return true
    }

    func reset() {
        lock.lock(); _balance = 100; lock.unlock()
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MARK: - PART 2: WAYS TO PREVENT DATA RACES
// ═══════════════════════════════════════════════════════════════════════════════
/*
 Summary (details + examples below):

  #  Technique                          Kind            Min OS     Use when
 ─── ────────────────────────────────── ─────────────── ────────── ──────────────────────────────
  1  Immutability / value types         Design          any        Default choice - avoid sharing
  2  Serial DispatchQueue               Confinement     any        Legacy GCD code, simple state
  3  Concurrent queue + .barrier        Reader/Writer   any        Read-heavy caches
  4  DispatchSemaphore(value: 1)        Mutex           any        Rare; prefer a real lock
  5  NSLock / NSRecursiveLock           Mutex           any        Short critical sections
  6  OSAllocatedUnfairLock              Mutex           iOS 16     Fast, low-level, modern API
  7  Mutex (Synchronization)            Mutex           iOS 18     Swift-native, ~Copyable, safest
  8  Atomic (Synchronization)           Lock-free       iOS 18     Single flags / counters only
  9  OperationQueue (max 1)             Confinement     any        Already using Operations
 10  Actor                              Isolation       iOS 13*    Default for new async code
 11  @MainActor / global actor          Isolation       iOS 13*    UI state
 12  Sendable + strict concurrency      Compile-time    iOS 13*    Let the compiler find races
 13  Structured concurrency             Design          iOS 13*    Return results, don't share vars
 14  Thread Sanitizer                   Detection       Xcode      Finds races you missed

 (*) back-deployable via the Swift concurrency runtime; this project targets iOS 18.2.
*/

// ───────────────────────────────────────────────────────────────────────────────
// MARK: 2.1 Avoid sharing mutable state: immutability & value semantics
// ───────────────────────────────────────────────────────────────────────────────
/// The best fix for a data race is to make it impossible:
///  • `let` constants can be read from any number of threads safely.
///  • Value types are COPIED on assignment, so each thread mutates its own copy.
struct AppConfigDR {
    let baseURL: URL            // immutable -> safe to share across threads
    let timeout: TimeInterval
    let featureFlags: [String: Bool]
}

enum ImmutabilityDemoDR {
    static func demonstrate() {
        let original = [1, 2, 3]                   // `let` -> read-only shared data ✅

        DispatchQueue.concurrentPerform(iterations: 4) { i in
            var mine = original                    // COPY (copy-on-write) per thread ✅
            mine.append(i)                         // mutates only this thread's copy
            print("Thread-local result \(i): \(mine)")
        }

        print("Original untouched: \(original)")   // always [1, 2, 3]
    }

    /// "Mutate" immutable config by producing a new value instead of editing in place.
    static func updated(_ config: AppConfigDR, timeout: TimeInterval) -> AppConfigDR {
        AppConfigDR(baseURL: config.baseURL, timeout: timeout, featureFlags: config.featureFlags)
    }
}

// ───────────────────────────────────────────────────────────────────────────────
// MARK: 2.2 Serial DispatchQueue (thread confinement)
// ───────────────────────────────────────────────────────────────────────────────
/// All access to the state goes through ONE serial queue, so only one block
/// touches it at a time. State is "confined" to that queue.
final class SerialQueueCounterDR: CounterDR {
    private let queue = DispatchQueue(label: "com.app.counter.serial")
    private var count = 0

    func increment() {
        queue.sync { count += 1 }       // writes serialised ✅
    }

    var value: Int {
        queue.sync { count }            // reads go through the SAME queue ✅
    }
}

/// Real-world shape: protect a dictionary, expose a clean thread-safe API.
final class SerialQueueSessionManagerDR {
    static let shared = SerialQueueSessionManagerDR()
    private init() {}

    private let queue = DispatchQueue(label: "com.app.session.serial")
    private var _authToken: String?
    private var _requestLog: [String] = []

    var authToken: String? {
        get { queue.sync { _authToken } }
        set { queue.async { self._authToken = newValue } }   // async write: caller isn't blocked
    }

    func log(_ entry: String) {
        queue.async { self._requestLog.append(entry) }
    }

    var logSnapshot: [String] {
        queue.sync { _requestLog }       // returns a COPY (value type) ✅
    }

    /// Debug-only guard: crashes loudly if someone touches state off-queue.
    private func assertOnQueue() {
        dispatchPrecondition(condition: .onQueue(queue))
    }
}

/*
 ⚠️ SERIAL QUEUE PITFALLS
 • queue.sync { queue.sync { } }  ->  DEADLOCK (sync onto the queue you are already on)
 • Never call .sync on the main queue from the main thread.
 • Don't hand out references to mutable state - return copies (value types).
*/

// ───────────────────────────────────────────────────────────────────────────────
// MARK: 2.3 Concurrent queue + barrier (readers/writer lock)
// ───────────────────────────────────────────────────────────────────────────────
/// Many readers in parallel; a writer gets EXCLUSIVE access via `.barrier`.
/// Best for read-heavy data (caches, config, lookup tables).
final class BarrierCounterDR: CounterDR {
    private let queue = DispatchQueue(label: "com.app.counter.barrier", attributes: .concurrent)
    private var count = 0

    func increment() {
        queue.async(flags: .barrier) { self.count += 1 }   // exclusive write ✅
    }

    var value: Int {
        queue.sync { count }                                // concurrent reads ✅
    }
}

final class ThreadSafeCacheDR<Key: Hashable, Value> {
    private let queue = DispatchQueue(label: "com.app.cache.rw", attributes: .concurrent)
    private var storage: [Key: Value] = [:]

    func value(for key: Key) -> Value? {
        queue.sync { storage[key] }                         // many readers at once
    }

    func set(_ value: Value, for key: Key) {
        queue.async(flags: .barrier) { self.storage[key] = value }   // one writer, no readers
    }

    func remove(_ key: Key) {
        queue.async(flags: .barrier) { self.storage[key] = nil }
    }

    var count: Int { queue.sync { storage.count } }
}

/*
 ⚠️ BARRIER PITFALLS
 • .barrier only works on YOUR OWN concurrent queue. On a global queue it
   behaves like a plain async block (no exclusivity!).
 • Reads must use the same queue; a read outside the queue is still a race.
*/

// ───────────────────────────────────────────────────────────────────────────────
// MARK: 2.4 DispatchSemaphore(value: 1) used as a mutex
// ───────────────────────────────────────────────────────────────────────────────
final class SemaphoreCounterDR: CounterDR {
    private let semaphore = DispatchSemaphore(value: 1)     // 1 permit = mutual exclusion
    private var count = 0

    func increment() {
        semaphore.wait()                // acquire
        defer { semaphore.signal() }    // release (even on early return / throw)
        count += 1
    }

    var value: Int {
        semaphore.wait(); defer { semaphore.signal() }
        return count
    }
}

/*
 ⚠️ Semaphore is a *signalling* primitive, not an owner-aware lock: no priority
 donation, easy to forget signal(), deadlocks on early exit without `defer`.
 Prefer NSLock / OSAllocatedUnfairLock / Mutex for plain mutual exclusion.
*/

// ───────────────────────────────────────────────────────────────────────────────
// MARK: 2.5 NSLock & NSRecursiveLock
// ───────────────────────────────────────────────────────────────────────────────
final class NSLockCounterDR: CounterDR {
    private let lock = NSLock()
    private var count = 0

    func increment() {
        lock.lock()
        defer { lock.unlock() }         // ALWAYS pair lock/unlock with defer
        count += 1
    }

    var value: Int {
        lock.lock(); defer { lock.unlock() }
        return count
    }

    /// Foundation's closure-based helper (iOS 16+) - cannot forget to unlock.
    func incrementUsingWithLock() {
        lock.withLock { count += 1 }
    }
}

/// NSLock is NOT re-entrant: locking twice on the same thread = deadlock.
/// Use NSRecursiveLock when a locked method legitimately calls another locked method.
final class RecursiveLockDemoDR {
    private let lock = NSRecursiveLock()
    private var log: [String] = []

    func outer() {
        lock.lock(); defer { lock.unlock() }
        log.append("outer")
        inner()                         // same thread re-acquires: OK with recursive lock ✅
    }

    func inner() {
        lock.lock(); defer { lock.unlock() }
        log.append("inner")
    }

    var entries: [String] {
        lock.lock(); defer { lock.unlock() }
        return log
    }
}

/*
 ⚠️ LOCK PITFALLS
 • Forgetting unlock on an early return/throw  -> use `defer` or `withLock`.
 • Lock ordering: Thread 1 takes A then B, Thread 2 takes B then A -> DEADLOCK.
   Always acquire multiple locks in the same global order.
 • Don't call unknown code (closures/delegates) while holding a lock.
 • Keep critical sections tiny; never do I/O or `sleep` inside them.
*/

// ───────────────────────────────────────────────────────────────────────────────
// MARK: 2.6 OSAllocatedUnfairLock (iOS 16+) - modern wrapper over os_unfair_lock
// ───────────────────────────────────────────────────────────────────────────────
/// The lock OWNS the protected state, so you physically can't touch it unlocked.
final class UnfairLockCounterDR: CounterDR {
    private let state = OSAllocatedUnfairLock(initialState: 0)

    func increment() {
        state.withLock { $0 += 1 }
    }

    var value: Int {
        state.withLock { $0 }
    }
}

/// A lock-protected struct as state - great for several related properties.
final class UnfairLockSessionDR {
    private struct State {
        var token: String?
        var requestCount = 0
    }
    private let state = OSAllocatedUnfairLock(initialState: State())

    func setToken(_ token: String?) {
        state.withLock { $0.token = token }
    }

    func recordRequest() -> Int {
        state.withLock {
            $0.requestCount += 1
            return $0.requestCount      // check-and-update done in ONE critical section ✅
        }
    }
}

/*
 NOTES
 • Raw `os_unfair_lock` is a struct: storing it as `var lock = os_unfair_lock()`
   and passing `&lock` from different places can copy it / move it -> broken lock.
   OSAllocatedUnfairLock heap-allocates it for you - use it instead.
 • OSSpinLock is DEPRECATED (priority inversion). Unfair lock avoids that.
 • Not re-entrant, not fair (name says it).
*/

// ───────────────────────────────────────────────────────────────────────────────
// MARK: 2.7 Mutex & Atomic from the `Synchronization` module (iOS 18+ / Swift 6)
// ───────────────────────────────────────────────────────────────────────────────
@available(iOS 18.0, macOS 15.0, *)
final class MutexCounterDR: CounterDR {
    private let state = Mutex(0)            // Mutex<Int>, ~Copyable (can't be copied by accident)

    func increment() {
        state.withLock { $0 += 1 }
    }

    var value: Int {
        state.withLock { $0 }
    }
}

/// Atomics: lock-free, hardware-level operations on ONE value. Perfect for a
/// counter or flag; useless for protecting multi-step invariants.
@available(iOS 18.0, macOS 15.0, *)
final class AtomicCounterDR: CounterDR {
    private let count = Atomic<Int>(0)
    private let isCancelled = Atomic<Bool>(false)

    func increment() {
        count.wrappingAdd(1, ordering: .relaxed)    // single atomic read-modify-write ✅
    }

    var value: Int {
        count.load(ordering: .acquiring)
    }

    func cancel() { isCancelled.store(true, ordering: .releasing) }
    var cancelled: Bool { isCancelled.load(ordering: .acquiring) }
}

// ───────────────────────────────────────────────────────────────────────────────
// MARK: 2.8 OperationQueue with maxConcurrentOperationCount = 1
// ───────────────────────────────────────────────────────────────────────────────
final class OperationQueueCounterDR: CounterDR {
    private let queue: OperationQueue = {
        let q = OperationQueue()
        q.name = "com.app.counter.operations"
        q.maxConcurrentOperationCount = 1       // behaves like a serial queue ✅
        return q
    }()
    private var count = 0

    func increment() {
        queue.addOperation { self.count += 1 }
    }

    var value: Int {
        queue.waitUntilAllOperationsAreFinished()   // establishes happens-before for the read
        return count
    }
}

// ───────────────────────────────────────────────────────────────────────────────
// MARK: 2.9 @propertyWrapper "Atomic" - and why it is a TRAP
// ───────────────────────────────────────────────────────────────────────────────
/// Makes each individual get and set atomic. Looks great, but...
@propertyWrapper
final class AtomicDR<Value> {
    private let lock = NSLock()
    private var value: Value

    init(wrappedValue: Value) {
        self.value = wrappedValue
    }

    var wrappedValue: Value {
        get { lock.withLock { value } }
        set { lock.withLock { value = newValue } }
    }

    var projectedValue: AtomicDR<Value> { self }

    /// The correct way to do read-modify-write: ONE critical section.
    func mutate(_ transform: (inout Value) -> Void) {
        lock.withLock { transform(&value) }
    }
}

/// ❌ `count += 1` expands to `count = count + 1` = a locked GET, then a locked SET.
/// Another thread can run between them -> lost updates (a RACE CONDITION, no data race).
final class AtomicWrapperBrokenCounterDR: CounterDR {
    @AtomicDR private var count = 0

    func increment() { count += 1 }             // ❌ get + set are two separate locks
    var value: Int { count }
}

/// ✅ `mutate` does the read-modify-write under a single lock acquisition.
final class AtomicWrapperFixedCounterDR: CounterDR {
    @AtomicDR private var count = 0

    func increment() { $count.mutate { $0 += 1 } }
    var value: Int { count }
}

// ───────────────────────────────────────────────────────────────────────────────
// MARK: 2.10 Actors (Swift 5.5+) - compiler-enforced isolation
// ───────────────────────────────────────────────────────────────────────────────
/// An actor processes ONE message at a time. Its mutable state can only be
/// touched via `await` from outside, so the compiler rejects unsafe access.
actor ActorCounterDR {
    private var count = 0

    func increment() { count += 1 }             // inside the actor: plain, safe code
    var value: Int { count }
}

actor BankAccountActorDR {
    private(set) var balance: Int

    init(balance: Int) { self.balance = balance }

    enum BankError: Error { case insufficientFunds }

    /// ✅ No `await` between the check and the mutation -> atomic w.r.t. other callers.
    func withdraw(_ amount: Int) throws {
        guard balance >= amount else { throw BankError.insufficientFunds }
        balance -= amount
    }

    func deposit(_ amount: Int) { balance += amount }

    /// Calls on ANOTHER actor need `await`, which is a suspension point (see reentrancy).
    func transfer(_ amount: Int, to other: BankAccountActorDR) async throws {
        try withdraw(amount)                    // sync, still isolated ✅
        await other.deposit(amount)             // suspension point
    }
}

// MARK: 2.10.1 ⚠️ Actor reentrancy - actors fix DATA races, not RACE CONDITIONS
/// While an actor method is suspended at an `await`, ANOTHER call can enter the
/// actor. State you checked BEFORE the `await` may be stale AFTER it.
actor ReentrantImageLoaderDR {
    private var cache: [URL: Data] = [:]
    private(set) var downloadCount = 0

    // ❌ Two concurrent callers both see an empty cache, both download.
    func imageBroken(for url: URL) async -> Data {
        if let cached = cache[url] { return cached }    // (1) check
        let data = await download(url)                  // ⚠️ suspension - others can enter!
        cache[url] = data                               // (2) act on stale assumption
        return data
    }

    // Fixed version below.
    private var inFlight: [URL: Task<Data, Never>] = [:]

    // ✅ Record the in-flight Task BEFORE awaiting so later callers join it.
    func imageFixed(for url: URL) async -> Data {
        if let cached = cache[url] { return cached }
        if let running = inFlight[url] { return await running.value }

        let task = Task { await self.download(url) }
        inFlight[url] = task                            // published before any suspension ✅

        let data = await task.value
        cache[url] = data
        inFlight[url] = nil
        return data
    }

    private func download(_ url: URL) async -> Data {
        downloadCount += 1
        try? await Task.sleep(nanoseconds: 100_000_000)  // simulate network
        return Data(url.absoluteString.utf8)
    }

    func clear() {
        cache.removeAll(); inFlight.removeAll(); downloadCount = 0
    }
}

// ───────────────────────────────────────────────────────────────────────────────
// MARK: 2.11 @MainActor / global actors - UI state lives on the main thread
// ───────────────────────────────────────────────────────────────────────────────
@MainActor
final class ProfileViewModelDR {
    private(set) var title = "—"
    private(set) var isLoading = false

    func load() async {
        isLoading = true                                // on main actor ✅

        // Heavy work hops OFF the main actor...
        let fetched = await Task.detached(priority: .userInitiated) { () -> String in
            try? await Task.sleep(nanoseconds: 200_000_000)
            return "Loaded profile"
        }.value

        // ...and automatically hops BACK before touching `title`.
        title = fetched
        isLoading = false
    }
}

/// Custom global actor: one shared isolation domain for a whole subsystem.
@globalActor
actor DatabaseActorDR {
    static let shared = DatabaseActorDR()
}

@DatabaseActorDR
final class LocalStoreDR {
    private var rows: [Int: String] = [:]               // isolated to DatabaseActorDR ✅

    func insert(_ id: Int, _ value: String) { rows[id] = value }
    func row(_ id: Int) -> String? { rows[id] }
}

/*
 What the compiler gives you for free:

   let vm = await ProfileViewModelDR()
   vm.title = "x"        // ❌ error: main actor-isolated property can't be mutated
                         //    from a nonisolated context
   await vm.load()       // ✅ must hop to the main actor
*/

// ───────────────────────────────────────────────────────────────────────────────
// MARK: 2.12 Sendable & strict concurrency - let the compiler find races
// ───────────────────────────────────────────────────────────────────────────────
/// ✅ Value type with immutable `Sendable` members -> safe to pass across threads.
struct UserSnapshotDR: Sendable {
    let id: Int
    let name: String
}

/// ✅ `final` class whose stored properties are all immutable (`let`) and Sendable.
final class ImmutableSettingsDR: Sendable {
    let baseURL: URL
    let retryCount: Int

    init(baseURL: URL, retryCount: Int) {
        self.baseURL = baseURL
        self.retryCount = retryCount
    }
}

/// ✅ Escape hatch: a class with mutable state that YOU protect manually.
/// `@unchecked` = "compiler, trust me" - if the lock is wrong, no one will tell you.
final class LegacyTokenStoreDR: @unchecked Sendable {
    private let lock = NSLock()
    private var token: String?

    func set(_ newValue: String?) { lock.withLock { token = newValue } }
    func get() -> String? { lock.withLock { token } }
}

/// What the compiler catches in Swift 6 mode / `-strict-concurrency=complete`:
final class MutableBoxDR {                                 // NOT Sendable (mutable class)
    var number = 0
}

enum SendableDemoDR {
    static func demonstrate() async {
        let snapshot = UserSnapshotDR(id: 1, name: "Ana")
        let box = MutableBoxDR()

        await Task.detached {
            print("Snapshot crosses threads safely: \(snapshot.name)")  // ✅ Sendable
            // box.number += 1
            // ❌ Swift 6: "Capture of 'box' with non-sendable type 'MutableBoxDR'
            //    in a '@Sendable' closure"  -> the race never reaches runtime.
        }.value

        _ = box
    }
}

// ───────────────────────────────────────────────────────────────────────────────
// MARK: 2.13 Structured concurrency - return results, don't share variables
// ───────────────────────────────────────────────────────────────────────────────
enum StructuredConcurrencyDemoDR {

    /// ✅ Each child task RETURNS a value; only the parent accumulates, sequentially.
    static func sumOfSquares(_ numbers: [Int]) async -> Int {
        await withTaskGroup(of: Int.self) { group in
            for n in numbers {
                group.addTask { n * n }                    // no shared mutable state
            }

            var total = 0                                   // touched by the parent only
            for await partial in group { total += partial }
            return total
        }
    }

    /// ✅ Same idea for the URLSession-callback race from 1.4: gather results via
    /// the group instead of appending to a shared array from many threads.
    static func fetchAll(ids: [Int]) async -> [Int] {
        await withTaskGroup(of: Int.self) { group in
            for id in ids {
                group.addTask {
                    try? await Task.sleep(nanoseconds: 10_000_000)   // stand-in for network
                    return id * 10
                }
            }
            var results: [Int] = []
            for await value in group { results.append(value) }
            return results.sorted()
        }
    }

    /*
     ❌ The version the compiler stops you from writing (Swift 6 error, Swift 5 warning):

        var total = 0
        await withTaskGroup(of: Void.self) { group in
            for n in numbers {
                group.addTask { total += n * n }   // mutation of captured var in
            }                                      // concurrently-executing code
        }
    */
}

// ───────────────────────────────────────────────────────────────────────────────
// MARK: Fixed versions of the problems from PART 1
// ───────────────────────────────────────────────────────────────────────────────

/// Fix for 1.3 (singleton with mutable state): protect it with a lock-owned state.
final class SafeSessionManagerDR: @unchecked Sendable {
    static let shared = SafeSessionManagerDR()
    private init() {}

    private struct State {
        var authToken: String?
        var requestLog: [String] = []
    }
    private let state = OSAllocatedUnfairLock(initialState: State())

    var authToken: String? {
        get { state.withLock { $0.authToken } }
        set { state.withLock { $0.authToken = newValue } }
    }

    func log(_ entry: String) { state.withLock { $0.requestLog.append(entry) } }
    var logSnapshot: [String] { state.withLock { $0.requestLog } }
}

/// Fix for 1.4 (completion handlers): serialise the writes with a lock.
final class SafeAggregatorDR {
    func fetchAll(ids: [Int], completion: @escaping ([Int]) -> Void) {
        let results = OSAllocatedUnfairLock(initialState: [Int]())
        let group = DispatchGroup()

        for id in ids {
            group.enter()
            DispatchQueue.global().async {
                results.withLock { $0.append(id * 10) }     // ✅ synchronized append
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(results.withLock { $0 }.sorted())
        }
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MARK: - PART 3: DETECTING DATA RACES
// ═══════════════════════════════════════════════════════════════════════════════
/*
 1. THREAD SANITIZER (TSan)  - runtime detection
    Xcode: Product > Scheme > Edit Scheme > Run > Diagnostics > ✔ Thread Sanitizer
    CLI:   xcodebuild test -enableThreadSanitizer YES ...
    • Reports "WARNING: ThreadSanitizer: data race" with BOTH conflicting stacks.
    • Only finds races that actually EXECUTE during the run -> pair with tests.
    • 2-20x slowdown, can't combine with Address Sanitizer; simulator only for iOS.

 2. SWIFT STRICT CONCURRENCY - compile-time detection
    Build Settings > Strict Concurrency Checking = Complete
    (or `-strict-concurrency=complete`, or Swift Language Version = 6)
    • Flags non-Sendable captures, actor-isolation violations, shared globals.
    • Swift 6 language mode turns these warnings into hard ERRORS.

 3. EXCLUSIVITY ENFORCEMENT - not the same thing!
    Swift's "overlapping accesses" check catches simultaneous access to a
    variable from the SAME thread (e.g. passing `&x` while reading `x`).
    It does NOT detect races between different threads.

 4. DEBUGGING TRICKS
    • dispatchPrecondition(condition: .onQueue(q)) / .notOnQueue(q)
    • MainActor.assertIsolated()   (iOS 17+)
    • Main Thread Checker for UIKit-off-main-thread misuse
*/

// MARK: - Demo Runner
enum DataRaceDemoRunnerDR {

    static func runAll() async {
        print("\n══════ PART 1: THE PROBLEM ══════")
        DataRaceHarnessDR.hammer("UnsafeCounter (data race)", UnsafeCounterDR())
        demonstrateBankRaceCondition()

        print("\n══════ PART 2: THE FIXES ══════")
        DataRaceHarnessDR.hammer("Serial queue", SerialQueueCounterDR())
        DataRaceHarnessDR.hammer("Concurrent queue + barrier", BarrierCounterDR())
        DataRaceHarnessDR.hammer("DispatchSemaphore(1)", SemaphoreCounterDR())
        DataRaceHarnessDR.hammer("NSLock", NSLockCounterDR())
        DataRaceHarnessDR.hammer("OSAllocatedUnfairLock", UnfairLockCounterDR())
        if #available(iOS 18.0, macOS 15.0, *) {
            DataRaceHarnessDR.hammer("Mutex (Synchronization)", MutexCounterDR())
            DataRaceHarnessDR.hammer("Atomic (Synchronization)", AtomicCounterDR())
        }
        DataRaceHarnessDR.hammer("OperationQueue (max 1)", OperationQueueCounterDR())

        print("\n── property-wrapper trap ──")
        DataRaceHarnessDR.hammer("@Atomic wrapper, `+= 1` (broken)", AtomicWrapperBrokenCounterDR())
        DataRaceHarnessDR.hammer("@Atomic wrapper, `mutate` (fixed)", AtomicWrapperFixedCounterDR())

        print("\n── actors ──")
        await demonstrateActorCounter()
        await demonstrateActorReentrancy()

        print("\n── structured concurrency ──")
        let sum = await StructuredConcurrencyDemoDR.sumOfSquares(Array(1...100))
        print("\(sum == 338_350 ? "✅" : "❌") sumOfSquares(1...100) = \(sum) (expected 338350)")

        print("\n── immutability ──")
        ImmutabilityDemoDR.demonstrate()
    }

    private static func demonstrateBankRaceCondition() {
        let account = BankAccountRaceConditionDR()

        DispatchQueue.concurrentPerform(iterations: 10) { _ in _ = account.withdrawBroken(100) }
        print("\(account.balance >= 0 ? "✅" : "❌") withdrawBroken: balance = \(account.balance) (should never be < 0)")

        account.reset()
        DispatchQueue.concurrentPerform(iterations: 10) { _ in _ = account.withdrawFixed(100) }
        print("\(account.balance >= 0 ? "✅" : "❌") withdrawFixed:  balance = \(account.balance)")
    }

    private static func demonstrateActorCounter() async {
        let counter = ActorCounterDR()
        let total = DataRaceHarnessDR.iterations

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<total {
                group.addTask { await counter.increment() }
            }
        }

        let value = await counter.value
        print("\(value == total ? "✅" : "❌") Actor: expected \(total), got \(value)")
    }

    private static func demonstrateActorReentrancy() async {
        let loader = ReentrantImageLoaderDR()
        let url = URL(string: "https://example.com/logo.png")!

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<5 { group.addTask { _ = await loader.imageBroken(for: url) } }
        }
        let broken = await loader.downloadCount
        print("❌ imageBroken: downloaded \(broken)x (expected 1) - reentrancy")

        await loader.clear()

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<5 { group.addTask { _ = await loader.imageFixed(for: url) } }
        }
        let fixed = await loader.downloadCount
        print("\(fixed == 1 ? "✅" : "❌") imageFixed:  downloaded \(fixed)x (expected 1)")
    }
}

// MARK: - Interview Key Points

/*
 IMPORTANT INTERVIEW CONCEPTS COVERED:

 1. **What is a data race?**
    - Two+ threads access the same memory, at least one writes, no synchronization.
    - Undefined behaviour: lost updates, torn reads, corrupted collections, crashes.
    - `count += 1` is read-modify-write (3 steps), not a single atomic step.

 2. **Data race vs race condition**
    - Data race: unsynchronized memory access (low level, always a bug).
    - Race condition: result depends on timing/order (logic level).
    - Fully-locked code can still have a race condition (check-then-act).
    - Fix = widen the critical section so check + act happen under ONE lock/isolation.

 3. **Ways to prevent (best -> last resort)**
    a. Don't share mutable state: `let`, value types, copy-on-write, pass copies.
    b. Actors / @MainActor / global actors: compiler-enforced isolation (new code).
    c. Sendable + strict concurrency: compile-time proof; Swift 6 makes it an error.
    d. Structured concurrency: child tasks return values, parent aggregates.
    e. Serial queue: confine state to one queue (GCD codebases).
    f. Concurrent queue + barrier: reader/writer for read-heavy data.
    g. Locks: NSLock, NSRecursiveLock, OSAllocatedUnfairLock, Mutex (iOS 18).
    h. Atomics (Synchronization.Atomic): single value counters/flags only.
    i. OperationQueue with maxConcurrentOperationCount = 1.
    j. DispatchSemaphore(value: 1): works, but not recommended for mutual exclusion.

 4. **Actors in depth**
    - One message at a time; state reachable only through `await` from outside.
    - Prevent DATA races, NOT race conditions: actors are REENTRANT.
    - At every `await` inside an actor method, other calls can interleave.
    - Re-check state after `await`, or make the check+mutation synchronous,
      or store an in-flight Task (see ReentrantImageLoaderDR.imageFixed).
    - `nonisolated` members skip isolation; only use them for immutable data.

 5. **Sendable**
    - Marker protocol: "safe to transfer across concurrency domains".
    - Automatic for value types with Sendable members, actors, immutable final classes.
    - `@unchecked Sendable` = you guarantee thread safety manually (e.g. with a lock).
    - Non-Sendable class captured by `@Sendable` closure -> error in Swift 6 mode.

 6. **Barrier gotchas**
    - Only works on a custom CONCURRENT queue you created yourself.
    - On global queues, `.barrier` is silently ignored.
    - Reads and writes must both go through that same queue.

 7. **Lock gotchas**
    - Deadlock: re-locking a non-recursive lock; inconsistent lock ordering;
      `queue.sync` onto the current queue.
    - Always `defer { unlock() }` or use `withLock`.
    - Never hold a lock across `await` (withLock closures are synchronous, so the compiler blocks it).
    - Don't call out to unknown closures/delegates while holding a lock.

 8. **Atomic property wrapper trap**
    - Locking each getter/setter does NOT make `x += 1` atomic (get, then set).
    - Provide a `mutate { }` that does read-modify-write under one lock.
    - Same trap for `array.append` through a wrapper that only locks get/set of the array.

 9. **Thread-safe singleton myth**
    - `static let shared` makes CREATION thread-safe only.
    - Mutable properties on the singleton still need their own protection.

10. **Detection**
    - Thread Sanitizer (runtime, needs the race to actually happen).
    - Strict Concurrency Checking = Complete / Swift 6 mode (compile time).
    - Exclusivity enforcement only covers same-thread overlapping access.

11. **Common Interview Questions**:
    - Q: How do you make a Swift Array/Dictionary thread-safe?
    - A: They are not thread-safe for concurrent mutation. Wrap in an actor, a serial
         queue, a barrier-protected concurrent queue, or a lock-owned state type.

    - Q: Are `let` properties thread-safe?
    - A: Yes for the binding, since it never changes. A `let` reference to a mutable
         class instance is NOT safe - the object's internals can still race.

    - Q: Does a serial queue make `sync` calls safe from any thread?
    - A: Yes for data races, but `sync` from the same queue deadlocks.

    - Q: Actor vs lock - when to choose which?
    - A: Actor for async code and new APIs (compile-time checked, no blocking).
         Lock/Mutex for synchronous APIs, tiny critical sections, or when you
         can't make the caller async.

    - Q: Is `atomic` a thing in Swift like Objective-C?
    - A: No. ObjC properties were `atomic` by default (and still not fully safe).
         Swift has no atomic keyword; use locks/actors or `Atomic<T>` (iOS 18+).

    - Q: Why can an actor still have a race condition?
    - A: Reentrancy: state can change across an `await` suspension point.

    - Q: How would you detect a data race you can't reproduce?
    - A: Run tests with Thread Sanitizer, enable strict concurrency checking,
         and add dispatchPrecondition / MainActor.assertIsolated assertions.

12. **Best Practices**:
    - Prefer immutability and value types; share as little as possible.
    - New code: actors + async/await + Sendable. Legacy code: serial queue or lock.
    - Protect state WITH the lock (OSAllocatedUnfairLock / Mutex own it).
    - Make check-then-act sequences a single critical section.
    - Never expose internal mutable collections - return copies.
    - Keep critical sections short; no I/O, no callbacks inside them.
    - Run the test suite with Thread Sanitizer in CI.
    - Adopt Swift 6 language mode incrementally per module.
*/
