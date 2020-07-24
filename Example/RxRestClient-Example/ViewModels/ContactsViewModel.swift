//
//  ContactsViewModel.swift
//  RxRestClient-Example
//
//  Created by Tigran Hambardzumyan on 3/27/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ContactsViewModel {

    let contactsState: Driver<ContactsState>

    init(refresh: Driver<Void>, service: ContactsService) {
        contactsState = refresh
            .flatMapLatest {
                service.get()
                    .asDriver(onErrorJustReturn: ContactsState.empty)
        }
    }

}
