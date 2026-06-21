//
//  SplashScreenView.swift
//  Circa
//
//  Created by Jackenson Charles on 4/29/25.
//


import SwiftUI

struct SplashScreenView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var viewModel: EventsViewModel
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false

    @State private var animate = false
    @State private var animateBackground = false
    @State private var splashOpacity: Double = 1.0

    var body: some View {
        ZStack {
            if isLoggedIn {
                EventsView()
                    .environmentObject(locationManager)
                    .environmentObject(viewModel)
            } else {
                WelcomeView()
                    .environmentObject(locationManager)
                    .environmentObject(viewModel)
            }

            splashContent
                .opacity(splashOpacity)
                .zIndex(1)
        }
        .onAppear {
            animate = true
            animateBackground = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 4.4) {
                withAnimation(.easeInOut(duration: 1.0)) {
                    splashOpacity = 0
                }
            }
        }
    }

    private var splashContent: some View {
        ZStack {
            LinearGradient(colors: [
                Color("GradientTop"), Color("GradientMiddle"), Color("GradientBottom")
            ], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 250, height: 250)
                .offset(x: animateBackground ? 100 : -100, y: animateBackground ? -150 : 150)
                .blur(radius: 50)
                .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animateBackground)

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [
                            Color("GradientTop"), Color("GradientMiddle"), Color("GradientBottom")
                        ], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: animate ? 120 : 80, height: animate ? 120 : 80)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)

                    Image(systemName: "sparkles")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .scaleEffect(animate ? 1.2 : 1.0)
                }

                Text("Circa")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(animate ? 1 : 0.7)
            }
            .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: animate)
        }
    }
}

// ✅ Preview
#Preview {
    SplashScreenView()
        .environmentObject(LocationManager())
        .environmentObject(EventsViewModel())
}
