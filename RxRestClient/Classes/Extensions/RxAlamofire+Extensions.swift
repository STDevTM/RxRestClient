//
//  RxAlamofire+Extensions.swift
//  RxRestClient
//
//  Created by Yervand Saribekyan on 8/15/17.
//  Copyright © 2017 STDev's Mac Mini. All rights reserved.
//

import Alamofire
import Foundation
import RxAlamofire
import RxSwift

extension Reactive where Base: Session {
    public func upload(
        _ file: URL,
        to url: URLConvertible,
        method: HTTPMethod,
        headers: HTTPHeaders? = nil)
        -> Observable<UploadRequest> {
        return request { manager in
            manager.upload(file, to: url, method: method, headers: headers)
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
            manager.upload(data, to: url, method: method, headers: headers)
        }
    }

    public func upload(
        multipartFormData: @escaping (MultipartFormData) -> Void,
        to url: URLConvertible,
        method: HTTPMethod = .post,
        headers: HTTPHeaders? = nil)
        -> Observable<UploadRequest> {
        return request { manager in
            manager.upload(multipartFormData: multipartFormData, to: url, method: method, headers: headers)
        }
    }

    /**
     Creates an observable of the DataRequest.
     - parameter createRequest: A function used to create a `Request` using a `Manager`
     - returns: A generic observable of created data request
     */
    func request<R: UploadRequest>(_ createRequest: @escaping (Session) throws -> R) -> Observable<R> {
        return Observable.create { observer -> Disposable in
            let request: R
            do {
                request = try createRequest(self.base)
                observer.on(.next(request))
                request.responseWith(completionHandler: { response in
                    if let error = response.error {
                        observer.on(.error(error))
                    } else {
                        observer.on(.completed)
                    }
                })

                if !self.base.startRequestsImmediately {
                    _ = request.resume()
                }

                return Disposables.create {
                    _ = request.cancel()
                }
            } catch {
                observer.on(.error(error))
                return Disposables.create()
            }
        }
    }
}

protocol RxAlamofireRequest {
    func responseWith(completionHandler: @escaping (RxAlamofireResponse) -> Void)
    func resume() -> Self
    func cancel() -> Self
}

protocol RxAlamofireResponse {
    var error: Error? { get }
}

extension DataResponse: RxAlamofireResponse {
    var error: Error? {
        switch result {
        case let .failure(error):
            return error
        default:
            return nil
        }
    }
}

extension UploadRequest: RxAlamofireRequest {
    func responseWith(completionHandler: @escaping (RxAlamofireResponse) -> Void) {
        response { response in
            completionHandler(response)
        }
    }
}
