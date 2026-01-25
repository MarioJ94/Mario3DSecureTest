import Foundation

protocol ThreeDSecureAPIProtocol: APIProtocol {
    func requestToken(cardNumber: String,
                      expiryMonth: String,
                      expiryYear: String,
                      cvv: String) async throws -> Data
    func performPayment(token: String) async throws -> Data
}
