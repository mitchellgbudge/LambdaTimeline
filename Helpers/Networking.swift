//
//  Networking.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum Networking {
    
    static func performRequestFor(url: URL, httpMethod: HTTPMethod, parameters: [String: String]? = nil, headers: [String: String]? = nil, body: Data? = nil, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        var formattedURL: URL? = url
        
        if let parameters = parameters { formattedURL = format(url: url, with: parameters) }
        
        guard let requestURL = formattedURL else { fatalError("requestURL is nil") }
        
        var request = URLRequest(url: requestURL)
        
        request.httpMethod = httpMethod.rawValue
        request.httpBody = body
        
        if let headers = headers {
            headers.forEach { (key, value) in
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        URLSession.shared.dataTask(with: request, completionHandler: completion).resume()
    }
    
    static private func format(url: URL, with queryParameters: [String: String]) -> URL? {
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        urlComponents?.queryItems = queryParameters.compactMap({ URLQueryItem(name: $0.key, value: $0.value) })
        
        return urlComponents?.url ?? nil
    }
}
