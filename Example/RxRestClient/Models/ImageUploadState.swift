//
//  ImageUploadState.swift
//  RxRestClient_Example
//
//  Created by Tigran Hambardzumyan on 3/27/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import RxRestClient

struct ImageUploadState: ResponseState {

    var state: BaseState? = nil
    var response: ImageUploadResponse? = nil
    var tooLarge: Bool? = nil

    init(state: BaseState) {
        self.state = state

    }

    init(response: (HTTPURLResponse, String)) {
        self.state = BaseState.online
        switch response.0.statusCode {
        case 200..<300:
            self.response = try? ImageUploadResponse(JSONString: response.1)
        case 413:
            self.tooLarge = true
        default:
            break
        }
    }

    static let empty = ImageUploadState(state: BaseState.empty)
}
