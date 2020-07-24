//
//  RepositoryQuery.swift
//  RxRestClient-Example
//
//  Created by Tigran Hambardzumyan on 10/10/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift
import RxRestClient

struct RepositoryQuery: PagingQueryProtocol {

    let q: String
    var page: Int

    init(q: String) {
        self.q = q
        self.page = 1
    }

    func nextPage() -> RepositoryQuery {
        var new = self
        new.page += 1
        return new
    }
}
