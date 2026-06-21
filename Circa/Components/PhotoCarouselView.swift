//
//  PhotoCarouselView.swift
//  Circa
//
//  Created by Jackenson on 8/28/25.
//

import SwiftUI

struct PhotoCarouselView: View {
    let imageDataArray: [Data]
    let height: CGFloat
    let cornerRadius: CGFloat
    
    @State private var currentIndex = 0
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            if !imageDataArray.isEmpty {
                if imageDataArray.count == 1 {
                    // Single image - no TabView, no looping, no indicators
                    if let uiImage = UIImage(data: imageDataArray[0]) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: height)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .cornerRadius(cornerRadius)
                    }
                } else {
                    // Multiple images - use TabView with auto-looping
                    TabView(selection: $currentIndex) {
                        ForEach(Array(imageDataArray.enumerated()), id: \.offset) { index, data in
                            if let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: height)
                                    .clipped()
                                    .tag(index)
                            }
                        }
                    }
                    .frame(height: height)
                    .frame(maxWidth: .infinity)
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .onAppear {
                        startAutoLoop()
                    }
                    .onDisappear {
                        stopAutoLoop()
                    }
                    
                    // Page indicators (dots) - only for multiple images
                    VStack {
                        Spacer()
                        HStack(spacing: 6) {
                            ForEach(0..<imageDataArray.count, id: \.self) { index in
                                Circle()
                                    .fill(currentIndex == index ? Color.white : Color.white.opacity(0.5))
                                    .frame(width: 6, height: 6)
                            }
                        }
                        .padding(.bottom, 12)
                    }
                    
                    // Photo counter - only for multiple images
                    VStack {
                        HStack {
                            Spacer()
                            Text("\(currentIndex + 1)/\(imageDataArray.count)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.6))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .padding(.top, 8)
                                .padding(.trailing, 8)
                        }
                        Spacer()
                    }
                }
            } else {
                // Placeholder when no images
                Rectangle()
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: height)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    )
                    .cornerRadius(cornerRadius)
            }
        }
    }
    
    private func startAutoLoop() {
        guard imageDataArray.count > 1 else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentIndex = (currentIndex + 1) % imageDataArray.count
            }
        }
    }
    
    private func stopAutoLoop() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    let sampleImages = [
        UIImage(named: "art")?.jpegData(compressionQuality: 1.0),
        UIImage(named: "music")?.jpegData(compressionQuality: 1.0),
        UIImage(named: "tech")?.jpegData(compressionQuality: 1.0)
    ].compactMap { $0 }
    
    return PhotoCarouselView(
        imageDataArray: sampleImages,
        height: 180,
        cornerRadius: 16
    )
    .padding()
}
