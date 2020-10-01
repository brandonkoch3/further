//
//  StoryButton.swift
//  SwiftUIDesignProject
//
//  Created by Brandon on 4/9/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import SwiftUI
import CodeScanner

struct StoryButton: View {
    
    // UI Config
    @Binding var showingStorySheet: Bool
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: Helpers
    private let logger = FurtherLogger(category: "storyButton")
    
    // MARK: Sharing
    @Binding var qrVendorID: String
    
    // View
    var body: some View {
        Button(action: {
            self.showingStorySheet.toggle()
        }) {
            Image(systemName: "qrcode.viewfinder")
                .foregroundColor(self.colorScheme == .dark ? Color.gray : Color.lairDarkGray)
                .font(.system(size: 25, weight: .regular))
        }.sheet(isPresented: $showingStorySheet) {
            CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson\npaul@hackingwithswift.com", completion: handleScan)
                .edgesIgnoringSafeArea(.all)
        }.padding()
    }
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
       self.showingStorySheet = false
        switch result {
        case .success(let code):
            self.qrVendorID = "miyabi"
        case .failure(let error):
            self.logger.logger.log("Error scanning QR Code: \(error.localizedDescription, privacy: .public)")
        }
    }
}

struct StoryButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StoryButton(showingStorySheet: .constant(true), qrVendorID: .constant(""))
                .environmentObject(EnvironmentSettings())
                .environment(\.colorScheme, .light)
                .previewDevice("iPhone 11 Pro Max")
            
            StoryButton(showingStorySheet: .constant(true), qrVendorID: .constant(""))
                .environmentObject(EnvironmentSettings())
                .environment(\.colorScheme, .light)
                .previewDevice("iPhone SE")
        }
        
    }
}
