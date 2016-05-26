Medium SDK - Swift
===============
> A library to allow access to Medium SDK to any Swift iOS application.

[![Swift Version][swift-image]][swift-url]
[![License][license-image]][license-url]
[![Platform](https://img.shields.io/cocoapods/p/LFAlertController.svg?style=flat)](http://cocoapods.org/pods/LFAlertController)

## Features

- [x] Medium.com authorization & token handling
- [x] Login state saved in user defaults
- [x] Supported scopes: basicProfile, listPublications, publishPost
- [x] Implemented all the related requests from the [Medium API docs](https://github.com/Medium/medium-api-docs)

## Requirements

- iOS 8.0+
- Xcode 7.3
- OAuthSwift, SwiftyJSON, Alamofire pods

## Installation

#### Manually

Include `MediumSDKManager.swift` file into your project, add `OAuthSwift`, `SwiftyJSON` and `Alamofire` pods to your podfile:

```
  pod 'OAuthSwift', '~> 0.5.2'
  pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'
  pod 'Alamofire', '~> 3.4'
```

and run `pod install` in the directory to load dependencies.

In the project right click on your Info.plist file, choose "Open As" - "Source code" and add these lines :

```
<key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLName</key>
            <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>mediumswift</string>
            </array>
        </dict>
    </array>
```

right before the </dict> tag.

Handle the callback in App Delegate:

```
func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        if (url.host == "mediumswift-callback") {
            OAuthSwift.handleOpenURL(url)
        }
        return true
    }
```

And you are all set!

## Usage

``MediumSDKManager`` class is designed as a singleton, you can access all it's methods by calling a shared instance:

```
let mediumSession = MediumSDKManager.sharedInstance
```

List of methods of the ``MediumSDKManager`` class:

* **Authorize**, completion handler returns state: success/failure and user's medium token or error string: 
```
doOAuthMedium(completionHandler: (String, String) -> Void)
```

* **Check login credentials**, completion handler returns state: success/failure and medium token string if present: 
```
checkCred(completionHandler: (String, String) -> Void)
```

* **Get current user ID**, completion handler returns state: success/failure and user ID string if present: 
```
getUserID(completionHandler: (String, String) -> Void)
```

* **Get current Medium token**, completion handler returns state: success/failure and medium token string if present:
```
getToken(completionHandler: (String, String) -> Void)
```

* **Sign out**, completion handler returns state: success/failure, and explanation string: 
```
signOutMedium(completionHandler: (String, String) -> Void)
```

* **Get current user's credentials**, completion handler returns state: success/failure, and user ID as a string if present: 
```
ownCredentialsRequest(completionHandler: (String, String) -> Void)
```

* **Get list of current user's publications**, completion handler returns state: success/failure, number of users publications as string and publications JSON if present: 
```
userPublicationsListRequest(completionHandler: (String, String, JSON) -> Void)
```

* **Get list of a publication's contributors**, completion handler returns state: success/failure, number of users publications as string and publications JSON if present: 
```
getListOfContributors(publicationId: String, completionHandler: (String, String, JSON) -> Void)
```

* **Create new post**, completion handler returns state: success/failure, and error message if present: 
```
createPost(title: String, contentFormat: String, content: String, canonicalUrl: String?=nil, tags: [String]?=nil,  publishStatus: MediumPublishStatus?=nil, license: MediumLicense?=nil, completionHandler: (String, String) -> Void)
```

* **Create a post under existing publication**, completion handler returns state: success/failure, and error message if present: 
```
createPostUnderPublication(rootPublication: String, title: String, contentFormat: String, content: String, canonicalUrl: String?=nil, tags: [String]?=nil, publishStatus: MediumPublishStatus?=nil, license: MediumLicense?=nil, completionHandler: (String, String) -> Void)
```

Note that publish status and licence fields are coded as enums with all the possible states of these parameters, when creating a publication just use the proper values.

## Release History

* 0.1.0
    * The first release, current version

## Contribute

We would love for you to contribute to **Medium SDK - Swift**, check the ``LICENSE`` file for more info.

## Meta

Original author:
Alexander Telegin – [@drinkius](https://github.com/drinkius) – telegin.alexander@gmail.com

Created as a part of development internship, distributed under the MIT license. See ``LICENSE`` for more information.

https://github.com/96-problems/medium-sdk-swift

[swift-image]:https://img.shields.io/badge/swift-2.2-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE
