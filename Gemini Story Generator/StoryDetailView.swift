//
//  StoryDetailView.swift
//  Gemini Story Generator
//
//  Created by Jevon Mao on 7/7/25.
//


import SwiftUI

struct StoryDetailView: View {
    let story: String
    let speakAction: () -> Void

    var body: some View {
        VStack {
            if story.isEmpty {
                ProgressView() {
                    Text("Please wait while your story generates...")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            else {
                ScrollView {
                    Text(try! AttributedString(markdown: story))
                        .font(.system(size: 18))
                        .fontDesign(.serif)
                        .lineSpacing(12)
                        .padding(25)
                }
            }
        }
        .navigationTitle("Your Story")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button("Speak") {
                    speakAction()
                }
                .disabled(story.isEmpty)

                ShareLink(item: story) {
                    Text("Share")
                }
                .disabled(story.isEmpty)
            }
        }
    }
}
