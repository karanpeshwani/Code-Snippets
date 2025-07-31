//
//  ViewController (View).swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 31/07/25.
//

import UIKit

class MoviesListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var viewModel: (MoviesListViewModelInput & MoviesListViewModelOutput)!
    private var movies: [MovieItemViewModel] = []
    
    // MARK: - Dependency Injection
    func bindViewModel(to viewModel: MoviesListViewModelInput & MoviesListViewModelOutput) {
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindToViewModel()
    }
    
    private func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
    }
    
    private func bindToViewModel() {
        // Bind to movies data
        viewModel.movies.bind { [weak self] movies in
            DispatchQueue.main.async {
                self?.movies = movies
                self?.tableView.reloadData()
            }
        }
        
        // Bind to loading state
        viewModel.isLoading.bind { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.activityIndicator.startAnimating()
                } else {
                    self?.activityIndicator.stopAnimating()
                }
            }
        }
        
        // Bind to error messages
        viewModel.errorMessage.bind { [weak self] errorMessage in
            DispatchQueue.main.async {
                if let error = errorMessage {
                    self?.showErrorAlert(message: error)
                }
            }
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - TableView DataSource & Delegate
extension MoviesListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieTableViewCell
        cell.configure(with: movies[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.didSelectMovie(at: indexPath.row)
    }
}

// MARK: - SearchBar Delegate
extension MoviesListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        viewModel.searchMovies(query: query)
        searchBar.resignFirstResponder()
    }
}

// MARK: - Custom Cell
class MovieTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    func configure(with movie: MovieItemViewModel) {
        titleLabel.text = movie.title
        overviewLabel.text = movie.overview
        yearLabel.text = movie.releaseYear
    }
}
