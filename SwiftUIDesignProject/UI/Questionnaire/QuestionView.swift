//
//  QuestionView.swift
//  SwiftUIDesignProject
//
//  Created by Brandon Koch on 3/31/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import SwiftUI
import Combine
import UIKit

struct QuestionView: View {
    
    // UI
    @Binding var showingQuestionSheet: Bool
    @State private var showingQuestion = false
    
    // MARK: Helpers
    @EnvironmentObject var personController: PersonInfoController
    
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: Sharing
    @Binding var isSharingData: Bool
    
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
                            VStack {
                                InformationView(sectionImage: Image("\(colorScheme == .light ? "light" : "dark")_hand_icon"), headerTitle: "Name", subTitle: "Your Name", showingQuestionSheet: $showingQuestionSheet, isSharingData: $isSharingData)
                                Spacer()
                            }
                                .padding(.top, 25.0)
                                .padding([.leading, .trailing], 15.0)
                        }
                    }
                }
            }
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
            QuestionView(showingQuestionSheet: .constant(true), isSharingData: .constant(false))
                .previewDevice("iPhone SE (2nd generation)")
                .environment(\.colorScheme, .dark)
                .environmentObject(PersonInfoController())
            
            QuestionView(showingQuestionSheet: .constant(true), isSharingData: .constant(false))
                .previewDevice("iPhone 11 Pro Max")
            .environment(\.colorScheme, .light)
            .environmentObject(PersonInfoController())
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
    
    @EnvironmentObject var personController: PersonInfoController
    @EnvironmentObject var environmentSettings: EnvironmentSettings
    
    @State private var showList = false
    
    // MARK: Animation
    @Namespace private var animation
    
    // MARK: Text
    @State private var activeTag = 0
    
    // MARK: Selection
    @State private var didSelect = false
    
    // MARK: Validation
    @State private var isValidating = false
    @State private var submitted = false
    @State private var submitText = "Share Securely"
    
    // MARK: Navigation
    @Binding var showingQuestionSheet: Bool
    
    // MARK: Sharing
    @Binding var isSharingData: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20.0) {
                
                if !showList {
                    Group {
                        EntryField(geometry: geometry, sectionImage: self.sectionImage, keyboardType: "name", headerText: "Name", subtitle: "First Last", fieldBinding: $personController.personInfo.name, tag: 0, activeTag: $activeTag, isValid: $personController.validName, isInValidationMode: $isValidating, isSharingData: $isSharingData)
                        
                        EntryField(geometry: geometry, sectionImage: self.sectionImage, keyboardType: "phone", headerText: "Phone Number", subtitle: "A number you'll answer", fieldBinding: $personController.personInfo.phone, tag: 1, activeTag: $activeTag, isValid: $personController.validPhone, isInValidationMode: $isValidating, isSharingData: $isSharingData)
                        
                        EntryField(geometry: geometry, sectionImage: self.sectionImage, keyboardType: "email", headerText: "E-mail", subtitle: "An e-mail you check", fieldBinding: $personController.personInfo.email, tag: 2, activeTag: $activeTag, isValid: $personController.validEmail, isInValidationMode: $isValidating, isSharingData: $isSharingData)
                    }
                }
                
                // Address Field
                ZStack {
                    RectView(geometry: geometry)

                    HStack {
                        self.sectionImage
                        VStack(alignment: .leading, spacing: 5.0) {
                            Text("Local Address")
                                .font(Font.custom("Rubik-Medium", size: 23.3))
                            HStack {
                                
                                FormattedTextField(text: $personController.personInfo.address, placeholder: "Address", type: "address", isValid: $personController.validAddress, isInValidationMode: $isValidating, isFirstResponder: .constant(false), activeTag: $activeTag, tag: 3)
                                    .frame(height: 25.0)
                                    .animation(Animation.easeInOut)
                                    .onChange(of: personController.personInfo.address) { value in
                                        if didSelect {
                                            showList = false
                                            self.didSelect = false
                                        } else {
                                            showList = true
                                        }
                                    }
                                
                                if !showList {
                                    Spacer()
                                    FormattedTextField(text: $personController.personInfo.unit, placeholder: "Apt/Suite", type: "unit", isValid: .constant(true), isInValidationMode: $isValidating, isFirstResponder: .constant(false), activeTag: $activeTag, tag: 4)
                                    .frame(height: 25.0)
                                    .frame(width: 75.0)
                                    .padding([.trailing], 12.0)
                                }
                            }
                            
                            FormattedTextField(text: $personController.personInfo.addressZip, placeholder: "Zip", type: "locale", isValid: $personController.validAddress, isInValidationMode: $isValidating, isFirstResponder: .constant(false), activeTag: $activeTag, tag: 5)
                                .frame(height: 25.0)

                        }
                        Spacer()
                    }
                }

                // Search List
                if showList {
                    SearchView(showList: $showList, activeTag: $activeTag, didSelect: $didSelect)
                }

                Spacer()

                Button(action: {
                    self.isValidating = true
                    self.activeTag = 99
                    if self.personController.validate() {
                        self.submitText = "Sharing..."
                        self.personController.test() { response in
                            self.submitted = response
                            if response {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                    self.environmentSettings.didShareDataSuccessfully = response
                                    self.showingQuestionSheet.toggle()
                                }
                            }
                        }
                    }
                }, label: {
                    if submitted {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 50, height: 50)
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                                .font(.system(size: 18.0))
                        }
                        .animation(.easeInOut)
                        .matchedGeometryEffect(id: "complete", in: animation)
                        
                    } else {
                        Text(isSharingData ? submitText : "Save")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50.0)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(40)
                            .padding()
                            .matchedGeometryEffect(id: "complete", in: animation)
                    }
                })
            }
        }
    }
}

struct TextFieldConfigured: ViewModifier {
    var type: String
    
    func body(content: Content) -> some View {
        content
            .font(Font.custom("Rubik-Light", size: 15.5))
            .keyboardType(keyboardType())
            .textContentType(contentType())
    }
    
    private func keyboardType() -> UIKeyboardType {
        switch type {
        case "name":
            return .namePhonePad
        case "phone":
            return .phonePad
        case "email":
            return .emailAddress
        case "address":
            return .numbersAndPunctuation
        case "unit":
            return .numbersAndPunctuation
        default:
            return .default
        }
    }
    
    private func contentType() -> UITextContentType {
        switch type {
        case "name":
            return .name
        case "phone":
            return .telephoneNumber
        case "email":
            return .emailAddress
        case "address":
            return .streetAddressLine1
        case "unit":
            return .streetAddressLine2
        case "locale":
            return .postalCode
        default:
            return .name
        }
    }
}
extension View {
    func keyboardConfigured(for type: String) -> some View {
        self.modifier(TextFieldConfigured(type: type))
    }
}

struct SearchView: View {
    
    @EnvironmentObject var personController: PersonInfoController
    @Environment(\.colorScheme) var colorScheme
    @Binding var showList: Bool
    @Binding var activeTag: Int
    @Binding var didSelect: Bool
    
    var body: some View {
        ScrollView(showsIndicators: true) {
            VStack(alignment: .leading, spacing: 8.0) {
                ForEach(personController.mapHelper.results) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.title)
                            Text(item.subtitle)
                                .foregroundColor(.gray)
                                .font(.system(size: 9.0))
                        }.onTapGesture {
                            personController.mapHelper.itemSelected(selection: item)
                            self.activeTag = 7
                            self.showList = false
                            self.didSelect = true
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}

struct RectView: View {
    var geometry: GeometryProxy
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(colorScheme == .light ? Color.offWhite : Color(hex: "25282d"))
            .frame(width: geometry.size.width, height: geometry.size.height * 0.16)
            .shadow(color: colorScheme == .light ? Color("LightShadow") : Color(hex: "505050"), radius: colorScheme == .light ? 8 : 0.5, x: colorScheme == .light ? -8 : -1, y: colorScheme == .light ? -8 : -1)
            .shadow(color: colorScheme == .light ? Color("DarkShadow") : .black, radius: 8, x: colorScheme == .light ? 8 : -1, y: colorScheme == .light ? 8 : 1)
    }
}

struct EntryField: View {
    
    // MARK: Helpers
    var geometry: GeometryProxy
    var sectionImage: Image
    var keyboardType: String
    
    // MARK: Environment
    @EnvironmentObject var personController: PersonInfoController
    
    // MARK: Config
    var headerText: String
    var subtitle: String
    @Binding var fieldBinding: String
    var tag: Int
    @State private var isResponder = false
    @Binding var activeTag: Int
    @Binding var isValid: Bool
    @Binding var isInValidationMode: Bool
    @Binding var isSharingData: Bool
    
    var body: some View {
        ZStack {
            RectView(geometry: geometry)
            
            HStack {
                self.sectionImage
                VStack(alignment: .leading, spacing: 5.0) {
                    Text(headerText)
                        .font(Font.custom("Rubik-Medium", size: 23.3))
                    FormattedTextField(text: $fieldBinding, placeholder: subtitle, type: keyboardType, isValid: $isValid, isInValidationMode: $isInValidationMode, isFirstResponder: $isResponder, activeTag: $activeTag, tag: tag)
                        .frame(height: 25.0)
                }
                Spacer()
            }
        }
    }
}
