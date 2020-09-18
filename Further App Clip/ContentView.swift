//
//  ContentView.swift
//  Further App Clip
//
//  Created by Brandon on 9/17/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: Configuration
    @AppStorage("hasSeenDisclaimer", store: UserDefaults(suiteName: "group.com.bnbmedia.further.contents")) var hasSeenDisclaimer: Bool = false
    
    // MARK: UI Config
    @Binding var isInRegion: Bool
    @Binding var establishmentName: String
    @State private var showingDisclaimer = true
    
    // MARK: Test
    @Binding var receivedURL: String
    
    var body: some View {
        QuestionView(showingQuestionSheet: .constant(true))
            .sheet(isPresented: $showingDisclaimer) {
                Disclaimer(establishmentName: $establishmentName, isInRegion: $isInRegion, receivedURL: $receivedURL)
            }
        
    }
}

struct Disclaimer: View {
    
    // MARK: Configuration
    @AppStorage("hasSeenDisclaimer", store: UserDefaults(suiteName: "group.com.bnbmedia.further.contents")) var hasSeenDisclaimer: Bool = false
    
    // MARK: UI Configuration
    @Binding var establishmentName: String
    
    // MARK: Test
    @Binding var isInRegion: Bool
    @Binding var receivedURL: String
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
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
                    Text("Your region requires at least one diner from your party provide contact information to \(establishmentName).")
                        .multilineTextAlignment(.center)
                    Text("This information will be used to contact you in the event someone dining at the same time as you reports a positive COVID-19 test.")
                        .multilineTextAlignment(.center)
                }.padding()
                
                Spacer()
                
                VStack {
                    Text("Information you enter with this app will be stored securely on behalf of this establishment.  Your information will be removed after 14 days and will only be accessible by a public health authority.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding()
                    Button(action: {
                        //
                    }, label: {
                        Text("Get Started")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50.0)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(40)
                            .padding()
                    })
                    
                    Button(action: {
                        //
                    }, label: {
                        Text("Learn More")
                            .font(.footnote)
                    })
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(isInRegion: .constant(true), establishmentName: .constant("poop"), receivedURL: .constant(""))
    }
}
