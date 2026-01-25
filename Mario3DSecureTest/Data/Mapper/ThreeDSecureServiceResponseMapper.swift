import Foundation

protocol ThreeDSecureServiceResponseMapperProtocol {
    func mapGetToken(_ data: Data) throws -> GetTokenResponseModel
    func mapPayment(_ data: Data) throws -> RequestPaymentResponseModel
}

final class ThreeDSecureServiceResponseMapper: ThreeDSecureServiceResponseMapperProtocol {
    func mapGetToken(_ data: Data) throws -> GetTokenResponseModel {
        let entity = try JSONDecoder().decode(GetTokenResponseEntity.self, from: data)
        return entity.model
    }
    
    func mapPayment(_ data: Data) throws -> RequestPaymentResponseModel {
        let entity = try JSONDecoder().decode(RequestPaymentResponseEntity.self, from: data)
        return entity.model
    }
}

private extension GetTokenResponseEntity {
    var model: GetTokenResponseModel {
        GetTokenResponseModel(token: token)
    }
}

private extension RequestPaymentResponseEntity {
    var model: RequestPaymentResponseModel {
        let status: PaymentStatus = switch status {
        case "Pending":
            .pending(redirectURL: URL(string: _links.redirect.href))
        default:
            .unknown
        }
        return RequestPaymentResponseModel(status: status)
    }
}
