//
//  NewContact.swift
//  RxRestClient-Example
//
//  Created by Tigran Hambardzumyan on 3/27/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import ObjectMapper

class NewContact: ImmutableMappable {

    let firstName: String
    let lastName: String
    let email: String
    let images: [String]

    required init(map: Map) throws {
        firstName = try map.value("firstName")
        lastName = try map.value("lastName")
        email = try map.value("email")
        images = try map.value("images")
    }

    func mapping(map: Map) {
        firstName >>> map["firstName"]
        lastName >>> map["lastName"]
        email >>> map["email"]
        images >>> map["images"]
    }

    init(firstName: String, lastName: String, email: String, image: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.images = [image]
    }
}
