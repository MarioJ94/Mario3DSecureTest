protocol ThreeDSecureRepositoryProtocol {
    func getToken(cardNumber: String,
                  expiryMonth: String,
                  expiryYear: String,
                  cvv: String) async throws -> GetTokenResponseModel
    func performPayment(token: String) async throws -> RequestPaymentResponseModel
}
