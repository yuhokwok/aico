//
//  BlockColor.swift
//  Aico
//
//  Created by Yu Ho Kwok on 10/7/24.
//

import SwiftUI

enum BlockColor : String {
    case yellow = "yellow"
    case green = "green"
    case blue = "blue"
    case purple = "purple"
    case red = "red"
    case gray = "gray"
}

struct BlockColorSet {
    var handleColor : Color
    var shadowColor : Color
    var innerBorderGradient : LinearGradient
    var outterBorderGradient : LinearGradient

    static func get(_ string : String) -> BlockColorSet {
        guard let blockColor = BlockColor(rawValue: string) else {
            return .blue
        }
        
        switch(blockColor){
            
        case .yellow:
            return .yellow
        case .green:
            return .green
        case .blue:
            return .blue
        case .purple:
            return .purple
        case .red:
            return .red
        case .gray:
            return .gray
        }
    }

    
    static var yellow : BlockColorSet {
        return BlockColorSet(handleColor: Color(hex:"#FFC95F"),
                             shadowColor: Color(hex: "#FFE06C"),
                             innerBorderGradient: LinearGradient(colors: [Color(hex:"#FAFF00"), Color(hex:"#FEB97B")], startPoint: UnitPoint(x: 0.0, y: 0.0), endPoint: UnitPoint(x: 1.0, y: 1.0)),
                             outterBorderGradient: LinearGradient(colors: [Color(hex:"#FFB63D"), Color(hex:"#FFD87A")], startPoint: UnitPoint(x: 0.0, y: 0.0), endPoint: UnitPoint(x: 1.0, y: 1.0)))
    }
    
    
    static var green : BlockColorSet {
        return BlockColorSet(handleColor: Color(hex:"#65FF93"),
                             shadowColor: Color(hex: "#D4FF6F"),
                             innerBorderGradient: LinearGradient(colors: [Color(hex:"#D1FF65"), Color(hex:"#B0FFBC")], startPoint: UnitPoint(x: 0.0, y: 0.0), endPoint: UnitPoint(x: 1.0, y: 1.0)),
                             outterBorderGradient: LinearGradient(colors: [Color(hex:"#65FF93"), Color(hex:"#B0FFBC")], startPoint: UnitPoint(x: 0.0, y: 0.0), endPoint: UnitPoint(x: 1.0, y: 1.0)))
    }
    
    
    static var blue : BlockColorSet {
        return BlockColorSet(handleColor: Color(hex:"#6ED7FF"),
                             shadowColor: Color(hex: "#AFF8FF"),
                             innerBorderGradient: LinearGradient(colors: [Color(hex:"#9DF6FF"), Color(hex:"#B0DBFF")], startPoint: UnitPoint(x: 0.0, y: 0.0), endPoint: UnitPoint(x: 1.0, y: 1.0)),
                             outterBorderGradient: LinearGradient(colors: [Color(hex:"#6ED7FF"), Color(hex:"#AFE7FF")], startPoint: UnitPoint(x: 0.0, y: 0.0), endPoint: UnitPoint(x: 1.0, y: 1.0)))
    }
    
    static var purple : BlockColorSet {
        return BlockColorSet(handleColor: Color(hex:"#C692FF"),
                             shadowColor: Color(hex: "#CACDFF"),
                             innerBorderGradient: LinearGradient(colors: [Color(hex:"#9DA3FF"), Color(hex:"#FF9EED")], startPoint: UnitPoint(x: 0.0, y: 0.0), endPoint: UnitPoint(x: 1.0, y: 1.0)),
                             outterBorderGradient: LinearGradient(colors: [Color(hex:"#C692FF"), Color(hex:"#FFC1F3")], startPoint: UnitPoint(x: 0.0, y: 0.0), endPoint: UnitPoint(x: 1.0, y: 1.0)))
    }
    
    static var red : BlockColorSet {
        return BlockColorSet(handleColor: Color(hex:"#FF6565"),
                             shadowColor: Color(hex: "#FFD2D7"),
                             innerBorderGradient: LinearGradient(colors: [Color(hex:"#FFC3CA"), Color(hex:"#F83A3A")], startPoint: UnitPoint(x: 0.0, y: 0.0), endPoint: UnitPoint(x: 1.0, y: 1.0)),
                             outterBorderGradient: LinearGradient(colors: [Color(hex:"#FF6464"), Color(hex:"#FFB1B1")], startPoint: UnitPoint(x: 0.0, y: 0.0), endPoint: UnitPoint(x: 1.0, y: 1.0)))
    }
    
    static var gray : BlockColorSet {
        return BlockColorSet(handleColor: Color(hex:"#B2B2B2"),
                             shadowColor: Color(hex: "#C1C1C1"),
                             innerBorderGradient: LinearGradient(colors: [Color(hex:"#DADADA"), Color(hex:"#4F4F4F")], startPoint: UnitPoint(x: 0.0, y: 0.0), endPoint: UnitPoint(x: 1.0, y: 1.0)),
                             outterBorderGradient: LinearGradient(colors: [Color(hex:"#B2B2B2"), Color(hex:"#DBDBDB")], startPoint: UnitPoint(x: 0.0, y: 0.0), endPoint: UnitPoint(x: 1.0, y: 1.0)))
    }
}
