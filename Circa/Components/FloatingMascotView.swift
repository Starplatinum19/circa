import SwiftUI

/// A floating mascot with a text bubble, suitable for overlaying in any view.
struct FloatingMascotView: View {
    var message: String
    var onMascotTap: (() -> Void)? // Add callback for mascot tap
    
    @StateObject private var mascotViewModel = MascotViewModel()
    // Persistent mascot center position using @AppStorage
    @AppStorage("mascotCenterX") private var mascotCenterX: Double = -1
    @AppStorage("mascotCenterY") private var mascotCenterY: Double = -1
    
    // Drag state
    @State private var dragOffset: CGSize = .zero
    
    let mascotSize: CGFloat = 64 + 24 // mascot + padding
    let mascotPadding: CGFloat = 16
    let mascotBottomBar: CGFloat = 90
    
    private func mascotPosition(geo: GeometryProxy) -> (minX: CGFloat, maxX: CGFloat, minY: CGFloat, maxY: CGFloat, initialX: CGFloat, initialY: CGFloat) {
        let screenWidth = geo.size.width
        let screenHeight = geo.size.height
        let initialX = screenWidth - mascotSize / 2 - mascotPadding
        let initialY = screenHeight - mascotSize / 2 - mascotBottomBar
        var minX = mascotSize / 2 + mascotPadding
        var maxX = screenWidth - mascotSize / 2 - mascotPadding
        var minY = mascotSize / 2 + mascotPadding
        var maxY = screenHeight - mascotSize / 2 - mascotBottomBar
        if minX > maxX { minX = (screenWidth / 2); maxX = minX }
        if minY > maxY { minY = (screenHeight / 2); maxY = minY }
        return (minX, maxX, minY, maxY, initialX, initialY)
    }
    
    var body: some View {
        GeometryReader { geo in
            let pos = mascotPosition(geo: geo)
            let currentX = (mascotCenterX < 0 ? pos.initialX : mascotCenterX) + dragOffset.width
            let currentY = (mascotCenterY < 0 ? pos.initialY : mascotCenterY) + dragOffset.height
            HStack(alignment: .bottom, spacing: 8) {
                MascotView(viewModel: mascotViewModel)
                    .frame(width: 64, height: 64)
                    .shadow(color: Color.black.opacity(0.10), radius: 6, x: 0, y: 3)
                    .onTapGesture {
                        onMascotTap?() // Trigger the tap callback if set
                    }
                // Text bubble
                TextBubbleView(text: message)
            }
            .padding(12)
            .background(Color.clear)
            .position(x: currentX.clamped(to: pos.minX...pos.maxX), y: currentY.clamped(to: pos.minY...pos.maxY))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        let newX = (mascotCenterX < 0 ? pos.initialX : mascotCenterX) + value.translation.width
                        let newY = (mascotCenterY < 0 ? pos.initialY : mascotCenterY) + value.translation.height
                        mascotCenterX = newX.clamped(to: pos.minX...pos.maxX)
                        mascotCenterY = newY.clamped(to: pos.minY...pos.maxY)
                        dragOffset = .zero
                    }
            )
            .onAppear {
                if mascotCenterX < 0 || mascotCenterY < 0 {
                    mascotCenterX = pos.initialX
                    mascotCenterY = pos.initialY
                }
            }
        }
    }
}

// MARK: - Preview
struct FloatingMascotView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.systemBackground)
            FloatingMascotView(message: "Welcome to Circa! Tap me for tips.")
        }
    }
}
