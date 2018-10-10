//
//  RepositoriesState.swift
//  RxRestClient_Example
//
//  Created by Tigran Hambardzumyan on 3/16/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import RxRestClient

struct RepositoriesState: ResponseState {

    typealias Body = Data

    var state: BaseState?
    var data: [Repository]?

    private init() {
        state = nil
    }

    init(state: BaseState) {
        self.state = state
    }

    init(response: (HTTPURLResponse, Data?)) {
        if response.0.statusCode == 200, let body = response.1 {
            self.data = try? JSONDecoder().decode(RepositoryResponse.self, from: body).items
        }
    }

    static let empty = RepositoriesState()
}
