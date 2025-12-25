//
//  ActionButtonsView.swift
//  artist discoverer
//
//  Created by Abhi Reddy on 16/12/2025.
//

import SwiftUI

struct ActionButtonsView: View {
    @Binding var liked: Bool
    @State var saved: Bool = false
    @State private var likePulse: Bool = false

    var body: some View {
        
        HStack {
            
            Spacer()
            
            VStack (alignment: .trailing, spacing: 27) {
                Spacer()
                VStack(spacing: 2) {
                    Button {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.6, blendDuration: 0.1)) {
                            liked.toggle()
                            if liked {
                                // Trigger pulse and log current index safely
                                likePulse.toggle()
                            }
                        }
                        // Reset the pulse state after a short delay so it can be retriggered
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            
                            likePulse = false
                        }
                    } label: {
                        Image(systemName: liked ? "heart.fill" : "heart")
                            .foregroundStyle(liked ? .red : .white)
                            .font(.system(size: 26))
                            .scaleEffect(likePulse ? 1.35 : 1.0)
                            .rotationEffect(.degrees(Double(likePulse ? Int.random(in: -10...10) : 0)))
                            .shadow(color: (liked ? Color.red : Color.black).opacity(0.6), radius: 10)
                            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: likePulse)
                            .animation(.easeInOut(duration: 0.15), value: liked)
                    }
                    
                    
                    Text("3.4K")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(.white)
                    
                }
                
                VStack(spacing: 2) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            print("SHARING")
                        }
                    } label: {
                        Image(systemName: "paperplane")
                            .font(.system(size: 23))
                            .shadow(color: .black.opacity(0.6), radius: 14)

                    }
                    .buttonStyle(ShrinkingButton())

                    
                    Text("2.1K")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(.white)
                    
                }
                
            
                VStack(spacing: 2) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            saved.toggle()
                        }
                        
                        
                    } label: {
                        Image(saved ? "spotify bg clr" : "spotify bg")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .shadow(color: saved ? .green.opacity(0.3) : .black.opacity(0.5), radius: 11)

                    }
                    .buttonStyle(ShrinkingButton())
                    
                    if !saved {
                        Text("Save")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    
                }

            }
        }
        .padding([.horizontal, .top], 21)
        .padding(.bottom, saved ? 75 : 60)
        
        
    }
}

struct ShrinkingButton: ButtonStyle {
    
    var foregroundColor: Color = .white
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.8 : 1)
            .foregroundStyle(configuration.isPressed ? .white.opacity(0.4) : foregroundColor)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

