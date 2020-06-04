//
//  MultipartFormDataBuilder.swift
//  RxRestClient
//
//  Created by Tigran Hambardzumyan on 3/23/18.
//

import Foundation
import Alamofire

open class MultipartFormDataBuilder {

    private var data = [(data: Data, name: String, fileName: String, mimeType: MIMETypes)]()
    private var dataWithName = [(data: Data, name: String, mimeType: MIMETypes)]()
    private var files = [(url: URL, name: String, mimeType: MIMETypes)]()
    private var params: [String: String] = [:]

    /// Initialize MultipartFormDataBuilder
    public init() { }

    /// Adds a body part from the data and appends it to the multipart form data object.
    ///
    /// The body part data will be encoded using the following format:
    ///
    /// - `Content-Disposition: form-data; name=#{name}; filename=#{filename}` (HTTP Header)
    /// - `Content-Type: #{mimeType}` (HTTP Header)
    /// - Encoded file data
    /// - Multipart form boundary
    ///
    /// - Parameters:
    ///   - data: The data to encode into the multipart form data.
    ///   - name: The name to associate with the data in the `Content-Disposition` HTTP header.
    ///   - fileName: The filename to associate with the data in the `Content-Disposition` HTTP header.
    ///   - type: The MIME type to associate with the data in the `Content-Type` HTTP header.
    ///   - showExtension: Whether should extension be added to `filename`.
    public func add(data: Data, name: String, fileName: String, mimeType type: MIMETypes, showExtension: Bool = false) {
        var fileName = fileName
        if showExtension {
            fileName += ".\(type.rawValue)"
        }
        self.data.append((data, name, fileName, type))
    }

    /// Adds a body part from the data and appends it to the multipart form data object.
    ///
    /// The body part data will be encoded using the following format:
    ///
    /// - `Content-Disposition: form-data; name=#{name}` (HTTP Header)
    /// - `Content-Type: #{generated mimeType}` (HTTP Header)
    /// - Encoded data
    /// - Multipart form boundary
    ///
    /// - Parameters:
    ///   - data: The data to encode into the multipart form data.
    ///   - name: The name to associate with the data in the `Content-Disposition` HTTP header.
    ///   - type: The MIME type to associate with the data content type in the `Content-Type` HTTP header.
    public func add(data: Data, name: String, mimeType type: MIMETypes) {
        self.dataWithName.append((data, name, type))
    }

    /// Adds a body part from the file and appends it to the multipart form data object.
    /// The body part data will be encoded using the following format:
    ///
    /// - Content-Disposition: form-data; name=#{name}; filename=#{filename} (HTTP Header)
    /// - Content-Type: #{mimeType} (HTTP Header)
    /// - Encoded file data
    /// - Multipart form boundary
    ///
    /// - Parameters:
    ///   - url: The URL of the file whose content will be encoded into the multipart form data.
    ///   - name: The name to associate with the file content in the `Content-Disposition` HTTP header.
    ///   - type: The MIME type to associate with the file content in the `Content-Type` HTTP header.
    public func add(file url: URL, name: String, mimeType type: MIMETypes) {
        self.files.append((url, name, type))
    }

    /// Creates a body part from the data and appends it to the multipart form data object.
    ///
    /// The body part data will be encoded using the following format:
    ///
    /// - `Content-Disposition: form-data; name=#{key}` (HTTP Header)
    /// - Encoded data
    /// - Multipart form boundary
    ///
    /// - Parameters:
    ///   - value: The value to encode into the multipart form data.
    ///   - forKey: The key to associate with the value in the `Content-Disposition` HTTP header.
    public func addParam(_ value: String, for key: String) {
        params[key] = value
    }

    /// Builds MultipartFormData object.
    public func build() -> (MultipartFormData) -> Void {
        return { formData in
            self.params.forEach { arg in
                let (key, value) = arg
                guard let data = value.data(using: .utf8) else { return }
                formData.append(data, withName: key)
            }
            self.data.forEach { arg in
                let (data, name, fileName, type) = arg
                formData.append(data, withName: name, fileName: fileName, mimeType: type.mimeType)
            }
            self.dataWithName.forEach { arg in
                let (data, name, type) = arg
                formData.append(data, withName: name, mimeType: type.mimeType)
            }
            self.files.forEach { arg in
                let (url, name, type) = arg
                formData.append(url, withName: name, fileName: url.lastPathComponent, mimeType: type.mimeType)
            }
        }
    }

}
