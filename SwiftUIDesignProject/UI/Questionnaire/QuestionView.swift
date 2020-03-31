//
//  QuestionView.swift
//  SwiftUIDesignProject
//
//  Created by Brandon Koch on 3/30/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import SwiftUI

struct QuestionView: View {
    @Binding var showingQuestionSheet: Bool
    var uuid: String
    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            self.showingQuestionSheet = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color.gray)
                                .font(.system(size: 30, weight: .regular))
                        }.padding([.all], 24.0)
                    }
                    Spacer()
                }.frame(width: geometry.size.width, height: geometry.size.height / 3)
                    .background(Color(UIColor.lightGray))
                VStack {
                    HStack {
                        Text("COVID-19 Questionnaire")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                        Spacer()
                    }.padding(.top, 18.0)
                    .padding(.leading, 8.0)
                    VStack {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                            .font(.system(size: 30, weight: .regular))
                            .foregroundColor(.blue)
                            Spacer()
                            Text("All answers are completely confidential and will not be shared with anyone.")
                        }.padding()
                        HStack {
                            Image(systemName: "location.fill")
                            .font(.system(size: 30, weight: .regular))
                            .foregroundColor(.blue)
                            Spacer()
                            Text("Your answers and a random identifier created by this device are the only pieces of data shared with this app.")
                        }.padding()
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 30, weight: .regular))
                            .foregroundColor(.blue)
                            Spacer()
                            Text("The answers you provide are not validated.  Please help others and answer honestly.")
                        }.padding()
                        Button(action: {
                            // start
                        }) {
                            Text("Answer Questions")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(12.0)
                                .padding()
                        }
                        Spacer()
                        Text("By using this app, you constitute that you are participating in the interest of helping others.  We do not take responsibility for the validity of your answers.  If you are feeling sick, please consult a medical professional.  This app does not provide medical advice or guidance and is for informative purposes only.")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding()
                            .foregroundColor(.gray)
                        
                    }
                    
                }
                Spacer()
            }
        }.edgesIgnoringSafeArea(.all)
    }
}

struct QuestionView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionView(showingQuestionSheet: .constant(true), uuid: "test")
    }
}
