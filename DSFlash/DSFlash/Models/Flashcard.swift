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

    // MARK: - Spaced Repetition (SM-2)
    var srsInterval: Int        // days until next review
    var srsEaseFactor: Double   // ease factor (default 2.5, min 1.3)
    var srsRepetitions: Int     // consecutive correct responses
    var srsDueDate: Date        // date when next review is due

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
        self.srsInterval = 1
        self.srsEaseFactor = 2.5
        self.srsRepetitions = 0
        self.srsDueDate = .now
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
