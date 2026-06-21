import SwiftUI

struct MascotWelcomeView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var locationManager: LocationManager
    @StateObject private var mascotViewModel = MascotViewModel()
    
    @State private var showMascot = false
    @State private var showMessage = false
    @State private var showButton = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color("GradientTop"),
                    Color("GradientMiddle"),
                    Color("GradientBottom")
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Welcome text
                VStack(spacing: 16) {
                    Text("Meet Your Personal Guide!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .opacity(showMessage ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.8).delay(1.5), value: showMessage)
                    
                    Text("I'm here to help you discover events that match your comfort style and provide encouragement along the way.")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .opacity(showMessage ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.8).delay(2.0), value: showMessage)
                }
                
                Spacer()
                
                // Mascot with speech bubble
                VStack {
                    HStack {
                        Spacer()
                        
                        // Speech bubble
                        if showMessage {
                            TextBubbleView(text: mascotViewModel.currentMessage)
                                .transition(.scale.combined(with: .opacity))
                        }
                        
                        // Mascot
                        MascotView(viewModel: mascotViewModel, size: 120)
                            .scaleEffect(showMascot ? 1.0 : 0.3)
                            .opacity(showMascot ? 1.0 : 0.0)
                            .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.5), value: showMascot)
                        
                        Spacer()
                    }
                }
                
                Spacer()
                
                // Continue button
                Button(action: {
                    // Mark onboarding as complete and dismiss
                    dismiss()
                }) {
                    Text("Let's Start Exploring!")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(25)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal, 32)
                .opacity(showButton ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.8).delay(3.0), value: showButton)
                
                Spacer()
            }
        }
        .onAppear {
            // Trigger animations and mascot greeting
            startWelcomeSequence()
        }
    }
    
    private func startWelcomeSequence() {
        // Show mascot first
        withAnimation {
            showMascot = true
        }
        
        // Then show message and text
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            mascotViewModel.updateContext(.firstTimeUser, user: locationManager)
            withAnimation {
                showMessage = true
            }
        }
        
        // Finally show button
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation {
                showButton = true
            }
        }
    }
}

#Preview {
    MascotWelcomeView()
        .environmentObject(LocationManager())
}