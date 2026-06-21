//
//  WelcomeView.swift
//  Circa
//
//  Created by Jackenson Charles on 3/26/25.
//
import SwiftUI

struct WelcomeView: View {
    @State private var name = ""
    @State private var city = ""
    @State private var zip = ""
    @State private var showAlert = false
    @State private var showPreferences = false
    @State private var showMascotWelcome = false

    @EnvironmentObject var viewModel: EventsViewModel
    @EnvironmentObject var locationManager: LocationManager
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false

    var body: some View {
        ZStack {
            Image("Event")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                Text("Welcome to Circa")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                StyledInputField(placeholder: "Enter your name", text: $name)
                StyledInputField(placeholder: "Enter your city", text: $city)
                StyledInputField(placeholder: "Enter your ZIP code", text: $zip, keyboardType: .numberPad)

                Button(action: {
                    if name.isEmpty || city.isEmpty || zip.isEmpty {
                        showAlert = true
                    } else {
                        locationManager.username = name
                        locationManager.currentCity = city
                        locationManager.currentZip = zip
                        showPreferences = true // Show preferences sheet instead of logging in immediately
                    }
                }) {
                    Text("Continue")
                        .fontWeight(.semibold)
                        .frame(width: 150, height: 44)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.50), lineWidth: 1)
                        )
                        .foregroundColor(.black)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                .padding(.top, 10)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Missing Information"), message: Text("Please fill in all fields."), dismissButton: .default(Text("OK")))
                }

                Spacer()
            }
            .padding(.horizontal)
        }
        // Present ComfortPreferencesView as a sheet after user info is entered
        .sheet(isPresented: $showPreferences, onDismiss: {
            // After preferences are set, show mascot welcome
            showMascotWelcome = true
        }) {
            ComfortPreferencesView()
                .environmentObject(locationManager)
        }
        // Present MascotWelcomeView after preferences are complete
        .fullScreenCover(isPresented: $showMascotWelcome, onDismiss: {
            // After mascot welcome, mark user as logged in
            isLoggedIn = true
        }) {
            MascotWelcomeView()
                .environmentObject(locationManager)
        }
    }
}

struct StyledInputField: View {
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(keyboardType)
            .padding(.horizontal, 20)
            .frame(width: 260, height: 44)
            .background(.ultraThinMaterial)
            .foregroundColor(.black)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.50), lineWidth: 1)
            )
            .multilineTextAlignment(.center)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
