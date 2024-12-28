//
//  Color+Hex.swift
//  SoundScene
//
//  Created by Yu Ho Kwok on 7/7/24.
//

import SwiftUI

extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        let length = hexSanitized.count
        
        if Scanner(string: hexSanitized).scanHexInt64(&rgb) == false {
            self.init(red: 0, green: 0, blue: 0)
        } else {
            
            if length == 6 {
                let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
                let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
                let blue = CGFloat(rgb & 0x0000FF) / 255.0
                
                self.init(red: red, green: green, blue: blue)
            } else if length == 8 {
                let red = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
                let green = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
                let blue = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
                let a = CGFloat(rgb & 0x000000FF) / 255.0
                
                self.init(red: red, green: green, blue: blue, opacity: a)
                
            } else {
                self.init(red: 0, green: 0, blue: 0)
            }
        }
    }
    
    var hexString : String {
        
        let uiColor = UIColor(self)
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        let alpha = Int(a * 255)
        
        return String(format: "#%06x%02X", rgb, alpha)
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        let length = hexSanitized.count
        
        if Scanner(string: hexSanitized).scanHexInt64(&rgb) == false {
            self.init(red: 0, green: 0, blue: 0, alpha: 1)
        } else {
            
            if length == 6 {
                let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
                let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
                let blue = CGFloat(rgb & 0x0000FF) / 255.0

                self.init(red: red, green: green, blue: blue, alpha: 1.0)
            } else if length == 8 {
                let red = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
                let green = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
                let blue = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
                let a = CGFloat(rgb & 0x000000FF) / 255.0
                
                self.init(red: red, green: green, blue: blue, alpha: a)
                
            } else {
                self.init(red: 0, green: 0, blue: 0, alpha: 1.0)
            }
        }
    }
    
    var hexString : String {

        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        let alpha = Int(a * 255)
        
        return String(format: "#%06x%02X", rgb, alpha)
    }
}

