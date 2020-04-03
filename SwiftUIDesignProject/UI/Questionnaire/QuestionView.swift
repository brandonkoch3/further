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
    
    // Internal
    @State private var showingQuestion = false
    
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        
        GeometryReader { geometry in
            ZStack {
                if self.colorScheme == .light {
                    Color.offWhite
                } else {
                    LinearGradient(Color.darkStart, Color.darkEnd)
                }
                
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
                        if self.colorScheme == .light {
                            self.modalViewLight(geometry: geometry)
                        } else {
                            self.modalViewDark(geometry: geometry)
                        }
                    }
                }
            }.edgesIgnoringSafeArea(.all)
        }
    }
    
    func modalViewLight(geometry: GeometryProxy) -> some View {
        return ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.offWhite)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                InformationView(sectionImage: Image(systemName: "hand.raised.fill"), headerTitle: "Privacy", subTitle: "All answers are completely anonymous and cannot be associated with you.", imageOffset: 5)
                InformationView(sectionImage: Image(systemName: "bandage.fill"), headerTitle: "Health", subTitle: "Feeling sick?  This app is informative and does not provide medical care or guidance.", imageOffset: 3)
                InformationView(sectionImage: Image(systemName: "location.fill"), headerTitle: "Honesty", subTitle: "Your provided reponses are not validated.  Please answer honestly in the interest of helping others.")
                Spacer(minLength: 60)
                HStack {
                    Spacer()
                    Button(action: {
                        self.showingQuestion.toggle()
                    }) {
                        Image(systemName: "arrow.right")
                            .foregroundColor(.gray)
                            .font(.system(size: 30, weight: .ultraLight))
                    }.buttonStyle(LightButtonStyle())
                }
                .sheet(isPresented: self.$showingQuestion) {
                    QuestionsView(questionID: 0).environmentObject(QuestionsController())
                }.padding()
            }
        }.offset(x: 0, y: -50)
    }
    
    func modalViewDark(geometry: GeometryProxy) -> some View {
        return ZStack {
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
                HStack {
                    Spacer()
                    Button(action: {
                        self.showingQuestion.toggle()
                    }) {
                        Image(systemName: "arrow.right")
                            .foregroundColor(.gray)
                            .font(.system(size: 30, weight: .ultraLight))
                    }.buttonStyle(DarkButtonStyle())
                }
                .sheet(isPresented: self.$showingQuestion) {
                    QuestionsView(questionID: 0).environmentObject(QuestionsController())
                }.padding()
            }
        }.offset(x: 0, y: -50)
    }
}

struct QuestionView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            QuestionView(showingQuestionSheet: .constant(true))
                .previewDevice("iPad Pro 12.9-inch")
                .environment(\.colorScheme, .light)
        }
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
                    self.sectionImage
                        .foregroundColor(self.colorScheme == .dark ? .red : .gray)
                        .font(.system(size: 30))
                        .multilineTextAlignment(.center)
                        .offset(x: self.imageOffset!, y: 0)
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text(self.headerTitle)
                        .font(.title)
                    Spacer()
                    Text(self.subTitle).font(.caption)
                    Spacer()
                }.frame(height: 80).padding(.leading, 6.0)
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
                VStack(alignment: .leading, spacing: 0) {
                    Text(self.headerTitle)
                        .font(.title)
                    Spacer()
                    Text(self.subTitle).font(.caption)
                    Spacer()
                }.frame(height: 80).padding(.leading, 6.0)
                Spacer()
            }
            .padding()
        }
    }
}
