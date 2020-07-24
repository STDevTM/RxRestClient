//
//  RepositoriesService.swift
//  RxRestClient-Example
//
//  Created by Tigran Hambardzumyan on 3/16/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift
import RxRestClient
import Alamofire

protocol RepositoriesServiceProtocol {
    func get(query: RepositoryQuery, loadNextPageTrigger: Observable<Void>) -> Observable<RepositoriesState>
}

final class RepositoriesService: RepositoriesServiceProtocol {

    private let client: RxRestClient

    init() {
        var options = RxRestClientOptions.default
        options.sessionManager = Session(eventMonitors: [APILogger()])
        self.client = RxRestClient(options: options)
    }

    func get(query: RepositoryQuery, loadNextPageTrigger: Observable<Void>) -> Observable<RepositoriesState> {
        return client.get("https://api.github.com/search/repositories", query: query, loadNextPageTrigger: loadNextPageTrigger)
    }
}
