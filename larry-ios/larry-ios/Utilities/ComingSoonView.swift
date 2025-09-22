//
//  ComingSoonView.swift
//  larry-ios
//
//  Created by AI Assistant on 9/15/25.
//

import SwiftUI

/// Reusable view for features that are coming soon
struct ComingSoonView: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "hammer.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Text("Coming Soon")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.orange)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(20)
            
            Spacer()
        }
    }
}

#Preview {
    ComingSoonView(
        title: "Feature Name",
        description: "This feature is currently in development and will be available soon."
    )
}

