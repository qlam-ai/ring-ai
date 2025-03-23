import Foundation

class AISummaryViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var summary = ""
    @Published var error: String?
    
    private let apiKey = Config.apiKey
    private let endpoint = Config.endpoint
    private let deploymentName = Config.deploymentName
    private let apiVersion = "2023-05-15"
    
    func generateSummary(stepsHistory: [Int]) {
        guard !apiKey.isEmpty else {
            self.error = "API Key not found"
            return
        }
        
        guard !endpoint.isEmpty else {
            self.error = "Endpoint not found"
            return
        }
        
        guard !deploymentName.isEmpty else {
            self.error = "Deployment name not found"
            return
        }
        
        isLoading = true
        error = nil
        
        let url = URL(string: "https://\(endpoint).openai.azure.com/openai/deployments/\(deploymentName)/chat/completions?api-version=\(apiVersion)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let prompt = """
        Analyze this 7-day step history (from most recent to oldest): \(stepsHistory.map(String.init).joined(separator: ", ")) steps.
        Provide a brief, encouraging summary of the user's physical activity. Include:
        1. Overall trend
        2. Best performing day
        3. Areas for improvement
        Keep the tone positive and motivational. Response should be 2-3 sentences.
        """
        
        let messages: [[String: String]] = [
            ["role": "system", "content": "You are a helpful fitness analysis AI assistant."],
            ["role": "user", "content": prompt]
        ]
        
        let requestBody: [String: Any] = [
            "messages": messages,
            "max_tokens": 800,
            "temperature": 0.7,
            "frequency_penalty": 0,
            "presence_penalty": 0,
            "top_p": 0.95
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            DispatchQueue.main.async {
                self.error = "Failed to create request: \(error.localizedDescription)"
                self.isLoading = false
            }
            return
        }
        
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                }
                
                guard httpResponse.statusCode == 200 else {
                    throw NSError(domain: "", code: httpResponse.statusCode, 
                                userInfo: [NSLocalizedDescriptionKey: "API returned status code \(httpResponse.statusCode)"])
                }
                
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    DispatchQueue.main.async {
                        self.summary = content
                        self.isLoading = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = "Failed to generate summary: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
} 