//
//  Extensions.swift
//  SwiftUIDesignProject
//
//  Created by Brandon on 3/24/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import UIKit
import SwiftUI
import Combine
import UIKit

extension UIColor {
    public class var lairDarkGray: UIColor {
        UIColor(red: 0.192, green: 0.212, blue: 0.329, alpha: 1.0)
    }
}

extension Color {
    public static var lairDarkGray: Color {
        Color(.lairDarkGray)
    }
    static let offWhite = Color(red: 225 / 255, green: 225 / 255, blue: 235 / 255)
    static let darkStart = Color(red: 50 / 255, green: 60 / 255, blue: 65 / 255)
    static let darkEnd = Color(red: 25 / 255, green: 25 / 255, blue: 30 / 255)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension LinearGradient {
    init(_ colors: Color...) {
        self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

extension Animation {
    func `repeat`(while expression: Bool, autoreverses: Bool = true) -> Animation {
        if expression {
            return self.repeatForever(autoreverses: autoreverses)
        } else {
            return self
        }
    }
}

extension View {
  func inverseMask<Mask>(_ mask: Mask) -> some View where Mask: View {
    self.mask(mask
      .foregroundColor(.black)
      .background(Color.white)
      .compositingGroup()
      .luminanceToAlpha()
    )
  }
}

extension Date {
    func checkDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let strDate = dateFormatter.string(from: Date())
        let desiredDate = "\(strDate) 19:00"
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let desired = dateFormatter.date(from: desiredDate)
        return desired
    }
    
    func yesterdayCheckDate() -> Date? {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let strDate = dateFormatter.string(from: yesterday!)
        let desiredDate = "\(strDate) 19:00"
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let desired = dateFormatter.date(from: desiredDate)
        guard let yesterdayDate = desired else { return nil }
        return yesterdayDate
    }
    
    func yesterdayAsString() -> String {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let strDate = dateFormatter.string(from: yesterday!)
        return strDate
    }
}

extension CGFloat {
    var native: CGFloat {
        get {
            #if targetEnvironment(macCatalyst)
            return self
            #else
            return self * 1.0/0.77
            #endif
        }
    }
    
    var scaledForDevice: CGFloat {
        get {
            #if !os(watchOS)
            let screenSize = UIScreen.main.bounds
            var baseLine = CGFloat(414.0)
            if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
                baseLine = baseLine * 2.1642512077
            }
            if screenSize.width < baseLine {
                let scale = screenSize.width / baseLine
                return self * scale
            }
            return self
            #else
            return self
            #endif
        }
    }
}

#if !os(watchOS)
extension Publishers {
    // 1.
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        // 2.
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        // 3.
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}
#endif

// MARK: Formatting
extension String {
    func applyPatternOnNumbers(pattern: String, replacmentCharacter: Character) -> String {
        var pureNumber = self.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else { return pureNumber }
            let stringIndex = String.Index(utf16Offset: index, in: pureNumber)
            //let stringIndex = String.Index(encodedOffset: index)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacmentCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        if pureNumber.count > pattern.count {
            let index = pureNumber.index(pureNumber.startIndex, offsetBy: pattern.count)
            let pure = pureNumber[..<index]
            return String(pure)
        }
        return pureNumber
    }
}

// MARK: Data Validation
extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    func isValidPhone() -> Bool {
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: self)
    }
}

