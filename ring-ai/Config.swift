import Foundation

struct Config {
    static let apiKey: String = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
    static let endpoint: String = ProcessInfo.processInfo.environment["OPENAI_ENDPOINT"] ?? ""
    static let deploymentName: String = ProcessInfo.processInfo.environment["OPENAI_DEPLOYMENT_NAME"] ?? ""
} 