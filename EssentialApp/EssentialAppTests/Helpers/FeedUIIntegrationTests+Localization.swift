//
//  FeedUIIntegrationTests+Localization.swift
//  EssentialFeediOSTests
//
//  Created by AmritPandey on 28/07/22.
//

import XCTest
import EssentialFeed
import Foundation

extension FeedUIIntegrationTests {
    func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let localizedKey = key
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: localizedKey, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string key: \(localizedKey) in table \(table)", file: file, line: line)
        }
        return value
    }
}
