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
    
    var searchCompleter = MKLocalSearchCompleter()
    @Published var results = [MKLocalSearchCompletion]()
    
    @Published var selectedItem: CLPlacemark?
    
    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.resultTypes = [.address, .pointOfInterest]
        
    }
    
    public func search(for query: String) {
        print("Search for", query)
        searchCompleter.queryFragment = query
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        //
    }
    
    public func itemSelected(selection: MKLocalSearchCompletion) {
        let request = MKLocalSearch.Request(completion: selection)
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else {
                return
            }
            if let item = response.mapItems.first {
                let placemark = item.placemark
                let pl = CLPlacemark(placemark: placemark)
                self.selectedItem = pl
            }
        }
    }
}

extension MKLocalSearchCompletion: Identifiable {}
