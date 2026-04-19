//
//  GPTWrapper.swift
//  JobTracker
//

import SwiftUI
import ChatGPTSwift

@globalActor
actor GPTWrapper {
    
    static let shared = GPTWrapper()
    
    static private var apiKeyString: String? { Bundle.main.object(forInfoDictionaryKey: "CHATGPT_API_KEY") as? String }
    
    static private var api: ChatGPTAPI? {
        guard let keyString = apiKeyString else { return nil }
        return ChatGPTAPI(apiKey: keyString)
    }
    
    static private var devPrompt: String? { Bundle.main.object(forInfoDictionaryKey: "DEV_PROMPT") as? String }
    
    static private let gptModel = "gpt-5.4-nano"
    
    static public func generateResponse(userPrompt: String) async throws -> String {
        do {
            guard let api = api else { throw NSError(domain: "ChatGPT API Key invalid!", code: 0) }
            guard let devPrompt = devPrompt else { throw NSError(domain: "Invalid dev prompt!", code: 0) }
            api.deleteHistoryList()
            let response = try await api.sendMessage(text: userPrompt,
                                                     model: gptModel,
                                                     systemText: devPrompt)
            return response
        } catch { throw error }
    }
    
    
}
