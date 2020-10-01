//
//  QuestionButton.swift
//  SwiftUIDesignProject
//
//  Created by Brandon on 4/9/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import SwiftUI

struct QuestionButton: View {
    
    // UI Config
    @Binding var showingQuestionSheet: Bool
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: Sharing
    @Binding var isSharingData: Bool
    
    var body: some View {
        Button(action: {
            self.showingQuestionSheet.toggle()
        }) {
            Image(systemName: "person")
                .foregroundColor(self.colorScheme == .dark ? Color.gray : Color.lairDarkGray)
                .font(.system(size: 25, weight: .regular))
                .padding()
        }.sheet(isPresented: $showingQuestionSheet) {
            QuestionView(showingQuestionSheet: self.$showingQuestionSheet, isSharingData: $isSharingData)
        }
    }
}

struct QuestionButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            QuestionButton(showingQuestionSheet: .constant(false), isSharingData: .constant(false))
                .environmentObject(EnvironmentSettings())
                .environment(\.colorScheme, .light)
                .previewDevice("iPhone 11 Pro Max")
            
            QuestionButton(showingQuestionSheet: .constant(false), isSharingData: .constant(false))
                .environmentObject(EnvironmentSettings())
                .environment(\.colorScheme, .light)
                .previewDevice("iPhone SE")
        }
        
    }
}
