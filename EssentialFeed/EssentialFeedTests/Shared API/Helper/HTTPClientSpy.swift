//
//  HTTPClientSpy.swift
//  EssentialFeedTests
//
//  Created by AmritPandey on 11/01/23.
//

import EssentialFeed

class HTTPClientSpy: HTTPClient {
    private class Task: HTTPClientTask {
        func cancel() { }
    }
    private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
    var requestedURLs: [URL] {
        return messages.map{$0.url}
    }
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> EssentialFeed.HTTPClientTask {
        messages.append((url: url, completion: completion))
        return Task()
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(with statusCode: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(url: requestedURLs[index],
                                       statusCode: statusCode,
                                       httpVersion: nil,
                                       headerFields: nil)
        messages[index].completion(.success((data, response!)))
    }

}
