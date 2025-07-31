//
//  Data Layer.swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 31/07/25.
//

import Foundation
//import Domain //here for Movie data model and MoviesRepositoryProtocol

// MARK: - Data Transfer Objects (DTOs)
struct MovieResponseDTO: Codable {
    let results: [MovieDTO]
}

struct MovieDTO: Codable {
    let id: Int
    let title: String
    let overview: String
    let releaseDate: String
    let posterPath: String?
    
    private enum CodingKeys: String, CodingKey {
        case id, title, overview
        case releaseDate = "release_date"
        case posterPath = "poster_path"
    }
}

// MARK: - Network Service
protocol NetworkServiceProtocol2 {
    func request<T: Codable>(endpoint: String, responseType: T.Type) async throws -> T
}

class NetworkService2: NetworkServiceProtocol2 {
    private let baseURL = "https://api.themoviedb.org/3"
    private let apiKey = "your_api_key"
    
    func request<T: Codable>(endpoint: String, responseType: T.Type) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)?api_key=\(apiKey)") else {
            throw NetworkError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(responseType, from: data)
    }
}

enum NetworkError2: Error {
    case invalidURL
    case noData
}

// MARK: - Repository Implementations
class DefaultMoviesRepository: MoviesRepositoryProtocol {
    private let networkService: NetworkServiceProtocol2
    
    init(networkService: NetworkServiceProtocol2) {
        self.networkService = networkService
    }
    
    func searchMovies(query: String) async throws -> [Movie] {
        let endpoint = "/search/movie?query=\(query)"
        let response = try await networkService.request(
            endpoint: endpoint,
            responseType: MovieResponseDTO.self
        )
        return response.results.map { $0.toDomain() }
    }
    
    func getPopularMovies() async throws -> [Movie] {
        let endpoint = "/movie/popular"
        let response = try await networkService.request(
            endpoint: endpoint,
            responseType: MovieResponseDTO.self
        )
        return response.results.map { $0.toDomain() }
    }
}

class DefaultMoviesQueriesRepository: MoviesQueriesRepositoryProtocol {
    private var queries: [MovieQuery] = []
    
    func getRecentQueries() async -> [MovieQuery] {
        return queries.sorted { $0.timestamp > $1.timestamp }
    }
    
    func saveQuery(_ query: MovieQuery) async {
        queries.append(query)
        // Keep only last 10 queries
        if queries.count > 10 {
            queries = Array(queries.suffix(10))
        }
    }
}

// MARK: - DTO to Domain Mapping
extension MovieDTO {
    func toDomain() -> Movie {
        return Movie(
            id: id,
            title: title,
            overview: overview,
            releaseDate: releaseDate,
            posterPath: posterPath
        )
    }
}
