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
                self.colorScheme == .light ? LinearGradient(Color.offWhite, Color.offWhite) : LinearGradient(Color.darkStart, Color.darkEnd)
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
    @Binding var story: CovidStory
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        GeometryReader { geometry in
            self.storyView(geometry: geometry)
        }
    }
    
    func storyView(geometry: GeometryProxy) -> some View {
        return ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(colorScheme == .light ? LinearGradient(Color.offWhite, Color.offWhite) : LinearGradient(Color.darkStart, Color.darkEnd))
                .frame(width: geometry.size.width, height: 100)
                .shadow(color: Color("LightShadow"), radius: 8, x: -8, y: -8)
                .shadow(color: Color("DarkShadow"), radius: 8, x: 8, y: 8)
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
        dateFormatter.dateFormat = "MMMM d,yyyy"
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
    
    func warningLevel() -> String {
        if self.story.positiveContacts.count >= 2 {
            return "Multiple people nearby on this date reported a positive COVID-19 test."
        } else if self.story.positiveContacts.count >= 1 {
            return "At least one person nearby on this date reported a positive COVID-19 test."
        } else {
            return "There were no interactions with any confirmed COVID-19 users on this date."
        }
    }
}


