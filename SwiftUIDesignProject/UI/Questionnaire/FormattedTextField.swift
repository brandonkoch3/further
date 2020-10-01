//
//  FormattedTextField.swift
//  Futher
//
//  Created by Brandon on 9/23/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import SwiftUI

struct FormattedTextField: UIViewRepresentable {
    
    // MARK: Text
    @Binding var text: String
    var placeholder: String
    
    // MARK: Appearance
    var type: String
    @Binding var isValid: Bool
    @Binding var isInValidationMode: Bool
    @Environment(\.colorScheme) var colorScheme
    
    // MARK: Responder
    @Binding var isFirstResponder: Bool
    @Binding var activeTag: Int
    var tag: Int
    
    func makeUIView(context: UIViewRepresentableContext<FormattedTextField>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.delegate = context.coordinator
        textField.textAlignment = .left
        textField.keyboardType = context.coordinator.keyboardType()
        textField.textContentType = context.coordinator.contentType()
        textField.font = UIFont(name: "Rubik-Light", size: 15.5)
        textField.tag = tag
        textField.textColor = colorScheme == .light ? .black : .white
        
        let attributes = [
            NSAttributedString.Key.font : UIFont(name: "Rubik-Light", size: 15.5)!
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<FormattedTextField>) {
        uiView.textColor = isValid ? (colorScheme == .light ? .black : .white) : (isInValidationMode ? .red : colorScheme == .light ? .black : .white)
        uiView.text = text
        if self.activeTag == 99 && context.coordinator.didBecomeFirstResponder {
            uiView.resignFirstResponder()
            context.coordinator.didBecomeFirstResponder = false
        }
        if self.tag == activeTag && !context.coordinator.didBecomeFirstResponder {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        var type: String
        var didBecomeFirstResponder = false
        var tag: Int
        @Binding var activeTag: Int
        
        // MARK: Autofill
        private var fieldPossibleAutofillReplacementAt: Date?
        private var fieldPossibleAutofillReplacementRange: NSRange?
        
        init(text: Binding<String>, type: String, tag: Int, activeTag: Binding<Int>) {
            _text = text
            self.type = type
            self.tag = tag
            _activeTag = activeTag
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            self.didBecomeFirstResponder = true
            if self.type == "phone" {
                if let enteredText = textField.text {
                    if enteredText.applyPatternOnNumbers(pattern: "(###) ###-####", replacmentCharacter: "#").count == 14 {
                        textField.keyboardType = .namePhonePad
                    }
                }
            }
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            guard let enteredText = textField.text else { return }
            if type == "phone" {
                text = enteredText.applyPatternOnNumbers(pattern: "(###) ###-####", replacmentCharacter: "#")
                return
            }
            text = enteredText
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.moveField()
            if self.activeTag == 6 {
                self.didBecomeFirstResponder = false
                textField.resignFirstResponder()
            }
            return true
        }
        
        private func moveField() {
            self.didBecomeFirstResponder = false
            if self.activeTag == self.tag {
                self.activeTag += 1
            } else {
                self.activeTag = self.tag + 1
            }
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if string == " " || string == "" {
                self.fieldPossibleAutofillReplacementRange = range
                self.fieldPossibleAutofillReplacementAt = Date()
            } else {
                if fieldPossibleAutofillReplacementRange == range, let replacedAt = self.fieldPossibleAutofillReplacementAt, Date().timeIntervalSince(replacedAt) < 0.1 {
                    if textField.text?.last == " " {
                        text = String(text.dropLast())
                    }
                    self.moveField()
                    return true
                }
                self.fieldPossibleAutofillReplacementRange = nil
                self.fieldPossibleAutofillReplacementAt = nil
            }
            
            
            if type == "phone" {
                guard let enteredText = textField.text else { return true }
                if enteredText.applyPatternOnNumbers(pattern: "(###) ###-####", replacmentCharacter: "#").count == 13 {
                    self.moveField()
                    return true
                }
                if enteredText.count > 14 {
                    return false
                }
            }
            return true
        }
        
        public func keyboardType() -> UIKeyboardType {
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
        
        public func contentType() -> UITextContentType {
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

    func makeCoordinator() -> FormattedTextField.Coordinator {
        return Coordinator(text: $text, type: type, tag: tag, activeTag: $activeTag)
    }
}
