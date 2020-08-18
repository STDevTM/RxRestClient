//
//  RxRestClientTests.swift
//  RxRestClientTests
//
//  Created by Tigran Hambardzumyan on 7/23/20.
//  Copyright © 2020 STDev. All rights reserved.
//

import Alamofire
import XCTest

@testable import RxRestClient

final class RxRestClientTests: XCTestCase {
    func testValidateSuccess() throws {
        // Given
        let client = RxRestClient()
        let url = URL(string: "http://example.com")!
        let request = URLRequest(url: url)
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: [:])!
        let data = Data()

        // When
        let result = client.validate(request, response, data)

        // Then
        guard case .success = result else {
            XCTFail("Expected .success, got \(result)")
            return
        }
    }

    func testValidateFailure() throws {
        // Given
        let client = RxRestClient()
        let url = URL(string: "http://example.com")!
        let request = URLRequest(url: url)
        let response = HTTPURLResponse(url: url, statusCode: 400, httpVersion: nil, headerFields: [:])!
        let data = "Some error response".data(using: .utf8)

        // When
        let result = client.validate(request, response, data)

        // Then
        if case let .failure(error) = result {
            let baseResponse = error as? BaseResponse
            XCTAssertNotNil(baseResponse)
            if case let .badRequest(body) = baseResponse {
                let errorBody = body as? Data
                XCTAssertEqual(errorBody, data)
            } else {
                XCTFail("Expected .badRequest, got \(baseResponse.debugDescription)")
            }
        } else {
            XCTFail("Expected .failure, got \(result)")
        }
    }

    func testMimeType() {
        // Given
        let ext = "png"
        let expectedMimeType = "image/png"

        // When
        let mimeType = MIMETypes.mimeType(for: ext)

        // Then
        XCTAssertEqual(mimeType, expectedMimeType)
    }

    static var allTests = [
        ("testValidateSuccess", testValidateSuccess),
        ("testValidateFailure", testValidateFailure),
        ("testMimeType", testMimeType)
    ]
}
