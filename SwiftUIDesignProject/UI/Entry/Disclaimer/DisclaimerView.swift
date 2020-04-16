//
//  DisclaimerView.swift
//  Futher
//
//  Created by Brandon on 4/15/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import SwiftUI

struct DisclaimerView: View {
    
    // UI Config
    @Environment(\.colorScheme) var colorScheme
    @Binding var agreed: Bool
    
    // Drag Gesture
    let dg = DragGesture()
    
    var body: some View {
        ScrollView {
            VStack {
                Spacer()
                Image(colorScheme == .light ? "logo-light" : "logo-dark")
                    .padding(.top, 60)
                
                Text("By using this app, you agree to the terms and conditions set forth in this message.  Further is a social distancing and contact interactions app.  By using Bluetooth technology, the app will detect other nearby users, determining the signal strength between your devices.  This calculation allows the app to generally determine if users are too close together, and notify that proper social distancing guidelines are not being followed.\n\nAdditionally, this app offers a \"contact interactions\" protocol, allowing you to participate in sharing your current symptoms with other users you have been nearby.  No personal data, including your name, location, age, gender, race, orientation, or medical history are ever asked, gathered, or stored.\n\nThis app does, however, save the following data locally to your device;\n- A random, unique identifier associated with your device(s).  If signed into an iCloud account, all devices will share the same identifier.\n- The unique identifiers of other users of this app that have been within several feet of you.\n- The answers to your questions, related to your self-reported symptoms and status of a COVID-19 test.\n\nThe following data is saved remotely on a server;\n- The random, unique identifier of your device(s).\n- The answers to the self-reported symptom and test questions, as referenced above.\n- The time in which you last updated your answers.\n\nAt any time, you can visit our website to learn how the data is transferred between your device and servers, as well as see full transparency of all data collected by this app.\n\nMost importantly, your use of this app means you agree that we are not responsible for inaccurate data, and you use this software at your own discretion.  Factors such as Bluetooth interference, device power, and environmental elements, can significantly impact the performance of social distancing calculations.  Additionally, answers to questions provided by users are not validated, and therefore, should only be used as a guide to determine best practices for your own safety and the safety of others.  We do not take responsibility for the accuracy of this data, and by using this app, you release any parties from responsibility or liability.  More information about this app, our practices, and policies, can be found on our website.")
                    .font(Font.custom("Rubik-Regular", size: 14.0))
                    .padding()
                
                Button(action: {
                    self.agreed.toggle()
                    UserDefaults.standard.set(true, forKey: "agreedToDisclaimer")
                }) {
                    Text("I Agree")
                    .fontWeight(.bold)
                    .font(.subheadline)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(40)
                    .foregroundColor(.white)
                    .padding(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(Color.blue, lineWidth: 5)
                    )
                }.padding(.bottom, 30)
            }
        }.background(colorScheme == .light ? Color.white : Color.black)
        .highPriorityGesture(dg)
        .edgesIgnoringSafeArea(.all)
    }
}

struct DisclaimerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DisclaimerView(agreed: .constant(false))
                .environmentObject(EnvironmentSettings())
                .environment(\.colorScheme, .dark)
                .previewDevice("iPhone 11 Pro Max")
            
            DisclaimerView(agreed: .constant(false))
            .environmentObject(EnvironmentSettings())
            .environment(\.colorScheme, .light)
            .previewDevice("iPhone SE")
        }
    }
}
