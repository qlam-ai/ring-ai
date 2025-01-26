//
//  ContentView.swift
//  ring-ai
//
//  Created by Sofyan Ajridi on 12/01/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var ringViewModel = RingSearchViewModel()
    
    var body: some View {
        
        NavigationStack {
            VStack {
                Image("qlam")
                    .resizable()
                    .frame(width: 128, height: 128)
                    .imageScale(.small)
                    .foregroundStyle(.tint)
                
                
                Text(ringViewModel.statusMessage)
                    .font(.headline)
                    .padding()
                Button {
                    ringViewModel.searchForDevice()
                } label: {
                    Text("Search for Ring Device")
                        .multilineTextAlignment(.center)
                }
                .disabled(ringViewModel.isSearching)
                .padding()
                .buttonStyle(.borderedProminent)
                
                if ringViewModel.isSearching {
                    ProgressView()
                }
                
                if !ringViewModel.discoveredDevices.isEmpty {
                                    Text("Discovered Devices:")
                                        .font(.headline)
                                        .padding(.top)
                                    
                                    List(ringViewModel.discoveredDevices, id: \.identifier) { device in
                                        VStack(alignment: .leading) {
                                            Text(device.name ?? "Unknown Device")
                                                .font(.body)
                                                .fontWeight(.semibold)
                                            Text("UUID: \(device.identifier.uuidString)")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                                
                                Spacer()
                
                
                
            }
            .padding()
            .navigationDestination(isPresented: $ringViewModel.isConnected){
                DeviceFoundView(deviceName: ringViewModel.deviceName, batteryStatus: ringViewModel.batteryLevel, steps: ringViewModel.todaySteps)
            }
        }
        
    }
    
}
    
    

#Preview {
    ContentView()
}
