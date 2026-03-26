import Foundation

enum AIError: Error, LocalizedError {
    case invalidURL
    case invalidAPIKey
    case networkError(Error)
    case decodingError(Error)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Geçersiz URL."
        case .invalidAPIKey:
            return "Lütfen ayarlardan geçerli bir OpenAI API Anahtarı girin."
        case .networkError(let error):
            return "Bağlantı hatası: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Yanıt okunamadı: \(error.localizedDescription)"
        case .unknown:
            return "Bilinmeyen bir hata oluştu."
        }
    }
}

class AIService {
    static let shared = AIService()
    
    // In a real app, securely store this in Keychain or fetch from your backend
    private var apiKey: String {
        UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
    }
    
    func fetchResponse(messages: [[String: String]]) async throws -> String {
        guard !apiKey.isEmpty else {
            throw AIError.invalidAPIKey
        }
        
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw AIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // System prompt to make it a fashion assistant
        let systemPrompt = [
            "role": "system",
            "content": "Sen lüks ve profesyonel bir moda stil koçusun (Kombin AI). Türkçe konuşursun. Kullanıcılara hava durumuna, etkinliklere ve trendlere göre kıyafet önerileri yaparsın (Örn: 'Akşam dökümlü bir gömlek harika olur!'). Yanıtların kısa, havalı ve vizyoner olsun. Kısa paragraflar kullan."
        ]
        
        var fullMessages = [systemPrompt]
        fullMessages.append(contentsOf: messages)
        
        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": fullMessages,
            "temperature": 0.7
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            throw AIError.unknown
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.unknown
        }
        
        if httpResponse.statusCode == 401 {
            throw AIError.invalidAPIKey
        }
        
        guard httpResponse.statusCode == 200 else {
            throw AIError.networkError(NSError(domain: "Server", code: httpResponse.statusCode, userInfo: nil))
        }
        
        do {
            let json = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            return json.choices.first?.message.content ?? "Bilinmeyen bir hata oluştu."
        } catch {
            throw AIError.decodingError(error)
        }
    }
}

private struct OpenAIResponse: Decodable {
    let choices: [Choice]
    struct Choice: Decodable {
        let message: Message
    }
    struct Message: Decodable {
        let content: String
    }
}
