//
//  AISummaryView.swift
//  ring-ai
//
//  Created by Sofyan Ajridi on 16/02/2025.
//
import SwiftUI
import llama

struct AISummaryView: View {
    var body: some View {
        VStack {
            Text("AI Summary")
                .font(.title)
                .bold()
                .padding(.top, 20)
            
            Spacer()
            Text("AI Summary content will be here.")
                .font(.body)
                .foregroundColor(.gray)
            Spacer()
        }
        .navigationTitle("AI Summary")
        .navigationBarTitleDisplayMode(.inline)
    }
}
