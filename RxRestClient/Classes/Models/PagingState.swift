//
//  PagingState.swift
//  Alamofire
//
//  Created by Tigran Hambardzumyan on 2/11/19.
//

import Foundation

open class PagingState<R: PagingResponseProtocol>: ResponseState {

    public typealias Body = Data

    public var state: BaseState?
    public var response: R?

    required public init(state: BaseState) {
        self.state = state
    }

    required public init(response: (HTTPURLResponse, Data?)) {
        self.state = BaseState.online
        if 200..<300 ~= response.0.statusCode, let data = response.1 {
            do {
                self.response = try R.decoder.decode(R.self, from: data)
            } catch let error {
                self.state = BaseState(unexpectedError: error)
            }
        }
    }

}
