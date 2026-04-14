import SwiftUI

// MARK: - SRS Rating

enum SRSRating: Int, CaseIterable, Equatable {
    case again = 0   // complete blackout — reset interval
    case hard  = 1   // recalled with significant difficulty
    case good  = 2   // recalled with effort
    case easy  = 3   // perfect recall

    var label: String {
        switch self {
        case .again: return "Again"
        case .hard:  return "Hard"
        case .good:  return "Good"
        case .easy:  return "Easy"
        }
    }

    var icon: String {
        switch self {
        case .again: return "arrow.counterclockwise"
        case .hard:  return "minus.circle.fill"
        case .good:  return "checkmark.circle"
        case .easy:  return "checkmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .again: return Color(hex: "#F87171")  // red
        case .hard:  return Color(hex: "#FBBF24")  // amber
        case .good:  return Color(hex: "#60A5FA")  // blue
        case .easy:  return Color(hex: "#34D399")  // green
        }
    }

    /// Maps to SM-2 quality scale (0–5). We use 1, 3, 4, 5 to leave
    /// room below 3 (fail) and above 3 (pass with varying ease).
    var sm2Quality: Int { [1, 3, 4, 5][rawValue] }
}

// MARK: - SM-2 Engine

enum SRSEngine {

    /// Apply an SM-2 update to a card after the user rates it.
    static func apply(rating: SRSRating, to card: Flashcard) {
        let q = rating.sm2Quality

        if q < 3 {
            // Failed recall — reset repetition sequence, review again tomorrow
            card.srsRepetitions = 0
            card.srsInterval = 1
        } else {
            // Successful recall — advance the interval
            switch card.srsRepetitions {
            case 0:  card.srsInterval = 1
            case 1:  card.srsInterval = 6
            default:
                let next = Double(card.srsInterval) * card.srsEaseFactor
                card.srsInterval = max(1, Int(next.rounded()))
            }
            card.srsRepetitions += 1
        }

        // Update ease factor: EF' = EF + 0.1 − (5−q)(0.08 + (5−q)·0.02)
        let delta = 0.1 - Double(5 - q) * (0.08 + Double(5 - q) * 0.02)
        card.srsEaseFactor = max(1.3, card.srsEaseFactor + delta)

        // Schedule next review
        card.srsDueDate = Calendar.current.date(
            byAdding: .day, value: card.srsInterval, to: .now
        ) ?? .now

        card.lastSeenAt = .now
        card.seenCount += 1
        card.isKnown    = q >= 4
        card.needsReview = q < 3
    }

    static func isDue(_ card: Flashcard) -> Bool {
        card.srsDueDate <= .now
    }

    static func dueCount(from cards: [Flashcard]) -> Int {
        cards.filter(isDue).count
    }

    /// Human-readable label for when a card is next due.
    static func dueLabel(for card: Flashcard) -> String {
        let days = Calendar.current.dateComponents([.day], from: .now, to: card.srsDueDate).day ?? 0
        switch days {
        case ...0:  return "Due now"
        case 1:     return "Due tomorrow"
        default:    return "Due in \(days)d"
        }
    }
}
