//
//  BaseResponse.swift
//  RxRestClient
//
//  Created by Tigran Hambardzumyan on 3/2/18.
//

import Foundation

/// Enum for representing basic response cases.
///
/// - serviceOffline: When network service is offline.
/// - badRequest: When recieve **400** status code from server.
/// - unauthorized: When recieve **401** status code from server.
/// - forbidden: When recieve **403** status code from server.
/// - notFound: When recieve **404** status code from server.
/// - validationProblem: When recieve **422** status code from server.
/// - unexpectedError: When recieve `Internal Sever Error`.
public enum BaseResponse: Error {
    case serviceOffline

    case badRequest(body: Any?)

    case unauthorized(body: Any?)

    case forbidden(body: Any?)

    case notFound(body: Any?)

    case validationProblem(error: Any?)

    case unexpectedError(error: Any?)
}
