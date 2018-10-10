//
//  ResponseState.swift
//  RxRestClient
//
//  Created by Tigran Hambardzumyan on 3/2/18.
//

import Foundation

public protocol ResponseState {

    associatedtype Body: ResponseBody

    var state: BaseState? { get }

    init(state: BaseState)

    init(response: (HTTPURLResponse, Body?))

}

public protocol ResponseBody { }

extension String: ResponseBody { }
extension Data: ResponseBody { }
