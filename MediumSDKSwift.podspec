Pod::Spec.new do |s|
  s.name     = 'MediumSDKSwift'
  s.version  = '0.1.0'
  s.summary  = 'A swift SDK for Medium\'s OAuth2 API https://medium.com'
  s.homepage = 'https://github.com/96-problems/medium-sdk-swift'
  s.license  = { :type => 'MIT' }
  s.authors  = { 'drinkius' => 'telegin.alexander@gmail.com',
                 'ferbass'  => 'ferbass@gmail.com',
                 'ndethore' => 'nicolas.dethore@gmail.com' }

  s.requires_arc          = true
  s.ios.deployment_target = '9.0'

  s.source = { :git => 'https://github.com/96-problems/medium-sdk-swift.git',
               :tag => '0.1.0' }

  s.source_files = 'medium-sdk-swift/*.swift'

  s.dependency 'OAuthSwift', '~> 1.0'
  s.dependency 'SwiftyJSON', '~> 3.1'
  s.dependency 'Alamofire',  '~> 4.0'
end
