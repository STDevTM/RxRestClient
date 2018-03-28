//
//  BaseResponse.swift
//  RxRestClient
//
//  Created by Tigran Hambardzumyan on 3/2/18.
//

import Foundation

public enum BaseResponse {
    case serviceOffline

    /* http status code 400 */
    case badRequest

    /* http status code 401 */
    case unauthorized

    /* http status code 401 */
    case forbidden

    /* http status code 404 */
    case notFound

    /* http status code 422 */
    case validationProblem(error: String)

    /* http status code 500 */
    case unexpectedError(error: String)

}
