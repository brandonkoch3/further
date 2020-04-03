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
                if self.colorScheme == .dark {
                    LinearGradient(Color.darkStart, Color.darkEnd)
                } else {
                    Color.offWhite
                }
                VStack{
                    HStack {
                        Text((self.storyController.stories.count > 0) ? "Previous Interactions" : "No Previous Interactions")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                            .foregroundColor(self.colorScheme == .dark ? .white : .black)
                            .padding([.leading, .trailing], 10.0)
                        Spacer()
                    }.padding()
                    
                    ScrollView(.vertical, showsIndicators: true) {
                        ForEach(self.storyController.testData.indices) { idx in
                            StoryItem(story: self.$storyController.testData[idx]).frame(height: 120)
                            Spacer()
                        }
                    }
                    Spacer()
                }.padding(.top, 70)
            }.edgesIgnoringSafeArea(.all)
        }
    }
}

struct StoryView_Previews: PreviewProvider {
    static var previews: some View {
        StoryView(storyController: StoriesController())
            .previewDevice("iPhone 11 Pro Max")
            .environment(\.colorScheme, .dark)
    }
}

struct StoryItem: View {
    @Binding var story: CovidStory
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        GeometryReader { geometry in
            if self.colorScheme == .light {
                self.lightView(geometry: geometry)
            } else {
                self.darkView(geometry: geometry)
            }
        }
    }
    
    func lightView(geometry: GeometryProxy) -> some View {
        return ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.offWhite)
                .frame(width: geometry.size.width - 20, height: 100)
                .shadow(color: Color("LightShadow"), radius: 8, x: -8, y: -8)
                .shadow(color: Color("DarkShadow"), radius: 8, x: 8, y: 8)
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                    .fill(Color.offWhite)
                    .frame(width: 60, height: 60)
                    .shadow(color: Color("LightShadow"), radius: 8, x: -8, y: -8)
                    .shadow(color: Color("DarkShadow"), radius: 8, x: 8, y: 8)
                    .padding(.leading, 6)
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.offWhite)
                            .frame(width: 60, height: 60)
                            .shadow(color: Color("LightShadow"), radius: 8, x: -8, y: -8)
                            .shadow(color: Color("DarkShadow"), radius: 8, x: 8, y: 8)
                            .padding(.leading, 6)
                        
                        self.warningImage()
                            .foregroundColor(.gray)
                            .font(.system(size: 30))
                            .multilineTextAlignment(.center)
                            .offset(x: 5, y: 0)
                    }
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    Text(self.readableDate())
                        .font(.system(size: 25.0))
                        .fontWeight(.semibold)
                    Spacer()
                    Text(self.warningLevel()).font(.subheadline)
                    Spacer()
                }.frame(height: 100).padding(.leading, 6.0).padding(.top, 2.0)
                Spacer()
            }
            .padding()
        }
    }
    
    func darkView(geometry: GeometryProxy) -> some View {
        return ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(LinearGradient(Color.darkStart, Color.darkEnd))
                .frame(width: geometry.size.width - 20, height: 100)
                .shadow(color: Color.darkStart, radius: 10, x: -10, y: -10)
                .shadow(color: Color.darkEnd, radius: 10, x: 10, y: 10)
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                    .fill(LinearGradient(Color.darkStart, Color.darkEnd))
                    .frame(width: 60, height: 60)
                    .shadow(color: Color.darkStart, radius: 10, x: -10, y: -10)
                    .shadow(color: Color.darkEnd, radius: 10, x: 10, y: 10)
                    .padding(.leading, 6)
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(LinearGradient(Color.darkStart, Color.darkEnd))
                            .frame(width: 60, height: 60)
                            .shadow(color: Color.darkStart, radius: 10, x: -10, y: -10)
                            .shadow(color: Color.darkEnd, radius: 10, x: 10, y: 10)
                            .padding(.leading, 6)
                        
                        self.warningImage()
                            .foregroundColor(.red)
                            .font(.system(size: 30))
                            .multilineTextAlignment(.center)
                            .offset(x: 5, y: 0)
                    }
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    Text(self.readableDate())
                        .font(.system(size: 25.0))
                        .fontWeight(.semibold)
                    Spacer()
                    Text(self.warningLevel()).font(.subheadline)
                    Spacer()
                }.frame(height: 100).padding(.leading, 6.0).padding(.top, 2.0)
                Spacer()
            }
            .padding()
        }
    }
    
    func warningImage() -> Image {
        if self.story.positiveContacts.count >= 3 {
            return Image(systemName: "bed.double")
        } else if self.story.positiveContacts.count >= 1 {
            return Image(systemName: "exclamationmark")
        } else {
            return Image(systemName: "checkmark")
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


