//
//  ContentView.swift
//  NetworkingDemoApp
//
//  Created by Alejandro Franco on 04/04/20.
//  Copyright © 2020 Alejandro Franco. All rights reserved.
//

import SwiftUI

struct Response: Codable {
    var results: [Result]
}

struct Result: Codable {
    var trackId: Int
    var trackName: String
    var collectionName: String
}

struct ContentView: View {
    @State private var results = [Result]()
    @State var searchTerm: String = "michael jackson"
    @State private var showCancelButton: Bool = true
    
    var body: some View {
        NavigationView {
            VStack {
                // Search view
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")

                        TextField("search", text: $searchTerm, onEditingChanged: { isEditing in
                            self.showCancelButton = true
                        }, onCommit: {
                            self.loadData()
                        }).foregroundColor(.primary)
                        
                        Button(action: {
                            self.searchTerm = ""
                        }) {
                            Image(systemName: "xmark.circle.fill").opacity(searchTerm == "" ? 0 : 1)
                        }
                    }
                    .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
                    .foregroundColor(.secondary)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10.0)
                    
                    if showCancelButton  {
                        Button("Cancel") {
                            self.searchTerm = ""
                            self.loadData()
                            self.showCancelButton = false
                        }
                        .foregroundColor(Color(.systemBlue))
                    }
                }
                .padding(.horizontal)

                List {
                    ForEach(results, id: \.trackId) { item in
                        VStack(alignment: .leading){
                            Text(item.trackName)
                                .font(.headline)
                            Text(item.collectionName)
                        }
                    }
                }
                
            }
            .onAppear(perform: loadData)
            .navigationBarTitle("Songs list")
        }
    }
    
    func loadData() {
        if self.searchTerm == "" {
            results = [Result]()
            return
        }
        let str = self.searchTerm
        let replaced = str.replacingOccurrences(of: " ", with: "+")
        guard let url = URL(string: "https://itunes.apple.com/search?term=\(replaced)&entity=song") else {
            print("Invalid URL")
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(Response.self, from: data) {
                    DispatchQueue.main.async {
                        self.results = decodedResponse.results
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
