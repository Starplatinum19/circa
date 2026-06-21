import SwiftUI

struct MascotView: View {
    @ObservedObject var viewModel: MascotViewModel
    @State private var isBlinking: Bool = false
    @State private var isBreathing: Bool = true
    @State private var gazeOffset: CGFloat = 0
    
    let blinkTimer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    let breathingTimer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    let gazeTimer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    
    // Default smaller size
    var size: CGFloat = 64
    var lineWidth: CGFloat = 4
    
    var body: some View {
        GeometryReader { geo in
            let actualSize = min(geo.size.width, geo.size.height)
            let centerX = actualSize / 2
            let centerY = actualSize / 2
            ZStack {
                // Face with solid gradient + subtle outline
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#4A90E2"), Color(hex: "#50E3C2")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.6), lineWidth: 2)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                    .frame(width: actualSize, height: actualSize)
                
                // Minimal cheeks
                HStack(spacing: actualSize * 0.45) {
                    Circle()
                        .fill(Color.red.opacity(0.15))
                        .frame(width: actualSize * 0.10, height: actualSize * 0.10)
                    Circle()
                        .fill(Color.red.opacity(0.15))
                        .frame(width: actualSize * 0.10, height: actualSize * 0.10)
                }
                .position(x: centerX, y: centerY + actualSize * 0.05)
                
                // Eyes
                HStack(spacing: actualSize * 0.18) {
                    eyeView(size: actualSize)
                    eyeView(size: actualSize)
                }
                .position(x: centerX + gazeOffset, y: centerY - actualSize * 0.18)
                
                // Mouth
                mouthView(size: actualSize, centerX: centerX, centerY: centerY)
            }
            .scaleEffect(viewModel.shouldAnimate ? 1.05 : 1.0)
            .animation(.spring(response: 0.5, dampingFraction: 0.9), value: viewModel.shouldAnimate)
            .animation(.easeInOut(duration: 1.5), value: isBreathing)
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(width: size, height: size)
        .onReceive(blinkTimer) { _ in
            withAnimation(.easeInOut(duration: 0.15)) { isBlinking = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                withAnimation(.easeInOut(duration: 0.15)) { isBlinking = false }
            }
        }
        .onReceive(breathingTimer) { _ in
            isBreathing.toggle()
        }
        .onReceive(gazeTimer) { _ in
            withAnimation(.easeInOut(duration: 1.0)) {
                gazeOffset = CGFloat.random(in: -4...4)
            }
        }
    }
    
    // MARK: - Eye and Mouth
    private func eyeView(size: CGFloat) -> some View {
        Ellipse()
            .fill(Color.black)
            .frame(width: size * 0.12, height: isBlinking ? size * 0.025 : size * 0.08)
            .animation(.easeInOut(duration: 0.15), value: isBlinking)
    }
    
    private func mouthView(size: CGFloat, centerX: CGFloat, centerY: CGFloat) -> some View {
        Path { path in
            let mouthWidth = size * 0.38
            let mouthY = centerY + size * 0.16
            let start = CGPoint(x: centerX - mouthWidth/2, y: mouthY)
            let end = CGPoint(x: centerX + mouthWidth/2, y: mouthY)
            switch viewModel.currentMood {
            case .encouraging, .supportive, .celebrating, .excited, .proud:
                let mouthHeight = size * 0.12
                path.move(to: start)
                path.addQuadCurve(to: end, control: CGPoint(x: centerX, y: mouthY + mouthHeight))
            case .calming, .thoughtful:
                path.move(to: start)
                path.addLine(to: end)
            case .sad, .disappointed:
                let mouthHeight = size * 0.08
                path.move(to: start)
                path.addQuadCurve(to: end, control: CGPoint(x: centerX, y: mouthY - mouthHeight))
            case .surprised:
                let mouthRadius = size * 0.07
                path.addEllipse(in: CGRect(x: centerX - mouthRadius, y: mouthY, width: mouthRadius * 2, height: mouthRadius * 2))
            }
        }
        .stroke(Color.black, lineWidth: size * 0.035)
    }
}

// Helper for hex colors
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    let viewModel = MascotViewModel()
    viewModel.currentMood = .celebrating
    return MascotView(viewModel: viewModel, size: 64)
        .padding()
        .background(Color(.systemBackground))
}
