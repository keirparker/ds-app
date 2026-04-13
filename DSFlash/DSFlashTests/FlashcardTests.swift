import XCTest
import SwiftData
@testable import DSFlash

final class FlashcardTests: XCTestCase {
    var container: ModelContainer!
    var context: ModelContext!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Flashcard.self, configurations: config)
        context = ModelContext(container)
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
    }

    // MARK: - Initialisation

    func testDefaultsOnInit() {
        let card = Flashcard(
            topicRaw: "ML Fundamentals",
            difficultyRaw: "Intermediate",
            question: "What is overfitting?",
            answer: "When a model memorises training data.",
            explanation: "It generalises poorly to unseen data."
        )
        XCTAssertFalse(card.isKnown)
        XCTAssertFalse(card.needsReview)
        XCTAssertEqual(card.seenCount, 0)
        XCTAssertNil(card.lastSeenAt)
    }

    func testCustomUUIDPreserved() {
        let id = UUID()
        let card = Flashcard(
            id: id,
            topicRaw: "Statistics & Probability",
            difficultyRaw: "Senior",
            question: "Q",
            answer: "A",
            explanation: "E"
        )
        XCTAssertEqual(card.id, id)
    }

    // MARK: - Topic parsing

    func testTopicParsingMatchesRawValue() {
        for topic in Topic.allCases {
            let card = Flashcard(
                topicRaw: topic.rawValue,
                difficultyRaw: "Intermediate",
                question: "Q",
                answer: "A",
                explanation: "E"
            )
            XCTAssertEqual(card.topic, topic, "Topic '\(topic.rawValue)' failed to round-trip.")
        }
    }

    func testUnknownTopicFallsBackToMLFundamentals() {
        let card = Flashcard(
            topicRaw: "Nonexistent Topic",
            difficultyRaw: "Intermediate",
            question: "Q",
            answer: "A",
            explanation: "E"
        )
        XCTAssertEqual(card.topic, .mlFundamentals)
    }

    // MARK: - Difficulty parsing

    func testDifficultyParsingMatchesRawValue() {
        for difficulty in Difficulty.allCases {
            let card = Flashcard(
                topicRaw: "ML Fundamentals",
                difficultyRaw: difficulty.rawValue,
                question: "Q",
                answer: "A",
                explanation: "E"
            )
            XCTAssertEqual(card.difficulty, difficulty)
        }
    }

    func testUnknownDifficultyFallsBackToIntermediate() {
        let card = Flashcard(
            topicRaw: "ML Fundamentals",
            difficultyRaw: "Novice",
            question: "Q",
            answer: "A",
            explanation: "E"
        )
        XCTAssertEqual(card.difficulty, .intermediate)
    }

    // MARK: - Persistence

    func testInsertAndFetch() throws {
        let card = Flashcard(
            topicRaw: "Deep Learning & Neural Networks",
            difficultyRaw: "Intermediate",
            question: "What is backpropagation?",
            answer: "Gradient descent via chain rule.",
            explanation: "Computes gradients layer by layer."
        )
        context.insert(card)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Flashcard>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.question, "What is backpropagation?")
    }

    func testMultipleCardsAreStoredIndependently() throws {
        for i in 0..<5 {
            let card = Flashcard(
                topicRaw: "Statistics & Probability",
                difficultyRaw: "Intermediate",
                question: "Question \(i)",
                answer: "Answer \(i)",
                explanation: "Explanation \(i)"
            )
            context.insert(card)
        }
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Flashcard>())
        XCTAssertEqual(fetched.count, 5)
    }

    // MARK: - State mutations

    func testMarkingCardAsKnown() throws {
        let card = Flashcard(
            topicRaw: "ML Fundamentals",
            difficultyRaw: "Beginner",
            question: "Q",
            answer: "A",
            explanation: "E"
        )
        context.insert(card)

        card.isKnown = true
        card.seenCount += 1
        card.lastSeenAt = Date()
        try context.save()

        XCTAssertTrue(card.isKnown)
        XCTAssertFalse(card.needsReview)
        XCTAssertEqual(card.seenCount, 1)
        XCTAssertNotNil(card.lastSeenAt)
    }

    func testMarkingCardAsNeedsReview() throws {
        let card = Flashcard(
            topicRaw: "ML Fundamentals",
            difficultyRaw: "Intermediate",
            question: "Q",
            answer: "A",
            explanation: "E"
        )
        context.insert(card)

        card.needsReview = true
        card.seenCount += 1
        try context.save()

        XCTAssertFalse(card.isKnown)
        XCTAssertTrue(card.needsReview)
        XCTAssertEqual(card.seenCount, 1)
    }
}
