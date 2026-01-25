struct RequestPaymentResponseEntity: Codable {
    let status: String
    let _links: RequestPaymentLinksEntity
}

struct RequestPaymentLinksEntity: Codable {
    let redirect: RequestPaymentRedirectEntity
}

struct RequestPaymentRedirectEntity: Codable {
    let href: String
}
