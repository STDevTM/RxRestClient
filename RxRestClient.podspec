Pod::Spec.new do |s|
  s.name             = 'RxRestClient'
  s.version          = '2.2.0'

  s.summary          = 'Simple REST Client based on RxSwift and Alamofire.'
  s.swift_version    = '5.1'

  s.description      = <<-DESC
  Reactive way to interact with REST API. Send request and get responses easily. Handling basic response cases by default, for example: Not Found, Unauthorized, etc.
                       DESC

  s.homepage         = 'https://github.com/STDevTM/RxRestClient'

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Tigran Hambardzumyan' => 'tigran@stdevmail.com' }
  s.source           = { :git => 'https://github.com/STDevTM/RxRestClient.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = "10.12"
  s.tvos.deployment_target = "10.0"

  s.requires_arc = true

  s.source_files = 'Sources/RxRestClient/**/*'

  s.dependency 'RxSwift', '>= 5.1'
  s.dependency 'RxAlamofire', '>= 5.6'

end
