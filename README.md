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

Include `MediumSDKManager.swift` file into your project and run `pod install` in the directory to load dependencies.

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

Here be instructions

## Release History

* 0.1.0
    * The first release, current version

## Contribute

We would love for you to contribute to **Medium SDK - Swift**, check the ``LICENSE`` file for more info.

## Meta

Original author:
Alexander Telegin – [@drinkius](https://twitter.com/drinkius) – telegin.alexander@gmail.com

Created as a part of development internship, distributed under the MIT license. See ``LICENSE`` for more information.

https://github.com/drinkius/medium-sdk-swift

[swift-image]:https://img.shields.io/badge/swift-2.2-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE
