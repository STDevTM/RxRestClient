//
//  APILogger.swift
//  RxRestClient-Example
//
//  Created by Tigran Hambardzumyan on 4/18/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Alamofire

final class APILogger: EventMonitor {

    func requestDidResume(_ request: Request) {
        print(request.cURLDescription())
    }
}
