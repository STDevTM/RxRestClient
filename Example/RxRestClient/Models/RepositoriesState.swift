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

    var state: BaseState?
    var data: [Repository]?

    private init() {
        state = nil
    }

    init(state: BaseState) {
        self.state = state
    }

    init(response: (HTTPURLResponse, String)) {
        if response.0.statusCode == 200 {
            self.data = try! RepositoryResponse(JSONString: response.1).items
        }
    }

    static let empty = RepositoriesState()
}
