import Foundation
import NaturalLanguage

class SentimentAnalyzer: ObservableObject {
    enum Sentiment: String {
        case positive, neutral, negative
    }
    
    func analyzeSentiment(for text: String) -> Sentiment {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        let (sentiment, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
        if let scoreStr = sentiment?.rawValue, let score = Double(scoreStr) {
            if score > 0.1 {
                return .positive
            } else if score < -0.1 {
                return .negative
            }
        }
        return .neutral
    }
    
    func advice(for sentiment: Sentiment) -> String {
        switch sentiment {
        case .positive:
            return "Keep up the positive energy! Celebrate your wins."
        case .neutral:
            return "It's okay to feel neutral. Take a moment to reflect or relax."
        case .negative:
            return "It's normal to have tough moments. Consider taking a deep breath or reaching out to someone you trust."
        }
    }
} 