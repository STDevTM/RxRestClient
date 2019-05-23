# RxRestClient

[![CI Status](http://img.shields.io/travis/stdevteam/RxRestClient.svg?style=flat)](https://travis-ci.org/stdevteam/RxRestClient)
[![Version](https://img.shields.io/cocoapods/v/RxRestClient.svg?style=flat)](http://cocoapods.org/pods/RxRestClient)
[![License](https://img.shields.io/cocoapods/l/RxRestClient.svg?style=flat)](http://cocoapods.org/pods/RxRestClient)
[![Platform](https://img.shields.io/cocoapods/p/RxRestClient.svg?style=flat)](http://cocoapods.org/pods/RxRestClient)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

* iOS 10.0+
* Swift 5.0+
* Xcode 10.2+

## Installation

RxRestClient is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'RxRestClient'
```

## Features

* Simple way to do requests
* Simple way to have response state in reactive way
* Ability to customization
* Retry on any error
* Handle network reachability status
* Retry on become reachable
* Ability to use absalute and relative urls
* Logger
* Swift Codable protocol support
* Use custom SessionManager
* Pagination support
* _more coming soon_

## How to use

First of all you need to create `struct` of your response state and implement `ResponseState` protocol.

```swift
struct RepositoriesState: ResponseState {

    typealias Body = Data

    var state: BaseState?
    var data: [Repository]?

    private init() {
        state = nil
    }

    init(state: BaseState) {
        self.state = state
    }

    init(response: (HTTPURLResponse, Data?)) {
        if response.0.statusCode == 200, let body = response.1 {
            self.data = try? JSONDecoder().decode(RepositoryResponse.self, from: body).items
        }
    }

    static let empty = RepositoriesState()
}
```

It is required to mention expected Body type (`String` or `Data`).

After that you need to create request model:

```swift
struct RepositoryQuery: Encodable {
    let q: String
}

```

Then you can do the request to get repositories:

```swift
import RxSwift
import RxRestClient

protocol RepositoriesServiceProtocol {
    func get(query: RepositoryQuery) -> Observable<RepositoriesState>
}

final class RepositoriesService: RepositoriesServiceProtocol {

    private let client = RxRestClient()

    func get(query: RepositoryQuery) -> Observable<RepositoriesState> {
        return client.get("https://api.github.com/search/repositories", query: query)
    }
}

```

In order to customize client you can use `RxRestClientOptions`:

```swift
var options = RxRestClientOptions.default
options.addHeader(key: "x-apikey", value: "<API_KEY>")
client = RxRestClient(baseUrl: <BASE _URL>), options: options)
```

### Relative vs absalute url

In order to use relative url you need to give `<BASE_URL>` when initializing client object.

```swift
let client = RxRestClient(baseURL: <BASE_URL>)
```

When calling any request you can provide either `String` endpoint or absalute `URL`. If you will `String` it will be appended to `baseURL`.

```swift
client.get("rest/contacts")
```

If `baseURL` is `nil` then it will try to convert provided `String` to `URL`.

In order to use absalute url even when your client has `baseURL` you can provide `URL` like this:

```swift
if let url = URL(string: "https://api.github.com/search/repositories") {
    client.get(url: url, query: ["q": search])
}
```

### Pagination

Pagination support is working only for `GET` requests. In order to have pagination (or infinite scrolling) feature you need to implement following protocols for query and response models:

For query model you need to implement `PagingQueryProtocol`:

```swift
struct RepositoryQuery: PagingQueryProtocol {

    let q: String
    var page: Int

    init(q: String) {
        self.q = q
        self.page = 1
    }

    func nextPage() -> RepositoryQuery {
        var new = self
        new.page += 1
        return new
    }
}
```

For response model you need to implement `PagingResponseProtocol`:

```swift
struct RepositoryResponse: PagingResponseProtocol {
    let totalCount: Int
    var repositories: [Repository]

    private enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case repositories = "items"
    }

    // MARK: - PagingResponseProtocol
    typealias Item = Repository

    static var decoder: JSONDecoder {
        return .init()
    }

    var canLoadMore: Bool {
        return totalCount > items.count
    }

    var items: [Repository] {
        get {
            return repositories
        }
        set(newValue) {
            repositories = newValue
        }
    }

}
```

For response states you need to use `PagingState` class or custom subclass:

```swift
final class RepositoriesState: PagingState<RepositoryResponse> {
    ...
}
```

After having all necessary models you can do your request:

```swift
client.get("https://api.github.com/search/repositories", query: query, loadNextPageTrigger: loadNextPageTrigger)
```

`loadNextPageTrigger` is an `Observable` with `Void` type in order to trigger client to do request for next page using new query moderl generated using `nextPage()` function. 

### Logger

In order to log `curl` command of sent request you can use `RxRestClientOptions.logger` option. For just printing debug description to console you can use builtin `DebugRxRestClientLogger` logger.

If you prefer to have a custom logger, for example, log requests to the file, you need to implement `RxRestClientLogger` protocol and pass it as an option.

## Author

Tigran Hambardzumyan, tigran@stdevmail.com

## Support

Feel free to [open issuses](https://github.com/stdevteam/RxRestClient/issues/new) with any suggestions, bug reports, feature requests, questions.

## Let us know!

We’d be really happy if you sent us links to your projects where you use our component. Just send an email to developer@stdevmail.com and do let us know if you have any questions or suggestion.

## License

RxRestClient is available under the MIT license. See the LICENSE file for more info.
