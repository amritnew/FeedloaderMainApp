//
//  URLSessionHttpClient.swift
//  FeedLoader
//
//  Created by AmritPandey on 06/05/22.
//

import Foundation


public final class URLSessionHttpClient: HTTPClient {
    
    private let session: URLSession
        
    public init(urlSession: URLSession = .shared) {
        self.session = urlSession
    }
    
    private struct UnexpectedValuesRepresentation: Error {}

    private struct URLSessionTaskWrapper: HTTPClientTask {
        let wrapped: URLSessionTask
        
        func cancel() {
            wrapped.cancel()
        }
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = session.dataTask(with: url) { data, response, error in
            completion(Result {
                if let err = error {
                    throw err
                }
                else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                }
                else {
                    throw UnexpectedValuesRepresentation()
                }
            })
            
        }
        task.resume()
        return URLSessionTaskWrapper(wrapped: task)
    }
}
