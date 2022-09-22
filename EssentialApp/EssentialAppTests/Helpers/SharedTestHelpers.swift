//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by AmritPandey on 22/09/22.
//

import Foundation

func anyError() -> NSError {
    return NSError(domain: "any-error", code: 0, userInfo: nil)
}

func anyUrl() -> URL {
    return URL(string: "https://any-url.com")!
}

func anyData() -> Data {
    return Data("any-data".utf8)
}
