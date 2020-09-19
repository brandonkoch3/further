//
//  MapHelper.swift
//  Futher
//
//  Created by Brandon on 9/18/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import Foundation
import MapKit
import SwiftUI

class MapHelper: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    
    // MARK: Setup
    struct MapResults: Identifiable {
        var id: UUID
        var title: String
        var subtitle: String
    }
    
    @State private var test = ""
    
    var searchCompleter = MKLocalSearchCompleter()
    @Published var results = [MapResults]()
    
    override init() {
        super.init()
        searchCompleter.delegate = self
    }
    
    public func search(for query: String) {
        print("Search for", query)
        searchCompleter.queryFragment = query
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results.compactMap { MapResults(id: UUID(), title: $0.title, subtitle: $0.subtitle) }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        //
    }
}
