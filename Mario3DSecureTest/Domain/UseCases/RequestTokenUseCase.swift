struct RequestTokenParams {
    let cardNumber: String
    let expiryMonth: String
    let expiryYear: String
    let cvv: String
}

protocol RequestTokenUseCaseProtocol {
    func run(_ params: RequestTokenParams) async throws -> GetTokenResponseModel
}

final class RequestTokenUseCase: RequestTokenUseCaseProtocol {
    let repository: ThreeDSecureRepositoryProtocol
    
    init(repository: ThreeDSecureRepositoryProtocol = ThreeDSecureRepository()) {
        self.repository = repository
    }

    func run(_ params: RequestTokenParams) async throws -> GetTokenResponseModel {
        try await repository.getToken(cardNumber: params.cardNumber,
                                      expiryMonth: params.expiryMonth,
                                      expiryYear: params.expiryYear,
                                      cvv: params.cvv)
    }
}
