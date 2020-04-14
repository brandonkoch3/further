//
//  SimpleButtonStyle.swift
//  SwiftUIDesignProject
//
//  Created by Brandon on 3/24/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import SwiftUI

struct LightButtonStyle: ButtonStyle {
    
    private var lightMode: Bool = true
    
    init(lightMode: Bool) {
        if lightMode {
            self.lightMode = true
        } else {
            self.lightMode = false
        }
    }
    
    func makeLightBody(configuration: ButtonStyleConfiguration) -> some View {
        return configuration.label
        .padding(30)
        .contentShape(Circle())
        .background(
            LightBackground(isHighlighted: configuration.isPressed, shape: Circle())
        )
    }
    
    func makeDarkBody(configuration: ButtonStyleConfiguration) -> some View {
        return configuration.label
        .padding(30)
        .contentShape(Circle())
        .background(
            DarkBackground(isHighlighted: configuration.isPressed, shape: Circle())
        )
    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        if lightMode {
            return AnyView(makeLightBody(configuration: configuration))
        } else {
            return AnyView(makeDarkBody(configuration: configuration))
        }
    }
}

struct DarkButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(30)
            .contentShape(Circle())
            .background(
                DarkBackground(isHighlighted: configuration.isPressed, shape: Circle())
            )
    }
}

struct LightBackground<S: Shape>: View {
    var isHighlighted: Bool
    var shape: S

    var body: some View {
        ZStack {
            if isHighlighted {
                shape
                    .fill(Color.offWhite)
                    .overlay(
                        Circle()
                        .stroke(Color.gray, lineWidth: 4)
                        .blur(radius: 4)
                        .offset(x: 2, y: 2)
                        .mask(Circle().fill(LinearGradient(Color.black, Color.clear)))
                    )
                    .overlay(
                        Circle()
                        .stroke(Color.white, lineWidth: 8)
                        .blur(radius: 4)
                        .offset(x: -2, y: -2)
                        .mask(Circle().fill(LinearGradient(Color.clear, Color.black)))
                    )
            } else {
                shape
                    .fill(Color.offWhite)
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                    .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
            }
        }
    }
}

struct DarkBackground<S: Shape>: View {
    var isHighlighted: Bool
    var shape: S

    var body: some View {
        ZStack {
            if isHighlighted {
                shape
                    .fill(Color.darkEnd)
                    .shadow(color: Color.darkStart, radius: 10, x: 5, y: 5)
                    .shadow(color: Color.darkEnd, radius: 10, x: -5, y: -5)
            } else {
                shape
                    .fill(Color(hex: "25282d"))
                    .shadow(color: Color.darkStart, radius: 10, x: -10, y: -10)
                    .shadow(color: Color.darkEnd, radius: 10, x: 10, y: 10)
            }
        }
    }
}
