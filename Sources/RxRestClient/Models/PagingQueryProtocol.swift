//
//  PagingQueryProtocol.swift
//  Alamofire
//
//  Created by Tigran Hambardzumyan on 2/8/19.
//

import Foundation
import RxSwift

public protocol PagingQueryProtocol: Encodable {
    func nextPage() -> Self
}
