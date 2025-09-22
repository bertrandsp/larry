import SwiftUI

struct ChatView: View {
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Messages list
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            if messages.isEmpty {
                                emptyStateView
                            } else {
                                ForEach(messages) { message in
                                    ChatMessageView(message: message)
                                        .id(message.id)
                                }
                            }
                            
                            if isLoading {
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Larry is thinking...")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                            }
                        }
                        .padding()
                    }
                    .onChange(of: messages.count) { _ in
                        if let lastMessage = messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Message input
                messageInputView
            }
            .navigationTitle("Larry Chat")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "message.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Start a conversation with Larry")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Ask about vocabulary, get explanations, or practice pronunciation!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 8) {
                Text("Try asking:")
                    .font(.headline)
                    .fontWeight(.medium)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("• \"Explain the word 'serendipity'\"")
                    Text("• \"Give me synonyms for 'happy'\"")
                    Text("• \"How do I pronounce 'entrepreneur'?\"")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .padding(.top, 50)
    }
    
    private var messageInputView: some View {
        HStack {
            TextField("Ask Larry anything...", text: $messageText, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...4)
            
            Button {
                sendMessage()
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundColor(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .secondary : .blue)
            }
            .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        // Add user message
        let userMessage = ChatMessage(
            id: UUID(),
            content: text,
            isFromUser: true,
            timestamp: Date()
        )
        messages.append(userMessage)
        
        // Clear input
        messageText = ""
        
        // Simulate AI response (replace with actual API call)
        simulateAIResponse(to: text)
    }
    
    private func simulateAIResponse(to userMessage: String) {
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let aiResponse = generateMockResponse(for: userMessage)
            let aiMessage = ChatMessage(
                id: UUID(),
                content: aiResponse,
                isFromUser: false,
                timestamp: Date()
            )
            messages.append(aiMessage)
            isLoading = false
        }
    }
    
    private func generateMockResponse(for message: String) -> String {
        let responses = [
            "That's a great question! Let me help you with that vocabulary term.",
            "I can see you're interested in expanding your vocabulary. Here's what I can tell you...",
            "Excellent choice of word to explore! This term has an interesting etymology.",
            "I love helping with vocabulary questions. Let me break this down for you.",
            "That's a fascinating word with multiple meanings. Let me explain..."
        ]
        return responses.randomElement() ?? "I'm here to help with your vocabulary questions!"
    }
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isFromUser: Bool
    let timestamp: Date
}

struct ChatMessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer(minLength: 50)
            }
            
            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(12)
                    .background(message.isFromUser ? Color.blue : Color(.systemGray5))
                    .foregroundColor(message.isFromUser ? .white : .primary)
                    .cornerRadius(16)
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !message.isFromUser {
                Spacer(minLength: 50)
            }
        }
    }
}

#Preview {
    ChatView()
}
