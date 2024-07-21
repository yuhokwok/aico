//
//  StorylineCell.swift
//  Aico
//
//  Created by itst on 5/4/24.
//

import SwiftUI

struct StorylineCell: View {
    
    var color : Color = Color("StorylineCellText", bundle: .main)
    let linearGradient = LinearGradient(colors: [Color("StorylineColor1", bundle:. main),
                                                 Color("StorylineColor2", bundle:. main)],
                                        startPoint: UnitPoint(x: 0, y: 0),
                                        endPoint: UnitPoint(x: 1, y: 1))
    
    var title : String = "場景一"
    var subtitle : String = "辦公室"
    
    var selected : Bool = false
    
    var body: some View {
        HStack {
            
            HStack {
                VStack (alignment: .leading) {
                    Text("\(title)")
                        .lineLimit(2)
                        .foregroundStyle(color)
                        .font(.system(size: 14))
                        .bold()
                    
                    Spacer().frame(height: 14)
                    
                    Text("\(subtitle)")
                        .lineLimit(3)
                        .foregroundStyle(color)
                        .font(.system(size: 10))
                        .bold()
                    
                    Spacer()
                }
                .padding()
                Spacer()
            }
        }
        .transition(.scale)
        .frame(width: 160, height: 106)
        .background {
            
            if selected {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.white)
                    .stroke(linearGradient.opacity(selected ? 1.0 : 0.5), lineWidth: 1)
                    .shadow(color: Color("StorylineColor1", bundle:. main).opacity(0.4), radius: 4)
            } else {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.white)
                    .stroke(linearGradient.opacity(selected ? 1.0 : 0.5), lineWidth: 1)
                    //.shadow(color: Color("StorylineColor1", bundle:. main).opacity(0.4), radius: 4)
            }
                
        }
        .padding(5)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(radius: 10)
                .opacity(0.5)
        }
    }
}

#Preview {
    StorylineCell()
}
