//
//  BaseState.swift
//  RxRestClient
//
//  Created by Tigran Hambardzumyan on 3/2/18.
//

import Foundation

public struct BaseState {

    public var serviceState: ServiceState

    public var badRequest: Any?

    public var unauthorized: Any?

    public var forbidden: Any?

    public var notFound: Any?

    public var validationProblem: Any?

    public var unexpectedError: Any?

    public init(
        serviceState: ServiceState = .online,
        badRequest: Any? = nil,
        unauthorized: Any? = nil,
        forbidden: Any? = nil,
        notFound: Any? = nil,
        validationProblem: Any? = nil,
        unexpectedError: Any? = nil
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

    public static let offline = BaseState(serviceState: .offline)

    public static let online = BaseState(serviceState: .online)

}

//extension BaseState: Equatable {
//    public static func == (lhs: BaseState, rhs: BaseState) -> Bool {
//        return lhs.serviceState == rhs.serviceState
//            && lhs.badRequest == rhs.badRequest
//            && lhs.unauthorized == rhs.unauthorized
//            && lhs.forbidden == rhs.forbidden
//            && lhs.notFound == rhs.notFound
//            && lhs.validationProblem == rhs.validationProblem
//            && lhs.unexpectedError == rhs.unexpectedError
//    }
//}
