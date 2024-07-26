import SwiftUI

struct DottedGrid: View {
    let rows: Int
    let columns: Int
    let dotSize: CGFloat = 3
    let spacing: CGFloat = 27
    
    var body: some View {
        VStack(spacing: spacing) {
            ForEach(0..<rows, id: \.self) { _ in
                HStack(spacing: spacing) {
                    ForEach(0..<columns, id: \.self) { _ in
                        Circle()
                            .fill(.white.opacity(0.5))
                            .frame(width: dotSize, height: dotSize)
                    }
                }
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        DottedGrid(rows: 10, columns: 10)
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
