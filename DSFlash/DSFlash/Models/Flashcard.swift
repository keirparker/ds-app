import SwiftData
import Foundation

@Model
final class Flashcard {
    var id: UUID
    var topicRaw: String
    var difficultyRaw: String
    var question: String
    var answer: String
    var explanation: String
    var isKnown: Bool
    var needsReview: Bool
    var lastSeenAt: Date?
    var seenCount: Int

    init(
        id: UUID = UUID(),
        topicRaw: String,
        difficultyRaw: String,
        question: String,
        answer: String,
        explanation: String
    ) {
        self.id = id
        self.topicRaw = topicRaw
        self.difficultyRaw = difficultyRaw
        self.question = question
        self.answer = answer
        self.explanation = explanation
        self.isKnown = false
        self.needsReview = false
        self.lastSeenAt = nil
        self.seenCount = 0
    }

    var topic: Topic {
        Topic(rawValue: topicRaw) ?? .mlFundamentals
    }

    var difficulty: Difficulty {
        Difficulty(rawValue: difficultyRaw) ?? .intermediate
    }
}

// MARK: - DTO for JSON decoding

struct FlashcardDTO: Codable {
    let id: String
    let topic: String
    let difficulty: String
    let question: String
    let answer: String
    let explanation: String
}
