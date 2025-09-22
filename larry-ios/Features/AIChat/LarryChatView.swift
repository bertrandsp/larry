//
//  LarryChatView.swift
//  larry-ios
//
//  Created by AI Assistant on 9/15/25.
//

import SwiftUI

/// AI chat interface for asking Larry about vocabulary and language questions
struct LarryChatView: View {
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack {
                if messages.isEmpty {
                    // Empty state
                    VStack(spacing: 24) {
                        Spacer()
                        
                        Image(systemName: "message.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        VStack(spacing: 8) {
                            Text("Chat with Larry")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Ask me about any word, phrase, or language concept. I'm here to help you learn!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Try asking:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            VStack(spacing: 4) {
                                Text("• \"What does 'serendipity' mean?\"")
                                Text("• \"How do I use 'affect' vs 'effect'?\"")
                                Text("• \"Give me synonyms for 'happy'\"")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                } else {
                    // Chat messages
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(messages) { message in
                                ChatMessageView(message: message)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                }
                
                // Message input
                HStack(spacing: 12) {
                    TextField("Ask Larry anything...", text: $messageText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(1...4)
                    
                    Button {
                        sendMessage()
                    } label: {
                        Image(systemName: isLoading ? "stop.circle.fill" : "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(messageText.isEmpty ? .secondary : .blue)
                    }
                    .disabled(messageText.isEmpty && !isLoading)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .navigationTitle("Larry Chat")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let userMessage = ChatMessage(
            id: UUID().uuidString,
            text: messageText,
            isFromUser: true,
            timestamp: Date()
        )
        
        messages.append(userMessage)
        messageText = ""
        isLoading = true
        
        // Simulate AI response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let aiResponse = ChatMessage(
                id: UUID().uuidString,
                text: "This is where Larry's AI response would appear. The chat functionality will be implemented with the backend integration.",
                isFromUser: false,
                timestamp: Date()
            )
            messages.append(aiResponse)
            isLoading = false
        }
    }
}

// MARK: - Supporting Types

private struct ChatMessage: Identifiable {
    let id: String
    let text: String
    let isFromUser: Bool
    let timestamp: Date
}

private struct ChatMessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.text)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    
                    Text(message.timestamp, format: .dateTime.hour().minute())
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.text)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray5))
                        .cornerRadius(16)
                    
                    Text(message.timestamp, format: .dateTime.hour().minute())
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    LarryChatView()
}

