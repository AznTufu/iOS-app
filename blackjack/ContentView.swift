//
//  ContentView.swift
//  blackjack
//
//  Created by ZHANG Tony on 15/10/2024.
//

import SwiftUI
  
struct ContentView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isAuthenticated: Bool = false
    @State private var errorMessage: String?

    private let adminUsername = "Utilisateur"
    private let adminPassword = "motdepasse"

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Connexion")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.bottom, 40)
                    VStack {
                        TextField("Nom d'utilisateur", text: $username)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(Color.blue)
                            .cornerRadius(10)

                        SecureField("Mot de passe", text: $password)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(Color.blue)
                            .cornerRadius(10)
                    }.padding(.top, 0)
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                        .padding(.bottom, 0)

                    NavigationLink(destination: GameView(), isActive: $isAuthenticated) {
                        Button(action: {
                            authenticateUser()
                        }) {
                            Text("Se connecter")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.leading, 10)
                    .padding(.trailing, 10)
                    .padding(.bottom, 0)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .padding()
            }
        }
    }

    private func authenticateUser() {
        if username == adminUsername && password == adminPassword {
            isAuthenticated = true
            errorMessage = nil
        } else if username == "" {
            errorMessage = "Veuillez remplir le nom d'utilisateur"
        } else if password == "" {
            errorMessage = "Veuillez remplir le mot de passe"
        } else {
            errorMessage = "Nom d'utilisateur ou mot de passe incorect"
        }
    }
}

#Preview {
    ContentView()
}
