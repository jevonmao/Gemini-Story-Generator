//
//  StoryViewModel.swift
//  Gemini Story Generator
//
//  Created by Jevon Mao on 7/7/25.
//
import AVFoundation
import FirebaseAI
import SwiftUICore

enum StoryStyle: String, CaseIterable, Identifiable {
    case classic
    case fantasy
    case sciFi
    case custom

    var id: Self { self }
    var title: String {
        switch self {
        case .classic: return "Classic"
        case .fantasy: return "Fantasy"
        case .sciFi: return "Sci‑Fi"
        case .custom: return "Custom"
        }
    }
}

@MainActor
class StoryViewModel: ObservableObject {
    @Published var prompt = ""
    @Published var story = ""
    @Published var style: StoryStyle = .fantasy
    @Published var customStyle = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var task: Task<Void, Never>?
    private let synthesizer = AVSpeechSynthesizer()
    // Initialize the Gemini Developer API backend service
    var ai: FirebaseAI
    // Create a `GenerativeModel` instance with a model that supports your use case
    var model: GenerativeModel
    
    init() {
        self.ai = FirebaseAI.firebaseAI(backend: .googleAI())
        self.model = ai.generativeModel(modelName: "gemini-2.5-flash")
    }
    
    func generateStory() async {
        task?.cancel()
        story = ""
        errorMessage = nil
        isLoading = true
        if customStyle.isEmpty {
            customStyle = style.title
        }
        let instruction = """
                You are a master creative storyteller. Write a \(customStyle) story based on the user prompt. Output strictly valid Markdown. Make sure to break up story into paragraphs, and seperate with two paragraph separators (U+2029). Do not include explanations or metadata—only the story in Markdown. Prompt: \(prompt)
                """
        do {
            let contentStream = try model.generateContentStream(instruction)
            for try await chunk in contentStream {
              if let text = chunk.text {
                  withAnimation {
                      self.story += text
                  }
                 
              }
            }
        }
        catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func speakStory() {
        let utterance = AVSpeechUtterance(string: story)
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }

    func cancel() {
        task?.cancel()
        isLoading = false
    }
}
