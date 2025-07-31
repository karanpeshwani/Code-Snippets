//
//  ViewModel (UIKit Version).swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 31/07/25.
//

import Foundation
//import Domain //here for usecases protocols

// Note: ViewModel does NOT import UIKit/SwiftUI// MARK: - Observable for Data Binding
class Observable<T> {
    private var listener: ((T) -> Void)?
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(_ listener: @escaping (T) -> Void) {
        self.listener = listener
        listener(value)
    }
}

// MARK: - View Model
protocol MoviesListViewModelInput {
    func searchMovies(query: String)
    func loadPopularMovies()
    func didSelectMovie(at index: Int)
}

protocol MoviesListViewModelOutput {
    var movies: Observable<[MovieItemViewModel]> { get }
    var isLoading: Observable<Bool> { get }
    var errorMessage: Observable<String?> { get }
}

struct MoviesListViewModelActions {
    let showMovieDetail: (Movie) -> Void
}

class MoviesListViewModel: MoviesListViewModelInput, MoviesListViewModelOutput {
    
    // MARK: - Output
    let movies = Observable<[MovieItemViewModel]>([])
    let isLoading = Observable<Bool>(false)
    let errorMessage = Observable<String?>(nil)
    
    // MARK: - Dependencies (Domain Layer only)
    private let searchMoviesUseCase: SearchMoviesUseCaseProtocol
    private let actions: MoviesListViewModelActions?
    private var currentMovies: [Movie] = []
    
    init(
        searchMoviesUseCase: SearchMoviesUseCaseProtocol,
        actions: MoviesListViewModelActions? = nil
    ) {
        self.searchMoviesUseCase = searchMoviesUseCase
        self.actions = actions
    }
    
    // MARK: - Input
    func searchMovies(query: String) {
        Task {
            await performSearch(query: query)
        }
    }
    
    func loadPopularMovies() {
        // Implementation for loading popular movies
    }
    
    func didSelectMovie(at index: Int) {
        guard index < currentMovies.count else { return }
        let movie = currentMovies[index]
        actions?.showMovieDetail(movie)
    }
    
    @MainActor
    private func performSearch(query: String) async {
        isLoading.value = true
        errorMessage.value = nil
        
        do {
            let movieResults = try await searchMoviesUseCase.execute(query: query)
            currentMovies = movieResults
            movies.value = movieResults.map(MovieItemViewModel.init)
        } catch {
            errorMessage.value = error.localizedDescription
        }
        
        isLoading.value = false
    }
}

// MARK: - Item View Model
struct MovieItemViewModel {
    let title: String
    let overview: String
    let releaseYear: String
    let posterURL: String?
    
    init(movie: Movie) {
        self.title = movie.title
        self.overview = movie.overview
        self.releaseYear = String(movie.releaseDate.prefix(4))
        self.posterURL = movie.posterPath.map { "https://image.tmdb.org/t/p/w500\($0)" }
    }
}
