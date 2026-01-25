import SwiftUI

struct SecondScreen: View {
    private let url: URL
    
    @State private var cardNumberText = ""

    init(url: URL) {
        self.url = url
    }

    var body: some View {
        VStack {
            WebView(url: URL(string: "https://www.google.es")!)
                .ignoresSafeArea(.all)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
                .opacity(0.7)
                .background(Color.blue)
        }
        .frame(maxWidth: .infinity)
        .background(Color.red)
    }
}

import WebKit

struct WebView: UIViewRepresentable {
    func updateUIView(_ uiView: UIView, context: Context) {}

//    @ObservedObject var viewModel: WebViewModel
    let webView = WKWebView()
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator(url: url)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        private let url: URL
//        private var viewModel: WebViewModel

        init(url: URL) {
            self.url = url
//            self.viewModel = viewModel
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//            self.viewModel.didFinishLoading = webView.isLoading
            print("hola")
        }
    }

    public func makeUIView(context: Context) -> UIView {
        self.webView.navigationDelegate = context.coordinator
        self.webView.load(URLRequest(url: url))

        return self.webView
    }
}
