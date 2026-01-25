import Combine

import Foundation

enum PaymentVerificationStatus {
    case none, pending(URL?)
}

protocol MainScreenViewModelProtocol {
    var inputStatePublisher: AnyPublisher<MainScreenModel, Never> { get }
    var paymentStatusPublisher: AnyPublisher<PaymentStatus?, Never> { get }
    func notifyAppearance()
    func validateCardDetails(cardNumber: String,
                             expiryMonth: String,
                             expiryYear: String,
                             cvv: String)
    func didTapPayButton()
}

struct MainScreenData {
    let cardNumber: String
    let expiryMonth: String
    let expiryYear: String
    let cvv: String
    let cardType: CardType
    let state: CardInputState
    
    static var empty: MainScreenData {
        .init(cardNumber: "",
              expiryMonth: "",
              expiryYear: "",
              cvv: "",
              cardType: .unknown,
              state: .none)
    }
}

struct MainScreenModel {
    let icon: String?
    let inputState: CardInputState
    let showPaymentError: Bool
    
    static var empty: MainScreenModel {
        .init(icon: nil, inputState: .none, showPaymentError: false)
    }
}

final class MainScreenViewModel {
    @Published var model: MainScreenData = .empty
    @Published var showPaymentError: Bool = false
    @Published var paymentStatus: PaymentStatus? = nil

    let validationUseCase: ValidateCardInputUseCaseProtocol
    let requestTokenUseCase: RequestTokenUseCaseProtocol
    let makePaymentUseCase: RequestPaymentUseCaseProtocol
    
    init(validationUseCase: ValidateCardInputUseCaseProtocol = ValidateCardInputUseCase(),
         requestTokenUseCase: RequestTokenUseCaseProtocol = RequestTokenUseCase(),
         makePaymentUseCase: RequestPaymentUseCaseProtocol = RequestPaymentUseCase()) {
        self.validationUseCase = validationUseCase
        self.requestTokenUseCase = requestTokenUseCase
        self.makePaymentUseCase = makePaymentUseCase
    }
}

extension MainScreenViewModel: MainScreenViewModelProtocol {
    var inputStatePublisher: AnyPublisher<MainScreenModel, Never> {
        $model.combineLatest($showPaymentError).map { input, paymentError in
            MainScreenModel(icon: input.cardType.icon,
                            inputState: input.state,
                            showPaymentError: paymentError)
        }.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    
    var paymentStatusPublisher: AnyPublisher<PaymentStatus?, Never> {
        $paymentStatus.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }
    
    func notifyAppearance() {}
    
    func validateCardDetails(cardNumber: String,
                             expiryMonth: String,
                             expiryYear: String,
                             cvv: String) {
        showPaymentError = false
        let value = validationUseCase.run(params: .init(cardNumber: cardNumber,
                                                        expiryMonth: expiryMonth,
                                                        expiryYear: expiryYear,
                                                        cvv: cvv))
        model = .init(cardNumber: cardNumber,
                      expiryMonth: expiryMonth,
                      expiryYear: value.formattedYear ?? expiryYear,
                      cvv: cvv,
                      cardType: value.cardType,
                      state: value.state)
    }
    
    func didTapPayButton() {
        let currentData = model
        switch currentData.state {
        case .result(let errors) where errors.isEmpty:
            makePayment(with: currentData)
        case .none, .result:
            return
        }
    }
    
    func makePayment(with data: MainScreenData) {
        Task {
            do {
                let tokenResponse = try await requestTokenUseCase.run(.init(cardNumber: data.cardNumber,
                                                                    expiryMonth: data.expiryMonth,
                                                                    expiryYear: data.expiryYear,
                                                                    cvv: data.cvv))
                let paymentResult = try await makePaymentUseCase.run(.init(token: tokenResponse.token))
                handlePaymentResponse(paymentResult)
            } catch {
                showPaymentError = true
            }
        }
    }
    
    func handlePaymentResponse(_ result: RequestPaymentResponseModel) {
        paymentStatus = result.status
    }
}

private extension CardType {
    var icon: String? {
        switch self {
        case .visa: "visa"
        case .amex: "amex"
        case .unknown: nil
        }
    }
}
