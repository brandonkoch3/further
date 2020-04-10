//
//  StoryButton.swift
//  SwiftUIDesignProject
//
//  Created by Brandon on 4/9/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import SwiftUI

struct StoryButton: View {
    
    // UI Config
    @Binding var showingStorySheet: Bool
    @Environment(\.colorScheme) var colorScheme
    
    // Helpers
    var storiesController = StoriesController()
    
    // View
    var body: some View {
        Button(action: {
            self.showingStorySheet.toggle()
        }) {
            Image(systemName: "person.3")
                .foregroundColor(self.colorScheme == .dark ? Color.gray : Color.lairDarkGray)
                .font(.system(size: 25, weight: .regular))
        }.sheet(isPresented: $showingStorySheet) {
            StoryView(storyController: self.storiesController)
        }.padding()
    }
}

struct StoryButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StoryButton(showingStorySheet: .constant(true))
                .environmentObject(EnvironmentSettings())
                .environment(\.colorScheme, .light)
                .previewDevice("iPhone 11 Pro Max")
            
            StoryButton(showingStorySheet: .constant(true))
                .environmentObject(EnvironmentSettings())
                .environment(\.colorScheme, .light)
                .previewDevice("iPhone SE")
        }
        
    }
}
