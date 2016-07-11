Pod::Spec.new do |s|
  s.name     = 'MediumSDKSwift'
  s.version  = '0.0.2'
  s.summary  = 'A swift SDK for Medium\'s OAuth2 API https://medium.com'
  s.homepage = 'https://github.com/96-problems/medium-sdk-swift'
  s.license  = { :type => 'MIT' }
  s.authors  = { 'drinkius' => 'telegin.alexander@gmail.com',
                 'ferbass'  => 'ferbass@gmail.com',
                 'ndethore' => 'nicolas.dethore@gmail.com' }

  s.requires_arc          = true
  s.osx.deployment_target = '10.10'
  s.ios.deployment_target = '8.0'

  s.source = { :git => 'https://github.com/96-problems/medium-sdk-swift.git',
               :tag => '0.0.2' }

  s.source_files = 'medium-sdk-swift/*.swift'

  s.dependency 'OAuthSwift', '~> 0.5.2'
  s.dependency 'SwiftyJSON', '2.3.2'
  s.dependency 'Alamofire', '~> 3.4'
end
