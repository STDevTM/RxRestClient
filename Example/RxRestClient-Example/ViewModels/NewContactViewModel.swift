//
//  NewContactViewModel.swift
//  RxRestClient-Example
//
//  Created by Tigran Hambardzumyan on 3/27/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxRestClient
import SDWebImage

class NewContactViewModel {

    private let disposeBag = DisposeBag()

    let firstName = BehaviorRelay<String?>(value: nil)
    let lastName = BehaviorRelay<String?>(value: nil)
    let email = BehaviorRelay<String?>(value: nil)
    let image = BehaviorRelay<UIImage?>(value: nil)
    let saveCommand = PublishSubject<Void>()

    var createState: Driver<DefaultState> = .never()
    var updateState: Driver<DefaultState> = .never()
    var isValid: Driver<Bool> = .never()
    var imageUploadState: Driver<ImageUploadState> = .never()
    var imageUploaded = BehaviorSubject<String?>(value: nil)

    private let service: ContactsService
    private let oldContact: Contact?

    init(
        oldContact: Contact?,
        service: ContactsService
    ) {

        self.service = service
        self.oldContact = oldContact

        initData()

        initStates()
    }

    private func initData() {
        guard let contact = oldContact else { return }
        firstName.accept(contact.firstName)
        lastName.accept(contact.lastName)
        email.accept(contact.email)

        SDWebImageDownloader.shared().downloadImage(with: contact.imageURL, progress: nil) { [weak self] image, _, _, _ in
            self?.image.accept(image)
            self?.imageUploaded.onNext(contact.images.first)
        }
    }

    private func initStates() {
        isValid = Driver.combineLatest(
            firstName.asDriver().filterNil(),
            lastName.asDriver().filterNil(),
            email.asDriver().filterNil(),
            image.asDriver().filterNil()
        ) {
            $0.isNotEmpty && $1.isNotEmpty && $2.isNotEmpty && $3.size != CGSize.zero
        }
        .startWith(false)

        imageUploadState = saveCommand.asDriver(onErrorDriveWith: .never())
            .withLatestFrom(imageUploaded.asDriver(onErrorDriveWith: .never()))
            .filter { $0?.isEmpty ?? true }
            .withLatestFrom(image.asDriver())
            .map {
                $0?.resizeImage(newWidth: 1024)
            }
            .filterNil()
            .flatMapLatest { [service] image in
                service.upload(image: image)
                    .asDriver(onErrorDriveWith: .empty())
        }

        Driver.merge(
            imageUploadState
                .map { $0.response?.ids.first },
            image.asDriver().map { _ in nil }.skip(1)
            )
            .drive(imageUploaded)
            .disposed(by: disposeBag)

        let newContact = Driver.combineLatest(
            firstName.asDriver().filterNil(),
            lastName.asDriver().filterNil(),
            email.asDriver().filterNil(),
            imageUploaded.asDriver(onErrorDriveWith: .never()).filterNil()
        ) {
            NewContact(firstName: $0, lastName: $1, email: $2, image: $3)
        }

        let request = saveCommand.asDriver(onErrorDriveWith: .never())
            .withLatestFrom(imageUploaded.asDriver(onErrorDriveWith: .never()))
            .flatMap { [imageUploaded] id in
                return (id?.isEmpty ?? true) ? imageUploaded
                    .filterNil()
                    .map { _ in () }
                    .asDriver(onErrorDriveWith: .never())
                    : Driver.of(())
            }
            .withLatestFrom(newContact)

        createState = request
            .filter { [oldContact] _ in oldContact == nil }
            .flatMapLatest { [service] newContact in
                service.create(contact: newContact)
                    .asDriver(onErrorDriveWith: .empty())
        }

        updateState = request
            .filter { [oldContact] _ in oldContact != nil }
            .flatMapLatest { [service, oldContact] newContact in
                service.update(contact: newContact, for: oldContact!.id)
                    .asDriver(onErrorDriveWith: .empty())
        }
    }
}
