final class ThreeDSecureRepository: ThreeDSecureRepositoryProtocol {
    let remoteDataSource: ThreeDSecureRepositoryRemoteDataSourceProtocol
    
    init(remoteDataSource: ThreeDSecureRepositoryRemoteDataSourceProtocol = ThreeDSecureRepositoryRemoteDataSource()) {
        self.remoteDataSource = remoteDataSource
    }

    func getToken(cardNumber: String,
                  expiryMonth: String,
                  expiryYear: String,
                  cvv: String) async throws -> GetTokenResponseModel {
        try await remoteDataSource.getToken(cardNumber: cardNumber,
                                            expiryMonth: expiryMonth,
                                            expiryYear: expiryYear,
                                            cvv: cvv)
    }
    
    func performPayment(token: String) async throws -> RequestPaymentResponseModel {
        try await remoteDataSource.performPayment(token: token)
    }
}
