//
//  MultipartFormDataBuilder.swift
//  RxRestClient
//
//  Created by Tigran Hambardzumyan on 3/23/18.
//

import Foundation
import Alamofire

public enum MIMETypes: String {
    case jpeg = "image/jpeg"
    case png = "image/png"
    case gif = "image/gif"
    case tiff = "image/tiff"
    case pdf = "application/pdf"
    case vnd = "application/vnd"
    case plainText = "text/plain"
    case binaru = "application/octet-stream"
}

open class MultipartFormDataBuilder {

    private var data = [(data: Data, name: String, fileName: String, mimeType: MIMETypes)]()
    private var dataWithName = [(data: Data, name: String, mimeType: MIMETypes)]()
    private var files = [(url: URL, name: String, mimeType: MIMETypes)]()
    private var params: [String: String] = [:]

    public init() { }

    public func add(data: Data, name: String, fileName: String, mimeType type: MIMETypes, showExtension: Bool = false) {
        var fileName = fileName
        if showExtension, let ext = type.rawValue.components(separatedBy: "/").last {
            fileName += ".\(ext)"
        }
        self.data.append((data, name, fileName, type))
    }

    public func add(data: Data, name: String, mimeType type: MIMETypes) {
        self.dataWithName.append((data, name, type))
    }

    public func add(file url: URL, name: String, mimeType type: MIMETypes) {
        self.files.append((url, name, type))
    }

    public func addParam(_ value: String, forKey: String) {
        params[forKey] = value
    }

    public func build() -> (MultipartFormData) -> Void {
        return { formData in
            self.params.forEach { arg in
                let (key, value) = arg
                guard let data = value.data(using: .utf8) else { return }
                formData.append(data, withName: key)
            }
            self.data.forEach { arg in
                let (data, name, fileName, type) = arg
                formData.append(data, withName: name, fileName: fileName, mimeType: type.rawValue)
            }
            self.dataWithName.forEach { arg in
                let (data, name, type) = arg
                formData.append(data, withName: name, mimeType: type.rawValue)
            }
            self.files.forEach { arg in
                let (url, name, type) = arg
                formData.append(url, withName: name, fileName: url.lastPathComponent, mimeType: type.rawValue)
            }
        }
    }

}
