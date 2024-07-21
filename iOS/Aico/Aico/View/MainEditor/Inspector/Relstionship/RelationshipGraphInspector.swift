//
//  RelationshipGraphInspector.swift
//  Aico
//
//  Created by itst on 12/9/23.
//

import SwiftUI

struct RelationshipGraphInspector: View {
    var body: some View {
        ScrollView {
            VStack (alignment: .leading) {
                InspectorTitle("Relationship")
                
                HStack {
                    Spacer()
                    Text("No Setting for Relationship")
                        .font(.system(size: 12))
                        .foregroundStyle(.gray)
                    Spacer()
                }
                .frame(minHeight: 150)
                .zIndex(0)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.gray.opacity(0.1))
                }
                
//                Text("Relationship Graph 喺用嚟定義所有 AI 的人物角色的，仲可以設定佢地之間的關喺，例如宜家家私的公仔嘅上下弦的關喺之類。越複雜的人物關係，可能會有意想不到的效果")
//                    .font(.system(size: 14))
//                
//                Rectangle()
//                    .fill(.gray)
//                    .frame(height: 0.5)
//                    .padding([.top, .bottom])
//                    
//                
//                InspectorSectionTitle("角色")
//                
//                Text("Relationship Graph 喺用嚟定義所有 AI 的人物角色的，仲可以設定佢地之間的關喺，例如宜家家私的公仔嘅上下弦的關喺之類。越複雜的人物關係，可能會有意想不到的效果 \n\n Relationship Graph 喺用嚟定義所有 AI 的人物角色的，仲可以設定佢地之間的關喺，例如宜家家私的公仔嘅上下弦的關喺之類。越複雜的人物關係，可能會有意想不到的效果")
//                    .font(.system(size: 14))
//                
//                Rectangle()
//                    .fill(.gray)
//                    .frame(height: 0.5)
//                    .padding([.top, .bottom])
//                
//                InspectorSectionTitle("關係")
//                
//                Text("Relationship Graph 喺用嚟定義所有 AI 的人物角色的，仲可以設定佢地之間的關喺，例如宜家家私的公仔嘅上下弦的關喺之類。越複雜的人物關係，可能會有意想不到的效果")
//                    .font(.system(size: 14))
//                
//                Spacer()
            }
        }
    }
}

#Preview {
    RelationshipGraphInspector()
        .frame(width : 250)
}
