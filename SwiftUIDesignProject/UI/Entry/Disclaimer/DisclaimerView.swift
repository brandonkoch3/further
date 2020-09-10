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
                
                Text("By using this app, you agree to the terms and conditions set forth in this message.  Further is a social connections app that uses Bluetooth signals to communicate with nearby devices.  The philosophy of this product, above all else, is to take your privacy incredibly seriously.  By using this product, you recognize that the developers, our parent company, and any associated companies take no responsibility for the content and functionality of this app.  While we work to ensure an optimal experience, we take no responsbility for techincal issues that may arise or performance anomalies that could occur within the product.\n\nFurthering our commitment to privacy, we make every effort to ensure users of this app are treated with respect and anonymity.")
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
