//
//  ContentView.swift
//  Gemini Story Generator
//
//  Created by Jevon Mao on 7/7/25.
//

import SwiftUI
struct ContentView: View {
    @StateObject var viewModel = StoryViewModel()
    @State private var showStoryView = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("Enter prompt", text: $viewModel.prompt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Picker("Style", selection: $viewModel.style) {
                    ForEach(StoryStyle.allCases) { style in
                        Text(style.title)
                            .tag(style)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                if viewModel.style == .custom {
                    TextField("Style description", text: $viewModel.customStyle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                }

                Button(action: {
                    showStoryView = true
                    Task {
                        await viewModel.generateStory()
                    }
                }) {
                    Text(viewModel.isLoading ? "Loading" : "Generate Story")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(viewModel.prompt.isEmpty || viewModel.isLoading)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Story Generator")
            .navigationDestination(isPresented: $showStoryView) {
                StoryDetailView(
                    story: viewModel.story,
                    speakAction: viewModel.speakStory
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    ContentView()
}
