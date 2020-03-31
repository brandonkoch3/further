//
//  QuestionView2.swift
//  SwiftUIDesignProject
//
//  Created by Brandon Koch on 3/31/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import SwiftUI

struct QuestionView2: View {
    var body: some View {
        
        GeometryReader { geometry in
            VStack {
                VStack {
                    VStack {
                        Text("COVID-19 Questionnaire")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .padding()
                    }
                }.frame(maxWidth: .infinity, minHeight: geometry.size.height / 3, maxHeight: geometry.size.height / 3)
                    .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "D94c7a"), Color(hex: "Fcde89")]), startPoint: .topLeading, endPoint: .trailing))
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color("Background"))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .edgesIgnoringSafeArea(.all)
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color("Background"))
                            .frame(width: geometry.size.width - 20, height: 60)
                            .shadow(color: Color("LightShadow"), radius: 8, x: -8, y: -8)
                            .shadow(color: Color("DarkShadow"), radius: 8, x: 8, y: 8)
                    }.offset(x: 0, y: -50)
                }.background(Color("Background"))
            }.edgesIgnoringSafeArea(.all)
            
        }
        
    }
}

struct QuestionView2_Previews: PreviewProvider {
    static var previews: some View {
        QuestionView2()
    }
}
