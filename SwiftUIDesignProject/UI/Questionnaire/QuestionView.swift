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
    
    // Helpers
    @EnvironmentObject var questions: QuestionsController
    @EnvironmentObject var personController: PersonInfoController
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var keyboardHeight: CGFloat = 0
    
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
            InformationView(sectionImage: Image("\(colorScheme == .light ? "light" : "dark")_people_icon"), headerTitle: "Phone", subTitle: "Phone Number")
            InformationView(sectionImage: Image("\(colorScheme == .light ? "light" : "dark")_health_icon"), headerTitle: "Address", subTitle: "Local Address")
            InformationView(sectionImage: Image("\(colorScheme == .light ? "light" : "dark")_health_icon"), headerTitle: "Email", subTitle: "An e-mail you check")
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
            
            QuestionView(showingQuestionSheet: .constant(true))
                .previewDevice("iPhone 11 Pro Max")
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
    //@Binding var textField: String
    var imageOffset: CGFloat? = 0
    @Environment(\.colorScheme) var colorScheme
    
    @State var test = ""
    
    var body: some View {
        GeometryReader { geometry in
            self.infoView(geometry: geometry)
        }
    }
    
    func infoView(geometry: GeometryProxy) -> some View {
        return ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(colorScheme == .light ? Color.offWhite : Color(hex: "25282d"))
                .frame(width: geometry.size.width, height: 100)
                .shadow(color: colorScheme == .light ? Color("LightShadow") : Color(hex: "505050"), radius: colorScheme == .light ? 8 : 0.5, x: colorScheme == .light ? -8 : -1, y: colorScheme == .light ? -8 : -1)
                .shadow(color: colorScheme == .light ? Color("DarkShadow") : .black, radius: 8, x: colorScheme == .light ? 8 : -1, y: colorScheme == .light ? 8 : 1)
            
            HStack {
                self.sectionImage
                VStack(alignment: .leading, spacing: 5.0) {
                    Text(self.headerTitle)
                        .font(Font.custom("Rubik-Medium", size: 23.3))
                    TextField(subTitle, text: $test)
                        .font(Font.custom("Rubik-Light", size: 15.5))
                        .keyboardType(keyboardType())
                        .textContentType(contentType())
                }
                Spacer()
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

struct ButtonView: View {
    @Binding var showingQuestionSheet: Bool
    @EnvironmentObject var questions: QuestionsController
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    NavigationLink(destination: QuestionsView(questionID: 0, showingQuestion: self.$showingQuestionSheet).environmentObject(self.questions)) {
                        Image(systemName: "arrow.right")
                            .foregroundColor(.gray)
                            .font(.system(size: 30, weight: .ultraLight))
                    }
                    .buttonStyle(LightButtonStyle(lightMode: self.colorScheme == .light ? true : false))
                    .scaleEffect(geometry.size.height < 600.0 ? 0.8 : 1.0)
                    .padding(.trailing, geometry.size.height < 600.0 ? 6.0 : 12.9)
                    .padding(.bottom, geometry.size.height < 600.0 ? 35.0 : 50.0)
                }
            }
        }
    }
}

struct TextFieldTyped: UIViewRepresentable {
    let keyboardType: UIKeyboardType
    let returnVal: UIReturnKeyType
    let contentType: UITextContentType
    let tag: Int
    @Binding var text: String
    @Binding var isfocusAble: [Bool]

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.keyboardType = self.keyboardType
        textField.returnKeyType = self.returnVal
        textField.tag = self.tag
        textField.delegate = context.coordinator
        textField.autocorrectionType = .no

        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if isfocusAble[tag] {
            uiView.becomeFirstResponder()
        } else {
            uiView.resignFirstResponder()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: TextFieldTyped

        init(_ textField: TextFieldTyped) {
            self.parent = textField
        }

        func updatefocus(textfield: UITextField) {
            textfield.becomeFirstResponder()
        }

func textFieldShouldReturn(_ textField: UITextField) -> Bool {

            if parent.tag == 0 {
                parent.isfocusAble = [false, true]
                parent.text = textField.text ?? ""
                NotificationCenter.default.post(name: Notification.Name("keyboardDidClose"), object: nil, userInfo: ["tag": 0])
            } else if parent.tag == 1 {
                parent.isfocusAble = [false, false]
                parent.text = textField.text ?? ""
         }
        return true
        }

    }
}
