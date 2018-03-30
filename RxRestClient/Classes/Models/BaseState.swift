//
//  BaseState.swift
//  RxRestClient
//
//  Created by Tigran Hambardzumyan on 3/2/18.
//

import Foundation

public struct BaseState {

    public var serviceState: ServiceState

    public var badRequest: Bool?

    public var unauthorized: Bool?

    public var forbidden: Bool?

    public var notFound: Bool?

    public var validationProblem: String?

    public var unexpectedError: String?

    public init(
        serviceState: ServiceState = .online,
        badRequest: Bool? = nil,
        unauthorized: Bool? = nil,
        forbidden: Bool? = nil,
        notFound: Bool? = nil,
        validationProblem: String? = nil,
        unexpectedError: String? = nil
        ) {
        self.serviceState = serviceState
        self.badRequest = badRequest
        self.unauthorized = unauthorized
        self.forbidden = forbidden
        self.notFound = notFound
        self.validationProblem = validationProblem
        self.unexpectedError = unexpectedError
    }

    public static let empty = BaseState()

    public static let badRequestState = BaseState(badRequest: true)

    public static let unauthorizedState = BaseState(unauthorized: true)

    public static let forbiddenState = BaseState(forbidden: true)

    public static let notFoundState = BaseState(notFound: true)

    public static let offline = BaseState(serviceState: .offline)

    public static let online = BaseState(serviceState: .online)

}

extension BaseState: Equatable {
    public static func == (lhs: BaseState, rhs: BaseState) -> Bool {
        return lhs.serviceState == rhs.serviceState
            && lhs.badRequest == rhs.badRequest
            && lhs.unauthorized == rhs.unauthorized
            && lhs.forbidden == rhs.forbidden
            && lhs.notFound == rhs.notFound
            && lhs.validationProblem == rhs.validationProblem
            && lhs.unexpectedError == rhs.unexpectedError
    }
}
