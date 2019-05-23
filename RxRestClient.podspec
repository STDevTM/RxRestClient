Pod::Spec.new do |s|
  s.name             = 'RxRestClient'
  s.version          = '1.2.1'
  s.summary          = 'Simple REST Client based on RxSwift and Alamofire.'
  s.swift_version = '5.0'

  s.description      = <<-DESC
  Reactive way to interct with REST API. Send request and get responses easily. Handling basic response cases by default, for example: Not Found, Unauthorized, etc.
                       DESC

  s.homepage         = 'https://github.com/stdevteam/RxRestClient'

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Tigran Hambardzumyan' => 'tigran@stdevmail.com' }
  s.source           = { :git => 'https://github.com/stdevteam/RxRestClient.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'RxRestClient/Classes/**/*'
  
  # s.resource_bundles = {
  #   'RxRestClient' => ['RxRestClient/Assets/*.png']
  # }

  s.dependency 'RxSwift', '~> 5'
  s.dependency 'RxCocoa', '~> 5'
  s.dependency 'Alamofire', '~> 4'
  s.dependency 'RxAlamofire', '~> 5'

end
