//
//  ProfileImageView.swift
//  FinancialTracker
//
//  Created by Roy Dimapilis on 11/10/25.
//

import SwiftUI

struct ProfileImageView: View {
    let user: User
    let size: CGFloat
    
    var body: some View {
        Group {
            if let photoData = user.photoData,
               let uiImage = UIImage(data: photoData) {
                // Show user's photo
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                // Fallback to emoji
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: size, height: size)
                    
                    Text(user.emoji)
                        .font(.system(size: size * 0.5))
                }
            }
        }
    }
}
