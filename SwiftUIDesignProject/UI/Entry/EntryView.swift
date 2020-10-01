//
//  EntryView.swift
//  SwiftUIDesignProject
//
//  Created by Brandon on 3/17/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import SwiftUI
import CoreHaptics

struct EntryView: View {
    
    // UI Config
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var environmentSettings: EnvironmentSettings

    @State private var pulsate = false
    @State var showingQuestionSheet = false
    @State var showingStorySheet = false
    @State private var agreedToDisclaimer = true
    @State private var showTypeSelection = true
    
    // Person config
    @StateObject var personController = PersonInfoController()
    
    // MARK: Sharing
    @State private var isSharingData = false
    @State private var qrVendorID = ""
    
    var body: some View {
        if environmentSettings.appType == .unknown {
            appTypeSelection()
        } else {
            mainView()
        }
    }
    
    func appTypeSelection() -> some View {
        return VStack {
            Spacer()
            Text("Choose your type")
            Spacer()
        }.actionSheet(isPresented: $showTypeSelection) {
            ActionSheet(title: Text("Who are you?"), message: Text("A person, a restaurant, or a kiosk?"), buttons: [
                .default(Text("Person"), action: {
                    environmentSettings.appType = .user
                    personController.generateQRCode() }),
                .default(Text("Establishment"), action: {
                    environmentSettings.appType = .establishmentClient
                    personController.generateQRCode() }),
                .default(Text("Establishment (Kisok)"), action: {
                    environmentSettings.appType = .establishmentKiosk
                    personController.generateQRCode()
                })
            ])
        }
    }
    
    
    func mainView() -> some View {
        return ZStack {
            EntryBackgroundView()
            VStack {
                Spacer()
                VStack {
                    VStack {
                        HeartView(image: $personController.qrCode)
                        Spacer()
                        MainTextView()
                    }.frame(maxHeight: 240)
                }
                Spacer()
                HStack {
                    QuestionButton(showingQuestionSheet: $showingQuestionSheet, isSharingData: $isSharingData)
                        .environmentObject(self.personController)
                    Spacer()
                    StoryButton(showingStorySheet: $showingStorySheet, qrVendorID: $qrVendorID)
                }
            }.padding()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct EntryView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EntryView()
                .environmentObject(EnvironmentSettings())
                .environment(\.colorScheme, .light)
                .previewDevice("iPhone 11 Pro Max")
            
            EntryView()
            .environmentObject(EnvironmentSettings())
            .environment(\.colorScheme, .dark)
                .previewDevice("iPhone SE (2nd generation)")
        }
        
    }
}

struct HeartView: View {
    
    // UI Config
    @Environment(\.colorScheme) var colorScheme
    @State private var pulsate = false
    
    // Image config
    @Binding var image: UIImage
    
    // View
    var body: some View {
        ZStack {
            Image(colorScheme == .light ? "light_heart_back" : "dark_heart_back")
            Image(colorScheme == .light ? "light_heart_middle" : "dark_heart_middle")
            Image(colorScheme == .light ? "light_heart_on" : "dark_heart_on")
            .scaleEffect(pulsate ? 0.5 : 1)
                .animation(Animation.easeInOut(duration: 1).delay(0).repeat(while: pulsate))
                .onAppear() {
                    self.pulsate.toggle()
                }
        }
    }
}

struct MainTextView: View {
    
    // UI Config
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var environmentSettings: EnvironmentSettings
    @State private var mainText = "Scan a QR code to check in"
    
    // View
    var body: some View {
        Text(mainText)
            .font(.custom("Rubik-Regular", size: CGFloat(26.67).scaledForDevice, relativeTo: .headline))
            .foregroundColor(colorScheme == .light ? Color(UIColor(red: 50.0/255.0, green: 54.0/255.0, blue: 83.0/255.0, alpha: 1.0)) : Color(UIColor(red: 172.0/255.0, green: 178.0/255.0, blue: 181.0/255.0, alpha: 1.0)))
            .fixedSize(horizontal: false, vertical: true)
            .onChange(of: environmentSettings.didShareDataSuccessfully) { change in
                if change {
                    self.mainText = "Successfully checked in!"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                        self.mainText = "Scan a QR code to check in"
                    })
                }
            }
    }
}








