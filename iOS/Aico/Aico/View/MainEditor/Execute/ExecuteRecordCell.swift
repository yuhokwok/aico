//
//  ExecuteRecordCell.swift
//  Aico
//
//  Created by itst on 5/5/24.
//

import SwiftUI

struct ExecuteRecordCell: View {
    var record : Record
    var thumbnail : UIImage?
    var formatter = DateFormatter()
    var body: some View {
        HStack {
            VStack (alignment: .leading) {
                HStack(alignment: .top) {
                    
                    if record.type != "system"
                    {
                        if let thumbnail = thumbnail {
                            Image(uiImage: thumbnail)
                                .resizable()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .overlay {
                                    Circle()
                                        .stroke(.white, lineWidth: 5)
                                }
                                .padding(.horizontal, 5)
                                .padding(.trailing, 10)
                        } else {
                            Circle()
                                .fill(.gray)
                                .frame(width: 60, height: 60)
                                .overlay {
                                    Circle()
                                        .stroke(.white, lineWidth: 5)
                                }
                                .padding(.horizontal, 5)
                                .padding(.trailing, 10)
                                
                        }
                    }
                    
                    VStack {
                        HStack {
                            Text("\(record.speaker)")
                                .bold()
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        
                        Spacer().frame(height: 5)
                        
                        HStack {
                            Text("\(record.content)")
                                .font(.system(size: 16))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.leading)
                                .lineLimit(20)
                            
                            Spacer()
                        }
                        
                        HStack {
                            Spacer()
                            Text("\n\(getDateString(date: record.date))")
                                .foregroundStyle(.white)
                                .font(.footnote)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: 680)
                .background {
                    if record.type == "system"
                    {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.gray.opacity(0.3))
                    } else {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.green.opacity(1.0))
                    }
                }
                
            }
            
            Spacer()
        }
        
        .padding()
    }
    
    func getDateString(date : Date) -> String {
        var formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    ExecuteRecordCell(record: Record(id: "1", speaker: "Yoyo", date: Date(), content: "我和你是好朋友", type: "user"))
}
