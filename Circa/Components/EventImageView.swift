//
//  EventImageView.swift
//  Circa
//
//  Created by Jackenson Charles on 3/24/25.
//


import SwiftUI

struct EventImageView: View {
    let imageData: Data?

    var body: some View {
        ZStack {
            if let data = imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
