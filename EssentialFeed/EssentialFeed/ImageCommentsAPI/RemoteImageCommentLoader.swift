//
//  RemoteImageCommentLoader.swift
//  EssentialFeed
//
//  Created by AmritPandey on 10/01/23.
//

import Foundation

public class RemoteImageCommentLoader {
    public typealias Result = Swift.Result<[ImageComment], Error>
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private let client: HTTPClient
    private let url: URL
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping ((Result) -> Void)) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success((data, response)):
                completion(RemoteImageCommentLoader.map(data, response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
            
        }
    }
    
    static func map(_ data: Data, _ response: HTTPURLResponse) -> Result {
        do  {
            let items = try ImageCommentMapper.map(data, response)
            return .success(items)
        }
        catch {
            return .failure(Error.invalidData)
        }
    }
}
