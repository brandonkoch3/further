//
//  QuestionView.swift
//  SwiftUIDesignProject
//
//  Created by Brandon Koch on 3/31/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import SwiftUI

struct QuestionView: View {
    @Binding var showingQuestionSheet: Bool
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        
        GeometryReader { geometry in
            VStack {
                VStack {
                    Spacer()
                    VStack {
                        VStack(alignment: .leading) {
                            HStack {
                            Text("COVID-19")
                                .font(.largeTitle)
                                .fontWeight(.semibold)
                                .fixedSize()
                                .foregroundColor(.white)
                                Spacer()
                            }
                            HStack {
                            Text("Questionnaire")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .fixedSize()
                                .foregroundColor(.white)
                                Spacer()
                            }
                            }.padding().offset(x: 0, y: -40)
                    }
                }.frame(maxWidth: .infinity, minHeight: geometry.size.height / 3, maxHeight: geometry.size.height / 3)
                    .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "D94c7a"), Color(hex: "Fcde89"), Color.blue]), startPoint: .topLeading, endPoint: .trailing))
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(LinearGradient(Color.darkStart, Color.darkEnd))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .edgesIgnoringSafeArea(.all)
                        VStack {
                            Spacer()
                            InformationView(sectionImage: Image(systemName: "hand.raised.fill"), headerTitle: "Privacy", subTitle: "All answers are completely anonymous and cannot be associated with you.", imageOffset: 5)
                            InformationView(sectionImage: Image(systemName: "bandage.fill"), headerTitle: "Health", subTitle: "Feeling sick?  This app is informative and does not provide medical care or guidance.", imageOffset: 3)
                            InformationView(sectionImage: Image(systemName: "location.fill"), headerTitle: "Honesty", subTitle: "Your provided reponses are not validated.  Please answer honestly in the interest of helping others.")
                            Spacer(minLength: 60)
                            VStack {
                                
                                Button(action: {
                                    
                                }) {
                                    ZStack {
                                        Text("YUP")
                                    }
                                }.buttonStyle(DarkAnswerButtonStyle())
                                .frame(width: 200, height: 100)
                            }
                        }
                    }.offset(x: 0, y: -50)
                }.background(LinearGradient(Color.darkStart, Color.darkEnd))
            }.edgesIgnoringSafeArea(.all)
        }
    }
}

struct QuestionView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionView(showingQuestionSheet: .constant(true)).previewDevice("iPhone 11 Pro Max").environment(\.colorScheme, .dark)
    }
}

struct InformationView: View {
    var sectionImage: Image
    var headerTitle: String
    var subTitle: String
    var imageOffset: CGFloat? = 0
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(LinearGradient(Color.darkStart, Color.darkEnd))
                    .frame(width: geometry.size.width - 20, height: 100)
                    .shadow(color: Color("LightShadow"), radius: 8, x: -8, y: -8)
                    .shadow(color: Color("DarkShadow"), radius: 8, x: 8, y: 8)
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(LinearGradient(Color.darkStart, Color.darkEnd))
                            .frame(width: 60, height: 60)
                            .shadow(color: Color("LightShadow"), radius: 8, x: -8, y: -8)
                            .shadow(color: Color("DarkShadow"), radius: 8, x: 8, y: 8)
                            .padding(.leading, 6)
                        self.sectionImage
                            .foregroundColor(self.colorScheme == .dark ? .red : .gray)
                            .font(.system(size: 30))
                            .multilineTextAlignment(.center)
                            .offset(x: self.imageOffset!, y: 0)
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 0) {
                        Text(self.headerTitle)
                            .font(.title)
                        Spacer()
                        Text(self.subTitle).font(.caption)
                        Spacer()
                    }.frame(height: 80)
                    Spacer()
                }
                .padding()
            }
        }
    }
}
