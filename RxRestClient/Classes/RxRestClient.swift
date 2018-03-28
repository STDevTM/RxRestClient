//
//  RxRestClient.swift
//  Alamofire
//
//  Created by Tigran Hambardzumyan on 3/2/18.
//

import Foundation
import RxSwift
import Alamofire
import RxAlamofire

public struct RxRestClientOptions {
    public var retryCount = 3
    public var headers = ["Content-Type": "application/json"]
    public var maxConcurrentOperationCount = 2

    public static let `default` = RxRestClientOptions()

    public mutating func addHeader(key: String, value: String) {
        self.headers[key] = value
    }

    public mutating func addAuth(token: String) {
        self.addHeader(key: "Authorization", value: "Bearer " + token)
    }
}

open class RxRestClient {

    // MARK: - Private vars
    private var operationQueue: OperationQueue
    private var backgroundWorkScheduler: OperationQueueScheduler
    // swiftlint:disable force_try
    private let reachabilityService: ReachabilityService = try! DefaultReachabilityService()
    // swiftlint:enable force_try

    private let options: RxRestClientOptions
    private let baseUrl: String

    // MARK: - Initializer
    public init(baseUrl: String = "", options: RxRestClientOptions = RxRestClientOptions.default) {
        self.options = options
        self.baseUrl = baseUrl
        operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = options.maxConcurrentOperationCount
        operationQueue.qualityOfService = QualityOfService.userInitiated
        backgroundWorkScheduler = OperationQueueScheduler(operationQueue: operationQueue)
    }

    // MARK: - POST Requests
    public func post<T: ResponseState>(_ endpoint: String, object: [String: Any]) -> Observable<T> {
        return run(request(.post, endpoint: endpoint, object: object))
    }

    public func post<T: ResponseState>(_ endpoint: String, array: [String]) -> Observable<T> {
        return run(request(.post, endpoint: endpoint, array: array))
    }

    // MARK: - PUT Requests
    public func put<T: ResponseState>(_ endpoint: String, object: [String: Any]) -> Observable<T> {
        return run(request(.put, endpoint: endpoint, object: object))
    }

    public func put<T: ResponseState>(_ endpoint: String, array: [String]) -> Observable<T> {
        return run(request(.put, endpoint: endpoint, array: array))
    }

    // MARK: - PATCH Requests
    public func patch<T: ResponseState>(_ endpoint: String, object: [String: Any]) -> Observable<T> {
        return run(request(.patch, endpoint: endpoint, object: object))
    }

    // MARK: - DELETE Requests
    public func delete<T: ResponseState>(_ endpoint: String, object: [String: Any] = [:]) -> Observable<T> {
        return run(request(.delete, endpoint: endpoint, object: object))
    }

    public func delete<T: ResponseState>(_ endpoint: String, array: [Any] = []) -> Observable<T> {
        return run(request(.delete, endpoint: endpoint, array: array))
    }

    // MARK: - GET Requests
    public func get<T: ResponseState>(_ endpoint: String, query: [String: Any] = [:]) -> Observable<T> {
        return run(request(.get, endpoint: endpoint, object: query, encoding: URLEncoding.default))
    }

    // MARK: - Request builder
    public func request(_ method: HTTPMethod, endpoint: String, object: [String: Any], encoding: ParameterEncoding = JSONEncoding.default) -> Observable<DataRequest> {
        return RxAlamofire.request(
            method,
            self.baseUrl + endpoint,
            parameters: object,
            encoding: encoding,
            headers: options.headers
        )
    }

    public func request(_ method: HTTPMethod, endpoint: String, array: [Any]) -> Observable<DataRequest> {
        return RxAlamofire.request(
            method,
            self.baseUrl + endpoint,
            parameters: [:],
            encoding: JSONArrayEncoding(array),
            headers: options.headers
        )
    }

    // MARK: - Request runner
    public func run<T: ResponseState>(_ request: Observable<DataRequest>) -> Observable<T> {

        return request
            .flatMap { request -> Observable<(HTTPURLResponse, String)> in
                return request.rx.responseString()
            }
            .retry(options.retryCount)
            .observeOn(backgroundWorkScheduler)
            .map { (httpResponse, string) -> RestResponseStatus in

                if let response = RxRestClient.checkBaseResponse(httpResponse, string) {
                    return .base(state: RxRestClient.checkBaseState(response: response))
                } else {
                    return .custom(response: (httpResponse, string))
                }
            }
            .retryOnBecomesReachable(.base(state: BaseState.offline), reachabilityService: reachabilityService)
            .flatMap { response -> Observable<T> in
                switch response {
                case let .base(state: state):
                    return Observable.just(T(state: state))
                case let .custom(response: response):
                    return Observable.just(T(response: response))
                }
            }
            .catchError { error -> Observable<T> in
                return Observable.just(T(state: BaseState(unexpectedError: error.localizedDescription)))
            }

    }

    // MARK: - Uploads
    public func upload<T: ResponseState>(
        builder: MultipartFormDataBuilder,
        to url: URLConvertible,
        method: HTTPMethod = .post,
        headers: HTTPHeaders? = nil) -> Observable<T> {

        return run(
            SessionManager.default.rx
                .upload(multipartFormData: builder.build(), to: url, method: method, headers: headers ?? options.headers)
                .map { $0.0 }
        )

    }

    public func upload<T: ResponseState>(
        _ file: URL,
        to url: URLConvertible,
        method: HTTPMethod = .post,
        headers: HTTPHeaders? = nil) -> Observable<T> {

        return run(
            SessionManager.default.rx
                .upload(file, to: url, method: method, headers: headers ?? options.headers)
                .map { $0 } // Casting to DataRequest
        )
    }

    public func upload<T: ResponseState>(
        _ file: URL,
        to url: URLConvertible,
        method: HTTPMethod = .post,
        headers: HTTPHeaders? = nil) -> Observable<(T?, RxProgress)> {

        return SessionManager.default.rx
            .upload(file, to: url, method: method, headers: headers ?? options.headers)
            .flatMap { [weak self] (request: UploadRequest) -> Observable<(T?, RxProgress)> in
                guard let strongSelf = self else {
                    return Observable.error(
                        NSError(
                            domain: "Self was already destroyed",
                            code: 4100,
                            userInfo: ["file": #file, "function": #function]
                        )
                    )
                }
                let state = strongSelf.run(Observable<DataRequest>.just(request))
                    .map { d -> T? in d }
                    .startWith(nil as T?)
                let progress = request.rx.progress()
                return Observable.combineLatest(state, progress) { ($0, $1) }
        }
    }

    public func upload<T: ResponseState>(
        _ data: Data,
        to url: URLConvertible,
        method: HTTPMethod = .post,
        headers: HTTPHeaders? = nil) -> Observable<T> {

        return run(
            SessionManager.default.rx
                .upload(data, to: url, method: method, headers: headers ?? options.headers)
                .map { $0 } // Casting to DataRequest
        )
    }

    // MARK: - Checking base response cases
    private static func checkBaseResponse(_ httpResponse: HTTPURLResponse, _ string: String) -> BaseResponse? {
        switch httpResponse.statusCode {
        case 400:
            return .badRequest
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 422:
            return .validationProblem(error: string)
        case 500..<600:
            return .unexpectedError(error: string)
        default:
            return nil
        }
    }

    // MARK: - Checking base state cases
    private static func checkBaseState(response: BaseResponse) -> BaseState {
        switch response {
        case .serviceOffline:
            return BaseState.offline
        case .badRequest:
            return BaseState.badRequestState
        case .unauthorized:
            return BaseState.unauthorizedState
        case .forbidden:
            return BaseState.forbiddenState
        case .notFound:
            return BaseState.notFoundState
        case let .validationProblem(error: error):
            return BaseState(validationProblem: error)
        case let .unexpectedError(error: error):
            return BaseState(unexpectedError: error)
        }
    }

}

struct JSONArrayEncoding: ParameterEncoding {
    private let array: [Any]

    init(_ array: [Any]) {
        self.array = array
    }

    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = urlRequest.urlRequest!

        let data = try JSONSerialization.data(withJSONObject: array, options: [])

        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        urlRequest.httpBody = data

        return urlRequest
    }
}
