//
//  CoreData-Concepts.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 31/07/25.
//

import Foundation
import CoreData
import UIKit

// MARK: - Core Data Stack
class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    private init() {}
    
    // MARK: - Persistent Container
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel") // Your .xcdatamodeld file name
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // In production, handle this error appropriately
                fatalError("Core Data error: \(error), \(error.userInfo)")
            }
        }
        
        // Configure automatic merging
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    // MARK: - Contexts
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    // MARK: - Save Context
    func saveContext() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
                print("💾 Core Data context saved successfully")
            } catch {
                let nsError = error as NSError
                print("❌ Core Data save error: \(nsError), \(nsError.userInfo)")
                // Handle the error appropriately
            }
        }
    }
    
    func saveBackgroundContext(_ context: NSManagedObjectContext) {
        context.perform {
            if context.hasChanges {
                do {
                    try context.save()
                    print("💾 Background context saved successfully")
                } catch {
                    let nsError = error as NSError
                    print("❌ Background context save error: \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }
}

// MARK: - Managed Object Subclasses (These would typically be generated)

// MARK: - User Entity
@objc(User2)
public class User2: NSManagedObject {
    
    @NSManaged public var userID: String
    @NSManaged public var name: String
    @NSManaged public var email: String
    @NSManaged public var createdAt: Date
    @NSManaged public var isActive: Bool
    @NSManaged public var posts: NSSet?
    @NSManaged public var profile: Profile1?
    
    // Convenience initializer
    convenience init(context: NSManagedObjectContext, userID: String, name: String, email: String) {
        self.init(context: context)
        self.userID = userID
        self.name = name
        self.email = email
        self.createdAt = Date()
        self.isActive = true
    }
}

// MARK: - User Core Data Extensions
extension User2 {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<User2> {
        return NSFetchRequest<User2>(entityName: "User2")
    }
    
    // Computed properties for relationships
    public var postsArray: [Post2] {
        let set = posts as? Set<Post2> ?? []
        return set.sorted { $0.createdAt < $1.createdAt }
    }
    
    public var activePostsCount: Int {
        return postsArray.filter { !$0.isDeleted }.count
    }
}

// MARK: - Post Entity
@objc(Post2)
public class Post2: NSManagedObject {
    
    @NSManaged public var postID: String
    @NSManaged public var title: String
    @NSManaged public var content: String
    @NSManaged public var createdAt: Date
    @NSManaged public var updatedAt: Date
    @NSManaged public var isDeleted: Bool
    @NSManaged public var viewCount: Int32
    @NSManaged public var author: User2?
    @NSManaged public var tags: NSSet?
    
    convenience init(context: NSManagedObjectContext, postID: String, title: String, content: String, author: User2) {
        self.init(context: context)
        self.postID = postID
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
        self.isDeleted = false
        self.viewCount = 0
        self.author = author
    }
}

extension Post2 {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Post2> {
        return NSFetchRequest<Post2>(entityName: "Post2")
    }
    
    public var tagsArray: [Tag1] {
        let set = tags as? Set<Tag1> ?? []
        return set.sorted { $0.name < $1.name }
    }
}

// MARK: - Profile Entity
@objc(Profile1)
public class Profile1: NSManagedObject {
    
    @NSManaged public var bio: String?
    @NSManaged public var avatarURL: String?
    @NSManaged public var location: String?
    @NSManaged public var website: String?
    @NSManaged public var user: User2?
}

extension Profile1 {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Profile1> {
        return NSFetchRequest<Profile1>(entityName: "Profile1")
    }
}

// MARK: - Tag Entity
@objc(Tag1)
public class Tag1: NSManagedObject {
    
    @NSManaged public var name: String
    @NSManaged public var color: String?
    @NSManaged public var posts: NSSet?
}

extension Tag1 {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag1> {
        return NSFetchRequest<Tag1>(entityName: "Tag1")
    }
}

// MARK: - Core Data Manager
class CoreDataManager1 {
    
    private let coreDataStack = CoreDataStack.shared
    
    // MARK: - User Operations
    func createUser(userID: String, name: String, email: String) -> User2 {
        let context = coreDataStack.viewContext
        let user = User2(context: context, userID: userID, name: name, email: email)
        
        coreDataStack.saveContext()
        print("👤 Created user: \(name)")
        return user
    }
    
    func fetchUsers() -> [User2] {
        let context = coreDataStack.viewContext
        let request: NSFetchRequest<User2> = User2.fetchRequest()
        
        // Sort by creation date
        request.sortDescriptors = [NSSortDescriptor(keyPath: \User2.createdAt, ascending: false)]
        
        do {
            let users = try context.fetch(request)
            print("📥 Fetched \(users.count) users")
            return users
        } catch {
            print("❌ Error fetching users: \(error)")
            return []
        }
    }
    
    func fetchUser(by userID: String) -> User2? {
        let context = coreDataStack.viewContext
        let request: NSFetchRequest<User2> = User2.fetchRequest()
        request.predicate = NSPredicate(format: "userID == %@", userID)
        request.fetchLimit = 1
        
        do {
            let users = try context.fetch(request)
            return users.first
        } catch {
            print("❌ Error fetching user: \(error)")
            return nil
        }
    }
    
    func updateUser(_ user: User2, name: String? = nil, email: String? = nil, isActive: Bool? = nil) {
        let context = coreDataStack.viewContext
        
        if let name = name {
            user.name = name
        }
        if let email = email {
            user.email = email
        }
        if let isActive = isActive {
            user.isActive = isActive
        }
        
        coreDataStack.saveContext()
        print("✏️ Updated user: \(user.name)")
    }
    
    func deleteUser(_ user: User2) {
        let context = coreDataStack.viewContext
        context.delete(user)
        coreDataStack.saveContext()
        print("🗑️ Deleted user: \(user.name)")
    }
    
    // MARK: - Post Operations
    func createPost(postID: String, title: String, content: String, author: User2) -> Post2 {
        let context = coreDataStack.viewContext
        let post = Post2(context: context, postID: postID, title: title, content: content, author: author)
        
        coreDataStack.saveContext()
        print("📝 Created post: \(title)")
        return post
    }
    
    func fetchPosts(for user: User2? = nil, limit: Int? = nil) -> [Post2] {
        let context = coreDataStack.viewContext
        let request: NSFetchRequest<Post2> = Post2.fetchRequest()
        
        // Filter by user if provided
        if let user = user {
            request.predicate = NSPredicate(format: "author == %@ AND isDeleted == NO", user)
        } else {
            request.predicate = NSPredicate(format: "isDeleted == NO")
        }
        
        // Sort by creation date
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Post2.createdAt, ascending: false)]
        
        // Set limit if provided
        if let limit = limit {
            request.fetchLimit = limit
        }
        
        do {
            let posts = try context.fetch(request)
            print("📥 Fetched \(posts.count) posts")
            return posts
        } catch {
            print("❌ Error fetching posts: \(error)")
            return []
        }
    }
    
    func searchPosts(containing searchText: String) -> [Post2] {
        let context = coreDataStack.viewContext
        let request: NSFetchRequest<Post2> = Post2.fetchRequest()
        
        // Search in title and content
        request.predicate = NSPredicate(
            format: "(title CONTAINS[cd] %@ OR content CONTAINS[cd] %@) AND isDeleted == NO",
            searchText, searchText
        )
        
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Post2.createdAt, ascending: false)]
        
        do {
            let posts = try context.fetch(request)
            print("🔍 Found \(posts.count) posts matching '\(searchText)'")
            return posts
        } catch {
            print("❌ Error searching posts: \(error)")
            return []
        }
    }
    
    func incrementPostViewCount(_ post: Post2) {
        post.viewCount += 1
        post.updatedAt = Date()
        coreDataStack.saveContext()
    }
    
    // MARK: - Batch Operations
    func batchDeleteOldPosts(olderThan days: Int) {
        let context = coreDataStack.viewContext
        let calendar = Calendar.current
        let cutoffDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        let request: NSFetchRequest<NSFetchRequestResult> = Post2.fetchRequest()
        request.predicate = NSPredicate(format: "createdAt < %@", cutoffDate as NSDate)
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        batchDeleteRequest.resultType = .resultTypeCount
        
        do {
            let result = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
            let deletedCount = result?.result as? Int ?? 0
            print("🗑️ Batch deleted \(deletedCount) old posts")
            
            // Refresh context after batch operation
            context.refreshAllObjects()
        } catch {
            print("❌ Error batch deleting posts: \(error)")
        }
    }
    
    func batchUpdatePostsAsRead(for user: User2) {
        let context = coreDataStack.viewContext
        
        let request: NSFetchRequest<NSFetchRequestResult> = Post2.fetchRequest()
        request.predicate = NSPredicate(format: "author == %@", user)
        
        let batchUpdateRequest = NSBatchUpdateRequest(entity: Post2.entity())
        batchUpdateRequest.predicate = request.predicate
        batchUpdateRequest.propertiesToUpdate = ["viewCount": NSNumber(value: 1)]
        batchUpdateRequest.resultType = .updatedObjectsCountResultType
        
        do {
            let result = try context.execute(batchUpdateRequest) as? NSBatchUpdateResult
            let updatedCount = result?.result as? Int ?? 0
            print("✏️ Batch updated \(updatedCount) posts")
            
            context.refreshAllObjects()
        } catch {
            print("❌ Error batch updating posts: \(error)")
        }
    }
    
    // MARK: - Background Operations
    func importUsersInBackground(_ userData: [(String, String, String)], completion: @escaping (Bool) -> Void) {
        let backgroundContext = coreDataStack.newBackgroundContext()
        
        backgroundContext.perform {
            for (userID, name, email) in userData {
                let user = User2(context: backgroundContext, userID: userID, name: name, email: email)
                print("📥 Importing user: \(name)")
            }
            
            do {
                try backgroundContext.save()
                print("✅ Successfully imported \(userData.count) users")
                
                DispatchQueue.main.async {
                    completion(true)
                }
            } catch {
                print("❌ Error importing users: \(error)")
                
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    // MARK: - Relationship Operations
    func createProfile(for user: User2, bio: String?, avatarURL: String?, location: String?) {
        let context = coreDataStack.viewContext
        
        // Delete existing profile if any
        if let existingProfile = user.profile {
            context.delete(existingProfile)
        }
        
        let profile = Profile1(context: context)
        profile.bio = bio
        profile.avatarURL = avatarURL
        profile.location = location
        profile.user = user
        
        coreDataStack.saveContext()
        print("👤 Created profile for user: \(user.name)")
    }
    
    func createTag(name: String, color: String? = nil) -> Tag1 {
        let context = coreDataStack.viewContext
        
        // Check if tag already exists
        let request: NSFetchRequest<Tag1> = Tag1.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        
        if let existingTag = try? context.fetch(request).first {
            return existingTag
        }
        
        let tag = Tag1(context: context)
        tag.name = name
        tag.color = color
        
        coreDataStack.saveContext()
        print("🏷️ Created tag: \(name)")
        return tag
    }
    
    func addTags(_ tags: [Tag1], to post: Post2) {
        let currentTags = post.tags?.mutableCopy() as? NSMutableSet ?? NSMutableSet()
        
        for tag in tags {
            currentTags.add(tag)
        }
        
        post.tags = currentTags
        coreDataStack.saveContext()
        print("🏷️ Added \(tags.count) tags to post: \(post.title)")
    }
    
    // MARK: - Advanced Fetching
    func fetchUsersWithPostCount() -> [(User2, Int)] {
        let context = coreDataStack.viewContext
        let request: NSFetchRequest<User2> = User2.fetchRequest()
        
        // Include posts relationship
        request.relationshipKeyPathsForPrefetching = ["posts"]
        
        do {
            let users = try context.fetch(request)
            let usersWithCount = users.map { user in
                (user, user.activePostsCount)
            }
            return usersWithCount
        } catch {
            print("❌ Error fetching users with post count: \(error)")
            return []
        }
    }
    
    func fetchPostsGroupedByUser() -> [String: [Post2]] {
        let posts = fetchPosts()
        let groupedPosts = Dictionary(grouping: posts) { post in
            post.author?.name ?? "Unknown"
        }
        return groupedPosts
    }
    
    // MARK: - Aggregate Functions
    func getPostStatistics() -> (totalPosts: Int, totalViews: Int, averageViews: Double) {
        let context = coreDataStack.viewContext
        
        // Total posts
        let countRequest: NSFetchRequest<Post2> = Post2.fetchRequest()
        countRequest.predicate = NSPredicate(format: "isDeleted == NO")
        let totalPosts = (try? context.count(for: countRequest)) ?? 0
        
        // Total views using NSExpression
        let sumRequest: NSFetchRequest<NSDictionary> = NSFetchRequest(entityName: "Post2")
        sumRequest.predicate = NSPredicate(format: "isDeleted == NO")
        sumRequest.resultType = .dictionaryResultType
        
        let sumExpression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "viewCount")])
        let sumExpressionDescription = NSExpressionDescription()
        sumExpressionDescription.name = "totalViews"
        sumExpressionDescription.expression = sumExpression
        sumExpressionDescription.expressionResultType = .integer32AttributeType
        
        sumRequest.propertiesToFetch = [sumExpressionDescription]
        
        var totalViews = 0
        if let results = try? context.fetch(sumRequest),
           let result = results.first,
           let views = result["totalViews"] as? Int {
            totalViews = views
        }
        
        let averageViews = totalPosts > 0 ? Double(totalViews) / Double(totalPosts) : 0.0
        
        return (totalPosts, totalViews, averageViews)
    }
}

// MARK: - Core Data Best Practices
class CoreDataBestPractices1 {
    
    private let coreDataStack = CoreDataStack.shared
    
    // MARK: - Performance Optimization
    func optimizedFetchWithPrefetching() -> [User2] {
        let context = coreDataStack.viewContext
        let request: NSFetchRequest<User2> = User2.fetchRequest()
        
        // Prefetch relationships to avoid additional queries
        request.relationshipKeyPathsForPrefetching = ["posts", "profile"]
        
        // Set fetch limit for pagination
        request.fetchLimit = 20
        
        // Use fault fulfillment for better memory management
        request.returnsObjectsAsFaults = false
        
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Error in optimized fetch: \(error)")
            return []
        }
    }
    
    // MARK: - Memory Management
    func processLargeDataSet() {
        let context = coreDataStack.newBackgroundContext()
        
        context.perform {
            let request: NSFetchRequest<Post2> = Post2.fetchRequest()
            request.fetchBatchSize = 50 // Process in batches
            
            do {
                let posts = try context.fetch(request)
                
                for post in posts {
                    // Process each post
                    post.updatedAt = Date()
                    
                    // Refresh context periodically to free memory
                    if posts.firstIndex(of: post)! % 100 == 0 {
                        try context.save()
                        context.refreshAllObjects()
                    }
                }
                
                try context.save()
            } catch {
                print("❌ Error processing large dataset: \(error)")
            }
        }
    }
    
    // MARK: - Thread Safety
    func safeContextAccess() {
        let backgroundContext = coreDataStack.newBackgroundContext()
        
        // Always access context on its queue
        backgroundContext.perform {
            let request: NSFetchRequest<User2> = User2.fetchRequest()
            
            do {
                let users = try backgroundContext.fetch(request)
                
                // Pass object IDs to main context
                let objectIDs = users.map { $0.objectID }
                
                DispatchQueue.main.async {
                    let mainContext = self.coreDataStack.viewContext
                    let mainContextUsers = objectIDs.compactMap { objectID in
                        try? mainContext.existingObject(with: objectID) as? User2
                    }
                    
                    // Update UI with mainContextUsers
                    print("📱 Updated UI with \(mainContextUsers.count) users")
                }
            } catch {
                print("❌ Error in safe context access: \(error)")
            }
        }
    }
    
    // MARK: - Error Handling
    func robustSaveOperation() {
        let context = coreDataStack.viewContext
        
        do {
            try context.save()
        } catch let error as NSError {
            // Handle specific Core Data errors
            switch error.code {
            case NSValidationMissingMandatoryPropertyError:
                print("❌ Missing required property")
            case NSValidationRelationshipLacksMinimumCountError:
                print("❌ Relationship lacks minimum count")
            case NSManagedObjectValidationError:
                print("❌ Managed object validation error")
            default:
                print("❌ Core Data error: \(error.localizedDescription)")
            }
            
            // Rollback changes
            context.rollback()
        }
    }
}

// MARK: - Usage Examples
class CoreDataUsageExamples1 {
    
    private let manager = CoreDataManager1()
    
    func demonstrateCoreDataOperations() {
        print("=== Core Data Operations Demo ===\n")
        
        // Create users
        let user1 = manager.createUser(userID: "user1", name: "Alice Johnson", email: "alice@example.com")
        let user2 = manager.createUser(userID: "user2", name: "Bob Smith", email: "bob@example.com")
        
        // Create posts
        let post1 = manager.createPost(postID: "post1", title: "Introduction to Core Data", content: "Core Data is Apple's framework...", author: user1)
        let post2 = manager.createPost(postID: "post2", title: "SwiftUI Best Practices", content: "When building SwiftUI apps...", author: user1)
        let post3 = manager.createPost(postID: "post3", title: "iOS Performance Tips", content: "Optimizing iOS apps...", author: user2)
        
        // Create profiles
        manager.createProfile(for: user1, bio: "iOS Developer", avatarURL: "https://example.com/avatar1.jpg", location: "San Francisco")
        manager.createProfile(for: user2, bio: "Mobile App Designer", avatarURL: "https://example.com/avatar2.jpg", location: "New York")
        
        // Create and add tags
        let swiftTag = manager.createTag(name: "Swift", color: "orange")
        let iosTag = manager.createTag(name: "iOS", color: "blue")
        let coreDataTag = manager.createTag(name: "Core Data", color: "green")
        
        manager.addTags([swiftTag, iosTag, coreDataTag], to: post1)
        manager.addTags([swiftTag, iosTag], to: post2)
        manager.addTags([iosTag], to: post3)
        
        // Fetch operations
        let allUsers = manager.fetchUsers()
        print("All users: \(allUsers.map(\.name))")
        
        let alicePosts = manager.fetchPosts(for: user1)
        print("Alice's posts: \(alicePosts.map(\.title))")
        
        let searchResults = manager.searchPosts(containing: "Core Data")
        print("Posts about Core Data: \(searchResults.map(\.title))")
        
        // Statistics
        let stats = manager.getPostStatistics()
        print("Post statistics - Total: \(stats.totalPosts), Views: \(stats.totalViews), Average: \(stats.averageViews)")
        
        // Update operations
        manager.updateUser(user1, name: "Alice Johnson Updated")
        manager.incrementPostViewCount(post1)
        
        // Background import
        let newUsersData = [
            ("user3", "Charlie Brown", "charlie@example.com"),
            ("user4", "Diana Prince", "diana@example.com")
        ]
        
        manager.importUsersInBackground(newUsersData) { success in
            print("Background import completed: \(success)")
        }
    }
}

// MARK: - Interview Key Points Comments

/*
 IMPORTANT INTERVIEW CONCEPTS COVERED:

 1. **Core Data Stack**:
    - NSPersistentContainer: Main container for Core Data stack
    - NSManagedObjectContext: Working space for managed objects
    - NSPersistentStoreCoordinator: Mediates between contexts and stores
    - NSManagedObjectModel: Schema definition

 2. **Managed Objects**:
    - NSManagedObject subclasses for entities
    - Automatic code generation vs manual subclasses
    - Managed object lifecycle
    - Faulting and relationship management

 3. **Context Management**:
    - Main context for UI operations
    - Background contexts for heavy operations
    - Context hierarchy and merging
    - Thread safety with performBlock

 4. **Fetching Data**:
    - NSFetchRequest for querying data
    - Predicates for filtering
    - Sort descriptors for ordering
    - Fetch limits and batch sizes

 5. **Relationships**:
    - One-to-one, one-to-many, many-to-many
    - Inverse relationships
    - Delete rules (cascade, nullify, deny)
    - Relationship prefetching

 6. **Performance Optimization**:
    - Batch operations (insert, update, delete)
    - Faulting and prefetching
    - Fetch request optimization
    - Memory management with large datasets

 7. **Common Interview Questions**:
    - Q: What is Core Data?
    - A: Apple's object graph and persistence framework
    
    - Q: Difference between Core Data and SQLite?
    - A: Core Data is ORM, SQLite is database; Core Data uses SQLite as store
    
    - Q: How to handle threading in Core Data?
    - A: Use separate contexts, perform operations on context's queue
    
    - Q: What is faulting?
    - A: Lazy loading mechanism to save memory

 8. **Best Practices**:
    - Use background contexts for heavy operations
    - Save contexts regularly but not too frequently
    - Handle merge conflicts appropriately
    - Use batch operations for large datasets
    - Implement proper error handling

 9. **Common Pitfalls**:
    - Accessing managed objects across thread boundaries
    - Not handling merge conflicts
    - Creating retain cycles with managed objects
    - Not using batch operations for large datasets

 10. **Advanced Features**:
     - Lightweight migration
     - Custom migration mapping models
     - Persistent store types (SQLite, Binary, In-Memory)
     - Core Data with CloudKit integration
     - NSFetchedResultsController for table views

 11. **Memory Management**:
     - Managed object contexts hold strong references
     - Use autoreleasepool for batch operations
     - Refresh contexts to free memory
     - Understand object graph loading

 12. **Testing Core Data**:
     - In-memory stores for unit tests
     - Mock contexts and managed objects
     - Testing migrations
     - Performance testing with large datasets
*/ 
