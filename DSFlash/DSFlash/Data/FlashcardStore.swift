import Foundation
import SwiftData

enum FlashcardStore {
    private static let seededKey = "dsflash_seeded_v1"

    private static let jsonFileNames: [String] = [
        "statistics",
        "ml_fundamentals",
        "deep_learning",
        "nlp_transformers",
        "computer_vision",
        "feature_engineering",
        "model_evaluation",
        "data_engineering",
        "ab_testing",
        "mlops",
        "llms_genai",
        "reinforcement_learning",
        "causal_inference",
        "leadership",
        "python_algorithms"
    ]

    static func seedIfNeeded(context: ModelContext) {
        guard !UserDefaults.standard.bool(forKey: seededKey) else { return }

        let decoder = JSONDecoder()

        for fileName in jsonFileNames {
            guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
                print("[FlashcardStore] Warning: could not find bundle resource '\(fileName).json'")
                continue
            }

            do {
                let data = try Data(contentsOf: url)
                let dtos = try decoder.decode([FlashcardDTO].self, from: data)

                for dto in dtos {
                    let card = Flashcard(
                        id: UUID(uuidString: dto.id) ?? UUID(),
                        topicRaw: dto.topic,
                        difficultyRaw: dto.difficulty,
                        question: dto.question,
                        answer: dto.answer,
                        explanation: dto.explanation
                    )
                    context.insert(card)
                }
            } catch {
                print("[FlashcardStore] Failed to decode '\(fileName).json': \(error)")
            }
        }

        do {
            try context.save()
            UserDefaults.standard.set(true, forKey: seededKey)
        } catch {
            print("[FlashcardStore] Failed to save seeded cards: \(error)")
        }
    }
}
