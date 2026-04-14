# DSFlash

A SwiftUI flashcard app for data science and machine learning interview preparation. Study 200+ cards across 15 topics, track your progress, and search across the full card library.

## Topics

| Topic | Cards |
|---|---|
| Statistics & Probability | 18 |
| ML Fundamentals | 20 |
| Deep Learning & Neural Networks | 18 |
| NLP & Transformers | 15 |
| Computer Vision | 12 |
| Feature Engineering | 12 |
| Model Evaluation & Metrics | 15 |
| Data Engineering & SQL | 15 |
| Experimentation & A/B Testing | 12 |
| MLOps & Deployment | 15 |
| LLMs & Generative AI | 18 |
| Reinforcement Learning | 8 |
| Causal Inference | 8 |
| Leadership & Strategy | 10 |
| Python & Algorithms | 4 |

## Requirements

- Xcode 15 or later
- iOS 17+ / macOS 14+ deployment target
- Swift 5.9+

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/keirparker/ds-app.git
   cd ds-app
   ```

2. Open the project in Xcode:
   ```bash
   open DSFlash/DSFlash.xcodeproj
   ```

3. Select a simulator or device running iOS 17+ and press **Run** (⌘R).

Flashcard data is seeded automatically on first launch from the JSON files in `DSFlash/Data/Cards/`. The seeded state is tracked via a `UserDefaults` key (`dsflash_seeded_v1`) so data is only loaded once.

## Project Structure

```
DSFlash/
├── App/
│   ├── DSFlashApp.swift          # App entry point and SwiftData container setup
│   └── AppEnvironment.swift      # Observable app state (study mode, selected topic)
├── Models/
│   ├── Flashcard.swift           # SwiftData @Model — core entity
│   ├── Topic.swift               # 15 topic categories with emoji, colour, expected count
│   └── Difficulty.swift          # Beginner / Intermediate / Senior / Team Lead
├── Data/
│   ├── FlashcardStore.swift      # Seeds cards from JSON on first launch
│   └── Cards/                   # 15 JSON files, one per topic
├── Extensions/
│   ├── Animation+Flip.swift      # Card flip animation modifier
│   ├── Color+Theme.swift         # Dark theme colour palette
│   └── View+CardStyle.swift      # Shared card container styling
└── Views/
    ├── Components/               # DifficultyBadge, TopicBadge, EmptyStateView
    ├── Deck/                     # DeckView (study session) and DeckProgressBar
    ├── Flashcard/                # FlashcardView, CardFrontView, CardBackView
    ├── Home/                     # HomeView, TopicGridView, TopicCardView
    ├── Progress/                 # ProgressDashboardView, CircularProgressView
    └── Search/                   # SearchView, SearchResultRow

DSFlashTests/
├── FlashcardTests.swift          # Unit tests for Flashcard model and persistence
└── TopicAndStoreTests.swift      # Unit tests for Topic enum and FlashcardStore seeding
```

## Running Tests

Select the **DSFlashTests** target in Xcode and press **⌘U**, or run:

```bash
xcodebuild test \
  -project DSFlash/DSFlash.xcodeproj \
  -scheme DSFlash \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

Tests use an in-memory SwiftData container so no persistent state is touched.

## Adding Flashcard Content

Flashcard JSON files live in `DSFlash/Data/Cards/`. Each file is an array of objects matching this schema:

```json
[
  {
    "id": "unique-string-id",
    "topic": "Topic Raw Value",
    "difficulty": "Beginner | Intermediate | Senior | Team Lead",
    "question": "The question text",
    "answer": "The concise answer",
    "explanation": "Deeper explanation for context"
  }
]
```

After adding or modifying a JSON file:

1. Add it to the Xcode project under `DSFlash > Data > Cards` (drag into the group in the Project Navigator, ensure "Add to target: DSFlash" is checked).
2. Bump the seeded key version in `FlashcardStore.swift` (e.g. `dsflash_seeded_v2`) to force a re-seed on next launch, or delete and reinstall the app on the simulator.

## Architecture

DSFlash uses **SwiftUI + SwiftData** — Apple's modern declarative UI and persistence frameworks (iOS 17+, macOS 14+). There are no external dependencies.

- **Data flow:** `FlashcardStore` seeds a SwiftData `ModelContainer` from JSON on first launch. Views query the store via `@Query` and mutate cards directly through the `ModelContext`.
- **State:** `AppEnvironment` (an `@Observable` class) holds global UI state (selected topic, study mode). It is injected as an environment object from the app entry point.
- **Study session:** `DeckView` manages card navigation and completion state. `FlashcardView` handles the flip animation and action buttons (Known / Review / Skip).

## License

MIT — see [LICENSE](LICENSE).
