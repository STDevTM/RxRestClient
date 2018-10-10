//
//  Repository.swift
//  RxRestClient_Example
//
//  Created by Tigran Hambardzumyan on 3/16/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

struct Repository: Decodable {

    let id: Int
    let name: String
    let description: String?
    let url: String

}

struct RepositoryResponse: Decodable {
    let totalCount: Int
    let items: [Repository]

    private enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case items
    }
}
