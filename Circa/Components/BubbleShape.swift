import SwiftUI

/// A rounded rectangle bubble with a small tail on the left.
struct BubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = RoundedRectangle(cornerRadius: 18).path(in: rect)
        // Tail
        let tailWidth: CGFloat = 12
        let tailHeight: CGFloat = 10
        let tailStart = CGPoint(x: rect.minX, y: rect.midY + 4)
        path.move(to: tailStart)
        path.addLine(to: CGPoint(x: rect.minX - tailWidth, y: rect.midY + 8))
        path.addLine(to: CGPoint(x: rect.minX + 8, y: rect.midY + tailHeight))
        path.closeSubpath()
        return path
    }
}
