//
//  Encodable+Extensions.swift
//  RxRestClient
//
//  Created by Tigran Hambardzumyan on 10/9/18.
//

import Foundation

extension Encodable {
    public func toDictionary(encoder: JSONEncoder = JSONEncoder()) -> [String: Any] {
        guard let data = try? encoder.encode(self) else { return [:] }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] } ?? [:]
    }

    public func toJSONString(encoder: JSONEncoder = JSONEncoder()) -> String? {
        guard let data = try? encoder.encode(self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}
