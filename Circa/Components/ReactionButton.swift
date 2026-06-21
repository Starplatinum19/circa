import SwiftUI

struct ReactionButton: View {
    let emoji: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(emoji)
                    .font(.system(size: 20))
                    .scaleEffect(isSelected ? 1.3 : 1.0)
                    .animation(.spring(), value: isSelected)
                Text("\(count)")
                    .font(.subheadline)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSelected ? Color.accentColor.opacity(0.25) : Color.white.opacity(0.15))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
