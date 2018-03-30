//
//  Contact.swift
//  RxRestClient_Example
//
//  Created by Tigran Hambardzumyan on 3/27/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import ObjectMapper

class Contact: Mappable {

    var id: String!
    var firstName: String!
    var lastName: String!
    var email: String!
    var images = [String]()

    var imageURL: URL?

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        id <- map["_id"]
        firstName <- map["firstName"]
        lastName <- map["lastName"]
        email <- map["email"]
        images <- map["images"]
        if let image = images.first {
            imageURL = URL(string: "https://rxrestdemo-f9a7.restdb.io/media/" + image)
        }
    }

}
