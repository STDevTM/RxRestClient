//
//  ImageUploadResponse.swift
//  RxRestClient-Example
//
//  Created by Tigran Hambardzumyan on 3/27/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import ObjectMapper

class ImageUploadResponse: ImmutableMappable {

    let msg: String
    let uploadId: String
    let ids: [String]

    required init(map: Map) throws {
        msg = try map.value("msg")
        uploadId = try map.value("uploadid")
        ids = try map.value("ids")
    }
}
