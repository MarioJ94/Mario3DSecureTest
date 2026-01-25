import Foundation

struct APIResponse {
    let data: Data
    let response: URLResponse
}

protocol APIProtocol {
    func performRequest(_ request: URLRequest) async throws -> APIResponse
}

extension APIProtocol {
    func performRequest(_ request: URLRequest) async throws -> APIResponse {
        let (data, response) = try await URLSession.shared.data(for: request)
        return APIResponse(data: data, response: response)
    }
}
