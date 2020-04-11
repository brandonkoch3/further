//
//  QuestionView.swift
//  SwiftUIDesignProject
//
//  Created by Brandon Koch on 3/31/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import SwiftUI

struct QuestionView: View {
    
    // UI
    @Binding var showingQuestionSheet: Bool
    @State private var showingQuestion = false
    
    // Helpers
    @EnvironmentObject var questions: QuestionsController
    
    @Environment(\.colorScheme) var colorScheme
    
    // Header Text
    struct HeaderText: View {
        var body: some View {
            VStack {
                HStack {
                    Text("COVID-19")
                    .font(Font.custom("Rubik-Medium", size: 34.0))
                    .foregroundColor(.white)
                    Spacer()
                }.padding(.leading, 16.0)
                
                HStack {
                    Text("Questionnaire")
                        .font(Font.custom("Rubik-Medium", size: 16.5))
                    .foregroundColor(.white)
                    Spacer()
                }.padding(.leading, 16.0).padding(.top, 5.0)
            }
        }
    }
    
    // Main View
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                ZStack {
                    Image(self.colorScheme == .light ? "day_graident" : "night_graident").resizable()
                    VStack {
                        HeaderText().padding(.top, geometry.size.height * 0.09).padding(.bottom, geometry.size.height < 600.0 ? 0.0 : 38.0)
                        Spacer()
                        ZStack {
                            Rectangle().fill(self.colorScheme == .light ? LinearGradient(Color.offWhite, Color.offWhite) : LinearGradient(Color.darkStart, Color.darkEnd))
                            .cornerRadius(20, corners: [.topLeft, .topRight])
                
                            VStack {
                                self.informationView(geometry: geometry)
                                    .padding(.top, 25.0)
                                    .padding([.leading, .trailing], 15.0)
                                Spacer()
                                HStack {
                                    Spacer()
                                    NavigationLink(destination: QuestionsView(questionID: 0, showingQuestion: self.$showingQuestionSheet).environmentObject(self.questions)) {
                                        Image(systemName: "arrow.right")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 30, weight: .ultraLight))
                                    }
                                        .buttonStyle(LightButtonStyle(lightMode: self.colorScheme == .light ? true : false))
                                        .scaleEffect(geometry.size.height < 600.0 ? 0.7 : 1.0)
                                        .padding(.trailing, geometry.size.height < 600.0 ? -2.0 : 12.9)
                                        .padding(.bottom, geometry.size.height < 600.0 ? 0.0 : 24.0)
                                }
                            }
                        }
                    }
                }.edgesIgnoringSafeArea(.all)
            } .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    // Information View
    func informationView(geometry: GeometryProxy) -> some View {
        return VStack {
            InformationView(sectionImage: Image("\(colorScheme == .light ? "light" : "dark")_hand_icon"), headerTitle: "Privacy", subTitle: "All answers are completely anonymous.")
            InformationView(sectionImage: Image("\(colorScheme == .light ? "light" : "dark")_people_icon"), headerTitle: "Honesty", subTitle: "Please answer honestly in the interest of others.")
            InformationView(sectionImage: Image("\(colorScheme == .light ? "light" : "dark")_health_icon"), headerTitle: "Health", subTitle: "Your answers will help inform best practices.")
        }
    }
}

// Helpers
struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

// Previews
struct QuestionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            QuestionView(showingQuestionSheet: .constant(true))
                .previewDevice("iPhone SE")
                .environment(\.colorScheme, .light)
                .environmentObject(QuestionsController())
            
            QuestionView(showingQuestionSheet: .constant(true))
            .previewDevice("iPhone XS")
            .environment(\.colorScheme, .light)
            .environmentObject(QuestionsController())
        }
    }
}

// InformationView
struct InformationView: View {
    var sectionImage: Image
    var headerTitle: String
    var subTitle: String
    var imageOffset: CGFloat? = 0
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        GeometryReader { geometry in
            self.infoView(geometry: geometry)
        }
    }
    
    func infoView(geometry: GeometryProxy) -> some View {
        return ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(colorScheme == .light ? LinearGradient(Color.offWhite, Color.offWhite) : LinearGradient(Color.darkStart, Color.darkEnd))
                .frame(width: geometry.size.width, height: 100)
                .shadow(color: Color("LightShadow"), radius: 8, x: -8, y: -8)
                .shadow(color: Color("DarkShadow"), radius: 8, x: 8, y: 8)
            HStack {
                self.sectionImage
                VStack(alignment: .leading, spacing: 5.0) {
                    Text(self.headerTitle)
                        .font(Font.custom("Rubik-Medium", size: 23.3))
                    Text(self.subTitle)
                        .font(Font.custom("Rubik-Light", size: 15.5))
                }
                Spacer()
            }
        }
    }
}
