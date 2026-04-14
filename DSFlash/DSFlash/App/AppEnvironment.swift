import Foundation
import Observation

enum StudyMode: String, CaseIterable {
    case all      = "All Cards"
    case dueToday = "Due Today"
    case review   = "Needs Review"
    case unseen   = "Unseen"
}

@Observable
final class AppEnvironment {
    var selectedTopic: Topic? = nil
    var studyMode: StudyMode  = .all
    var searchText: String    = ""
}
