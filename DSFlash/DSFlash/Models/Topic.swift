import SwiftUI

enum Topic: String, CaseIterable, Codable {
    case statistics        = "Statistics & Probability"
    case mlFundamentals    = "ML Fundamentals"
    case deepLearning      = "Deep Learning & Neural Networks"
    case nlpTransformers   = "NLP & Transformers"
    case computerVision    = "Computer Vision"
    case featureEngineering = "Feature Engineering"
    case modelEvaluation   = "Model Evaluation & Metrics"
    case dataEngineering   = "Data Engineering & SQL"
    case abTesting         = "Experimentation & A/B Testing"
    case mlops             = "MLOps & Deployment"
    case llmsGenAI         = "LLMs & Generative AI"
    case reinforcementLearning = "Reinforcement Learning"
    case causalInference   = "Causal Inference"
    case leadership        = "Leadership & Strategy"
    case pythonAlgorithms  = "Python & Algorithms"

    var emoji: String {
        switch self {
        case .statistics:           return "📊"
        case .mlFundamentals:       return "🤖"
        case .deepLearning:         return "🧠"
        case .nlpTransformers:      return "💬"
        case .computerVision:       return "👁"
        case .featureEngineering:   return "🔧"
        case .modelEvaluation:      return "📐"
        case .dataEngineering:      return "🗄️"
        case .abTesting:            return "🧪"
        case .mlops:                return "🚀"
        case .llmsGenAI:            return "✨"
        case .reinforcementLearning: return "🎮"
        case .causalInference:      return "🔗"
        case .leadership:           return "🎯"
        case .pythonAlgorithms:     return "🐍"
        }
    }

    var accentColor: Color {
        switch self {
        case .statistics:           return Color(hex: "#818CF8") // indigo
        case .mlFundamentals:       return Color(hex: "#60A5FA") // blue
        case .deepLearning:         return Color(hex: "#A78BFA") // violet
        case .nlpTransformers:      return Color(hex: "#34D399") // emerald
        case .computerVision:       return Color(hex: "#F472B6") // pink
        case .featureEngineering:   return Color(hex: "#FBBF24") // amber
        case .modelEvaluation:      return Color(hex: "#38BDF8") // sky
        case .dataEngineering:      return Color(hex: "#4ADE80") // green
        case .abTesting:            return Color(hex: "#FB923C") // orange
        case .mlops:                return Color(hex: "#E879F9") // fuchsia
        case .llmsGenAI:            return Color(hex: "#67E8F9") // cyan
        case .reinforcementLearning: return Color(hex: "#FDE68A") // yellow
        case .causalInference:      return Color(hex: "#86EFAC") // light green
        case .leadership:           return Color(hex: "#FCA5A5") // salmon
        case .pythonAlgorithms:     return Color(hex: "#93C5FD") // light blue
        }
    }

    var expectedCardCount: Int {
        switch self {
        case .statistics:           return 18
        case .mlFundamentals:       return 20
        case .deepLearning:         return 18
        case .nlpTransformers:      return 15
        case .computerVision:       return 12
        case .featureEngineering:   return 12
        case .modelEvaluation:      return 15
        case .dataEngineering:      return 15
        case .abTesting:            return 12
        case .mlops:                return 15
        case .llmsGenAI:            return 18
        case .reinforcementLearning: return 8
        case .causalInference:      return 8
        case .leadership:           return 10
        case .pythonAlgorithms:     return 4
        }
    }
}
