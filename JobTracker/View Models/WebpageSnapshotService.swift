//
//  WebpageSnapshotService.swift
//  JobTracker
//


import SwiftUI
import WebKit

actor WebpageSnapshotService {
    
    static let main = WebpageSnapshotService()
    private var cache = [String: CachedWebPage]()
    
    private var webView: WKWebView? = nil
    private var webViewDelegate: WebViewLoadDelegate? = nil
    private var currentRequest: String? = nil
    
    public func snapshot(for listingURL: URL) async throws -> NSImage {
        if let cached = cache[listingURL.absoluteString] { return cached.snapshot }
        let (webView, webViewDelegate) = await fetchWebView()
        
        currentRequest = listingURL.absoluteString
        
        do {
            let loadResult = try await loadWebPage(webView: webView, delegate: webViewDelegate, url: listingURL)
            guard loadResult else { throw SnapshotError.invalidURL }
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            guard currentRequest == listingURL.absoluteString else { throw SnapshotError.canceled }
            let snapshot = try await takeSnapshot(of: webView)
            
            let cachedWebpage = CachedWebPage(snapshot: snapshot, timestamp: .now)
            cache[listingURL.absoluteString] = cachedWebpage
            return snapshot
        } catch { throw error }
    }
    
    
    private func fetchWebView() async -> (WKWebView, WebViewLoadDelegate) {
        if let webView,
           let webViewDelegate { return (webView, webViewDelegate) }
        let (webView, webViewDelegate) = await loadWebView()
        self.webView = webView; self.webViewDelegate = webViewDelegate
        return (webView, webViewDelegate)
    }
    
    
    //Sends a load request to the webview on the main thread and then returns a throwing continuation when finished
    private func loadWebPage(webView: WKWebView, delegate: WebViewLoadDelegate, url: URL) async throws -> Bool {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                var requestCompleted = false
                
                //Completion handler, page finished loading (either success / failure)
                delegate.onComplete = { success, error in
                    guard !requestCompleted else { return }
                    requestCompleted = true
                    
                    if let error { continuation.resume(throwing: error) }
                    else { continuation.resume(returning: success) }
                }
                
                //Call the page load
                DispatchQueue.main.async {
                    print("Loading on main thread: \(Thread.current)")
                    webView.load(URLRequest(url: url))
                }
                
                //Request timed out
                DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                    guard !requestCompleted else { return }
                    requestCompleted = true
                    
                    continuation.resume(throwing: SnapshotError.timeout)
                }
            }
        } catch { throw error }
    }
    
    
    //
    @MainActor private func takeSnapshot(of webView: WKWebView) async throws -> NSImage {
        try await withCheckedThrowingContinuation { continuation in
            let config = WKSnapshotConfiguration()
            config.rect = CGRect(x: 0, y: 0, width: webView.bounds.width, height: webView.bounds.height)
            
            webView.takeSnapshot(with: config) { image, error in
                if let error = error { continuation.resume(throwing: error) }
                else if let image = image { continuation.resume(returning: image) }
                else { continuation.resume(throwing: SnapshotError.snapshotFailed) }
            }
        }
    }
    
    
    @MainActor private func loadWebView() async -> (WKWebView, WebViewLoadDelegate) {
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 1920, height: 1080))
        let delegate = WebViewLoadDelegate()
        webView.navigationDelegate = delegate
        return (webView, delegate)
    }
    
    
    //MARK: - Webview load delegate
    nonisolated private final class WebViewLoadDelegate: NSObject, WKNavigationDelegate {
        var onComplete: ((Bool, Error?) -> Void)?

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("Successfully navigated webpage")
            onComplete?(true, nil)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
            print("failed to navigate to webpage with error \(error)")
            onComplete?(false, error)
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
            print("failed to navigate to webpage with error \(error)")
            onComplete?(false, error)
        }
        
    }
    
    
}


extension WebpageSnapshotService {
    
    struct CachedWebPage {
        //let webView: WKWebView
        let snapshot: NSImage
        let timestamp: Date
    }
    
    
    enum SnapshotError: LocalizedError {
        case invalidURL
        case timeout
        case snapshotFailed
        case canceled
        case duplicateRequest
        
        var errorDescription: String? {
            switch self {
            case .invalidURL: return "Invalid URL"
            case .timeout: return "Page load timeout"
            case .snapshotFailed: return "Failed to capture snapshot"
            case .canceled: return "Snapshot Cancelled"
            case .duplicateRequest: return "Duplicate Request"
            }
        }
    }
    
}

typealias CachedWebpage = WebpageSnapshotService.CachedWebPage
typealias SnapshotError = WebpageSnapshotService.SnapshotError

