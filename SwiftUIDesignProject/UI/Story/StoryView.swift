//
//  StoryView.swift
//  SwiftUIDesignProject
//
//  Created by Brandon on 4/2/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import SwiftUI

struct StoryView: View {
    
    // MARK: Config
    @ObservedObject var storyController: StoriesController
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: View
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                self.colorScheme == .light ? Color.offWhite : Color(hex: "25282d")
                VStack{
                    ScrollView(.vertical, showsIndicators: true) {
                        HStack {
                            Spacer()
                            Text((self.storyController.stories.count > 0) ? "Previous Interactions" : "No Previous Interactions")
                            .font(Font.custom("Rubik-Light", size: 34.0))
                                .foregroundColor(self.colorScheme == .dark ? .white : .black)
                            Spacer()
                        }.padding()
                        ForEach(self.storyController.stories.indices) { idx in
                            StoryItem(story: self.$storyController.stories[idx])
                                .frame(height: 120)
                                .padding([.leading, .trailing], 15.0)
                            Spacer()
                        }
                    }
                    Spacer()
                }.padding(.top, geometry.size.height < 600.0 ? 40.0 : 80.0 )
            }.edgesIgnoringSafeArea(.all)
        }
    }
}

struct StoryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StoryView(storyController: StoriesController())
            .previewDevice("iPhone SE")
            .environment(\.colorScheme, .dark)
            
            StoryView(storyController: StoriesController())
            .previewDevice("iPhone 11 Pro Max")
            .environment(\.colorScheme, .light)
        }
        
    }
}

struct StoryItem: View {
    @Binding var story: WellnessStory
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        GeometryReader { geometry in
            self.storyView(geometry: geometry)
        }
    }
    
    func storyView(geometry: GeometryProxy) -> some View {
        return ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(colorScheme == .light ? Color.offWhite : Color(hex: "25282d"))
                .frame(width: geometry.size.width, height: 100)
                .shadow(color: colorScheme == .light ? Color("LightShadow") : Color(hex: "505050"), radius: colorScheme == .light ? 8 : 0.5, x: colorScheme == .light ? -8 : -1, y: colorScheme == .light ? -8 : -1)
                .shadow(color: colorScheme == .light ? Color("DarkShadow") : .black, radius: 8, x: colorScheme == .light ? 8 : -1, y: colorScheme == .light ? 8 : 1)
            HStack {
                self.warningImage()
                VStack(alignment: .leading, spacing: 5.0) {
                    Text(self.readableDate())
                        .font(Font.custom("Rubik-Medium", size: 23.3))
                    Text(self.warningLevel())
                        .font(Font.custom("Rubik-Light", size: 15.5))
                }
                Spacer()
            }
        }
    }
    
    func warningImage() -> Image {
        if self.story.positiveContacts.count >= 3 {
            return Image(self.colorScheme == .light ? "light_high_risk" : "dark_high_risk")
        } else if self.story.positiveContacts.count >= 1 {
            return Image(self.colorScheme == .light ? "light_medium_risk" : "dark_medium_risk")
        } else {
            return Image(self.colorScheme == .light ? "light_low_risk" : "dark_low_risk")
        }
    }
    
    func readableDate() -> String {
        let date = Date(timeIntervalSince1970: self.story.dateGathered)
        let dateFormatter = DateFormatter()
        //dateFormatter.locale = NSLocale.current
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "MMMM d, yyyy"
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
    
    func warningLevel() -> String {
        if self.story.positiveContacts.count >= 2 {
            return "High Risk"
        } else if self.story.positiveContacts.count >= 1 {
            return "Medium Risk"
        } else {
            return "Low Risk"
        }
    }
}


