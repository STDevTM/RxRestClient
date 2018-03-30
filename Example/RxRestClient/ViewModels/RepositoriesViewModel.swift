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

class RepositoriesViewModel {

    let repositoriesState: Driver<RepositoriesState>

    init(search: ControlProperty<String>, service: RepositoriesServiceProtocol) {

        repositoriesState = search
            .asDriver()
            .debounce(0.3)
            .flatMapLatest {
                service.get(search: $0)
                    .asDriver(onErrorJustReturn: RepositoriesState.empty)
            }
    }

}
