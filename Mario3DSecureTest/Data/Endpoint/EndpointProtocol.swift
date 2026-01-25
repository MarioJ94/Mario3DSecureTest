import Foundation

protocol EndpointProtocol {
    var host: String { get }
    var path: String { get }
    var scheme: String { get }
    var port: Int? { get }
    var httpMethod: Endpoint.HTTPMethod { get }
    var queryItems: [URLQueryItem]? { get }
    var headers: [String:String]? { get }
    var requestBody: Data? { get throws }
    var cachePolicy: URLRequest.CachePolicy { get }
    var timeoutInterval: TimeInterval { get }
}

extension EndpointProtocol {
    var scheme: String { "http" }
    var port: Int? { 80 }
    var httpMethod: Endpoint.HTTPMethod { .get }
    var queryItems: [URLQueryItem]? { nil }
    var headers: [String:String]? { nil }
    var requestBody: Data? { nil }
    var cachePolicy: URLRequest.CachePolicy { .useProtocolCachePolicy }
    var timeoutInterval: TimeInterval { 20.0 }
}

extension EndpointProtocol {
    func buildRequest() throws -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.port = port
        urlComponents.path = path
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            return nil
        }
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        request.httpMethod = httpMethod.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = try requestBody
        return request
    }
}
