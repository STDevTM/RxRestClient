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

public enum RxRestClientError: Error {
    case urlBuildFailed
    case selfDestroyed
}

public struct RxRestClientOptions {
    public var retryCount = 3
    public var headers = ["Content-Type": "application/json"]
    public var maxConcurrentOperationCount = 2
    public var logger: RxRestClientLogger?
    public var urlEncoding = URLEncoding.default
    public var jsonEncoding = JSONEncoding.default

    public static let `default` = RxRestClientOptions()

    /// Adding or replacing header via key
    ///
    /// - Parameters:
    ///   - key: key name of header
    ///   - value: value of specified key
    public mutating func addHeader(key: String, value: String) {
        self.headers[key] = value
    }

    /// Adding Authorization header
    ///
    /// - Parameter token: token string which will be added as a Authorization header with custom prefix
    public mutating func addAuth(token: String, prefix: String? = nil) {
        var prefixKey = (prefix ?? "")
        if !prefixKey.isEmpty {
            prefixKey += " "
        }
        self.addHeader(key: "Authorization", value: prefixKey + token)
    }
}

/// ReactiveX REST Client
open class RxRestClient {

    // MARK: - Private vars
    private var operationQueue: OperationQueue
    private var backgroundWorkScheduler: OperationQueueScheduler
    // swiftlint:disable force_try
    private let reachabilityService: ReachabilityService = try! DefaultReachabilityService()
    // swiftlint:enable force_try

    private let options: RxRestClientOptions
    private let baseUrl: URL?

    // MARK: - Initializer
    /// Initialize RxRestClient
    ///
    /// - Parameters:
    ///   - baseUrl: Base Url which will be used for all requests, default value is nil so you can use absalute URL in requests
    ///   - options: RxRestClientOptions object
    public init(baseUrl: URL? = nil, options: RxRestClientOptions = RxRestClientOptions.default) {
        self.options = options
        self.baseUrl = baseUrl
        operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = options.maxConcurrentOperationCount
        operationQueue.qualityOfService = QualityOfService.userInitiated
        backgroundWorkScheduler = OperationQueueScheduler(operationQueue: operationQueue)
    }

    // MARK: - POST Requests
    /// Do POST Request
    ///
    /// - Parameters:
    ///   - endpoint: Relative path of endpoint which will be appended to baseUrl
    ///   - object: dictinary representing body of request
    /// - Returns: An observable of a the response state
    public func post<T: ResponseState>(_ endpoint: String, object: [String: Any]) -> Observable<T> {
        guard let url = buildURL(endpoint) else {
            return Observable.error(RxRestClientError.urlBuildFailed)
        }
        return post(url: url, object: object)
    }

    /// Do POST Request
    ///
    /// - Parameters:
    ///   - url: absalute url
    ///   - object: dictinary representing body of request
    /// - Returns: An observable of a the response state
    public func post<T: ResponseState>(url: URL, object: [String: Any]) -> Observable<T> {
        return run(request(.post, url, object: object))
    }

    /// Do POST Request
    ///
    /// - Parameters:
    ///   - endpoint: Relative path of endpoint which will be appended to baseUrl
    ///   - array: array representing body of request
    /// - Returns: An observable of a the response state
    public func post<T: ResponseState>(_ endpoint: String, array: [String]) -> Observable<T> {
        guard let url = buildURL(endpoint) else {
            return Observable.error(RxRestClientError.urlBuildFailed)
        }
        return post(url: url, array: array)
    }

    /// Do POST Request
    ///
    /// - Parameters:
    ///   - url: absalute url
    ///   - array: array representing body of request
    /// - Returns: An observable of a the response state
    public func post<T: ResponseState>(url: URL, array: [String]) -> Observable<T> {
        return run(request(.post, url, array: array))
    }

    // MARK: - PUT Requests
    /// Do PUT Request
    ///
    /// - Parameters:
    ///   - endpoint: Relative path of endpoint which will be appended to baseUrl
    ///   - object: dictinary representing body of request
    /// - Returns: An observable of a the response state
    public func put<T: ResponseState>(_ endpoint: String, object: [String: Any]) -> Observable<T> {
        guard let url = buildURL(endpoint) else {
            return Observable.error(RxRestClientError.urlBuildFailed)
        }
        return put(url: url, object: object)
    }

    /// Do PUT Request
    ///
    /// - Parameters:
    ///   - url: absalute url
    ///   - object: dictinary representing body of request
    /// - Returns: An observable of a the response state
    public func put<T: ResponseState>(url: URL, object: [String: Any]) -> Observable<T> {
        return run(request(.put, url, object: object))
    }
    
    /// Do PUT Request
    ///
    /// - Parameters:
    ///   - endpoint: Relative path of endpoint which will be appended to baseUrl
    ///   - array: array representing body of request
    /// - Returns: An observable of a the response state
    public func put<T: ResponseState>(_ endpoint: String, array: [String]) -> Observable<T> {
        guard let url = buildURL(endpoint) else {
            return Observable.error(RxRestClientError.urlBuildFailed)
        }
        return put(url: url, array: array)
    }

    /// Do PUT Request
    ///
    /// - Parameters:
    ///   - url: absalute url
    ///   - array: array representing body of request
    /// - Returns: An observable of a the response state
    public func put<T: ResponseState>(url: URL, array: [String]) -> Observable<T> {
        return run(request(.put, url, array: array))
    }

    // MARK: - PATCH Requests
    /// Do PATCH Request
    ///
    /// - Parameters:
    ///   - endpoint: Relative path of endpoint which will be appended to baseUrl
    ///   - object: dictinary representing body of request
    /// - Returns: An observable of a the response state
    public func patch<T: ResponseState>(_ endpoint: String, object: [String: Any]) -> Observable<T> {
        guard let url = buildURL(endpoint) else {
            return Observable.error(RxRestClientError.urlBuildFailed)
        }
        return patch(url: url, object: object)
    }

    /// Do PATCH Request
    ///
    /// - Parameters:
    ///   - url: absalute url
    ///   - object: dictinary representing body of request
    /// - Returns: An observable of a the response state
    public func patch<T: ResponseState>(url: URL, object: [String: Any]) -> Observable<T> {
        return run(request(.patch, url, object: object))
    }

    // MARK: - DELETE Requests
    /// Do DELETE Request
    ///
    /// - Parameters:
    ///   - endpoint: Relative path of endpoint which will be appended to baseUrl
    ///   - object: dictinary representing body of request, default value is empty
    /// - Returns: An observable of a the response state
    public func delete<T: ResponseState>(_ endpoint: String, object: [String: Any] = [:]) -> Observable<T> {
        guard let url = buildURL(endpoint) else {
            return Observable.error(RxRestClientError.urlBuildFailed)
        }
        return delete(url: url, object: object)
    }

    /// Do DELETE Request
    ///
    /// - Parameters:
    ///   - url: absalute url
    ///   - object: dictinary representing body of request, default value is empty
    /// - Returns: An observable of a the response state
    public func delete<T: ResponseState>(url: URL, object: [String: Any] = [:]) -> Observable<T> {
        return run(request(.delete, url, object: object))
    }

    /// Do DELETE Request
    ///
    /// - Parameters:
    ///   - endpoint: Relative path of endpoint which will be appended to baseUrl
    ///   - array: array representing body of request, default value is empty
    /// - Returns: An observable of a the response state
    public func delete<T: ResponseState>(_ endpoint: String, array: [Any]) -> Observable<T> {
        guard let url = buildURL(endpoint) else {
            return Observable.error(RxRestClientError.urlBuildFailed)
        }
        return delete(url: url, array: array)
    }

    /// Do DELETE Request
    ///
    /// - Parameters:
    ///   - url: absalute url
    ///   - array: array representing body of request, default value is empty
    /// - Returns: An observable of a the response state
    public func delete<T: ResponseState>(url: URL, array: [Any]) -> Observable<T> {
        return run(request(.delete, url, array: array))
    }

    // MARK: - GET Requests
    /// Do GET Request
    ///
    /// - Parameters:
    ///   - endpoint: Relative path of endpoint which will be appended to baseUrl
    ///   - query: dictinary representing query of request, default value is empty
    /// - Returns: An observable of a the response state
    public func get<T: ResponseState>(_ endpoint: String, query: [String: Any] = [:]) -> Observable<T> {
        guard let url = buildURL(endpoint) else {
            return Observable.error(RxRestClientError.urlBuildFailed)
        }
        return get(url: url, query: query)
    }

    /// Do GET Request
    ///
    /// - Parameters:
    ///   - url: absalute url
    ///   - query: dictinary representing query of request, default value is empty
    /// - Returns: An observable of a the response state
    public func get<T: ResponseState>(url: URL, query: [String: Any] = [:]) -> Observable<T> {
        return run(request(.get, url, object: query, encoding: options.urlEncoding))
    }

    // MARK: - Request builder
    /// Build and return An observable of a the DataRequest
    ///
    /// - Parameters:
    ///   - method: Alamofire method object (example: .get, post, etc)
    ///   - url: absalute url
    ///   - object: A dictionary containing all necessary options
    ///   - encoding: The kind of encoding used to process parameters
    /// - Returns: An observable of a the created DataRequest
    public func request(_ method: HTTPMethod, _ url: URLConvertible, object: [String: Any], encoding: ParameterEncoding? = nil) -> Observable<DataRequest> {
        return RxAlamofire.request(
            method,
            url,
            parameters: object,
            encoding: encoding ?? options.jsonEncoding,
            headers: options.headers
        )
    }

    /// Build and return An observable of a the DataRequest
    ///
    /// - Parameters:
    ///   - method: Alamofire method object (example: .get, post, etc)
    ///   - url: absalute url
    ///   - array: An array containing all necessary options
    /// - Returns: An observable of a the created DataRequest
    public func request(_ method: HTTPMethod, _ url: URLConvertible, array: [Any]) -> Observable<DataRequest> {
        return RxAlamofire.request(
            method,
            url,
            parameters: [:],
            encoding: JSONArrayEncoding(array),
            headers: options.headers
        )
    }

    // MARK: - Request runner
    /// Will run DataRequest
    ///
    /// - Parameter request: An observable of the DataRequest
    /// - Returns: An observable of a the response state
    public func run<T: ResponseState>(_ request: Observable<DataRequest>) -> Observable<T> {

        return request
            .flatMap { [options] request -> Observable<(HTTPURLResponse, String)> in
                options.logger?.log(request)
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
    }

    // MARK: - Uploads
    /// Upload images or files using multipart form data
    ///
    /// - Parameters:
    ///   - builder: bulder of MultipartFormData
    ///   - endpoint: Relative path of endpoint which will be appended to baseUrl
    ///   - method: The HTTP method. `.post` by default.
    ///   - headers: The HTTP headers. `nil` by default. When value is `nil` the headers from options will be used
    /// - Returns: An observable of a the response state
    public func upload<T: ResponseState>(
        builder: MultipartFormDataBuilder,
        endpoint: String,
        method: HTTPMethod = .post,
        headers: HTTPHeaders? = nil) -> Observable<T> {

        guard let url = buildURL(endpoint) else {
            return Observable.error(RxRestClientError.urlBuildFailed)
        }
        return upload(builder: builder, to: url, method: method, headers: headers)
    }

    /// Upload images or files using multipart form data
    ///
    /// - Parameters:
    ///   - builder: bulder of MultipartFormData
    ///   - url: absalute url
    ///   - method: The HTTP method. `.post` by default.
    ///   - headers: The HTTP headers. `nil` by default. When value is `nil` the headers from options will be used.
    /// - Returns: An observable of a the response state
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

    /// Upload file using URL.
    ///
    /// - Parameters:
    ///   - file: An url of file to be uploaded.
    ///   - endpoint: Relative path of endpoint which will be appended to baseUrl.
    ///   - method: The HTTP method. `.post` by default.
    ///   - headers: The HTTP headers. `nil` by default. When value is `nil` the headers from options will be used.
    /// - Returns: An observable of a the response state.
    public func upload<T: ResponseState>(
        _ file: URL,
        endpoint: String,
        method: HTTPMethod = .post,
        headers: HTTPHeaders? = nil) -> Observable<T> {

        guard let url = buildURL(endpoint) else {
            return Observable.error(RxRestClientError.urlBuildFailed)
        }
        return upload(file, to: url, method: method, headers: headers)
    }

    /// Upload file using URL.
    ///
    /// - Parameters:
    ///   - file: An url of file to be uploaded.
    ///   - url: Absalute url.
    ///   - method: The HTTP method. `.post` by default.
    ///   - headers: The HTTP headers. `nil` by default. When value is `nil` the headers from options will be used.
    /// - Returns: An observable of a the response state.
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

    /// Upload file using URL.
    ///
    /// - Parameters:
    ///   - file: An url of file to be uploaded.
    ///   - endpoint: Relative path of endpoint which will be appended to baseUrl.
    ///   - method: The HTTP method. `.post` by default.
    ///   - headers: The HTTP headers. `nil` by default. When value is `nil` the headers from options will be used.
    /// - Returns: An observable of a the `ResponseState` and `RxProgress` tuple.
    public func upload<T: ResponseState>(
        _ file: URL,
        endpoint: String,
        method: HTTPMethod = .post,
        headers: HTTPHeaders? = nil) -> Observable<(T?, RxProgress)> {

        guard let url = buildURL(endpoint) else {
            return Observable.error(RxRestClientError.urlBuildFailed)
        }
        return upload(file, to: url, method: method, headers: headers)
    }

    /// Upload file using URL.
    ///
    /// - Parameters:
    ///   - file: An url of file to be uploaded.
    ///   - url: Absalute url.
    ///   - method: The HTTP method. `.post` by default.
    ///   - headers: The HTTP headers. `nil` by default. When value is `nil` the headers from options will be used.
    /// - Returns: An observable of a the `ResponseState` and `RxProgress` tuple.
    public func upload<T: ResponseState>(
        _ file: URL,
        to url: URLConvertible,
        method: HTTPMethod = .post,
        headers: HTTPHeaders? = nil) -> Observable<(T?, RxProgress)> {

        return SessionManager.default.rx
            .upload(file, to: url, method: method, headers: headers ?? options.headers)
            .flatMap { [weak self] (request: UploadRequest) -> Observable<(T?, RxProgress)> in
                guard let strongSelf = self else {
                    return Observable.error(RxRestClientError.selfDestroyed)
                }
                let state = strongSelf.run(Observable<DataRequest>.just(request))
                    .map { d -> T? in d }
                    .startWith(nil as T?)
                let progress = request.rx.progress()
                return Observable.combineLatest(state, progress) { ($0, $1) }
        }
    }

    /// Upload data.
    ///
    /// - Parameters:
    ///   - data: A `Data` object to be uploaded.
    ///   - endpoint: Relative path of endpoint which will be appended to baseUrl.
    ///   - method: The HTTP method. `.post` by default.
    ///   - headers: The HTTP headers. `nil` by default. When value is `nil` the headers from options will be used.
    /// - Returns: An observable of a the `ResponseState`.
    public func upload<T: ResponseState>(
        _ data: Data,
        endpoint: String,
        method: HTTPMethod = .post,
        headers: HTTPHeaders? = nil) -> Observable<T> {

        guard let url = buildURL(endpoint) else {
            return Observable.error(RxRestClientError.urlBuildFailed)
        }
        return upload(data, to: url, method: method, headers: headers)
    }

    /// Upload data
    ///
    /// - Parameters:
    ///   - data: A `Data` object to be uploaded.
    ///   - url: Absalute url.
    ///   - method: The HTTP method. `.post` by default.
    ///   - headers: The HTTP headers. `nil` by default. When value is `nil` the headers from options will be used.
    /// - Returns: An observable of a the `ResponseState`.
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
    /// Checking base response cases.
    ///
    /// - Parameters:
    ///   - httpResponse: `HTTPURLResponse` object.
    ///   - string: The body of response as a string.
    /// - Returns: A `BaseResponse` enum.
    private static func checkBaseResponse(_ httpResponse: HTTPURLResponse, _ string: String) -> BaseResponse? {
        switch httpResponse.statusCode {
        case 400:
            return .badRequest(body: string)
        case 401:
            return .unauthorized(body: string)
        case 403:
            return .forbidden(body: string)
        case 404:
            return .notFound(body: string)
        case 422:
            return .validationProblem(error: string)
        case 500..<600:
            return .unexpectedError(error: string)
        default:
            return nil
        }
    }

    // MARK: - Checking base state cases
    /// Checking base state cases.
    ///
    /// - Parameter response: `BaseResponse` enum.
    /// - Returns: The corresnponding `BaseState`.
    private static func checkBaseState(response: BaseResponse) -> BaseState {
        switch response {
        case .serviceOffline:
            return BaseState.offline
        case let .badRequest(body: body):
            return BaseState(badRequest: body)
        case let .unauthorized(body: body):
            return BaseState(unauthorized: body)
        case let .forbidden(body: body):
            return BaseState(forbidden: body)
        case let .notFound(body: body):
            return BaseState(notFound: body)
        case let .validationProblem(error: error):
            return BaseState(validationProblem: error)
        case let .unexpectedError(error: error):
            return BaseState(unexpectedError: error)
        }
    }

    /// Build URL from `endpoint` and `baseUrl`.
    /// This will try to convert `endpoint` parameter to URL if `baseUrl` is nil.
    /// - Parameter endpoint: Relative path of endpoint.
    /// - Returns: Built optional URL.
    private func buildURL(_ endpoint: String) -> URL? {
        return baseUrl?.appendingPathComponent(endpoint) ?? URL(string: endpoint)
    }

}

/// JSON Encoder for Array
private struct JSONArrayEncoding: ParameterEncoding {
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
