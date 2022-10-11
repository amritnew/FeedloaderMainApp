//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by AmritPandey on 19/09/22.
//

import Foundation

public final class RemoteFeedImageDataLoader: FeedImageDataLoader {
    
    private let httpClient: HTTPClient
    
    public init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    public enum Error: Swift.Error {
            case connectivity
            case invalidData
        }
    
    private final class HTTPClientTaskWrapper: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result)-> Void)?
        
        var wrapped: HTTPClientTask?
        
        init(_ completion: @escaping (FeedImageDataLoader.Result)-> Void) {
            self.completion = completion
        }
        
        func completion(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            completion = nil
            wrapped?.cancel()
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        task.wrapped = httpClient.get(from: url, completion: { [weak self] result in
            guard self != nil else {return}
            
            task.completion(with: result
                .mapError{ _ in Error.connectivity}
                .flatMap { (data, response) in
                    let isValidResponse = response.isOK && !data.isEmpty
                    return isValidResponse ? .success(data) : .failure(Error.invalidData)
                }
            )
        })
        
        return task
    }
     
}
 
