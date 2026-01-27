import Foundation

final class ThreeDSecureAPI: ThreeDSecureAPIProtocol {
    let hostPrefix: String = "5s5vhamy"
    var host: String {
        "\(hostPrefix).api.sandbox.checkout.com"
    }
    
    func requestToken(cardNumber: String,
                      expiryMonth: String,
                      expiryYear: String,
                      cvv: String) async throws -> APIResponse {
        let endpoint = ThreeDSecureToken(host: host,
                                         cardNumber: cardNumber,
                                         expiryMonth: expiryMonth,
                                         expiryYear: expiryYear,
                                         cvv: cvv)
        guard let request = try? endpoint.buildRequest() else {
            throw URLError(.badURL)
        }
//        return try mockedResponse(cardNumber: cardNumber, expiryMonth: expiryMonth, expiryYear: expiryYear, cvv: cvv)
        return try await performRequest(request)
    }
    
    func performPayment(token: String) async throws -> APIResponse {
        let endpoint = ThreeDSecurePayment(host: host,
                                           token: token)
        guard let request = try? endpoint.buildRequest() else {
            throw URLError(.badURL)
        }
//        return try mockedResponse(token: token)
        return try await performRequest(request)
    }
}

private extension ThreeDSecureAPI {
    final class ThreeDSecureToken: EndpointProtocol {
        let scheme: String = "https"
        let host: String
        let path: String = "/tokens"
        let type: String = "card"
        let cardNumber: String
        let expiryMonth: String
        let expiryYear: String
        let cvv: String
        let httpMethod: Endpoint.HTTPMethod = .post
    
        init(host: String, cardNumber: String, expiryMonth: String, expiryYear: String, cvv: String) {
            self.host = host
            self.cardNumber = cardNumber
            self.expiryMonth = expiryMonth
            self.expiryYear = expiryYear
            self.cvv = cvv
        }
        
        var requestBody: Data? {
            get throws {
                let body = [
                    "type": type,
                    "number": cardNumber,
                    "expiry_month": expiryMonth,
                    "expiry_year": expiryYear,
                    "cvv": cvv
                ]
                return try JSONSerialization.data(withJSONObject: body)
            }
        }
        
        var headers: [String : String]? {
            [
                "Content-Type": "application/json",
                "Authorization" : "Bearer \(APIKeys().publicKeyPart1)"
            ]
        }
    }
    
    final class ThreeDSecurePayment: EndpointProtocol {
        let scheme: String = "https"
        let host: String
        let path: String = "/payments"
        let token: String
        let httpMethod: Endpoint.HTTPMethod = .post
    
        init(host: String, token: String) {
            self.host = host
            self.token = token
        }
        
        var requestBody: Data? {
            get throws {
                let body = [
                    "source": [
                        "type": "token",
                        "token": token
                    ],
                    "amount": 6540,
                    "currency": "GBP",
                    "3ds": [
                        "enabled": true
                    ],
                    "success_url": "https://example.com/payments/success",
                    "failure_url": "https://example.com/payments/fail"
                ] as [String : Any]
                return try JSONSerialization.data(withJSONObject: body)
            }
        }
        
        var headers: [String : String]? {
            [
                "Content-Type": "application/json",
                "Authorization" : "Bearer \(APIKeys().privateKeyPat2)"
            ]
        }
    }
}

private extension ThreeDSecureAPI {
    var mockedSuccess: GetTokenResponseEntity {
        GetTokenResponseEntity(token: "success_token")
    }
    
    var mockedError: Error {
        URLError(.badServerResponse)
    }
    
    func mockedResponse(cardNumber: String,
                        expiryMonth: String,
                        expiryYear: String,
                        cvv: String) throws -> Data {
        if cardNumber == "4111111111111111",
           expiryMonth == "04",
           expiryYear == "2030",
           cvv == "123" {
            return try JSONEncoder().encode(mockedSuccess)
        } else {
            throw mockedError
        }
    }
    
    var mockedPaymentResponse: RequestPaymentResponseEntity {
        RequestPaymentResponseEntity(
            status: "Pending",
            _links: RequestPaymentLinksEntity(
                redirect: RequestPaymentRedirectEntity(
                    href: "https://api.checkout.com/3ds/pay_mbabizu24mvu3mela5njyhpit4")))
    }

    func mockedResponse(token: String) throws -> Data {
        if token == "success_token" {
            return try JSONEncoder().encode(mockedPaymentResponse)
        } else {
            throw mockedError
        }
    }
}
