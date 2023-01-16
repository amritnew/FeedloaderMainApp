//
//  RemoteImageCommentLoader.swift
//  EssentialFeed
//
//  Created by AmritPandey on 10/01/23.
//

import Foundation

public typealias RemoteImageCommentLoader = RemoteLoader<[ImageComment]>

extension RemoteImageCommentLoader {
    public convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: ImageCommentMapper.map)
    }
}
