Medium SDK - Swift
===============
> A library to allow access to Medium API for any Swift iOS application.

[![Swift Version][swift-image]][swift-url]
[![License][license-image]][license-url]
[![Platform][platform-image]][platform-url]

## Features

- [x] Medium.com authorization & token handling
- [x] Login state saved in user defaults
- [x] Supported scopes: basicProfile, listPublications, publishPost
- [x] Implemented all the related requests from the [Medium API docs](https://github.com/Medium/medium-api-docs)

## Compatibility

- iOS 8.0+
- osx 10.10

## Installation

```
  pod 'MediumSDKManager', '~> 0.0.1'
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

Note that the redirect is done via a free Heroku app and it's highly recommended to setup your own redirect service by cloning and running [this repo](https://github.com/drinkius/mediumswift.herokuapp.com) (courtesy of the original [oauthswift.herokuapp.com](https://github.com/dongri/oauthswift.herokuapp.com) repo). Change all the `mediumswift` strings in the repo to the name of your app and make related changes in `Info.plist` and `App Delegate` files. The deployment with Heroku is easy - just link your GitHub repo and the app is built automatically.

You are all set!

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

* **Check login credentials**, completion handler returns state: success/failure and medium token or error string:
```
checkCred(completionHandler: (String, String) -> Void)
```

* **Get current user ID**, completion handler returns state: success/failure and user ID or error string:
```
getUserID(completionHandler: (String, String) -> Void)
```

* **Get current Medium token**, completion handler returns state: success/failure and medium token or error string:
```
getToken(completionHandler: (String, String) -> Void)
```

* **Sign out**, completion handler returns state: success/failure, and message or error string:
```
signOutMedium(completionHandler: (String, String) -> Void)
```

* **Get current user's credentials**, completion handler returns state: success/failure, and user ID as or error string:
```
ownCredentialsRequest(completionHandler: (String, String) -> Void)
```

* **Get list of current user's publications**, completion handler returns state: success/failure, number of users publications or error string and publications JSON if present:
```
userPublicationsListRequest(completionHandler: (String, String, JSON) -> Void)
```

* **Get list of a publication's contributors**, completion handler returns state: success/failure, number of users publications or error string and publications JSON if present:
```
getListOfContributors(publicationId: String, completionHandler: (String, String, JSON) -> Void)
```

* **Create new post**, completion handler returns state: success/failure, and message or error string:
```
createPost(title: String, contentFormat: String, content: String, canonicalUrl: String?=nil, tags: [String]?=nil,  publishStatus: MediumPublishStatus?=nil, license: MediumLicense?=nil, completionHandler: (String, String) -> Void)
```

* **Create a post under existing publication**, completion handler returns state: success/failure, and message or error string:
```
createPostUnderPublication(rootPublication: String, title: String, contentFormat: String, content: String, canonicalUrl: String?=nil, tags: [String]?=nil, publishStatus: MediumPublishStatus?=nil, license: MediumLicense?=nil, completionHandler: (String, String) -> Void)
```

Note that publish status and licence fields are coded as enums with all the possible states of these parameters, when creating a publication just use the proper values.

## Release History

* 0.0.1
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
[platform-image]: https://img.shields.io/badge/platform-ios-green.svg
[platform-url]: http://www.apple.com
