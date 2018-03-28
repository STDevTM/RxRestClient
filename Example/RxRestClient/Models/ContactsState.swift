//
//  ContactsState.swift
//  RxRestClient_Example
//
//  Created by Tigran Hambardzumyan on 3/27/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import RxRestClient

struct ContactsState: ResponseState {

    var state: BaseState?
    var contacts: [Contact]

    init(state: BaseState) {
        self.state = state
        self.contacts = []
    }

    init(response: (HTTPURLResponse, String)) {
        if response.0.statusCode == 200 {
            self.state = BaseState.online
            self.contacts = [Contact](JSONString: response.1) ?? []
        } else {
            self.state = BaseState(serviceState: .online, unexpectedError: "Unable to map response")
            self.contacts = []
        }
    }

    static let empty = ContactsState(state: BaseState.empty)
}
