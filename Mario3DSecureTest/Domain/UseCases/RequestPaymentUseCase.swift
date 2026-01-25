struct RequestPaymentParams {
    let token: String
}

protocol RequestPaymentUseCaseProtocol {
    func run(_ params: RequestPaymentParams) async throws -> RequestPaymentResponseModel
}

final class RequestPaymentUseCase: RequestPaymentUseCaseProtocol {
    let repository: ThreeDSecureRepositoryProtocol
    
    init(repository: ThreeDSecureRepositoryProtocol = ThreeDSecureRepository()) {
        self.repository = repository
    }

    func run(_ params: RequestPaymentParams) async throws -> RequestPaymentResponseModel {
        try await repository.performPayment(token: params.token)
    }
}
