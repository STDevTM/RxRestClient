//
//  Repository.swift
//  RxRestClient_Example
//
//  Created by Tigran Hambardzumyan on 3/16/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import RxRestClient

struct Repository: Decodable {

    let id: Int
    let name: String
    let description: String?
    let url: String

}

struct RepositoryResponse {
    let totalCount: Int
    var repositories: [Repository]

    private enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case repositories = "items"
    }
}

extension RepositoryResponse: PagingResponseProtocol {

    typealias Item = Repository

    static var decoder: JSONDecoder {
        return .init()
    }

    var canLoadMore: Bool {
        return totalCount > items.count
    }

    var items: [Repository] {
        get {
            return repositories
        }
        set(newValue) {
            repositories = newValue
        }
    }

}
