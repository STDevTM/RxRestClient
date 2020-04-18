//
//  ContactsService.swift
//  RxRestClient_Example
//
//  Created by Tigran Hambardzumyan on 3/27/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift
import RxRestClient
import Alamofire

enum ContactsServiceError: Error {
    case imageLoadFailed
}

class ContactsService {
    private let client: RxRestClient

    init() {
        var options = RxRestClientOptions.default
        options.addHeader(key: "x-apikey", value: "5ab9fa1af0a7555103cea80b")
        options.sessionManager = Session(eventMonitors: [APILogger()])
        client = RxRestClient(baseUrl: URL(string: "https://rxrestdemo-f9a7.restdb.io/"), options: options)
    }

    func get() -> Observable<ContactsState> {
        return client.get("rest/contacts")
    }

    func create(contact: NewContact) -> Observable<DefaultState> {
        return client.post("rest/contacts", object: contact.toJSON())
    }

    func update(contact: NewContact, for id: String) -> Observable<DefaultState> {
        return client.put("rest/contacts/\(id)", object: contact.toJSON())
    }

    func upload(image: UIImage) -> Observable<ImageUploadState> {
        #if swift(>=4.2)
        guard let data = image.jpegData(compressionQuality: 0.7) else {
            return Observable.error(ContactsServiceError.imageLoadFailed)
        }
        #else
        guard let data = UIImageJPEGRepresentation(image, 0.7) else {
            return Observable.error(ContactsServiceError.imageLoadFailed)
        }
        #endif

        let formDataBuilder = MultipartFormDataBuilder()
        formDataBuilder.add(data: data, name: "image", fileName: UUID().uuidString, mimeType: .jpeg)

        return client.upload(builder: formDataBuilder, endpoint: "media")

    }

}
