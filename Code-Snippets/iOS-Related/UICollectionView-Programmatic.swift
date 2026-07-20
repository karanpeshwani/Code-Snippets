//
//  UICollectionView-Programmatic.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 31/07/25.
//

import UIKit

// MARK: - Data Model
struct CollectionItem1 {
    let id: Int
    let title: String
    let color: UIColor
}

// MARK: - Custom Collection View Cell
class CustomCollectionViewCell1: UICollectionViewCell {
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        
        // Auto Layout Constraints
        NSLayoutConstraint.activate([
            // Container view constraints
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            // Title label constraints
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configuration
    func configure(with item: CollectionItem1) {
        titleLabel.text = item.title
        containerView.backgroundColor = item.color
    }
    
    // MARK: - Reuse Preparation
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        containerView.backgroundColor = .clear
    }
}

// MARK: - Collection View Controller
class CollectionViewController1: UIViewController {
    
    // MARK: - Properties
    private var collectionView: UICollectionView!
    private var items: [CollectionItem1] = []
    
    // Cell identifier constant
    private let cellIdentifier = "CustomCollectionViewCell1"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupCollectionView()
        setupNavigationBar()
    }
    
    // MARK: - Data Setup
    private func setupData() {
        // Sample data for demonstration
        let colors: [UIColor] = [.systemRed, .systemBlue, .systemGreen, .systemOrange, 
                                .systemPurple, .systemPink, .systemTeal, .systemYellow]
        
        items = (1...20).map { index in
            CollectionItem1(
                id: index,
                title: "Item \(index)",
                color: colors[index % colors.count]
            )
        }
    }
    
    // MARK: - Collection View Setup
    private func setupCollectionView() {
        // Create flow layout with custom configuration
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        // Calculate item size based on screen width
        // 2 items per row with proper spacing
        let screenWidth = UIScreen.main.bounds.width
        let totalSpacing = layout.sectionInset.left + layout.sectionInset.right + layout.minimumInteritemSpacing
        let itemWidth = (screenWidth - totalSpacing) / 2
        layout.itemSize = CGSize(width: itemWidth, height: 100)
        
        // Initialize collection view
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        
        // Set delegates
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Register cell
        collectionView.register(CustomCollectionViewCell1.self, forCellWithReuseIdentifier: cellIdentifier)
        
        // Add to view hierarchy
        view.addSubview(collectionView)
        
        // Auto Layout
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Navigation Setup
    private func setupNavigationBar() {
        title = "Collection View"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Add refresh button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshData)
        )
    }
    
    // MARK: - Actions
    @objc private func refreshData() {
        // Simulate data refresh
        items.shuffle()
        
        // Animate the reload
        collectionView.performBatchUpdates({
            collectionView.reloadSections(IndexSet(integer: 0))
        }, completion: nil)
    }
}

// MARK: - UICollectionViewDataSource
extension CollectionViewController1: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: cellIdentifier,
            for: indexPath
        ) as? CustomCollectionViewCell1 else {
            fatalError("Unable to dequeue CustomCollectionViewCell1")
        }
        
        let item = items[indexPath.item]
        cell.configure(with: item)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension CollectionViewController1: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Handle cell selection
        let selectedItem = items[indexPath.item]
        
        let alert = UIAlertController(
            title: "Item Selected",
            message: "You selected \(selectedItem.title)",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        
        // Deselect the item (optional visual feedback)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CollectionViewController1: UICollectionViewDelegateFlowLayout {
    
    // Dynamic item sizing based on orientation
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let screenWidth = collectionView.bounds.width
        
        // Determine number of columns based on device orientation
        let isLandscape = UIDevice.current.orientation.isLandscape
        let numberOfColumns: CGFloat = isLandscape ? 3 : 2
        
        let totalSpacing = layout.sectionInset.left + layout.sectionInset.right + 
                          (layout.minimumInteritemSpacing * (numberOfColumns - 1))
        let itemWidth = (screenWidth - totalSpacing) / numberOfColumns
        
        return CGSize(width: itemWidth, height: 100)
    }
    
    // Header size (if needed)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 0) // No header for this example
    }
}

// MARK: - Interview Key Points Comments

/*
 IMPORTANT INTERVIEW CONCEPTS COVERED:

 1. **Programmatic UI Creation**: 
    - No Storyboard usage, everything created in code
    - Proper Auto Layout constraints
    - translatesAutoresizingMaskIntoConstraints = false

 2. **UICollectionView Architecture**:
    - UICollectionViewDataSource: Provides data (numberOfItemsInSection, cellForItemAt)
    - UICollectionViewDelegate: Handles user interactions (didSelectItemAt)
    - UICollectionViewDelegateFlowLayout: Controls layout (sizeForItemAt)

 3. **Cell Reuse Pattern**:
    - Custom cell class inheriting from UICollectionViewCell
    - Cell registration: collectionView.register()
    - Cell dequeuing: collectionView.dequeueReusableCell()
    - prepareForReuse() method to reset cell state

 4. **Flow Layout Configuration**:
    - UICollectionViewFlowLayout for grid-like layouts
    - itemSize, minimumLineSpacing, minimumInteritemSpacing
    - sectionInset for padding around sections
    - Dynamic sizing based on screen width and orientation

 5. **Memory Management**:
    - Cell reuse prevents memory issues with large datasets
    - Proper constraint setup prevents retain cycles
    - prepareForReuse() ensures clean cell state

 6. **Performance Considerations**:
    - Cell reuse for efficient memory usage
    - Batch updates with performBatchUpdates()
    - Lazy loading of cells (only visible cells are created)

 7. **Common Interview Questions**:
    - Q: How does cell reuse work?
    - A: Cells are reused when they go off-screen to save memory
    
    - Q: When is cellForItemAt called?
    - A: When a cell becomes visible on screen
    
    - Q: Difference between UITableView and UICollectionView?
    - A: UICollectionView is more flexible, supports 2D layouts
    
    - Q: How to handle dynamic cell sizes?
    - A: Use UICollectionViewDelegateFlowLayout's sizeForItemAt method
*/ 