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
                }.padding(.leading, 16.0).padding(.top, 12.0)
            }.padding(.top, 12.0)
        }
    }
    
    struct RoundedCorner: Shape {

        var radius: CGFloat = .infinity
        var corners: UIRectCorner = .allCorners

        func path(in rect: CGRect) -> Path {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            return Path(path.cgPath)
        }
    }
    
    
    
    var body: some View {
        
        GeometryReader { geometry in
            NavigationView {
                ZStack {
                    Image(self.colorScheme == .light ? "day_graident" : "night_graident").resizable()
                    VStack {
                        HeaderText().padding(.top, geometry.size.height / 8).padding(.bottom, 38.0)
                        Spacer()
                        VStack {
                            Rectangle().fill(Color.offWhite)
                                .cornerRadius(20, corners: [.topLeft, .topRight])
                        }
                    }
                    
//                    VStack {
//                        VStack {
//                            Spacer()
//                            VStack {
//                                VStack(alignment: .leading) {
//                                    HStack {
//                                    Text("COVID-19")
//                                        .font(.largeTitle)
//                                        .fontWeight(.semibold)
//                                        .fixedSize()
//                                        .foregroundColor(.white)
//                                        Spacer()
//                                    }
//                                    HStack {
//                                    Text("Questionnaire")
//                                        .font(.subheadline)
//                                        .fontWeight(.semibold)
//                                        .fixedSize()
//                                        .foregroundColor(.white)
//                                        Spacer()
//                                    }
//                                    }.padding().offset(x: 0, y: -40)
//                            }
//                        }.frame(maxWidth: .infinity, minHeight: geometry.size.height / geometry.size.height < 600 ? 3.5 : 3.0, maxHeight: geometry.size.height / (geometry.size.height < 600.0 ? 3.5 : 3.0))
//                            .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "D94c7a"), Color(hex: "Fcde89"), Color.blue]), startPoint: .topLeading, endPoint: .trailing))
//                        VStack {
//                            if self.colorScheme == .light {
//                                self.modalViewLight(geometry: geometry)
//                            } else {
//                                self.modalViewDark(geometry: geometry)
//                            }
//                        }
//                    }
                }.edgesIgnoringSafeArea(.all)
            } .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    func informationView(geometry: GeometryProxy) -> some View {
        return VStack {
            InformationView(sectionImage: Image(systemName: "hand.raised.fill"), headerTitle: "Privacy", subTitle: "All answers are completely anonymous and cannot be associated with you.", imageOffset: 5)
            if geometry.size.height < 600.0 {
                Spacer(minLength: 50.0)
            }
            InformationView(sectionImage: Image(systemName: "person.2.fill"), headerTitle: "Honesty", subTitle: "Your provided reponses are not validated.  Please answer honestly to help others.")
            if geometry.size.height < 600.0 {
                Spacer(minLength: 50.0)
            }
            InformationView(sectionImage: Image(systemName: "bandage.fill"), headerTitle: "Health", subTitle: "Your answers can help inform others.", imageOffset: 3)
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
                informationView(geometry: geometry)
                Spacer(minLength: 60)
                
                HStack {
                    Spacer()
                    if geometry.size.height < 600 {
                        VStack {
                            HStack {
                                Spacer()
                                NavigationLink(destination: QuestionsView(questionID: 0, showingQuestion: self.$showingQuestionSheet).environmentObject(self.questions)) {
                                    Text("Tap to Continue")
                                }
                                Spacer()
                            }
                        }.padding(.top, 10)
                    } else {
                        NavigationLink(destination: QuestionsView(questionID: 0, showingQuestion: self.$showingQuestionSheet).environmentObject(self.questions)) {
                            Image(systemName: "arrow.right")
                            .foregroundColor(.gray)
                            .font(.system(size: 30, weight: .ultraLight))
                        }.padding().buttonStyle(LightButtonStyle())
                    }
                }
            }
        }.offset(x: 0, y: geometry.size.height < 600.0 ? 0 : -50).padding(.bottom, geometry.size.height < 600 ? 15.0 : 0.0)
    }
    
    
    func modalViewDark(geometry: GeometryProxy) -> some View {
        return ZStack {
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                informationView(geometry: geometry)
                Spacer(minLength: 60)
                HStack {
                    Spacer()
                        if geometry.size.height < 600 {
                        VStack {
                            HStack {
                                Spacer()
                                NavigationLink(destination: QuestionsView(questionID: 0, showingQuestion: self.$showingQuestionSheet).environmentObject(self.questions)) {
                                    Text("Tap to Continue")
                                }
                                Spacer()
                            }
                        }.padding(.top, 10)
                    } else {
                        NavigationLink(destination: QuestionsView(questionID: 0, showingQuestion: self.$showingQuestionSheet).environmentObject(self.questions)) {
                            Image(systemName: "arrow.right")
                            .foregroundColor(.gray)
                            .font(.system(size: 30, weight: .ultraLight))
                        }.padding().buttonStyle(DarkButtonStyle())
                    }
                }
            }
        }.offset(x: 0, y: geometry.size.height < 600.0 ? 0 : -50).padding(.bottom, geometry.size.height < 600 ? 15.0 : 0.0)
    }
}

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
                        .padding(.top, geometry.size.height < 600.0 ? 6.0 : 0.0)
                    Spacer()
                    Text(self.subTitle).font(.caption)
                    Spacer()
                }.frame(height: geometry.size.height < 600.0 ? 100 : 80).padding(.leading, 6.0)
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
                        .padding(.top, geometry.size.height < 600.0 ? 6.0 : 0.0)
                    Spacer()
                    Text(self.subTitle).font(.caption)
                    Spacer()
                }.frame(height: geometry.size.height < 600.0 ? 100 : 80).padding(.leading, 6.0)
                Spacer()
            }
            .padding()
        }
    }
}
