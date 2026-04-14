import XCTest
import SwiftData
@testable import DSFlash

final class TopicTests: XCTestCase {

    func testAllTopicsHaveEmoji() {
        for topic in Topic.allCases {
            XCTAssertFalse(topic.emoji.isEmpty, "\(topic.rawValue) has no emoji")
        }
    }

    func testAllTopicsHavePositiveExpectedCount() {
        for topic in Topic.allCases {
            XCTAssertGreaterThan(
                topic.expectedCardCount, 0,
                "\(topic.rawValue) has zero expected card count"
            )
        }
    }

    func testTopicRawValueRoundTrip() {
        for topic in Topic.allCases {
            let reconstructed = Topic(rawValue: topic.rawValue)
            XCTAssertEqual(reconstructed, topic, "Round-trip failed for '\(topic.rawValue)'")
        }
    }

    func testTopicCodableRoundTrip() throws {
        for topic in Topic.allCases {
            let encoded = try JSONEncoder().encode(topic)
            let decoded = try JSONDecoder().decode(Topic.self, from: encoded)
            XCTAssertEqual(decoded, topic, "Codable round-trip failed for '\(topic.rawValue)'")
        }
    }

    func testTopicCount() {
        XCTAssertEqual(Topic.allCases.count, 15, "Expected 15 topics")
    }
}

// MARK: -

final class FlashcardStoreTests: XCTestCase {
    private let seededKey = "dsflash_seeded_v1"
    var container: ModelContainer!
    var context: ModelContext!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Flashcard.self, configurations: config)
        context = ModelContext(container)
        UserDefaults.standard.removeObject(forKey: seededKey)
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
        UserDefaults.standard.removeObject(forKey: seededKey)
    }

    func testSeedingInsertsCards() throws {
        FlashcardStore.seedIfNeeded(context: context)

        let cards = try context.fetch(FetchDescriptor<Flashcard>())
        XCTAssertGreaterThan(cards.count, 0, "Seeding should insert at least one card")
    }

    func testSeedingIsIdempotent() throws {
        FlashcardStore.seedIfNeeded(context: context)
        let countAfterFirst = try context.fetch(FetchDescriptor<Flashcard>()).count

        FlashcardStore.seedIfNeeded(context: context)
        let countAfterSecond = try context.fetch(FetchDescriptor<Flashcard>()).count

        XCTAssertEqual(countAfterFirst, countAfterSecond, "Calling seedIfNeeded twice should not duplicate cards")
    }

    func testAllSeededCardsHaveNonEmptyContent() throws {
        FlashcardStore.seedIfNeeded(context: context)

        let cards = try context.fetch(FetchDescriptor<Flashcard>())
        for card in cards {
            XCTAssertFalse(card.question.isEmpty, "Card \(card.id) has an empty question")
            XCTAssertFalse(card.answer.isEmpty, "Card \(card.id) has an empty answer")
            XCTAssertFalse(card.explanation.isEmpty, "Card \(card.id) has an empty explanation")
        }
    }

    func testAllSeededCardsHaveValidTopics() throws {
        FlashcardStore.seedIfNeeded(context: context)

        let cards = try context.fetch(FetchDescriptor<Flashcard>())
        let knownTopicRawValues = Set(Topic.allCases.map(\.rawValue))
        for card in cards {
            XCTAssertTrue(
                knownTopicRawValues.contains(card.topicRaw),
                "Card '\(card.question)' has unknown topic '\(card.topicRaw)'"
            )
        }
    }

    func testAllSeededCardsHaveValidDifficulties() throws {
        FlashcardStore.seedIfNeeded(context: context)

        let cards = try context.fetch(FetchDescriptor<Flashcard>())
        let knownDifficulties = Set(Difficulty.allCases.map(\.rawValue))
        for card in cards {
            XCTAssertTrue(
                knownDifficulties.contains(card.difficultyRaw),
                "Card '\(card.question)' has unknown difficulty '\(card.difficultyRaw)'"
            )
        }
    }

    func testAllFifteenTopicsReceiveCards() throws {
        FlashcardStore.seedIfNeeded(context: context)

        let cards = try context.fetch(FetchDescriptor<Flashcard>())
        let topicsFound = Set(cards.map(\.topicRaw))
        let allTopicRawValues = Set(Topic.allCases.map(\.rawValue))

        let missing = allTopicRawValues.subtracting(topicsFound)
        XCTAssertTrue(missing.isEmpty, "Topics missing cards: \(missing.sorted().joined(separator: ", "))")
    }
}
