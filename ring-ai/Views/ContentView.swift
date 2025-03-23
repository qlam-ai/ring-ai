//
//  ContentView.swift
//  ring-ai
//
//  Created by Sofyan Ajridi on 12/01/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var ringSearchVM = RingSearchViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                Image("qlam")
                    .resizable()
                    .frame(width: 128, height: 128)
                    .imageScale(.small)
                    .foregroundStyle(.tint)
                
                Text(ringSearchVM.statusMessage)
                    .font(.headline)
                    .padding()
                
                Button {
                    ringSearchVM.searchForDevice()
                } label: {
                    Text("Search for Ring Device")
                        .multilineTextAlignment(.center)
                }
                .disabled(ringSearchVM.isSearching)
                .padding()
                .buttonStyle(.borderedProminent)
                
                if ringSearchVM.isSearching {
                    ProgressView()
                }
                
                if !ringSearchVM.discoveredDevices.isEmpty {
                    Text("Discovered Devices:")
                        .font(.headline)
                        .padding(.top)
                    
                    List(ringSearchVM.discoveredDevices, id: \.identifier) { device in
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
            .navigationDestination(isPresented: $ringSearchVM.isConnected) {
                DeviceFoundView(viewModel: ringSearchVM)
            }
        }
    }
}

#Preview {
    ContentView()
}
