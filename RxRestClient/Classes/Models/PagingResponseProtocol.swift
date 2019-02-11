//
//  PagingResponseProtocol.swift
//  Alamofire
//
//  Created by Tigran Hambardzumyan on 2/8/19.
//

import Foundation

public protocol PagingResponseProtocol: Decodable {

    associatedtype Item

    static var decoder: JSONDecoder { get }

    var canLoadMore: Bool { get }

    var items: [Item] { get set }
}
