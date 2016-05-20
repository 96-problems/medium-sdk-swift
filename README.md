Medium SDK - Swift
===============

## Usage

Right click on your Info.plist file, choose Open As - Source code and add these lines :

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

Right before the </dict> tag.

Handle the callback in App Delegate:

func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        if (url.host == "mediumswift-callback") {
            OAuthSwift.handleOpenURL(url)
        }
        return true
    }
