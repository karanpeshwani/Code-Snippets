//
//  UITableView-Programmatic.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 31/07/25.
//

import UIKit

// MARK: - Data Models
struct TableSection1 {
    let title: String
    var items: [TableItem1]
}

struct TableItem1 {
    let id: Int
    let title: String
    let subtitle: String
    let imageName: String?
    var isCompleted: Bool = false
}

// MARK: - Custom Table View Cell
class CustomTableViewCell1: UITableViewCell {
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let customImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let statusIndicator: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        contentView.addSubview(customImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(statusIndicator)
        
        // Auto Layout Constraints
        NSLayoutConstraint.activate([
            // Image view constraints
            customImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            customImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            customImageView.widthAnchor.constraint(equalToConstant: 40),
            customImageView.heightAnchor.constraint(equalToConstant: 40),
            
            // Title label constraints
            titleLabel.leadingAnchor.constraint(equalTo: customImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: statusIndicator.leadingAnchor, constant: -12),
            
            // Subtitle label constraints
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),
            
            // Status indicator constraints
            statusIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            statusIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusIndicator.widthAnchor.constraint(equalToConstant: 12),
            statusIndicator.heightAnchor.constraint(equalToConstant: 12)
        ])
        
        // Set minimum height constraint
        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
    }
    
    // MARK: - Configuration
    func configure(with item: TableItem1) {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        
        // Configure image
        if let imageName = item.imageName {
            customImageView.image = UIImage(systemName: imageName)
            customImageView.tintColor = .systemBlue
        } else {
            customImageView.image = UIImage(systemName: "circle.fill")
            customImageView.tintColor = .systemGray3
        }
        
        // Configure status indicator
        statusIndicator.backgroundColor = item.isCompleted ? .systemGreen : .systemOrange
        
        // Configure accessibility
        accessibilityLabel = "\(item.title), \(item.subtitle)"
        accessibilityHint = item.isCompleted ? "Completed" : "Not completed"
    }
    
    // MARK: - Reuse Preparation
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        subtitleLabel.text = nil
        customImageView.image = nil
        statusIndicator.backgroundColor = .clear
    }
}

// MARK: - Table View Controller
class TableViewController1: UIViewController {
    
    // MARK: - Properties
    private var tableView: UITableView!
    private var sections: [TableSection1] = []
    
    // Cell identifier
    private let cellIdentifier = "CustomTableViewCell1"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupTableView()
        setupNavigationBar()
    }
    
    // MARK: - Data Setup
    private func setupData() {
        sections = [
            TableSection1(title: "Work Tasks", items: [
                TableItem1(id: 1, title: "Review Code", subtitle: "Review pull request #123 for new feature", imageName: "doc.text.magnifyingglass", isCompleted: false),
                TableItem1(id: 2, title: "Team Meeting", subtitle: "Daily standup at 10:00 AM", imageName: "person.3.fill", isCompleted: true),
                TableItem1(id: 3, title: "Deploy to Production", subtitle: "Deploy version 2.1.0 to production servers", imageName: "arrow.up.circle.fill", isCompleted: false)
            ]),
            TableSection1(title: "Personal", items: [
                TableItem1(id: 4, title: "Grocery Shopping", subtitle: "Buy milk, eggs, and bread", imageName: "cart.fill", isCompleted: false),
                TableItem1(id: 5, title: "Exercise", subtitle: "30 minutes cardio workout", imageName: "figure.run", isCompleted: true),
                TableItem1(id: 6, title: "Read Book", subtitle: "Continue reading 'Clean Code'", imageName: "book.fill", isCompleted: false)
            ]),
            TableSection1(title: "Learning", items: [
                TableItem1(id: 7, title: "SwiftUI Tutorial", subtitle: "Complete advanced SwiftUI course", imageName: "swift", isCompleted: false),
                TableItem1(id: 8, title: "iOS Interview Prep", subtitle: "Practice common iOS interview questions", imageName: "questionmark.circle.fill", isCompleted: true)
            ])
        ]
    }
    
    // MARK: - Table View Setup
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set delegates
        tableView.delegate = self
        tableView.dataSource = self
        
        // Register cell
        tableView.register(CustomTableViewCell1.self, forCellReuseIdentifier: cellIdentifier)
        
        // Configure table view
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorStyle = .singleLine
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        
        // Enable editing
        tableView.allowsSelectionDuringEditing = true
        
        // Add to view hierarchy
        view.addSubview(tableView)
        
        // Auto Layout
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Navigation Setup
    private func setupNavigationBar() {
        title = "Tasks"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Add edit button
        navigationItem.rightBarButtonItem = editButtonItem
        
        // Add add button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewItem)
        )
    }
    
    // MARK: - Actions
    @objc private func addNewItem() {
        let alert = UIAlertController(title: "Add New Task", message: "Enter task details", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Task title"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Task description"
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let title = alert.textFields?[0].text, !title.isEmpty,
                  let subtitle = alert.textFields?[1].text, !subtitle.isEmpty else { return }
            
            let newItem = TableItem1(
                id: Int.random(in: 1000...9999),
                title: title,
                subtitle: subtitle,
                imageName: "circle.fill",
                isCompleted: false
            )
            
            // Add to first section
            self?.sections[0].items.insert(newItem, at: 0)
            
            // Animate insertion
            let indexPath = IndexPath(row: 0, section: 0)
            self?.tableView.insertRows(at: [indexPath], with: .automatic)
        }
        
        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    // Override edit button behavior
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
}

// MARK: - UITableViewDataSource
extension TableViewController1: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: cellIdentifier,
            for: indexPath
        ) as? CustomTableViewCell1 else {
            fatalError("Unable to dequeue CustomTableViewCell1")
        }
        
        let item = sections[indexPath.section].items[indexPath.row]
        cell.configure(with: item)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    // Enable editing
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Handle row deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            sections[indexPath.section].items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    // Enable row reordering
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Only allow moving within the same section
        guard sourceIndexPath.section == destinationIndexPath.section else { return }
        
        let item = sections[sourceIndexPath.section].items.remove(at: sourceIndexPath.row)
        sections[destinationIndexPath.section].items.insert(item, at: destinationIndexPath.row)
    }
}

// MARK: - UITableViewDelegate
extension TableViewController1: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Toggle completion status
        sections[indexPath.section].items[indexPath.row].isCompleted.toggle()
        
        // Reload the specific cell with animation
        tableView.reloadRows(at: [indexPath], with: .none)
        
        // Show feedback
        let item = sections[indexPath.section].items[indexPath.row]
        let message = item.isCompleted ? "Task completed!" : "Task marked as incomplete"
        
        // Simple haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    // Custom swipe actions
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let item = sections[indexPath.section].items[indexPath.row]
        
        // Complete/Incomplete action
        let completeTitle = item.isCompleted ? "Mark Incomplete" : "Mark Complete"
        let completeAction = UIContextualAction(style: .normal, title: completeTitle) { [weak self] _, _, completion in
            self?.sections[indexPath.section].items[indexPath.row].isCompleted.toggle()
            tableView.reloadRows(at: [indexPath], with: .none)
            completion(true)
        }
        completeAction.backgroundColor = item.isCompleted ? .systemOrange : .systemGreen
        completeAction.image = UIImage(systemName: item.isCompleted ? "xmark.circle" : "checkmark.circle")
        
        // Delete action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.sections[indexPath.section].items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        
        return UISwipeActionsConfiguration(actions: [deleteAction, completeAction])
    }
    
    // Leading swipe actions
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let favoriteAction = UIContextualAction(style: .normal, title: "Favorite") { _, _, completion in
            // Handle favorite action
            print("Favorited item at \(indexPath)")
            completion(true)
        }
        favoriteAction.backgroundColor = .systemYellow
        favoriteAction.image = UIImage(systemName: "star.fill")
        
        return UISwipeActionsConfiguration(actions: [favoriteAction])
    }
    
    // Header view customization
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemGroupedBackground
        
        let titleLabel = UILabel()
        titleLabel.text = sections[section].title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let countLabel = UILabel()
        countLabel.text = "\(sections[section].items.count) items"
        countLabel.font = UIFont.systemFont(ofSize: 14)
        countLabel.textColor = .secondaryLabel
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(titleLabel)
        headerView.addSubview(countLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            
            countLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            countLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            countLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
}

// MARK: - Interview Key Points Comments

/*
 IMPORTANT INTERVIEW CONCEPTS COVERED:

 1. **UITableView Architecture**:
    - UITableViewDataSource: Provides data (numberOfSections, numberOfRowsInSection, cellForRowAt)
    - UITableViewDelegate: Handles user interactions and customization
    - Section-based data structure with headers

 2. **Cell Reuse Pattern**:
    - Custom cell class inheriting from UITableViewCell
    - Cell registration and dequeuing
    - prepareForReuse() for memory management
    - Configuration pattern with configure(with:) method

 3. **Programmatic UI**:
    - No Storyboard/XIB files
    - Auto Layout constraints in code
    - Custom cell layout with multiple UI elements

 4. **Table View Features**:
    - Multiple sections with headers
    - Custom header views
    - Row editing (delete, reorder)
    - Swipe actions (leading and trailing)
    - Dynamic row heights with Auto Layout

 5. **Data Management**:
    - Structured data model (sections and items)
    - CRUD operations (Create, Read, Update, Delete)
    - Animated insertions and deletions

 6. **User Interaction**:
    - Cell selection handling
    - Edit mode toggle
    - Swipe gestures
    - Haptic feedback

 7. **Performance Considerations**:
    - Cell reuse for memory efficiency
    - Estimated row heights for smooth scrolling
    - Batch updates for multiple changes

 8. **Common Interview Questions**:
    - Q: Difference between UITableView and UICollectionView?
    - A: UITableView is for single-column lists, UICollectionView for flexible layouts
    
    - Q: How does cell reuse work?
    - A: Cells are reused when scrolled off-screen to save memory
    
    - Q: When to use sections in UITableView?
    - A: To group related data and provide headers/footers
    
    - Q: How to handle dynamic cell heights?
    - A: Use Auto Layout with automaticDimension and estimated heights
    
    - Q: What's the purpose of prepareForReuse?
    - A: Reset cell state before reuse to prevent data inconsistencies

 9. **Memory Management**:
    - Weak references in closures to prevent retain cycles
    - Proper cell reuse to handle large datasets
    - Efficient data structure updates

 10. **Accessibility**:
     - Proper accessibility labels and hints
     - Support for VoiceOver users
     - Semantic UI element configuration
*/ 