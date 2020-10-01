//
//  ContentView.swift
//  Further App Clip
//
//  Created by Brandon on 9/17/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import SwiftUI
import AuthenticationServices

struct ContentView: View {
    
    // MARK: Sheet config
    enum sheets {
        case disclaimer
        case questions
    }
    
    @State private var sheetToShow: sheets = .disclaimer
    
    // MARK: UI Config
    @Binding var isInRegion: Bool
    @State private var showingSheet = true
    @State private var showingQuestionSheet = false
    
    // MARK: Sharing
    @Binding var isSharingData: Bool
    var environmentSettings = EnvironmentSettings()
    
    // MARK: Test
    @Binding var receivedURL: String
    @State private var showingDebugAlert = false
    
    var body: some View {
        EntryView()
            .sheet(isPresented: $showingSheet) {
                switch sheetToShow {
                case .disclaimer:
                    Disclaimer(isShowingDisclaimer: $showingSheet, isInRegion: $isInRegion, receivedURL: $receivedURL)
                        .onDisappear() {
                            self.sheetToShow = .questions
                            self.showingSheet.toggle()
                        }
                case .questions:
                    QuestionView(showingQuestionSheet: $showingSheet, isSharingData: $isSharingData)
                }
            }
            .onAppear() {
                if isSharingData {
                    self.sheetToShow = .disclaimer
                }
            }
    }
}

struct Disclaimer: View {
    
    // MARK: UI Configuration
    @Binding var isShowingDisclaimer: Bool
    
    // MARK: Helpers
    @StateObject var authenticationHelper = AuthenticationHelper()
    @EnvironmentObject var environmentSettings: EnvironmentSettings
    let defaults = UserDefaults(suiteName: "group.com.bnbmedia.further.contents")
    let decoder = JSONDecoder()
    
    // MARK: Test
    @Binding var isInRegion: Bool
    @Binding var receivedURL: String
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    ZStack {
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: geometry.size.height / 3)
                        
                        ZStack {
                            EntryBackgroundView()
                                .frame(width: geometry.size.width - 40.0, height: geometry.size.height / 5)
                                .cornerRadius(30)
                            
                            HStack {
                                Image("\(colorScheme == .light ? "light" : "dark")_health_icon")
                                    .padding([.leading], 25.0)
                                VStack {
                                    Path { path in
                                        path.move(to: CGPoint(x: 0, y: 0))
                                        path.addLine(to: CGPoint(x: 200, y: 0))
                                    }
                                    .stroke(Color.lairDarkGray, style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
                                    
                                    Path { path in
                                        path.move(to: CGPoint(x: 0, y: 0))
                                        path.addLine(to: CGPoint(x: 150, y: 0))
                                    }
                                    .stroke(Color.gray, style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
                                    
                                    Path { path in
                                        path.move(to: CGPoint(x: 0, y: 0))
                                        path.addLine(to: CGPoint(x: 100, y: 0))
                                    }
                                    .stroke(Color.gray, style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
                                }
                                .frame(height: 75.0)
                                .padding([.top], 25.0)
                                
                            }
                        }
                        
                    }
                    
                    VStack(spacing: 30.0) {
                        Text("Securely Share Contact Information")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("Your region requires at least one diner from your party provide contact information to \(environmentSettings.establishmentName).")
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("This information will be used to contact you in the event someone dining at the same time as you reports a positive COVID-19 test.")
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }.padding()
                    
                    Spacer()
                    
                    VStack {
                        Text(receivedURL != "" ? receivedURL : "Information you enter with this app will be stored securely on behalf of this establishment.  Your information will be removed after 14 days and will only be accessible by a public health authority.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding()
                        
                        Button(action: {
                            self.isShowingDisclaimer.toggle()
                        }, label: {
                            Text(hasUserInfoSaved() ? "Confirm My Information" : "Get Started")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50.0)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(40)
                                .padding()
                        })
                    }
                }
            }
        }
    }
    
    private func hasUserInfoSaved() -> Bool {
        if let savedData = defaults!.object(forKey: "personInfoModel") as? Data {
            if let loadedData = try? decoder.decode(PersonInfoModel.self, from: savedData) {
                _ = loadedData
                return true
            }
        }
        return false
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView(isInRegion: .constant(true), establishmentName: .constant("poop"), receivedURL: .constant(""))
//            .environmentObject(PersonInfoController())
//    }
//}

struct Disclaimer_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Disclaimer(isShowingDisclaimer: .constant(true), isInRegion: .constant(true), receivedURL: .constant(""))
                .previewDevice("iPhone SE (2nd generation)")
            
            Disclaimer(isShowingDisclaimer: .constant(true), isInRegion: .constant(true), receivedURL: .constant(""))
                .previewDevice("iPhone 11 Pro Max")
        }
        
    }
}
