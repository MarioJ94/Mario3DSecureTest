import SwiftUI

enum NavigationRoute: Hashable {
    case challenge(URL)
    case result(Bool)
}

struct MainScreen: View {
    private let viewModel: MainScreenViewModelProtocol
    private let navigator: MainScreenNavigatorProtocol
    
    @State private var cardNumberText = ""
    @State private var cardNumber = ""
    @State private var expiration = ""
    @State private var expirationMonth = ""
    @State private var expirationYear = ""
    @State private var cvv = ""
    @State private var validation: CardInputState = .none
    @State private var icon: String? = nil
    @State private var showPaymentError: Bool = false
    @State private var navigation: NavigationRoute? = nil

    init(viewModel: MainScreenViewModelProtocol,
         navigator: MainScreenNavigatorProtocol) {
        self.viewModel = viewModel
        self.navigator = navigator
    }
    var body: some View {
        navigationStack
            .onAppear {
                viewModel.notifyAppearance()
            }
            .onReceive(viewModel.inputStatePublisher) { value in
                validation = value.inputState
                icon = value.icon
                showPaymentError = value.showPaymentError
            }
            .onReceive(viewModel.paymentStatusPublisher) { value in
                guard let value else {
                    return navigation = nil
                }
                switch value {
                case let .pending(redirectURL):
                    if let redirectURL {
                        navigation = .challenge(redirectURL)
                    }
                case .unknown:
                    navigation = nil
                }
            }
    }
    
    let successURL = "https://example.com/payments/success"
    let failureURL = "https://example.com/payments/fail"
    @State private var resultView: Bool?

    @ViewBuilder
    var navigationStack: some View {
        NavigationStack {
            content
                .navigationDestination(item: $navigation, destination: { value in
                    switch value {
                    case .challenge(let url):
                        SecondScreen(
                            url: url,
                            onChallengeResult: { result in
                                navigation = .result(result)
                            },
                            successURL: successURL,
                            failureURL: failureURL)
                    case .result(let success):
                        ResultScreen(isSuccess: success)
                    }
                })
        }
    }
    
    @ViewBuilder
    var content: some View {
        VStack(spacing: 20) {
            cardInputField
            HStack {
                expirationInputField
                cvvInputField
            }
            payButton
            Spacer()
            paymentError
        }
        .padding()
        .frame(maxWidth: .infinity)
        .textFieldStyle(.roundedBorder)
    }
    
    @ViewBuilder
    var cardInputField: some View {
        VStack(alignment: .leading) {
            HStack {
            Text("Card number")
                if let icon {
                    Text("Card type icon (TODO): \(icon)")
                }
            }
            TextField("", text: $cardNumberText)
                .keyboardType(.numberPad)
                .textContentType(.creditCardNumber)
                .onChange(of: cardNumberText) { _, newValue in
                    formatCardNumber(newValue)
                    validate()
                }
        }
    }
    
    @ViewBuilder
    var expirationInputField: some View {
        VStack(alignment: .leading) {
            Text("Expiry date")
            TextField("", text: $expiration)
                .keyboardType(.numberPad)
                .textContentType(.creditCardExpirationMonth)
                .onChange(of: expiration) { _, newValue in
                    formatExpiration(newValue)
                    validate()
                }
        }
    }
    
    @ViewBuilder
    var cvvInputField: some View {
        VStack(alignment: .leading) {
            Text("Cvv")
            TextField("", text: $cvv)
                .keyboardType(.numberPad)
                .textContentType(.creditCardSecurityCode)
                .onChange(of: cvv) { _, newValue in
                    cvv = formatCVV(newValue)
                    validate()
                }
        }
    }
    
    @ViewBuilder
    var payButton: some View {
        VStack(alignment: .center) {
            Button {
                viewModel.didTapPayButton()
            } label: {
                Text("Pay")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!isFormValid)
            errorMessage
        }
    }
    
    @ViewBuilder
    var errorMessage: some View {
        switch validation {
        case .none:
            EmptyView()
        case .result(let set):
            let errors = set.map { $0.message }
            let text = errors.joined(separator: ". ")
            Text(text)
        }
    }
    
    @ViewBuilder
    var paymentError: some View {
        if showPaymentError {
            Text("There was an error when processing your payment. Please try again.")
        }
    }
}

extension MainScreen {
    func formatCardNumber(_ input: String) {
        let digits = Array(input.filter(\.isNumber).prefix(16))
        let chunks = digits.chunked(into: 4)
        let value = chunks.joined(separator: " ")
        let result = value.map { String($0) }.joined()
        cardNumber = String(digits)
        cardNumberText = result
    }
    
    func validate() {
        viewModel.validateCardDetails(cardNumber: cardNumber,
                                      expiryMonth: expirationMonth,
                                      expiryYear: expirationYear,
                                      cvv: cvv)
    }
    
    func formatExpiration(_ input: String) {
        let digits = input.filter(\.isNumber).prefix(4)
        switch digits.count {
        case 0...2:
            let month = String(digits)
            expirationMonth = month
            expiration = month
        default:
            expirationMonth = String(digits.prefix(2))
            expirationYear = String(digits.suffix(digits.count - 2))
            expiration = "\(expirationMonth)/\(expirationYear)"
        }
    }
    
    func formatCVV(_ input: String) -> String {
        return String(input.filter(\.isNumber))
    }
    
    var isFormValid: Bool {
        switch validation {
        case .result(let errors) where errors.isEmpty: true
        case .none, .result: false
        }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension CardValidationError {
    var message: String {
        switch self {
        case .invalidNumber:
            "Invalid Number"
        case .invalidCVV:
            "Invalid CVV"
        case .invalidExpiration:
            "Invalid Expiration"
        case .unknownCard:
            "Unknown Card"
        }
    }
}
