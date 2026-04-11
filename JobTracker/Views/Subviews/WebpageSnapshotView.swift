//
//  WebpageSnapshotView.swift
//  JobTracker
//

import SwiftUI
import WebKit
import Combine

struct WebpageSnapshotView: View {
    
    @ObservedObject var viewModel: ViewModel
    
    @State var currentWebpageZoom: CGFloat = 1.0
    @Binding var currentURLString: String
    @Binding var isExpanded: Bool
    let canExpand: Bool
    
    var body: some View {
        Group {
            if viewModel.currentURL != nil { webSnapshotView }
            else { emptyView }
        }
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(sideBarDividerColor, lineWidth: 2)
        )
        .frame(minHeight: 600)
        
        //Update urlString in viewModel
        .onChange(of: currentURLString, { _, newValue in
            viewModel.updateURL(newValue)
        })
        .onAppear(perform: {
            viewModel.updateURL(currentURLString)
        })
    }
    
    private var webSnapshotView: some View {
        ZStack(alignment: .top) {
            CustomWebView(currentWebpageZoom: $currentWebpageZoom, listingURL: $viewModel.currentURL, attachWebView: viewModel.attachWebView(_:))
            
            HStack {
                if canExpand {
                    WebViewExpansionButton(isExpanded: $isExpanded)
                        .padding(.leading, -5)
                }
                
                Spacer()
                
                WebViewZoomControls (
                    onZoomIn: { currentWebpageZoom = min(currentWebpageZoom + 0.15, 3.0) },
                    onZoomOut: { currentWebpageZoom = max(currentWebpageZoom - 0.15, 0.5) }
                )
                .frame(height: 45)
            }
            .padding(.top, 12)
            .padding(.horizontal, 22)
            .zIndex(1000)
        }
    }
    
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "globe")
                .font(.system(size: 64, weight: .light))
                .foregroundColor(.gray.opacity(0.8))
            
            VStack(spacing: 6) {
                Text("No Preview Available")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.gray.opacity(0.9))
                
                Text("Provide a link to see a web preview")
                    .font(.system(size: 14))
                    .foregroundColor(.gray.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(sideBarColor)
    }
    
}


//MARK: - Webview
extension WebpageSnapshotView {
    
    struct CustomWebView: NSViewRepresentable {
        
        //@State var currentWebView: WKWebView?
        @Binding var currentWebpageZoom: CGFloat
        @Binding var listingURL: URL?
        let attachWebView: (WKWebView) -> Void
        
        func makeNSView(context: Context) -> WKWebView {
            let config = WKWebViewConfiguration()
            let preferences = WKWebpagePreferences()
            preferences.allowsContentJavaScript = true
            config.defaultWebpagePreferences = preferences
            
            let webView = WKWebView(frame: .zero, configuration: config)
            webView.allowsMagnification = true
            webView.allowsBackForwardNavigationGestures = true
            
            webView.load(URLRequest(url: listingURL!))
            DispatchQueue.main.async { attachWebView(webView) }
            return webView
        }
        
        func updateNSView(_ nsView: WKWebView, context: Context) {
            if let url = listingURL, nsView.url != url {
                nsView.load(URLRequest(url: url))
            }
            
            if nsView.pageZoom != currentWebpageZoom {
                zoomWithAnimation(nsView, to: currentWebpageZoom)
            }
        }
        
        //TODO: - Fix this shit
        private func zoomWithAnimation(_ webView: WKWebView, to newZoom: CGFloat) {
//            NSAnimationContext.runAnimationGroup { context in
//                context.duration = 0.3
//                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//                webView.animator().pageZoom = newZoom
//            }
            webView.pageZoom = newZoom
        }
        
    }
    
}


//MARK: - View Model
extension WebpageSnapshotView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published var currentURL: URL? = nil
        @Published var currentImage: NSImage? = nil
        @Published var fetchError: String? = nil
        private weak var webView: WKWebView?
        
        func updateURL(_ newURLString: String) {
            let trimmed = newURLString.trimmingCharacters(in: .whitespacesAndNewlines)
            currentURL = isValidUrl(url: trimmed) ? URL(string: trimmed) : nil
        }
        
        func attachWebView(_ webView: WKWebView) { self.webView = webView }
    
        
        public func exportPDF() async throws -> Data {
            return try await withCheckedThrowingContinuation { continuation in
                guard let webView else {
                    continuation.resume(throwing: NSError(domain: "WebpageSnapshotView", code: 1, userInfo: [NSLocalizedDescriptionKey: "No WebView available"]))
                    return
                }
                 
                let config = WKPDFConfiguration()
                webView.createPDF(configuration: config) { result in
                    switch result {
                    case .success(let data): continuation.resume(returning: data)
                    case .failure(let error): continuation.resume(throwing: error)
                    }
                }
                
                return
            }
        }
        
    }
    
}




#Preview {
    
    PreviewStruct()
        .frame(width: 800, height: 600)
        .background(Color.white)
}


fileprivate struct PreviewStruct: View {
    static let google = "https://www.google.com"
    static let apple = "https://www.apple.org"
    @State var pageString = Self.google
    @State var isExpanded: Bool = false
    @StateObject var vm = WebpageSnapshotView.ViewModel()
    
    var body: some View {
        WebpageSnapshotView(viewModel: vm, currentURLString: $pageString, isExpanded: $isExpanded, canExpand: true)
    }
    
}

