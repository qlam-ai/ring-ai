//
//  DeviceFoundView.swift
//  ring-ai
//
//  Created by Sofyan Ajridi on 12/01/2025.
//
import SwiftUI

struct ChatMessage {
    let id = UUID()
    let content: String
    let isUser: Bool
}

struct DeviceFoundView: View {
    var deviceName: String
    var batteryStatus: Int
    var steps: Int
    @State private var messages: [ChatMessage] = []
    @State private var newMessage: String = ""
    
    var body: some View {
        VStack {
            Text("Connected to \(deviceName)%")
                .font(.subheadline)
                .padding()
            
            Text("Battery status: \(batteryStatus)%")
                .font(.subheadline)
                .padding()
            
            Text("Steps today: \(steps)")
                .font(.subheadline)
                .padding()
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(messages, id: \.id) { message in
                        MessageBubbleView(message: message)
                    }
                }
                .padding()
            }
            
            HStack {
                TextField("Ask a question...", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.blue)
                }
                .disabled(newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                
                
                Button(action: resetMessages) {
                    Image(systemName: "minus.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.blue)
                    
                }
                .padding()
            }
            .padding(.bottom)
        }
    }
    
    private func sendMessage() {
        let trimmedMessage = newMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }
        
        let userMessage = ChatMessage(content: trimmedMessage, isUser: true)
        messages.append(userMessage)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let responseMessage = ChatMessage(content: "I received your question: \(trimmedMessage)", isUser: false)
            messages.append(responseMessage)
        }
        
        newMessage = ""
    }
    
    private func resetMessages() {
        messages = []
    }
}

struct MessageBubbleView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            Text(message.content)
                .padding()
                .background(message.isUser ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(message.isUser ? .white : .primary)
                .cornerRadius(15)
            
            if !message.isUser { Spacer() }
        }
    }
}

struct DeviceFoundView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceFoundView(deviceName: "Test", batteryStatus: 2, steps: 10)
    }
}
