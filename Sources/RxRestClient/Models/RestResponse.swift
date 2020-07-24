//
//  RestResponse.swift
//  RxRestClient
//
//  Created by Tigran Hambardzumyan on 3/2/18.
//

import Foundation

public enum RestResponseStatus {
    case base(state: BaseState)
    case custom(response: (HTTPURLResponse, Any?))
}
