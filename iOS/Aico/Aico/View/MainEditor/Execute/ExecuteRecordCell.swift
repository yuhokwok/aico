//
//  ExecuteRecordCell.swift
//  Aico
//
//  Created by Yu Ho Kwok on 5/5/24.
//

import SwiftUI

struct ExecuteRecordCell: View {
    var record : Record
    var body: some View {
        HStack {
            VStack (alignment: .leading) {
                VStack {
                    HStack {
                        Text("\(record.content)")
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                            .lineLimit(5)
                        
                        Spacer()
                    }
                    Text("\n\(record.date)")
                        .foregroundStyle(.white)
                        .font(.footnote)
                }
                .padding()
                .frame(maxWidth: 250)
                .background {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.green)
                }
                Text("\(record.speaker)")
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ExecuteRecordCell(record: Record(id: "1", speaker: "Yoyo", date: Date(), content: "我和你是好朋友"))
}
