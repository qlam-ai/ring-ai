//
//  ContentView.swift
//  ring-ai
//
//  Created by Sofyan Ajridi on 12/01/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var ringViewModel = RingSearchViewModel()
    @State private var isAnimating = false
    @State private var showDataView = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.05, green: 0.1, blue: 0.2), Color(red: 0.2, green: 0.5, blue: 0.7)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Spacer()
                    // Rotating Ring Animation
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.15), lineWidth: 16)
                            .frame(width: 160, height: 160)
                        Circle()
                            .trim(from: 0, to: 0.85)
                            .stroke(
                                AngularGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.white, Color.blue]),
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .frame(width: 140, height: 140)
                            .rotationEffect(.degrees(isAnimating ? 360 : 0))
                            .animation(Animation.linear(duration: 2).repeatForever(autoreverses: false), value: isAnimating)
                        Image(systemName: "circle.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(Color.blue.opacity(0.7))
                            .shadow(radius: 10)
                    }
                    .onAppear { isAnimating = true }
                    
                    // Welcome Title
                    Text("Welcome to QRing")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 2)
                    
                    // Status Message
                    Text(ringViewModel.statusMessage)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.horizontal, 24)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 320)
                    
                    // Search Button
                    Button {
                        ringViewModel.searchForDevice()
                    } label: {
                        HStack {
                            Image(systemName: "dot.radiowaves.left.and.right")
                            Text(ringViewModel.isSearching ? "Searching..." : "Search for Ring Device")
                                .fontWeight(.semibold)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 36)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.white.opacity(0.7)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.black)
                        .cornerRadius(30)
                        .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(ringViewModel.isSearching)
                    .opacity(ringViewModel.isSearching ? 0.7 : 1)
                    
                    // Show "Let's go see my Data" button if connected
                    if ringViewModel.isConnected {
                        Button {
                            showDataView = true
                        } label: {
                            Text("Let's go see my Data")
                                .fontWeight(.bold)
                                .padding(.vertical, 14)
                                .padding(.horizontal, 32)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(24)
                                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.top, 8)
                        .transition(.opacity)
                    }
                    
                    // Progress Indicator
                    if ringViewModel.isSearching {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                            .padding(.top, 8)
                    }
                    
                    Spacer()
                    
                    // Discovered Devices List (optional, can be hidden for minimal look)
                    if !ringViewModel.discoveredDevices.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Discovered Devices:")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                            ScrollView {
                                ForEach(ringViewModel.discoveredDevices, id: \ .identifier) { device in
                                    HStack {
                                        Text(device.name ?? "Unknown Device")
                                            .font(.body)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text("UUID: \(device.identifier.uuidString)")
                                            .font(.caption2)
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                    .padding(8)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(8)
                                }
                            }
                            .frame(maxHeight: 120)
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    Spacer(minLength: 24)
                }
                .padding(.top, 32)
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationDestination(isPresented: $showDataView) {
                NewRingView(viewModel: ringViewModel)
            }
        }
    }
}

#Preview {
    ContentView()
}
