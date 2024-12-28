//
//  StageGraphInspector.swift
//  Aico
//
//  Created by itst on 18/10/2023.
//

import SwiftUI
import WrappingHStack
import UIKit



struct StageGraphInspector: View, BaseInspector {

    @FocusState private var focusState : Int?
    
    @Binding var editorState : EditorState
    
    //@Binding var stage : StageGraph
    
    @State var identifier : String = ""
    @State var name : String
    @State var description : String = ""
    @State var attrStr : String = ""
    @State var attribute : Attribute
    
    @ObservedObject var handler : DocumentHandler
    
    var showDelete : Bool
    
    //undo redo
    var isUndoEnabled: Bool = false
    
    var body: some View {
        ScrollView {
            VStack (alignment: .leading) {
                
                
                InspectorTitle("Stage")
                
                VStack(alignment: .leading) {
                    InspectorSectionTitle("Name")
                    
                    HStack {
                        TextField("", text: $name, prompt: Text("Name of the Task"))
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 12, weight: .semibold))
                            .onSubmit(of: .text) {
                                updateName()
                            }
                            .focused($focusState, equals: 1)

                    }
                    
                    InspectorSectionTitle("Short Description")
                    
                    HStack {
                        TextField("", text: $description, prompt: Text("Short Description of this Task"))
                            .textFieldStyle(.roundedBorder)
                            .font(.system(size: 12, weight: .semibold))
                            .onSubmit(of: .text) {
                                updateDescription()
                            }
                            .focused($focusState, equals: 2)

                    }
                }


                VStack(alignment: .leading) {
                    InspectorSectionTitle("Instructions")
                    
                    
                    ZStack(alignment: .top) {
                        if attribute.contents.count == 0  {
                            HStack {
                                Spacer()
                                Text("No Task Instruction")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.gray)
                                Spacer()
                            }
                            .frame(minHeight: 150)
                            .zIndex(0)
                        } else {
                            WrappingHStack (alignment: .topLeading) {
                                ForEach(0..<attribute.contents.count, id:\.self) {
                                    i in
                                    
                                    HStack {
                                        Text(attribute.contents[i].content)
                                            .lineLimit(10)
                                            .padding([.leading, .trailing], 8)
                                            .font(.footnote)
                                        Button(action: {
                                            
                                            deleteTag(i)
                                            
                                        }, label: {
                                            Image(systemName: "xmark")
                                                .font(.footnote)
                                        })
                                        .padding(2)
                                        .background {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(.white.opacity(0.2))
                                        }
                                        .padding([.leading, .trailing], 2)
                                    }
                                    .background {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(UIColor.generateColor(from: attribute.contents[i].content).color)
                                    }
                                    .transition(.scale)
                                }
                            }.padding(10)
                            .zIndex(1)
                        }
                    }
                    
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.gray.opacity(0.1))
                    }
                }

                VStack(alignment: .leading) {
                                        
                    TextEditor(text: $attrStr)
                        .font(.system(size: 12))
                        .onSubmit(of: .text) {
                            self.addTag()
                        }
                        .focused($focusState, equals: 3)
                        .frame(height: 80)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.gray, lineWidth: 1)
                                .fill(.clear)
                                
                        }
                        .padding(2)
                    
                    Button(action: {
                        self.addTag()
                    }, label: {
                        HStack {
                            Spacer()
                            Text("Add Task")
                            Spacer()
                        }
                    }).buttonStyle(.borderedProminent)
                }
                


                if showDelete {
                    HStack {
                        
//                        Button(action: {}, label: {
//                            HStack {
//                                Spacer()
//                                Image(systemName: "doc.on.doc")
//                                Spacer()
//                            }
//                            
//                        })
//                        .buttonStyle(.bordered)
//                        
                        Button(action: {
                            self.delete()
                        }, label: {
                            Spacer()
                            Image(systemName: "trash")
                            Spacer()
                        })
                        .buttonStyle(.bordered)
                        
                    }
                }
                
                Text("\(identifier)")
                    .font(.system(size: 6))
                
            }
            .onChange(of: focusState, {
                updateName()
            })
            .onChange(of: editorState, initial: true, {
                print("changed")
                
                if let id = editorState.selectedStageId, let stageGraph = handler.graph(for: id) as? StageGraph {
                    self.identifier = stageGraph.identifier
                    self.name = stageGraph.name
                    self.description = stageGraph.description
                    self.attribute = stageGraph.attribute
                }
            })

        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
    }

    
    func updateName(){
        commitChange()
    }
    
    func updateDescription()  {
        commitChange()
    }

    
    func addTag() {
        if attrStr.isEmpty == false {
            withAnimation {
                let t = attrStr
                attribute.contents.append(AttributeEntry(id: UUID().uuidString,
                                                         content: t))
                attrStr = ""
                
                commitChange()
            }
        }
    }
    
    func delete() {
        handler.deleteEntity(with: identifier)
    }
    
    func deleteTag(_ index : Int){
        withAnimation {
            _ = attribute.contents.remove(at: index)
            commitChange()
        }
    }
    
    @MainActor
    func commitChange(){
        if let id = editorState.selectedStageId, var stageGraph = handler.graph(for: id) as? StageGraph {
            stageGraph.attribute = self.attribute
            stageGraph.name = self.name
            stageGraph.description = self.description
            
            //handler.updateGraph(stageGraph, for: stageGraph.identifier)
            handler.commit(stageGraph, withId: stageGraph.identifier)
        }
    }
}

#Preview {
    StageGraphInspector(editorState: .constant(EditorState(mode: .stage)),
                        name: "",
                        attrStr: "",
                        attribute: Attribute(id: UUID().uuidString, contents: []),
                        handler: DocumentHandler(document: nil), showDelete: true)
        .frame(width: 250)
}


extension UIColor {
    //from colors: [UIColor],
    static func selectColor(basedOn string: String) -> UIColor {
        
        let colors: [UIColor] = [.red, .orange, .yellow, .green, .blue, .purple, .brown, .magenta, .gray, .black]
        
        // Get unicode scalar values
        let unicodeScalars = string.unicodeScalars.map { $0.value }
        
        // Calculate sum of unicode scalar values
        let unicodeSum = unicodeScalars.reduce(0, +)
        
        // Select color based on unicode sum
        let colorIndex = Int(unicodeSum) % colors.count
        
        return colors[colorIndex]
    }
    
    static func selectSwiftUIColor(basedOn string: String) -> Color {
        
        let colors: [UIColor] = [.red, .orange, .yellow, .green, .blue, .purple, .brown, .magenta, .gray, .black]
        
        // Get unicode scalar values
        let unicodeScalars = string.unicodeScalars.map { $0.value }
        
        // Calculate sum of unicode scalar values
        let unicodeSum = unicodeScalars.reduce(0, +)
        
        // Select color based on unicode sum
        let colorIndex = Int(unicodeSum) % colors.count
        
        return Color(uiColor: colors[colorIndex])
    }
    
    static func generateColor(from string: String) -> UIColor {
        // Get unicode scalar values
        let unicodeScalars = string.unicodeScalars.map { $0.value }
        
        // Calculate sum of unicode scalar values
        let unicodeSum = unicodeScalars.reduce(0, +)
        
        // Create "random" RGB values based on unicode sum
        let red = CGFloat(unicodeSum % 256) / 255.0
        let green = CGFloat((unicodeSum * 2) % 256) / 255.0
        let blue = CGFloat((unicodeSum * 3) % 256) / 255.0

        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    var color : Color {
        return Color(uiColor: self)
    }
}


