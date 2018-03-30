//
//  RepositoriesService.swift
//  RxRestClient_Example
//
//  Created by Tigran Hambardzumyan on 3/16/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import RxAlamofire
import RxRestClient

protocol RepositoriesServiceProtocol {
    func get(search: String) -> Observable<RepositoriesState>
}

class RepositoriesService: RepositoriesServiceProtocol {

    private let client = RxRestClient()

    func get(search: String) -> Observable<RepositoriesState> {
        return client.get("https://api.github.com/search/repositories", query: ["q": search])
    }
}
