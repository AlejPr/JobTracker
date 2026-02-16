//
//  LinkSnapshotView.swift
//  JobTracker
//

import SwiftUI
import WebKit
import Combine

struct LinkSnapshotView: View {
    
    @Binding var currentURLString: String
    @StateObject private var viewModel = ViewModel()
    
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
        CustomWebView(listingURL: $viewModel.currentURL)
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


extension LinkSnapshotView {
    
    struct CustomWebView: NSViewRepresentable {
        @Binding var listingURL: URL?
        
        func makeNSView(context: Context) -> WKWebView {
            let config = WKWebViewConfiguration()
            let preferences = WKWebpagePreferences()
            preferences.allowsContentJavaScript = true
            config.defaultWebpagePreferences = preferences
            
            let webView = WKWebView(frame: .zero, configuration: config)
            webView.allowsMagnification = true
            webView.allowsBackForwardNavigationGestures = true
                        
            webView.load(URLRequest(url: listingURL!))
            return webView
        }
        
        func updateNSView(_ nsView: WKWebView, context: Context) {
        }
        
    }
    
}


//MARK: - View Model
extension LinkSnapshotView {
    
    @MainActor
    final class ViewModel: ObservableObject {
        
        @Published var currentURL: URL? = nil
        @Published var currentImage: NSImage? = nil
        @Published var fetchError: String? = nil
        
        func updateURL(_ newURLString: String) {
            let trimmed = newURLString.trimmingCharacters(in: .whitespacesAndNewlines)
            currentURL = isValidUrl(url: trimmed) ? URL(string: trimmed) : nil

        }
        
    }
    
}




#Preview {
    
    PreviewStruct()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
}

fileprivate struct PreviewStruct: View {
    static let google = "https://www.google.com"
    static let apple = "https://www.apple.org"
    @State var pageString = Self.google
    
    var body: some View { LinkSnapshotView(currentURLString: $pageString) }
    
}

