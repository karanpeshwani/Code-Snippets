//
//  Domain Layer.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 31/07/25.
//

// Domain Layer (Core/Innermost ⇒ Pure Swift)

import Foundation

// MARK: - Entities (Business Models)
struct Movie {
    let id: Int
    let title: String
    let overview: String
    let releaseDate: String
    let posterPath: String?
}

struct MovieQuery {
    let query: String
    let timestamp: Date
}

// MARK: - Repository Interfaces (Protocols)
protocol MoviesRepositoryProtocol {
    func searchMovies(query: String) async throws -> [Movie]
    func getPopularMovies() async throws -> [Movie]
}

protocol MoviesQueriesRepositoryProtocol {
    func getRecentQueries() async -> [MovieQuery]
    func saveQuery(_ query: MovieQuery) async
}

// MARK: - Use Cases
protocol SearchMoviesUseCaseProtocol {
    func execute(query: String) async throws -> [Movie]
}

class SearchMoviesUseCase: SearchMoviesUseCaseProtocol {
    private let moviesRepository: MoviesRepositoryProtocol
    private let queriesRepository: MoviesQueriesRepositoryProtocol
    
    init(
        moviesRepository: MoviesRepositoryProtocol,
        queriesRepository: MoviesQueriesRepositoryProtocol
    ) {
        self.moviesRepository = moviesRepository
        self.queriesRepository = queriesRepository
    }
    
    func execute(query: String) async throws -> [Movie] {
        let movies = try await moviesRepository.searchMovies(query: query)
        
        // Save successful query
        if !movies.isEmpty {
            await queriesRepository.saveQuery(
                MovieQuery(query: query, timestamp: Date())
            )
        }
        
        return movies
    }
}

protocol FetchRecentQueriesUseCaseProtocol {
    func execute() async -> [MovieQuery]
}

class FetchRecentQueriesUseCase: FetchRecentQueriesUseCaseProtocol {
    private let queriesRepository: MoviesQueriesRepositoryProtocol
    
    init(queriesRepository: MoviesQueriesRepositoryProtocol) {
        self.queriesRepository = queriesRepository
    }
    
    func execute() async -> [MovieQuery] {
        return await queriesRepository.getRecentQueries()
    }
}
