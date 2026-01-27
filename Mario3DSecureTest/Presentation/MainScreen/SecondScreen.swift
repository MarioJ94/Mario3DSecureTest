import SwiftUI

struct SecondScreen: View {
    private let url: URL
    private let successURL: String
    private let failureURL: String
    private let onChallengeResult: (Bool) -> Void

    @State private var cardNumberText = ""
    
    init(url: URL, onChallengeResult: @escaping (Bool) -> Void, successURL: String, failureURL: String) {
        self.url = url
        self.onChallengeResult = onChallengeResult
        self.successURL = successURL
        self.failureURL = failureURL
    }

    var body: some View {
        VStack {
            webView
                .ignoresSafeArea(.all)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
                .opacity(0.7)
                .background(Color.blue)
        }
        .frame(maxWidth: .infinity)
        .background(Color.red)
    }
    
    var webView: some View {
        WebView(viewModel: .init(url: url, onResultReceived: { message in
            if message == successURL {
                onChallengeResult(true)
            } else if message == failureURL {
                onChallengeResult(false)
            } else {
                return false
            }
            return true
        }))
    }
}

import WebKit

struct WebViewModel {
    let url: URL
    let onResultReceived: (String) -> Bool
}

struct WebView: UIViewRepresentable {
    fileprivate let viewModel: WebViewModel

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }

    public func makeUIView(context: Context) -> WKWebView {
        let contentController = WKUserContentController()
        contentController.add(context.coordinator, name: "iosListener")

        let config = WKWebViewConfiguration()
        config.userContentController = contentController

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator

        webView.load(URLRequest(url: viewModel.url))
        return webView
    }
}

extension WebView {
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        private let parent: WebView

        init(_ parent: WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void) {
            if let url = navigationAction.request.url,
               let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                
                let baseURL = [components.scheme, "://", components.host, components.path]
                    .compactMap { $0 }.joined()
                
                if parent.viewModel.onResultReceived(baseURL) {
                    decisionHandler(.cancel)
                } else {
                    decisionHandler(.allow)
                }
            } else {
                decisionHandler(.allow)
            }
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            guard message.name == "iosListener" else { return }

        }
    }
}
