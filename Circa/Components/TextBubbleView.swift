import SwiftUI

struct TextBubbleView: View {
    let text: String
    @State private var isVisible = false
    
    var body: some View {
        if !text.isEmpty {
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .scaleEffect(isVisible ? 1.0 : 0.8)
                .opacity(isVisible ? 1.0 : 0.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isVisible)
                .onAppear {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.1)) {
                        isVisible = true
                    }
                }
                .onChange(of: text) {
                    isVisible = false
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.1)) {
                        isVisible = true
                    }
                }
        }
    }
}

#Preview {
    HStack {
        VStack {
            TextBubbleView(text: "Welcome to Circa! I'm here to help you find events that feel just right for you.")
            
            TextBubbleView(text: "Looking for the perfect event?")
            
            TextBubbleView(text: "")
        }
        Spacer()
    }
    .padding()
}
