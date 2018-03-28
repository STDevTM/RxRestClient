//
//  Repository.swift
//  RxRestClient_Example
//
//  Created by Tigran Hambardzumyan on 3/16/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import ObjectMapper

class Repository: ImmutableMappable {

    let id: Int
    let name: String
    let description: String?
    let url: String

    required init(map: Map) throws {
        id = try map.value("id")
        name = try map.value("name")
        description = try? map.value("description")
        url = try map.value("url")
    }

}

class RepositoryResponse: ImmutableMappable {
    let totalCount: Int
    let items: [Repository]

    required init(map: Map) throws {
        totalCount = try map.value("total_count")
        items = try map.value("items")
    }
}
