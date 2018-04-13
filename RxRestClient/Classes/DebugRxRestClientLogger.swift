//
//  DebugRxRestClientLogger.swift
//  RxRestClient
//
//  Created by Tigran Hambardzumyan on 4/11/18.
//

import Foundation

public class DebugRxRestClientLogger: RxRestClientLogger {

    public init() {}

    public func log(_ value: Any) {
        debugPrint(value)
    }

}
