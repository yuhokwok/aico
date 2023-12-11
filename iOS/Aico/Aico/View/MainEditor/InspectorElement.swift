//
//  InspectorElement.swift
//  Aico
//
//  Created by Yu Ho Kwok on 12/9/23.
//

import Foundation
import SwiftUI

struct InspectorTitle : View {
    var text : String
    init(_ text : String) { self.text = text }
    var body : some View {
        HStack {
            Text("\(text)")
                .font(.system(size: 28, weight: .bold))
                .padding([.top, .bottom], 10)
            Spacer()
        }
    }
}

struct InspectorSectionTitle : View {
    var text : String
    init(_ text : String) { self.text = text }
    var body : some View {
        Text("\(text)")
            .foregroundStyle(.black.opacity(1.0))
            .lineLimit(99)
            .font(.system(size: 14, weight: .semibold))
            .padding([.top, .bottom], 5)
    }
}

struct InspectorSectionFooter : View {
    var text : String
    init(_ text : String) { self.text = text }
    var body : some View {
        Text("\(text)")
            .foregroundStyle(.black.opacity(0.8))
            .lineLimit(99)
            .font(.system(size: 12))
            .padding(5)
    }
}
