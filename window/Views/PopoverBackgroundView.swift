import SwiftUI

struct PopoverBackgroundView: View {
    let arrowOffset: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main background with rounded corners
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(NSColor.windowBackgroundColor))
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                
                // Triangle pointer
                Triangle()
                    .fill(Color(NSColor.windowBackgroundColor))
                    .frame(width: 20, height: 10)
                    .offset(x: arrowOffset, y: -geometry.size.height / 2 + 5)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: -2)
            }
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
