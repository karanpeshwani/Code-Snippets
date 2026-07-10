// 460. LFU Cache
// https://leetcode.com/problems/lfu-cache/description/

/*
 Intuition:
 We need O(1) time for both `get` and `put`. This requires combining a hash map for O(1) key lookups
 with a mechanism that can track and evict the Least Frequently Used key in O(1) time too.

 The key insight: group keys by their frequency count. For each frequency, maintain a doubly linked list
 of keys with that frequency, ordered by recency (most recently used at the head, least recently used at
 the tail). This handles ties between keys sharing the same frequency (evict the LRU one among them).

 We maintain:
 1. `keyToNode`: key -> Node (Node holds key, value, and frequency), for O(1) access to any key's data.
 2. `freqToList`: frequency -> doubly linked list of Nodes with that frequency, for O(1) grouping.
 3. `minFreq`: tracks the current minimum frequency across all keys, so eviction is O(1)
    (just pop the tail of freqToList[minFreq]).

 On `get`/`put` (update), a key's node is unlinked from its current frequency list and relinked
 at the head of the (freq + 1) list. If the old list becomes empty and it was the minFreq list,
 minFreq is incremented.

 On `put` (insert) when at capacity, we evict the tail node of freqToList[minFreq] (the LFU, and
 among ties, LRU, key), then insert the new key with frequency 1, resetting minFreq to 1.

 Time Complexity: O(1) for both `get` and `put`.
 - All operations (dictionary lookups, linked list insert/remove) are O(1).
 Space Complexity: O(capacity)
 - We store at most `capacity` nodes across keyToNode and the frequency lists.
 */

class Node {
    let key: Int
    var value: Int
    var freq: Int
    var prev: Node?
    var next: Node?
    
    init(_ key: Int, _ value: Int) {
        self.key = key
        self.value = value
        self.freq = 1
    }
}

class DLinkedList {
    private let head: Node
    private let tail: Node
    private(set) var count: Int = 0
    
    init() {
        head = Node(-1, -1)
        tail = Node(-1, -1)
        head.next = tail
        tail.prev = head
    }
    
    var isEmpty: Bool { count == 0 }
    
    func addToHead(_ node: Node) {
        node.prev = head
        node.next = head.next
        head.next?.prev = node
        head.next = node
        count += 1
    }
    
    func remove(_ node: Node) {
        node.prev?.next = node.next
        node.next?.prev = node.prev
        node.prev = nil
        node.next = nil
        count -= 1
    }
    
    func removeTail() -> Node? {
        guard count > 0, let node = tail.prev else { return nil }
        remove(node)
        return node
    }
}

class LFUCache {
    private var capacity: Int
    private var minFreq: Int
    private var keyToNode: [Int: Node]
    private var freqToList: [Int: DLinkedList]
    
    init(_ capacity: Int) {
        self.capacity = capacity
        self.minFreq = 0
        self.keyToNode = [:]
        self.freqToList = [:]
    }
    
    private func touch(_ node: Node) {
        let oldFreq = node.freq
        freqToList[oldFreq]?.remove(node)
        if freqToList[oldFreq]?.isEmpty == true && minFreq == oldFreq {
            minFreq += 1
        }
        
        node.freq += 1
        let newList = freqToList[node.freq] ?? DLinkedList()
        newList.addToHead(node)
        freqToList[node.freq] = newList
    }
    
    func get(_ key: Int) -> Int {
        guard let node = keyToNode[key] else { return -1 }
        touch(node)
        return node.value
    }
    
    func put(_ key: Int, _ value: Int) {
        guard capacity > 0 else { return }
        
        if let node = keyToNode[key] {
            node.value = value
            touch(node)
            return
        }
        
        if keyToNode.count == capacity {
            if let evicted = freqToList[minFreq]?.removeTail() {
                keyToNode[evicted.key] = nil
            }
        }
        
        let node = Node(key, value)
        keyToNode[key] = node
        let list = freqToList[1] ?? DLinkedList()
        list.addToHead(node)
        freqToList[1] = list
        minFreq = 1
    }
}
