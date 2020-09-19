//
//  QuestionView.swift
//  SwiftUIDesignProject
//
//  Created by Brandon Koch on 3/31/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import SwiftUI
import Combine

struct QuestionView: View {
    
    // UI
    @Binding var showingQuestionSheet: Bool
    @State private var showingQuestion = false
    
    // MARK: Helpers
    @EnvironmentObject var questions: QuestionsController
    @EnvironmentObject var personController: PersonInfoController
    
    @Environment(\.colorScheme) var colorScheme
    
    // Header Text
    struct HeaderText: View {
        var body: some View {
            VStack {
                HStack {
                    Text("My Information")
                    .font(Font.custom("Rubik-Medium", size: 34.0))
                    .foregroundColor(.white)
                    Spacer()
                }.padding(.leading, 16.0)
            }
        }
    }
    
    // Main View
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                self.colorScheme == .light ? Color.offWhite : Color(hex: "25282d")
            }.edgesIgnoringSafeArea(.all)
            ScrollView {
                ZStack {
                    Image(self.colorScheme == .light ? "day_graident" : "night_graident").resizable()
                    VStack {
                        
                        // Header
                        HeaderText()
                            .padding(.top, 60.0)
                            .padding(.bottom, 28.0)

                        // Rectangle
                        ZStack {
                            Rectangle().fill(self.colorScheme == .light ? Color.offWhite : Color(hex: "25282d"))
                            .cornerRadius(20, corners: [.topLeft, .topRight])
                
                            // Information
                            self.informationView()
                                .padding(.top, 25.0)
                                .padding([.leading, .trailing], 15.0)
                        }
                    }
                }
            }
        }
    }
    
    // Information View
    func informationView() -> some View {
        return VStack {
            InformationView(sectionImage: Image("\(colorScheme == .light ? "light" : "dark")_hand_icon"), headerTitle: "Name", subTitle: "Your Name")
//            InformationView(sectionImage: Image("\(colorScheme == .light ? "light" : "dark")_people_icon"), headerTitle: "Phone", subTitle: "Phone Number")
//            InformationView(sectionImage: Image("\(colorScheme == .light ? "light" : "dark")_health_icon"), headerTitle: "Address", subTitle: "Local Address")
//            InformationView(sectionImage: Image("\(colorScheme == .light ? "light" : "dark")_health_icon"), headerTitle: "Email", subTitle: "An e-mail you check")
            Spacer()
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
                .previewDevice("iPhone SE (2nd generation)")
                .environment(\.colorScheme, .dark)
                .environmentObject(QuestionsController())
                .environmentObject(PersonInfoController())
            
            QuestionView(showingQuestionSheet: .constant(true))
                .previewDevice("iPhone 11 Pro Max")
            .environment(\.colorScheme, .light)
            .environmentObject(QuestionsController())
            .environmentObject(PersonInfoController())
        }
    }
}

// InformationView
struct InformationView: View {
    var sectionImage: Image
    var headerTitle: String
    var subTitle: String
    //@Binding var textField: String
    var imageOffset: CGFloat? = 0
    @Environment(\.colorScheme) var colorScheme
    
    @EnvironmentObject var personController: PersonInfoController
    
    @State var test = ""
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20.0) {
                
                if personController.mapHelper.results.isEmpty {
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(colorScheme == .light ? Color.offWhite : Color(hex: "25282d"))
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.16)
                        .shadow(color: colorScheme == .light ? Color("LightShadow") : Color(hex: "505050"), radius: colorScheme == .light ? 8 : 0.5, x: colorScheme == .light ? -8 : -1, y: colorScheme == .light ? -8 : -1)
                        .shadow(color: colorScheme == .light ? Color("DarkShadow") : .black, radius: 8, x: colorScheme == .light ? 8 : -1, y: colorScheme == .light ? 8 : 1)
                    
                    HStack {
                        self.sectionImage
                        VStack(alignment: .leading, spacing: 5.0) {
                            Text("Name")
                                .font(Font.custom("Rubik-Medium", size: 23.3))
                            TextField("First Last", text: $personController.name)
                                .font(Font.custom("Rubik-Light", size: 15.5))
                                .keyboardType(keyboardType())
                                .textContentType(contentType())
                        }
                        Spacer()
                    }
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(colorScheme == .light ? Color.offWhite : Color(hex: "25282d"))
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.16)
                        .shadow(color: colorScheme == .light ? Color("LightShadow") : Color(hex: "505050"), radius: colorScheme == .light ? 8 : 0.5, x: colorScheme == .light ? -8 : -1, y: colorScheme == .light ? -8 : -1)
                        .shadow(color: colorScheme == .light ? Color("DarkShadow") : .black, radius: 8, x: colorScheme == .light ? 8 : -1, y: colorScheme == .light ? 8 : 1)
                    
                    HStack {
                        self.sectionImage
                        VStack(alignment: .leading, spacing: 5.0) {
                            Text("Phone Number")
                                .font(Font.custom("Rubik-Medium", size: 23.3))
                            TextField("A number you'll answer", text: $personController.phone)
                                .font(Font.custom("Rubik-Light", size: 15.5))
                                .keyboardType(keyboardType())
                                .textContentType(contentType())
                        }
                        Spacer()
                    }
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(colorScheme == .light ? Color.offWhite : Color(hex: "25282d"))
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.16)
                        .shadow(color: colorScheme == .light ? Color("LightShadow") : Color(hex: "505050"), radius: colorScheme == .light ? 8 : 0.5, x: colorScheme == .light ? -8 : -1, y: colorScheme == .light ? -8 : -1)
                        .shadow(color: colorScheme == .light ? Color("DarkShadow") : .black, radius: 8, x: colorScheme == .light ? 8 : -1, y: colorScheme == .light ? 8 : 1)
                    
                    HStack {
                        self.sectionImage
                        VStack(alignment: .leading, spacing: 5.0) {
                            Text("E-mail")
                                .font(Font.custom("Rubik-Medium", size: 23.3))
                            TextField("An e-mail you check", text: $personController.email)
                                .font(Font.custom("Rubik-Light", size: 15.5))
                                .keyboardType(keyboardType())
                                .textContentType(contentType())
                        }
                        Spacer()
                    }
                }
                    
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(colorScheme == .light ? Color.offWhite : Color(hex: "25282d"))
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.16)
                        .shadow(color: colorScheme == .light ? Color("LightShadow") : Color(hex: "505050"), radius: colorScheme == .light ? 8 : 0.5, x: colorScheme == .light ? -8 : -1, y: colorScheme == .light ? -8 : -1)
                        .shadow(color: colorScheme == .light ? Color("DarkShadow") : .black, radius: 8, x: colorScheme == .light ? 8 : -1, y: colorScheme == .light ? 8 : 1)
                    
                    HStack {
                        self.sectionImage
                        VStack(alignment: .leading, spacing: 5.0) {
                            Text("Local Address")
                                .font(Font.custom("Rubik-Medium", size: 23.3))
                            TextField("Address", text: $personController.address)
                                .font(Font.custom("Rubik-Light", size: 15.5))
                                .keyboardType(keyboardType())
                                .textContentType(contentType())
                            TextField("Zip", text: $personController.addressZip)
                                .font(Font.custom("Rubik-Light", size: 15.5))
                                .keyboardType(keyboardType())
                                .textContentType(contentType())
                        }
                        Spacer()
                    }
                }
                
                
                if !personController.mapHelper.results.isEmpty {
                    List {
                        ForEach(personController.mapHelper.results) { item in
                            VStack(alignment: .leading) {
                                Text(item.title)
                                Text(item.subtitle)
                                    .foregroundColor(.gray)
                                    .font(.system(size: 8.0))
                            }
                        }
                    }.frame(height: 250.0)
                    .background(Color.clear)
                }
                
                Spacer()
                
                Button(action: {
                    //
                }, label: {
                    Text("Share Securely")
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
    
    func keyboardType() -> UIKeyboardType {
        switch headerTitle {
        case "Name":
            return .namePhonePad
        case "Phone":
            return .namePhonePad
        case "Email":
            return .emailAddress
        default:
            return .default
        }
    }
    
    func contentType() -> UITextContentType {
        switch headerTitle {
        case "Name":
            return .name
        case "Phone":
            return .telephoneNumber
        case "Email":
            return .emailAddress
        case "Address":
            return .streetAddressLine1
        default:
            return .name
        }
    }
}
