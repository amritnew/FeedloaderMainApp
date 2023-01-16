//
//  LoadImageCommentFromRemoteUseCase.swift
//  EssentialFeedTests
//
//  Created by AmritPandey on 30/12/22.
//

import XCTest
import EssentialFeed

final class LoadImageCommentFromRemoteUseCase: XCTestCase {
    
    func test_deliversErrorOnNon200HttpResponse() {
        let (sut, client) = makeSUT()
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithResult: .failure(RemoteImageCommentLoader.Error.invalidData)) {
                let json = makeItemJson(items: [])
                client.complete(with: code, data: json, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HttpResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWithResult: .failure(RemoteImageCommentLoader.Error.invalidData)) {
            let invalidJson = Data( "invalidJson".utf8)
            client.complete(with: 200, data: invalidJson)
        }
    }
    
    func test_load_deliversNoItemson200HTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWithResult: .success([])) {
            let emptyListJson = makeItemJson(items: [])
            client.complete(with: 200, data: emptyListJson)
        }
    }
    
    func test_load_deliversItemOn200HTTPResponseWithJSONItems() {
        let (sut, client) = makeSUT()

        let item1 = makeItem(id: UUID(), message: "a comment", createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"), author: CommentAuthorObject(username: "an author"))

        let item2 = makeItem(id: UUID(), message: "another comment", createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"), author: CommentAuthorObject(username: "another author"))

        expect(sut, toCompleteWithResult: .success([item1.model, item2.model])) {
            let data = makeItemJson(items: [item1.json, item2.json])
            client.complete (with: 200, data: data)
        }
    }
    
    //MARK: Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteImageCommentLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentLoader(url: url, client: client)
        trackMemoryLeak(instance: sut)
        trackMemoryLeak(instance: client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteImageCommentLoader, toCompleteWithResult expectedResult: RemoteImageCommentLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        let expectation = expectation(description: "Wait for load completion")
        sut.load { recievedResult in
            switch (recievedResult, expectedResult) {
            case let (.success(recievedItems), .success(expectedItems)):
                XCTAssertEqual(recievedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got instead \(recievedResult)", file: file, line: line)
            }
            
            expectation.fulfill()
        }
        
        action()
        
        wait(for: [expectation], timeout: 1.0)
        
    }
    
    private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8601String: String), author: CommentAuthorObject) -> (model: ImageComment, json: [String: Any]) {
        let item = ImageComment(id: id, message: message, createdAt: createdAt.date, author: author)

        let json: [String: Any] = [
            "id": id.uuidString,
            "message": message,
            "created_At": createdAt.iso8601String,
            "author": [
                "username": author.username
            ]
        ]

        return (item, json)
    }
    
    private func makeItemJson(items: [[String: Any]]) -> Data {
        let itemJSON = [
            "items" : items
            ]
        return try! JSONSerialization.data(withJSONObject: itemJSON)
    }
}
