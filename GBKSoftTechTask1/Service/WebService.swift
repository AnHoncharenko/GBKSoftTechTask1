//
//  WebService.swift
//  GBKSoftTechTask1
//
//  Created by Anton Honcharenko on 19.11.2020.
//

import Foundation
import SwiftyJSON
import PromiseKit

class WebService: NSObject {
    enum HTTPMethod: String {
        case GET
    }

    static let shared = WebService()
    var defaultUrlParam = [String: String]()

    private func generateRequest(with resource: Resource) -> URLRequest? {
        guard var urlComponents = URLComponents(url: URL(string: "https://randomuser.me")!, resolvingAgainstBaseURL: true) else { return nil }
        urlComponents.path = resource.path
        var allParam = defaultUrlParam
        resource.urlParam.forEach({ allParam[$0.key] = $0.value })
        urlComponents.queryItems = allParam.map({ URLQueryItem(name: $0.key, value: $0.value) })
        guard let url = urlComponents.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = resource.method.rawValue
        return request
    }

    func request(with resource: Resource) -> Promise<JSON> {
        let pendingPromise = Promise<JSON>.pending()
        guard let request = generateRequest(with: resource) else {
            pendingPromise.resolver.reject(Errors.invalidURL)
            return pendingPromise.promise
        }

        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            let response = $1 as? HTTPURLResponse
            let status = response?.statusCode ?? 0
            print("➡️ \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")")
            request.allHTTPHeaderFields?.forEach({ print("\($0): \($1)") })
            if let requestBody = request.httpBody { print(String(data: requestBody,
                                                                 encoding: .utf8) ?? "<<Binary Data>>") }
            print("⬅️ \(status)")
            response?.allHeaderFields.forEach({ print("\($0): \($1)") })

            if let responseBody = request.httpBody { print(String(data: responseBody,
                                                                  encoding: .utf8) ?? "<<Binary Data>>") }
            if let responseData = $0 { print(String(data: responseData, encoding: .utf8) ?? "<<Binary Data>>") }
            if let error = $2 { print("❗️", error) }
            guard (200...299).contains(status) else {
                return pendingPromise.resolver.reject(Errors.invalidStatus(status, JSON($0 as Any)))
            }
            if let error = $2 {
                pendingPromise.resolver.reject(error)
                return
            }
            if let data = $0 {
                let json = JSON(data)
                pendingPromise.resolver.fulfill(json)
                return
            }
            pendingPromise.resolver.reject(Errors.canNotParseJSON($0))
        })
        task.resume()
        return pendingPromise.promise
    }
}

extension WebService {

    enum Errors: Error {
        case invalidURL
        case cantGenerateBody
        case canNotParseJSON(Data?)
        case invalidStatus(Int, JSON?)
    }
}

extension WebService {
    struct RequestBody {
        let data: Data?
        let contentType: String?

        static func json(_ object: Any) -> RequestBody {
            let json = JSON(object)
            return RequestBody(data: try? json.rawData(), contentType: "application/json")
        }
    }
}

extension WebService {
    struct Resource {
        let path: String
        let method: HTTPMethod
        let urlParam: [String: String]

        init(path: String,
             method: HTTPMethod = .GET,
             urlParam: [String: String] = [:],
             body: RequestBody? = nil,
             headers: [String: String] = [:]) {
            self.path = path
            self.method = method
            self.urlParam = urlParam
        }
    }
}
