//
//  View (ViewController).swift
//  Code-Snippets
//
//  Created by Karan Peshwani on 31/07/25.
//

import SwiftUI

struct MoviesListView: View {
    @StateObject private var viewModel: MoviesListViewModel1
    @State private var searchText = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // MARK: - Dependency Injection
    init(viewModel: MoviesListViewModel1) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, onSearchButtonClicked: {
                    viewModel.searchMovies(query: searchText)
                })
                
                ZStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        MoviesList(
                            movies: viewModel.movies,
                            onMovieSelected: { index in
                                viewModel.didSelectMovie(at: index)
                            }
                        )
                    }
                }
            }
            .navigationTitle("Movies")
            .onReceive(viewModel.$errorMessage) { errorMessage in
                if let error = errorMessage {
                    alertMessage = error
                    showingAlert = true
                }
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
}

// MARK: - Search Bar Component
struct SearchBar: View {
    @Binding var text: String
    let onSearchButtonClicked: () -> Void
    
    var body: some View {
        HStack {
            TextField("Search movies...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    onSearchButtonClicked()
                }
            
            Button("Search") {
                onSearchButtonClicked()
            }
            .disabled(text.isEmpty)
        }
        .padding(.horizontal)
    }
}

// MARK: - Movies List Component
struct MoviesList: View {
    let movies: [MovieItemViewModel]
    let onMovieSelected: (Int) -> Void
    
    var body: some View {
        List {
            ForEach(Array(movies.enumerated()), id: \.offset) { index, movie in
                MovieRow(movie: movie)
                    .onTapGesture {
                        onMovieSelected(index)
                    }
            }
        }
    }
}

// MARK: - Movie Row Component
struct MovieRow: View {
    let movie: MovieItemViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(movie.title)
                        .font(.headline)
                        .lineLimit(2)
                    
                    Text(movie.releaseYear)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Text(movie.overview)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
struct MoviesListView_Previews: PreviewProvider {
    static var previews: some View {
        // Mock view model for preview
        let mockViewModel = MoviesListViewModel1(
            searchMoviesUseCase: MockSearchMoviesUseCase(),
            actions: nil
        )
        
        MoviesListView(viewModel: mockViewModel)
    }
}

// Mock for preview
class MockSearchMoviesUseCase: SearchMoviesUseCaseProtocol {
    func execute(query: String) async throws -> [Movie] {
        return []
    }
}
