//
//  QRCodeGenerator.swift
//  Futher
//
//  Created by Brandon on 9/10/20.
//  Copyright © 2020 Brandon. All rights reserved.
//

import Foundation
import CoreImage.CIFilterBuiltins
import UIKit
import Combine
import EFQRCode

class QRCodeGenerator {
    
    // MARK: CoreImage Hlpers
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    let invert = CIFilter.colorInvert()
    let alpha = CIFilter.maskToAlpha()
    
    // MARK: Combine
    private let qrCompletionSender = PassthroughSubject<URL, Never>()
    public var qrCompletionPublisher: AnyPublisher<URL, Never> {
        qrCompletionSender.eraseToAnyPublisher()
    }
    
    init() {
        //
    }
    
    public func buildQRCode(appType: EnvironmentSettings.appType, uniqueID: String, baseURL: String) {
        if let codeImage = generateCoolQRCode(appType: appType, uniqueID: uniqueID, baseURL: baseURL) {
            if let lightURL = saveQRCode(image: codeImage.0, fileName: "qrcode_light.png"), let darkURL = saveQRCode(image: codeImage.1, fileName: "qrcode_dark.png") {
                _ = darkURL
                qrCompletionSender.send(lightURL)
            }
        }
    }
    
    private func generateCoolQRCode(appType: EnvironmentSettings.appType, uniqueID: String, baseURL: String) -> (UIImage, UIImage)? {
        var data = baseURL
        switch appType {
        case .user:
            data += "person"
        case .establishmentClient:
            data += "vendor"
        case .establishmentKiosk:
            data += "vendor"
        default:
            break
        }
        data += "/"
        data += uniqueID
        
        var lightUIImage: UIImage?
        var darkUIImage: UIImage?
        
        if let lightImage = EFQRCode.generate(
            content: data,
            size: EFIntSize(width: 300, height: 300),
            backgroundColor: UIColor(red: 225.0/255.0, green: 225.0/255.0, blue: 236.0/255.0, alpha: 1.0).cgColor,
            watermark: UIImage(named: "light_heart_on")?.cgImage
        ) {
            lightUIImage = UIImage(cgImage: lightImage)
            print("created light image!")
        }
        
        if let darkImage = EFQRCode.generate(
            content: data,
            size: EFIntSize(width: 300, height: 300),
            backgroundColor: UIColor(red: 36.0/255.0, green: 40.0/255.0, blue: 46.0/255.0, alpha: 1.0).cgColor,
            watermark: UIImage(named: "dark_heart_on")?.cgImage
        ) {
            darkUIImage = UIImage(cgImage: darkImage)
            print("created light image!")
        }
        
        if let light = lightUIImage, let dark = darkUIImage {
            return (light, dark)
        }
        
        return nil
    }
    
    private func generateQRCode(appType: EnvironmentSettings.appType, uniqueID: String, baseURL: String) -> UIImage? {
        var data = baseURL
        switch appType {
        case .user:
            data += "person"
        case .establishmentClient:
            data += "vendor"
        case .establishmentKiosk:
            data += "vendor"
        default:
            break
        }
        data += "/"
        data += uniqueID
        
        let qrCodeData = data.data(using: String.Encoding.utf8)
        filter.setValue(qrCodeData, forKey: "inputMessage")
        
        if let outputImage = filter.outputImage {
            
            // Scale
            let scaledQrImage = outputImage.transformed(by: CGAffineTransform(scaleX: 10, y: 10))
            
            // Invert
            invert.inputImage = scaledQrImage
            if let invertedOutput = invert.outputImage {
                
                // Alpha
                alpha.inputImage = invertedOutput
                if let alphaOutput = alpha.outputImage {
                    
                    if let cgImage = context.createCGImage(alphaOutput, from: scaledQrImage.extent) {
                        return UIImage(cgImage: cgImage)
                    }
                }
            }
        }
        
        return nil
    }
    
    private func saveQRCode(image: UIImage, fileName: String? = nil) -> URL? {
        if let data = image.pngData() {
            let filename = getDocumentsDirectory().appendingPathComponent(fileName ?? "qrcode.png")
            try? data.write(to: filename)
            print("Wrote QR Code to", filename)
            return filename
        }
        return nil
    }
    
    public func userQRCode() -> UIImage? {
        if UITraitCollection.current.userInterfaceStyle == .light {
            let filename = getDocumentsDirectory().appendingPathComponent("qrcode_light.png")
            if let png = UIImage(contentsOfFile: filename.path) {
                return png
            }
        } else {
            let filename = getDocumentsDirectory().appendingPathComponent("qrcode_dark.png")
            if let png = UIImage(contentsOfFile: filename.path) {
                return png
            }
        }
        
        let filename = getDocumentsDirectory().appendingPathComponent("qrcode.png")
        if let png = UIImage(contentsOfFile: filename.path) {
            return png
        }
        return UIImage(systemName: "plus.viewfinder")
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
