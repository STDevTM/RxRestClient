//
//  RxAlamofire+Extensions.swift
//  AmvigoElite
//
//  Created by Yervand Saribekyan on 8/15/17.
//  Copyright © 2017 STDev's Mac Mini 2. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import RxAlamofire

extension Reactive where Base: DownloadRequest {
    /*
     Returns an `Observable` for the downloaded path.

     Parameters on observed tuple: String

     - returns: An instance of `Observable<String?>`
     */
    public func response() -> Observable<String?> {
        return Observable.create { observer in

            self.base.response { response in
                observer.onNext(response.destinationURL?.path)
                observer.onCompleted()

            }

            return Disposables.create()
        }
    }
}

extension Reactive where Base: SessionManager {

    public func upload(
        _ file: URL,
        to url: URLConvertible,
        method: HTTPMethod,
        headers: HTTPHeaders? = nil)
        -> Observable<UploadRequest> {

            return self.request { manager in
                return manager.upload(file, to: url, method: method, headers: headers)
            }
    }

    public func upload(
        _ file: URL,
        to url: URLConvertible,
        method: HTTPMethod,
        headers: HTTPHeaders? = nil) -> Observable<RxProgress> {
        return upload(file, to: url, method: method, headers: headers)
            .flatMap { $0.validate(statusCode: 200 ..< 300).rx.progress() }
            .observeOn(MainScheduler.instance)
    }

    public func upload(
        _ data: Data,
        to url: URLConvertible,
        method: HTTPMethod,
        headers: HTTPHeaders? = nil)
        -> Observable<UploadRequest> {
            return request { manager in
                return manager.upload(data, to: url, method: method, headers: headers)
            }
    }

    public func upload(
        multipartFormData: @escaping (MultipartFormData) -> Void,
        to url: URLConvertible,
        method: HTTPMethod = .post,
        headers: HTTPHeaders? = nil)
        -> Observable<(UploadRequest, Bool, URL?)> {

            return Observable.create { observer -> Disposable in
                self.base.upload(multipartFormData: multipartFormData, to: url, method: method, headers: headers) { result in
                    switch result {
                    case let .success(request, streamingFromDisk, streamFileURL):
                        observer.on(.next((request, streamingFromDisk, streamFileURL)))
                        observer.on(.completed)
                    case let .failure(error):
                        observer.onError(error)
                    }
                }
                return Disposables.create()
            }
    }

    /**
     Creates an observable of the DataRequest.

     - parameter createRequest: A function used to create a `Request` using a `Manager`

     - returns: A generic observable of created data request
     */
    func request<R: UploadRequest>(_ createRequest: @escaping (SessionManager) throws -> R) -> Observable<R> {
        return Observable.create { observer -> Disposable in
            let request: R
            do {
                request = try createRequest(self.base)
                observer.on(.next(request))
                request.responseWith(completionHandler: { (response) in
                    if let error = response.error {
                        observer.onError(error)
                    } else {
                        observer.on(.completed)
                    }
                })

                if !self.base.startRequestsImmediately {
                    request.resume()
                }

                return Disposables.create {
                    request.cancel()
                }
            } catch let error {
                observer.on(.error(error))
                return Disposables.create()
            }
        }
    }

}

extension UploadRequest {
    func responseWith(completionHandler: @escaping (DefaultDataResponse) -> Void) {
        response { (response) in
            completionHandler(response)
        }
    }
}
