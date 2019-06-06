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
    public var queryEncoding: ParameterEncoding = URLEncoding.default
    public var bodyEncoding: ParameterEncoding = JSONEncoding.default
    public var jsonDecoder: JSONDecoder = JSONDecoder()
    public var jsonEncoder: JSONEncoder = JSONEncoder()
    public var sessionManager: SessionManager?

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
    @available(*, deprecated, message: "Use RequestAdapter with custom SessionManager instead.")
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
        return run(request(.post, url, object: object, encoding: options.bodyEncoding))
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

    /// Do POST Request
    ///
    /// - Parameters:
    ///   - endpoint: Relative path of endpoint which will be appended to baseUrl
    ///   - body: Encodable model representing body of request
    /// - Returns: An observable of a the response state
    public func post<T: ResponseState>(_ endpoint: String, body: Encodable) -> Observable<T> {
        guard let url = buildURL(endpoint) else {
            return Observable.error(RxRestClientError.urlBuildFailed)
        }
        return post(url: url, object: body.toDictionary(encoder: options.jsonEncoder))
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
        return run(request(.put, url, object: object, encoding: options.bodyEncoding))
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

    /// Do PUT Request
    ///
    /// - Parameters:
    ///   - endpoint: Relative path of endpoint which will be appended to baseUrl
    ///   - body: Encodable model representing body of request
    /// - Returns: An observable of a the response state
    public func put<T: ResponseState>(_ endpoint: String, body: Encodable) -> Observable<T> {
        guard let url = buildURL(endpoint) else {
            return Observable.error(RxRestClientError.urlBuildFailed)
        }
        return put(url: url, object: body.toDictionary(encoder: options.jsonEncoder))
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
        return run(request(.patch, url, object: object, encoding: options.bodyEncoding))
    }

    /// Do PATCH Request
    ///
    /// - Parameters:
    ///   - endpoint: Relative path of endpoint which will be appended to baseUrl
    ///   - body: Encodable model representing body of request
    /// - Returns: An observable of a the response state
    public func patch<T: ResponseState>(_ endpoint: String, body: Encodable) -> Observable<T> {
        guard let url = buildURL(endpoint) else {
            return Observable.error(RxRestClientError.urlBuildFailed)
        }
        return patch(url: url, object: body.toDictionary(encoder: options.jsonEncoder))
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
        return run(request(.delete, url, object: object, encoding: options.queryEncoding))
    }

    /// Do DELETE Request
    ///
    /// - Parameters:
    ///   - endpoint: Relative path of endpoint which will be appended to baseUrl
    ///   - body: Encodable model representing body of request
    /// - Returns: An observable of a the response state
    public func delete<T: ResponseState>(_ endpoint: String, body: Encodable) -> Observable<T> {
        guard let url = buildURL(endpoint) else {
            return Observable.error(RxRestClientError.urlBuildFailed)
        }
        return delete(url: url, object: body.toDictionary(encoder: options.jsonEncoder))
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
        return run(request(.get, url, object: query, encoding: options.queryEncoding))
    }

    /// Do GET Request
    ///
    /// - Parameters:
    ///   - endpoint: Relative path of endpoint which will be appended to baseUrl
    ///   - query: Encodable model representing query of request
    /// - Returns: An observable of a the response state
    public func get<T: ResponseState>(_ endpoint: String, query: Encodable) -> Observable<T> {
        guard let url = buildURL(endpoint) else {
            return Observable.error(RxRestClientError.urlBuildFailed)
        }
        return get(url: url, query: query)
    }

    /// Do GET Request
    ///
    /// - Parameters:
    ///   - url: absalute url
    ///   - query: Encodable model representing query of request
    /// - Returns: An observable of a the response state
    public func get<T: ResponseState>(url: URL, query: Encodable) -> Observable<T> {
        return get(url: url, query: query.toDictionary(encoder: options.jsonEncoder))
    }


    /// Do Get Request
    ///
    /// - Parameters:
    ///   - endpoint: Relative path of endpoint which will be appended to baseUrl
    ///   - query: PagingQueryProtocol model representing query of request with pagination
    /// - Returns: An observable of a the response state with pagination
    public func get<T: PagingState<R>, R: PagingResponseProtocol>(
        _ endpoint: String,
        query: PagingQueryProtocol,
        loadNextPageTrigger: Observable<Void>) -> Observable<T> {

        guard let url = buildURL(endpoint) else {
            return Observable.error(RxRestClientError.urlBuildFailed)
        }
        return get(url: url, query: query, loadNextPageTrigger: loadNextPageTrigger)
    }

    /// Do Get Request
    ///
    /// - Parameters:
    ///   - endpoint: Relative path of endpoint which will be appended to baseUrl
    ///   - query: PagingQueryProtocol model representing query of request with pagination
    /// - Returns: An observable of a the response state with pagination
    public func get<T: PagingState<R>, R: PagingResponseProtocol>(
        url: URL,
        query: PagingQueryProtocol,
        loadNextPageTrigger: Observable<Void>) -> Observable<T> {

        return recursivelyGet(url: url, query: query, loadedSoFar: [], loadNextPageTrigger: loadNextPageTrigger)
    }


    /// Do Get Request recursively by appending the result of each request to previous one
    ///
    /// - Parameters:
    ///   - url: absalute url
    ///   - query: PagingQueryProtocol model representing query of request with pagination
    ///   - loadedSoFar: An array of items previously loaded
    ///   - loadNextPageTrigger: An observable to trigger next page load event
    /// - Returns: An observable of a the response state with pagination
    private func recursivelyGet<T: PagingState<R>, R: PagingResponseProtocol>(
        url: URL,
        query: PagingQueryProtocol,
        loadedSoFar: [R.Item],
        loadNextPageTrigger: Observable<Void>) -> Observable<T> {

        return get(url: url, query: query)
            .flatMapLatest { (state: T) -> Observable<T> in

                guard var response = state.response else {
                    return Observable.just(state)
                }

                if response.items.isEmpty {
                    state.response?.items = loadedSoFar
                    return Observable.just(state)
                }

                var loadedValues = loadedSoFar
                loadedValues.append(contentsOf: response.items)
                response.items = loadedValues
                state.response = response

                if !response.canLoadMore {
                    return Observable.just(state)
                }

                let newQuery = query.nextPage()

                return Observable<T>.concat([
                    // return loaded immediately
                    Observable.just(state),
                    // wait until next page can be loaded
                    Observable.never().takeUntil(loadNextPageTrigger),
                    // load next page
                    self.recursivelyGet(url: url, query: newQuery, loadedSoFar: loadedValues, loadNextPageTrigger: loadNextPageTrigger) as Observable<T>
                ])
        }
    }

    // MARK: - Request builder
    /// Build and return an observable of a the DataRequest
    ///
    /// - Parameters:
    ///   - method: Alamofire method object (example: .get, post, etc)
    ///   - url: absalute url
    ///   - object: A dictionary containing all necessary options
    ///   - encoding: The kind of encoding used to process parameters
    /// - Returns: An observable of a the created DataRequest
    public func request(_ method: HTTPMethod, _ url: URLConvertible, object: [String: Any], encoding: ParameterEncoding) -> Observable<DataRequest> {
        return getSessionManager().rx.request(
            method,
            url,
            parameters: object,
            encoding: encoding,
            headers: options.headers
        )
    }

    /// Build and return an observable of a the DataRequest
    ///
    /// - Parameters:
    ///   - method: Alamofire method object (example: .get, post, etc)
    ///   - url: absalute url
    ///   - array: An array containing all necessary options
    /// - Returns: An observable of a the created DataRequest
    public func request(_ method: HTTPMethod, _ url: URLConvertible, array: [Any]) -> Observable<DataRequest> {
        return getSessionManager().rx.request(
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
            .validate { [unowned self] request, response, data in
                return self.validate(request, response, data)
            }
            .flatMap { [options] request -> Observable<(HTTPURLResponse, T.Body?)> in
                options.logger?.log(request)

                switch T.Body.self {
                case is String.Type:
                    return request.rx.responseString().map { ($0.0, $0.1 as? T.Body) }
                default:
                    return request.rx.responseData().map { ($0.0, $0.1 as? T.Body) }
                }
            }
            .observeOn(backgroundWorkScheduler)
            .map { (httpResponse, body) -> RestResponseStatus in
                return .custom(response: (httpResponse, body))
            }
            .catchError { e in
                if let response = e as? BaseResponse {
                    return Observable.just(.base(state: RxRestClient.checkBaseState(response: response)))
                }
                return Observable.error(e)
            }
            .retry(options.retryCount)
            .retryOnBecomesReachable(.base(state: BaseState.offline), reachabilityService: reachabilityService)
            .flatMap { response -> Observable<T> in
                switch response {
                case let .base(state: state):
                    return Observable.just(T(state: state))
                case let .custom(response: response):
                    return Observable.just(T(response: (response.0, response.1 as? T.Body)))
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
            getSessionManager().rx
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
            getSessionManager().rx
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

        return getSessionManager().rx
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
            getSessionManager().rx
                .upload(data, to: url, method: method, headers: headers ?? options.headers)
                .map { $0 } // Casting to DataRequest
        )
    }

    /// Do validation of response
    ///
    /// - Parameters:
    ///   - request: URL Request
    ///   - response: URL Response
    ///   - data: Response body
    /// - Returns: ValidationResult
    open func validate(_ request: URLRequest?, _ response: HTTPURLResponse, _ data: Data?) -> Request.ValidationResult {

        if let baseResponse = RxRestClient.checkBaseResponse(response, data) {
            return .failure(baseResponse)
        }
        return .success
    }

    // MARK: - Checking base response cases
    /// Checking base response cases.
    ///
    /// - Parameters:
    ///   - httpResponse: `HTTPURLResponse` object.
    ///   - string: The body of response as a string.
    /// - Returns: A `BaseResponse` enum.
    private static func checkBaseResponse(_ httpResponse: HTTPURLResponse, _ body: Any?) -> BaseResponse? {
        switch httpResponse.statusCode {
        case 400:
            return .badRequest(body: body)
        case 401:
            return .unauthorized(body: body)
        case 403:
            return .forbidden(body: body)
        case 404:
            return .notFound(body: body)
        case 422:
            return .validationProblem(error: body)
        case 500..<600:
            return .unexpectedError(error: body)
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

    /// Get session manager
    ///
    /// - Returns: Session Managher instance
    private func getSessionManager() -> SessionManager {
        return options.sessionManager ?? .default
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
