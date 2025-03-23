//
//  AISummaryView.swift
//  ring-ai
//
//  Created by Sofyan Ajridi on 16/02/2025.
//
import SwiftUI

struct AISummaryView: View {
    @ObservedObject var ringViewModel: RingSearchViewModel
    @StateObject private var viewModel = AISummaryViewModel()
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("AI Analysis")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)
                
                if viewModel.isLoading {
                    ProgressView("Generating summary...")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else if !viewModel.summary.isEmpty {
                    Text(viewModel.summary)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                
                Button(action: refreshData) {
                    Label("Refresh Analysis", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.isLoading)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top)
            }
            .padding()
        }
        .navigationTitle("Activity Summary")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            refreshData()
        }
    }
    
    private func refreshData() {
        ringViewModel.fetchStepsForLast7Days()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if !ringViewModel.stepsHistory.isEmpty {
                viewModel.generateSummary(stepsHistory: ringViewModel.stepsHistory)
            }
        }
    }
}
