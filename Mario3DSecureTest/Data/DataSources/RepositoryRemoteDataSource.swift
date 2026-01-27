import Foundation

protocol ThreeDSecureRepositoryRemoteDataSourceProtocol {
    func getToken(cardNumber: String,
                  expiryMonth: String,
                  expiryYear: String,
                  cvv: String) async throws -> GetTokenResponseModel
    func performPayment(token: String) async throws -> RequestPaymentResponseModel
}

final class ThreeDSecureRepositoryRemoteDataSource: ThreeDSecureRepositoryRemoteDataSourceProtocol {
    let service: ThreeDSecureAPIProtocol
    let mapper: ThreeDSecureServiceResponseMapperProtocol
    
    init(service: ThreeDSecureAPIProtocol = ThreeDSecureAPI(),
         mapper: ThreeDSecureServiceResponseMapperProtocol = ThreeDSecureServiceResponseMapper()) {
        self.service = service
        self.mapper = mapper
    }
    
    func getToken(cardNumber: String,
                  expiryMonth: String,
                  expiryYear: String,
                  cvv: String) async throws -> GetTokenResponseModel {
        let response = try await service.requestToken(cardNumber: cardNumber,
                                                  expiryMonth: expiryMonth,
                                                  expiryYear: expiryYear,
                                                  cvv: cvv)
        let model = try mapper.mapGetToken(response.data)
        return model
    }
    
    func performPayment(token: String) async throws -> RequestPaymentResponseModel {
        let response = try await service.performPayment(token: token)
        let model = try mapper.mapPayment(response.data)
        return model
    }
}
