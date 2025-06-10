import Foundation

class OpenAIService {
    static let shared = OpenAIService()
    private let apiKey: String
    private let apiURL = URL(string: "https://api.openai.com/v1/chat/completions")!
    
    private init() {
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let key = dict["OpenAIAPIKey"] as? String {
            self.apiKey = key
        } else {
            self.apiKey = ""
        }
    }
    
    func classifyTopicsAndPrompt(transcript: String, completion: @escaping (String, String) -> Void) {
        let systemPrompt = "You are an assistant that classifies the main topic of a journal entry and suggests a context-aware journaling prompt. Respond in JSON: {\"topic\": <topic>, \"prompt\": <prompt>}"
        let userPrompt = "Journal entry: \"\(transcript)\""
        let messages: [[String: String]] = [
            ["role": "system", "content": systemPrompt],
            ["role": "user", "content": userPrompt]
        ]
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": messages,
            "max_tokens": 100
        ]
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion("Unknown", "Could not get prompt.")
                return
            }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let message = choices.first?["message"] as? [String: Any],
               let content = message["content"] as? String,
               let contentData = content.data(using: .utf8),
               let result = try? JSONSerialization.jsonObject(with: contentData) as? [String: String],
               let topic = result["topic"],
               let prompt = result["prompt"] {
                completion(topic, prompt)
            } else {
                completion("Unknown", "Could not parse response.")
            }
        }
        task.resume()
    }
} 