//
//  MediumSDKManager.swift
//
//
//  Created by drinkius on 20/05/16.
//  Updated by @reejosamuel on 08/11/16
//

import OAuthSwift
import SwiftyJSON
import Alamofire

public enum MediumPublishStatus: String {
    case published = "public"
    case draft = "draft"
    case unlisted = "unlisted"
}

public enum MediumLicense: String {
    case allRightsReserved = "all-rights-reserved"
    case cc40by = "cc-40-by"
    case cc40bysa = "cc-40-by-sa"
    case cc40bynd = "cc-40-by-nd"
    case cc40bync = "cc-40-by-nc"
    case cc40byncnd = "cc-40-by-nc-nd"
    case cc40byncsa = "cc-40-by-nc-sa"
    case cc40zero = "cc-40-zero"
    case publicDomain = "public-domain"
}

open class MediumSDKManager: NSObject {

    // Making our SDK behave like a singleton with sharedInstance
    open static let sharedInstance = MediumSDKManager()
    fileprivate override init() {}

    // Using user defaults to store userID & tokens
    open let userDefaults = UserDefaults.standard

    fileprivate let baseURL = "https://api.medium.com/v1"
    fileprivate var oauthswift: OAuth2Swift!
    fileprivate var credential: OAuthSwiftCredential!
    fileprivate var credentialsJSON: JSON!

    // Completion handler returns state: success/failure and user's medium token or error string
    open func doOAuthMedium(_ completionHandler: @escaping (String, String) -> Void) {

        // Insert your app credentials here
        let clientID = Bundle.main.object(forInfoDictionaryKey: "MediumClientID") as! String
        let clientSecret = Bundle.main.object(forInfoDictionaryKey: "MediumClientSecret") as! String

        // API URLs
        let authorizeURL = "https://medium.com/m/oauth/authorize"
        let accessTokenUrl = baseURL + "/tokens"
        let callbackURL = Bundle.main.object(forInfoDictionaryKey: "MediumCallbackURL") as! String

        // Specify the scope of public functions your app utilizes, options: basicProfile,publishPost, and listPublications. Extended scope "uploadImage" by default can't be requested by an application.

        let scope = "basicProfile,publishPost,listPublications"

        oauthswift = OAuth2Swift(
            consumerKey:    clientID,
            consumerSecret: clientSecret,
            authorizeUrl:   authorizeURL,
            accessTokenUrl: accessTokenUrl,
            responseType:   "code"
        )

        let state: String = generateState(withLength: 20)
        oauthswift.authorize(withCallbackURL: URL(string: callbackURL)!,
           scope: scope, state: state,
          success: { credential, response, parameters in

            self.credential = credential

            print("Token \(self.credential.oauthToken)")
            print("Refresh token \(self.credential.oauthRefreshToken)")

            self.userDefaults.set(true, forKey: "mediumIsAuthorized")
            self.userDefaults.set(self.credential.oauthToken, forKey: "mediumToken")
            self.userDefaults.set(self.credential.oauthRefreshToken, forKey: "mediumRefreshToken")

            self.ownCredentialsRequest() { state, response in
                if state != "error" {
                    completionHandler("success", self.userDefaults.object(forKey: "mediumToken")! as! String)
                } else {
                    let errorString = "Logged in but couldn't fetch your user details"
                    completionHandler("error", errorString)
                }
            }

            }, failure: { error in
                self.userDefaults.set(false, forKey: "mediumIsAuthorized")
                let errorString = "Login failed"
                completionHandler("error", errorString)
//                print(error.localizedDescription, terminator: "")
        })

    }

    // Completion handler returns state: success/failure and medium token string if present
    open func checkCred(_ completionHandler: (String, String) -> Void) {

        if userDefaults.bool(forKey: "mediumIsAuthorized") {
            let response = self.userDefaults.object(forKey: "mediumToken")! as! String
            completionHandler("success", response)
        } else {
            let response = "Not authorized on Medium"
            completionHandler("error", response)
        }
    }

    // Completion handler returns state: success/failure and user ID string if present
    open func getUserID(_ completionHandler: (String, String) -> Void) {
        if userDefaults.bool(forKey: "mediumIsAuthorized") {
            let response = userDefaults.object(forKey: "mediumUserID")! as! String
            completionHandler("success", response)
        } else {
            let response = "Not authorized on Medium"
            completionHandler("error", response)
        }
    }

    // Completion handler returns state: success/failure and medium token string if present
    open func getToken(_ completionHandler: (String, String) -> Void) {
        if userDefaults.bool(forKey: "mediumIsAuthorized") {
            let response = userDefaults.object(forKey: "mediumToken")! as! String
            completionHandler("success", response)
        } else {
            let response = "Not authorized on Medium"
            completionHandler("error", response)
        }
    }

    // Completion handler returns state: success/failure, and explanation string
    open func signOutMedium(_ completionHandler: (String, String) -> Void) {

        if userDefaults.bool(forKey: "mediumIsAuthorized") {
            self.userDefaults.set(false, forKey: "mediumIsAuthorized")
            self.userDefaults.set(nil, forKey: "mediumToken")
            self.userDefaults.set(nil, forKey: "mediumRefreshToken")

            let response = "Signed out"
            completionHandler("success", response)
        } else {
            let response = "Already signed out"
            completionHandler("error", response)
        }
    }

    // Completion handler returns state: success/failure, and user ID as a string if present
    open func ownCredentialsRequest(_ completionHandler: @escaping (String, String) -> Void) {

        if userDefaults.bool(forKey: "mediumIsAuthorized") {

            let token = userDefaults.object(forKey: "mediumToken")!
            let url = baseURL + "/me"
            let headers = [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json",
                "Accept": "application/json",
                "Accept-Charset": "utf-8"
            ]

          Alamofire.request(url, method: .get, headers: headers)
                .responseJSON { response in

                    if let value: AnyObject = response.result.value as AnyObject? {

                        let responseJSON = JSON(value)
                        let credentialsJSON = responseJSON["data"]

                        if credentialsJSON != "null" {
                            let userID = responseJSON["data"]["id"].string
                            self.credentialsJSON = credentialsJSON
                            if userID != nil {
                                self.userDefaults.set(userID, forKey: "mediumUserID")
                                completionHandler("success", self.userDefaults.object(forKey: "mediumUserID")! as! String)
                            } else {
                                completionHandler("error", "Couldn't fetch your User ID")
                            }
                        }
                    } else {
                        completionHandler("error", "Connection error")
                    }
            }
        } else {
            let errorString = "Not authorized on Medium"
            completionHandler("error", errorString)
        }
    }

    // Completion handler returns state: success/failure, number of users publications as string and publications JSON if present
    open func userPublicationsListRequest(_ completionHandler: @escaping (String, String, JSON) -> Void) {

        if userDefaults.bool(forKey: "mediumIsAuthorized") {

            let token = userDefaults.object(forKey: "mediumToken")!
            let userID = userDefaults.object(forKey: "mediumUserID")! as! String
            let url = baseURL + "/users/" + userID + "/publications"
            let headers = [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json",
                "Accept": "application/json",
                "Accept-Charset": "utf-8"
            ]

          Alamofire.request(url, method: .get ,headers: headers)
                .responseJSON { response in
                    print(response)

                    if let value: AnyObject = response.result.value as AnyObject? {

                        let responseJSON = JSON(value)
                        let publicationsJSON = responseJSON["data"]

                        if publicationsJSON != "null" {

                            let numberOfPublications = publicationsJSON.count

//                            // These properties to be used in data manager implementation
//                            for publicationNumber in 0 ..< numberOfPublications {
//
//                                let currentJSON = publicationsJSON[publicationNumber]
//                                let publicationID = currentJSON["id"].string!
//                                let carpark = currentJSON["description"].string!
//                                let currency = currentJSON["url"].string!
//                                let end_time = currentJSON["imageUrl"].string!
//
//                            }
                            completionHandler("success", "\(numberOfPublications)", publicationsJSON)

                        } else {
                            completionHandler("error", "Empty response", nil)
                        }
                    } else {
                        completionHandler("error", "Connection error", nil)
                    }
                }
        } else {
            let errorString = "Not authorized on Medium"
            completionHandler("error", errorString, nil)
        }
    }

    // Completion handler returns state: success/failure, number of users publications as string and publications JSON if present
    open func getListOfContributors(_ publicationId: String, completionHandler: @escaping (String, String, JSON) -> Void) {

        if userDefaults.bool(forKey: "mediumIsAuthorized") {

            let token = userDefaults.object(forKey: "mediumToken")!
            let url = baseURL + "/publications/" + publicationId + "/contributors"
            let headers = [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json",
                "Accept": "application/json",
                "Accept-Charset": "utf-8"
            ]

            Alamofire.request(url, method: .get, headers: headers)
                .responseJSON { response in
                   print(response)

                    if let value: AnyObject = response.result.value as AnyObject? {

                        let responseJSON = JSON(value)
                        let contributorsJSON = responseJSON["data"]

                        if contributorsJSON != "null" {

                            let numberOfContributors = contributorsJSON.count

                            //                            for publicationNumber in 0 ..< numberOfPublications {
                            //
                            //                                let currentJSON = publicationsJSON[publicationNumber]
                            //                                let publicationID = currentJSON["id"].string!
                            //                                let carpark = currentJSON["description"].string!
                            //                                let currency = currentJSON["url"].string!
                            //                                let end_time = currentJSON["imageUrl"].string!
                            //
                            //                            }
                            completionHandler("success", "\(numberOfContributors)", contributorsJSON)

                        } else {
                            completionHandler("error", "Empty response", nil)
                        }
                    } else {
                        completionHandler("error", "Connection error", nil)
                    }
            }
        } else {
            let errorString = "Not authorized on Medium"
            completionHandler("error", errorString, nil)
        }
    }

    // Completion handler returns state: success/failure, and error message if present
    open func createPost(_ title: String, contentFormat: String, content: String, canonicalUrl: String?=nil, tags: [String]?=nil,  publishStatus: MediumPublishStatus?=nil, license: MediumLicense?=nil, completionHandler: @escaping (String, String) -> Void) {

        if userDefaults.bool(forKey: "mediumIsAuthorized") {

            let token = userDefaults.object(forKey: "mediumToken")!
            let userID = self.userDefaults.object(forKey: "mediumUserID")! as! String
            let url = baseURL + "/users/" + userID + "/posts"
            let headers = [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json",
                "Accept": "application/json",
                "Accept-Charset": "utf-8"
            ]
            var parameters: [String : AnyObject] = [
                "title": title as AnyObject,
                "contentFormat": contentFormat as AnyObject,
                "content": content as AnyObject
            ]

            if canonicalUrl != nil {
                parameters["canonicalUrl"] = canonicalUrl! as AnyObject?
            }
            if tags != nil {
                parameters["tags"] = tags! as AnyObject?
            }
            if publishStatus != nil {
                parameters["publishStatus"] = publishStatus!.rawValue as AnyObject?
            }
            if license != nil {
                parameters["license"] = license!.rawValue as AnyObject?
            }

            Alamofire.request(url,
                              method: .post,
                              parameters: parameters,
                              encoding: JSONEncoding.default,
                              headers: headers)
                .responseJSON { response in
                    print(response)

                    if let value: AnyObject = response.result.value as AnyObject? {

                        let responseJSON = JSON(value)

                        if responseJSON["errors"] != nil {
                            if let responseMessage = responseJSON["errors"][0]["message"].string {
                                completionHandler("error", responseMessage)
                            } else {
                                completionHandler("error", "Some error")
                            }
                        } else if responseJSON["data"] != nil {
                            completionHandler("success", "Publication created")
                        } else {
                            completionHandler("error", "Connection error")
                        }

                    } else {
                        completionHandler("error", "Connection error")
                    }
            }
        } else {
            let errorString = "Not authorized on Medium"
            completionHandler("error", errorString)
        }

    }

    // Completion handler returns state: success/failure, and error message if present
    open func createPostUnderPublication(_ rootPublication: String, title: String, contentFormat: String, content: String, canonicalUrl: String?=nil, tags: [String]?=nil, publishStatus: MediumPublishStatus?=nil, license: MediumLicense?=nil, completionHandler: @escaping (String, String) -> Void) {

        if userDefaults.bool(forKey: "mediumIsAuthorized") {

            let token = userDefaults.object(forKey: "mediumToken")!
            let url = baseURL + "/publications/" + rootPublication + "/posts"
            let headers = [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json",
                "Accept": "application/json",
                "Accept-Charset": "utf-8"
            ]
            var parameters: [String : AnyObject] = [
                "title": title as AnyObject,
                "contentFormat": contentFormat as AnyObject,
                "content": content as AnyObject,
                ]

            if canonicalUrl != nil {
                parameters["canonicalUrl"] = canonicalUrl! as AnyObject?
            }
            if tags != nil {
                parameters["tags"] = tags! as AnyObject?
            }
            if publishStatus != nil {
                parameters["publishStatus"] = publishStatus!.rawValue as AnyObject?
            }
            if license != nil {
                parameters["license"] = license!.rawValue as AnyObject?
            }

            Alamofire.request(url, method: .post,
                              parameters: parameters,
                              encoding: JSONEncoding.default,
                              headers: headers)
                .responseJSON { response in
                    print(response)

                    if let value: AnyObject = response.result.value as AnyObject? {

                        let responseJSON = JSON(value)

                        if responseJSON["errors"] != nil {
                            if let responseMessage = responseJSON["errors"][0]["message"].string {
                                completionHandler("error", responseMessage)
                            } else {
                                completionHandler("error", "Some error")
                            }
                        } else if responseJSON["data"] != nil {
                            completionHandler("success", "Publication created")
                        } else {
                            completionHandler("error", "Connection error")
                        }

                    } else {
                        completionHandler("error", "Connection error")
                    }
            }
        } else {
            let errorString = "Not authorized on Medium"
            completionHandler("error", errorString)
        }
    }

}
