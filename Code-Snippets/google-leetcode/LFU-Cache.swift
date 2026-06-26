//
//  LFU-Cache.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 24/06/26.
//

import Foundation

class Node: Hashable {
    let key: Int
    var val: Int
    var freq: Int
    var next: Node?
    
    // CRITICAL: Swift uses ARC. Using 'weak' prevents strong reference cycles
    // and ensures memory doesn't leak when nodes are removed.
    weak var prev: Node?
    
    init(key: Int, val: Int) {
        self.key = key
        self.val = val
        self.freq = 1
    }
    
    // Equatable
    static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.key == rhs.key  // define what makes two Nodes "equal"
    }

    // Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(key)  // combine the properties that define equality
    }
}

class DLinkedList {
    // Using explicit head and tail dummy nodes is safer in Swift
    // to avoid initialization headaches with self-referencing nodes.
    private let head: Node
    private let tail: Node
    private(set) var size: Int = 0
    
    init() {
        head = Node(key: -1, val: -1)
        tail = Node(key: -1, val: -1)
        head.next = tail
        tail.prev = head
    }
    
    /// Appends the node to the head of the linked list (Most Recently Used).
    func append(_ node: Node) {
        node.next = head.next
        node.prev = head
        
        head.next?.prev = node
        head.next = node
        size += 1
    }
    
    /// Removes the referenced node.
    /// If no node is provided, removes the node right before the tail (Least Recently Used).
    @discardableResult
    func pop(_ node: Node? = nil) -> Node? {
        guard size > 0 else { return nil }
        
        // If node is nil, grab the one right before the tail dummy node
        guard let nodeToRemove = node ?? tail.prev, nodeToRemove !== head else {
            return nil
        }
        
        nodeToRemove.prev?.next = nodeToRemove.next
        nodeToRemove.next?.prev = nodeToRemove.prev
        size -= 1
        
        // Sever ties to ensure clean deallocation
        nodeToRemove.next = nil
        nodeToRemove.prev = nil
        
        return nodeToRemove
    }
}

class LFUCache {
    private let capacity: Int
    private var size: Int = 0
    private var minFreq: Int = 0
    
    private var nodeMap: [Int: Node] = [:]
    private var freqMap: [Int: DLinkedList] = [:]
    
    init(_ capacity: Int) {
        self.capacity = capacity
    }
    
    private func update(_ node: Node) {
        let currentFreq = node.freq
        
        // 1. Remove from current frequency list
        freqMap[currentFreq]?.pop(node)
        
        // 2. Check if we need to increment minFreq
        if minFreq == currentFreq, let list = freqMap[currentFreq], list.size == 0 {
            minFreq += 1
        }
        
        // 3. Increment node frequency and move to new list
        node.freq += 1
        let newFreq = node.freq
        
        if freqMap[newFreq] == nil {
            freqMap[newFreq] = DLinkedList()
        }
        freqMap[newFreq]?.append(node)
    }
    
    func get(_ key: Int) -> Int {
        guard let node = nodeMap[key] else { return -1 }
        
        update(node)
        return node.val
    }
    
    func put(_ key: Int, _ value: Int) {
        if capacity == 0 { return }
        
        if let node = nodeMap[key] {
            // Key exists: update value and frequency
            node.val = value
            update(node)
        } else {
            // Key is new: Check capacity constraints
            if size == capacity {
                // Pop the LRU node from the minimum frequency list
                if let list = freqMap[minFreq], let lruNode = list.pop() {
                    nodeMap.removeValue(forKey: lruNode.key)
                    size -= 1
                }
            }
            
            // Create and insert the new node
            let newNode = Node(key: key, val: value)
            nodeMap[key] = newNode
            
            if freqMap[1] == nil {
                freqMap[1] = DLinkedList()
            }
            freqMap[1]?.append(newNode)
            
            minFreq = 1
            size += 1
        }
    }
}
