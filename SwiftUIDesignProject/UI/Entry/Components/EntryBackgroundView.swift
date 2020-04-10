//
//  EntryBackgroundView.swift
//  SwiftUIDesignProject
//
//  Created by Brandon on 4/9/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import Foundation
import SwiftUI

struct EntryBackgroundView: View {
    
    // UI Config
    @Environment(\.colorScheme) var colorScheme
    
    // View
    var body: some View {
        Group {
            if colorScheme == .dark {
                LinearGradient(Color.darkStart, Color.darkEnd)
            } else {
                Color.offWhite
            }
        }
    }
}

struct EntryBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EntryBackgroundView()
                .environmentObject(EnvironmentSettings())
                .environment(\.colorScheme, .light)
                .previewDevice("iPhone 11 Pro Max")
            
            EntryBackgroundView()
            .environmentObject(EnvironmentSettings())
            .environment(\.colorScheme, .light)
            .previewDevice("iPhone SE")
        }
        
    }
}
