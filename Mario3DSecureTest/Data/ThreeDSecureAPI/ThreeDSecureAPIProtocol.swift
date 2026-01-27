import Foundation

protocol ThreeDSecureAPIProtocol: APIProtocol {
    func requestToken(cardNumber: String,
                      expiryMonth: String,
                      expiryYear: String,
                      cvv: String) async throws -> APIResponse
    func performPayment(token: String) async throws -> APIResponse
}
