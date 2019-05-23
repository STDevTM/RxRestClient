//
//  RepositoriesViewModel.swift
//  RxRestClient_Example
//
//  Created by Tigran Hambardzumyan on 3/16/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxRestClient

final class RepositoriesViewModel {

    // MARK: - Inputs
    let search = PublishRelay<String>()
    let loadMore = PublishRelay<Void>()

    // MARK: - Outputs
    let repositories = BehaviorRelay<[Repository]>(value: [])
    let baseState = PublishRelay<BaseState>()

    // MARK: - Services
    private let service: RepositoriesServiceProtocol

    // MARK: - Private vars
    private let disposeBag = DisposeBag()

    // MARK: -
    init(service: RepositoriesServiceProtocol) {

        self.service = service

        doBindings()
    }

    private func doBindings() {
        let state = search
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { RepositoryQuery(q: $0) }
            .flatMapLatest { [service, loadMore] query in
                service.get(query: query, loadNextPageTrigger: loadMore.asObservable())
            }
            .share()

        state.map { $0.state }
            .filterNil()
            .bind(to: baseState)
            .disposed(by: disposeBag)

        state.map { $0.response?.repositories ?? []}
            .bind(to: repositories)
            .disposed(by: disposeBag)

    }

}
