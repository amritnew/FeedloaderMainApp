//
//  XCTestcase+MemoryTracking.swift
//  EssentialAppTests
//
//  Created by AmritPandey on 22/09/22.
//

import XCTest

extension XCTestCase {
    func trackMemoryLeak(instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
       addTeardownBlock { [weak instance] in
           XCTAssertNil(instance, "Instance of sut have been deallocated. Potential memory leak", file: file, line: line)
       }
   }
}
