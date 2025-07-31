//
//  ViewModel (SwiftUI Version).swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 31/07/25.
//

import Foundation
import Combine

// Note: ViewModel does NOT import UIKit/SwiftUI

// MARK: - View Model
protocol MoviesListViewModelInput1 {
    func searchMovies(query: String)
    func loadPopularMovies()
    func didSelectMovie(at index: Int)
}

protocol MoviesListViewModelOutput1 {
    var movies: [MovieItemViewModel] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
}

struct MoviesListViewModelActions1 {
    let showMovieDetail: (Movie) -> Void
}

class MoviesListViewModel1: ObservableObject, MoviesListViewModelInput1, MoviesListViewModelOutput1 {
    
    // MARK: - Published Properties (Output)
    @Published var movies: [MovieItemViewModel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
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
        isLoading = true
        errorMessage = nil
        
        do {
            let movieResults = try await searchMoviesUseCase.execute(query: query)
            currentMovies = movieResults
            movies = movieResults.map(MovieItemViewModel.init)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

// MARK: - Item View Model
struct MovieItemViewModel1 {
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
