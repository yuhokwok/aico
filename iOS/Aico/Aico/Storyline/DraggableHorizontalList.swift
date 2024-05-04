//
//  DraggableHoriztonalList.swift
//  Aico
//
//  Created by Yu Ho Kwok on 5/1/24.
//

import SwiftUI

import SwiftUI

struct DraggableHorizontalList: View {
    @State private var items: [Note] = [
        Note(title: "yoyo0", body: "yoyo0"),
        Note(title: "yoyo1", body: "yoyo1"),
        Note(title: "yoyo2", body: "yoyo2"),
        Note(title: "yoyo3", body: "yoyo3"),
        Note(title: "yoyo4", body: "yoyo4")
    ]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(items) { item in
                    Text(item.title)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(5)
                        .foregroundColor(.white)
                        .draggable(item)
//                        .onDrag {
//                            NSItemProvider(object: String(item.id.uuidString) as NSString)
//                        }
//                        .onDrop(of: [.text], delegate: DropViewDelegate(item: item, items: $items))
                        
                }
            }
        }
    }
}
#Preview {
    DraggableHorizontalList()
}
