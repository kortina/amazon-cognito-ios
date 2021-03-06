Pod::Spec.new do |s|

  s.name         = 'AWSCognito'
  s.version      = '2.1.2'
  s.summary      = 'Amazon Cognito SDK for iOS'

  s.description  = 'Amazon Cognito offers multi device data synchronization with offline access'

  s.homepage     = 'http://aws.amazon.com/cognito'
  s.license      = 'Amazon Software License'
  s.author       = { 'Amazon Web Services' => 'amazonwebservices' }
  s.platform     = :ios, '7.0'
  s.source       = { :git => 'https://github.com/aws/amazon-cognito-ios.git',
                     :tag => s.version}
  s.requires_arc = true
  s.library      = 'sqlite3'
  s.dependency 'AWSCore', '~> 2.1.2'
  s.dependency 'Bolts', '~> 1.2.0'
  s.dependency 'Mantle', '~> 1.4'
  s.dependency 'UICKeyChainStore', '~> 2.0'
  s.dependency 'Reachability', '~> 3.1'
  
  s.source_files = 'CognitoSync/*.{h,m}', 'Cognito/*.{h,m}', 'Cognito/**/*.{h,m}'
  s.public_header_files = "Cognito/*.h",'CognitoSync/*.h'
  s.resources = ['CognitoSync/Resources/*.json']
end
