//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by AmritPandey on 22/09/22.
//

import Foundation
import EssentialFeed

func anyError() -> NSError {
    return NSError(domain: "any-error", code: 0, userInfo: nil)
}

func anyUrl() -> URL {
    return URL(string: "https://any-url.com")!
}

func anyData() -> Data {
    return Data("any-data".utf8)
}

func uniqueFeed() -> [FeedImage] {
    return [FeedImage(id: UUID(), description: "any", location: "any", url: anyUrl())]
}

