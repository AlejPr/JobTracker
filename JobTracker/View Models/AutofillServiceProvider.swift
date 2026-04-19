//
//  AutofillServiceProvider.swift
//  JobTracker
//


import Foundation


@globalActor
actor AutofillServiceProvider {
    
    static let shared = AutofillServiceProvider()
    
    public static func attemptAutofill(with text: String) async throws -> JobListing {
        do {
            let response = try await GPTWrapper.generateResponse(userPrompt: text)
            if response == "ERROR" { throw NSError(domain: "GPT Response Invalid", code: 0) }
            return JobListing(from: response)
        } catch { throw error }
    }
    
    
    private static func prepareInput(_ inputString: String) -> String {
        return inputString
    }
    
}
