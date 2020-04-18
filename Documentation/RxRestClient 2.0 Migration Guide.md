# RxRestClient 2.0 Migration Guide
RxRestClient 2.0 is the latest major release of Simple REST Client based on RxSwift 5.1 and Alamofire 5.1. As a major release, following Semantic Versioning conventions, 2.0 introduces API-breaking changes.

## Breaking API Changes

-  `RxRestClientLogger` and `DebugRxRestClientLogger` have been removed. You can use new `EventMonitor`'s of `Session` manager instance to access Alamofire’s internal events and log them. For more details please refer [here](https://github.com/Alamofire/Alamofire/blob/b18b808a3b52074e75cef5c12c282a2a9bdd35f0/Documentation/AdvancedUsage.md#logging).
-  `headers` option of `RxRestClientOptions` changed from `Dictionary` to  Alamofire's new `HTTPHeaders` struct.

For complete API changes of Alamofire 5.1 which may affect to RxRestClient behavior please check [here](https://github.com/Alamofire/Alamofire/blob/master/Documentation/Alamofire%205.0%20Migration%20Guide.md).

