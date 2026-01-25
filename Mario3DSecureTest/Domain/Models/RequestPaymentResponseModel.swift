import Foundation

struct RequestPaymentResponseModel {
    let status: PaymentStatus
}

enum PaymentStatus {
    case pending(redirectURL: URL?)
    case unknown
}
