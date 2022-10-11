//
//  URLSessionHttpClientTests.swift
//  FeedLoaderTests
//
//  Created by AmritPandey on 29/04/22.
//

import XCTest
@testable import EssentialFeed


class URLSessionHttpClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startIngterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequest()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyUrl()
        let exp = expectation(description: "Wait for request")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }

        makeSUT().get(from: url) { _ in }

        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failOnRequestError() {
        let requestError = anyError()
        
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError)
        
        XCTAssertEqual((receivedError as NSError?)?.domain, requestError.domain)
        XCTAssertEqual((receivedError as NSError?)?.code, requestError.code)
    }

    func test_getFromURL_failOnAllNilvalues() {

        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyUrlResponse(), error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyUrlResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHttpUrlResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyUrlResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHttpUrlResponse(), error: anyError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyUrlResponse(), error: nil))
    }
    
    func test_getFromURL_succeedOnHttpUrlResponseWithValidData() {
        let data = anyData()
        let httpUrlResponse = anyHttpUrlResponse()
        let receivedValues = resultValuesFor(data: data, response: httpUrlResponse, error: nil)
        
        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.reponse.url, httpUrlResponse.url)
        XCTAssertEqual(receivedValues?.reponse.statusCode, httpUrlResponse.statusCode)
            
    }
    
    func test_getFromURL_succeedWithEmptyDataOnHttpUrlResponseWithValidData() {
        let httpUrlResponse = anyHttpUrlResponse()
        let receivedValues = resultValuesFor(data: nil, response: httpUrlResponse, error: nil)
        
        let emptyData = Data()
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.reponse.url, httpUrlResponse.url)
        XCTAssertEqual(receivedValues?.reponse.statusCode, httpUrlResponse.statusCode)
            
    }
    
    
    //MARK: Helpers
    
    private func anyData() -> Data {
        return Data("any-data".utf8)
    }
    
    private func anyUrlResponse() -> URLResponse {
        return URLResponse(url: anyUrl(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyHttpUrlResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyUrl(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHttpClient()
        trackMemoryLeak(instance: sut)
        return sut
    }
    
    private func resultFor(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil, file: StaticString = #file, line: UInt = #line) -> HTTPClient.Result {
        var receivedResult: HTTPClient.Result!
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)
        
        let exp = expectation(description: "wait for completion")
        sut.get(from: anyUrl(), completion:  { result in
            receivedResult = result
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    
    private func resultErrorFor(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil, file: StaticString = #file, line: UInt = #line) -> Error? {
        var receivedError: Error?
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch result {
        case let .failure(error):
            receivedError = error
        default:
            XCTFail("Expected failure but got failure \(result) instead", file: file, line:line)
            
        }
            
        return receivedError
    }
    
    private func resultValuesFor(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil, file: StaticString = #file, line: UInt = #line) -> (data: Data, reponse: HTTPURLResponse)? {
        var receivedValues: (data: Data, reponse: HTTPURLResponse)?
        let result = resultFor(data: data, response: response, error: error)
        
        switch result {
        case let .success(data, response):
            receivedValues = (data, response)
        default:
            XCTFail("Expected success but got \(result) instead", file: file, line:line)
        }
        return receivedValues
    }
    
    /**private class URLProtocolStub: URLProtocol {
     private static var stub: Stub?
     private static var requestObserver: ((URLRequest) -> Void)?
     
     private struct Stub {
         let data: Data?
         let response: URLResponse?
         let error: Error?
     }
     
     static func stub(data: Data?, response: URLResponse?, error: Error?) {
         stub = Stub(data: data, response: response, error: error)
     }
     
     static func observeRequests(observer: @escaping (URLRequest) -> Void) {
         requestObserver = observer
     }
     
     static func startInterceptingRequests() {
         URLProtocol.registerClass(URLProtocolStub.self)
     }
     
     static func stopInterceptingRequests() {
         URLProtocol.unregisterClass(URLProtocolStub.self)
         stub = nil
         requestObserver = nil
     }
     
     override class func canInit(with request: URLRequest) -> Bool {
         return true
     }
     
     override class func canonicalRequest(for request: URLRequest) -> URLRequest {
         return request
     }
     
     override func startLoading() {
         if let requestObserver = URLProtocolStub.requestObserver {
             client?.urlProtocolDidFinishLoading(self)
             return requestObserver(request)
         }

         if let data = URLProtocolStub.stub?.data {
             client?.urlProtocol(self, didLoad: data)
         }
         
         if let response = URLProtocolStub.stub?.response {
             client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
         }
         
         if let error = URLProtocolStub.stub?.error {
             client?.urlProtocol(self, didFailWithError: error)
         }
         
         client?.urlProtocolDidFinishLoading(self)
     }
     
     override func stopLoading() {}
 }*/
    
    private class URLProtocolStub: URLProtocol {
        private static var stubs: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        static func stub(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
            stubs = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        static func startIngterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs = nil
            requestObserver = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            
            if let requestObserver = URLProtocolStub.requestObserver {
                client?.urlProtocolDidFinishLoading(self)
                return requestObserver(request)
            }
            
            if let data = URLProtocolStub.stubs?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = URLProtocolStub.stubs?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let error = URLProtocolStub.stubs?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() { }
    }
}
