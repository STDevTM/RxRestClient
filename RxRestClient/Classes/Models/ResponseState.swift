//
//  ResponseState.swift
//  RxRestClient
//
//  Created by Tigran Hambardzumyan on 3/2/18.
//

import Foundation

public protocol ResponseState {
    var state: BaseState? { get }

    init(state: BaseState)
    
    init(response: (HTTPURLResponse, String))
}
