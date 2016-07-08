//
//  MediumSDKManager.swift
//  
//
//  Created by drinkius on 20/05/16.
//
//

import UIKit
import OAuthSwift
import SwiftyJSON
import Alamofire

enum MediumPublishStatus: String {
    case published = "public"
    case draft = "draft"
    case unlisted = "unlisted"
}

enum MediumLicense: String {
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

class MediumSDKManager: NSObject {
    
    // Making our SDK behave like a singleton with sharedInstance
    static let sharedInstance = MediumSDKManager()
    private override init() {}
    
    // Using user defaults to store userID & tokens
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    private let baseURL = "https://api.medium.com/v1"
    private var oauthswift: OAuth2Swift!
    private var credential: OAuthSwiftCredential!
    private var credentialsJSON: JSON!
    
    // Completion handler returns state: success/failure and user's medium token or error string
    func doOAuthMedium(completionHandler: (String, String) -> Void) {
        
        // Insert your app credentials here
        let clientID = ""
        let clientSecret = ""
        
        // API URLs
        let authorizeURL = "https://medium.com/m/oauth/authorize"
        let accessTokenUrl = baseURL + "/tokens"
        let callbackURL = "http://mediumswift.herokuapp.com/callback/"
        
        // Specify the scope of functions your app utilizes, options: basicProfile,publishPost, and listPublications. Extended scope "uploadImage" by default can't be requested by an application.
        
        let scope = "basicProfile,publishPost,listPublications"
        
        let oauthswift = OAuth2Swift(
            consumerKey:    clientID,
            consumerSecret: clientSecret,
            authorizeUrl:   authorizeURL,
            accessTokenUrl: accessTokenUrl,
            responseType:   "code"
        )
        
        let state: String = generateStateWithLength(20) as String
        oauthswift.authorizeWithCallbackURL( NSURL(string: callbackURL)!, scope: scope, state: state, success: {
            credential, response, parameters in
            
            self.credential = credential
            
            print("Token \(self.credential.oauth_token)")
            print("Refresh token \(self.credential.oauth_refresh_token)")
            
            self.userDefaults.setBool(true, forKey: "mediumIsAuthorized")
            self.userDefaults.setObject(self.credential.oauth_token, forKey: "mediumToken")
            self.userDefaults.setObject(self.credential.oauth_refresh_token, forKey: "mediumRefreshToken")
            
            self.ownCredentialsRequest() { state, response in
                if state != "error" {
                    completionHandler("success", self.userDefaults.objectForKey("mediumToken")! as! String)
                } else {
                    let errorString = "Logged in but couldn't fetch your user details"
                    completionHandler("error", errorString)
                }
            }
            
            }, failure: { error in
                self.userDefaults.setBool(false, forKey: "mediumIsAuthorized")
                let errorString = "Login failed"
                completionHandler("error", errorString)
//                print(error.localizedDescription, terminator: "")
        })
        
    }
    
    // Completion handler returns state: success/failure and medium token string if present
    func checkCred(completionHandler: (String, String) -> Void) {
        
        if userDefaults.boolForKey("mediumIsAuthorized") {
            let response = self.userDefaults.objectForKey("mediumToken")! as! String
            completionHandler("success", response)
        } else {
            let response = "Not authorized on Medium"
            completionHandler("error", response)
        }
    }
    
    // Completion handler returns state: success/failure and user ID string if present
    func getUserID(completionHandler: (String, String) -> Void) {
        if userDefaults.boolForKey("mediumIsAuthorized") {
            let response = userDefaults.objectForKey("mediumUserID")! as! String
            completionHandler("success", response)
        } else {
            let response = "Not authorized on Medium"
            completionHandler("error", response)
        }
    }
    
    // Completion handler returns state: success/failure and medium token string if present
    func getToken(completionHandler: (String, String) -> Void) {
        if userDefaults.boolForKey("mediumIsAuthorized") {
            let response = userDefaults.objectForKey("mediumToken")! as! String
            completionHandler("success", response)
        } else {
            let response = "Not authorized on Medium"
            completionHandler("error", response)
        }
    }
    
    // Completion handler returns state: success/failure, and explanation string
    func signOutMedium(completionHandler: (String, String) -> Void) {
        
        if userDefaults.boolForKey("mediumIsAuthorized") {
            self.userDefaults.setBool(false, forKey: "mediumIsAuthorized")
            self.userDefaults.setObject(nil, forKey: "mediumToken")
            self.userDefaults.setObject(nil, forKey: "mediumRefreshToken")
            
            let response = "Signed out"
            completionHandler("success", response)
        } else {
            let response = "Already signed out"
            completionHandler("error", response)
        }
    }
    
    // Completion handler returns state: success/failure, and user ID as a string if present
    func ownCredentialsRequest(completionHandler: (String, String) -> Void) {
        
        if userDefaults.boolForKey("mediumIsAuthorized") {
            
            let token = userDefaults.objectForKey("mediumToken")!
            let url = baseURL + "/me"
            let headers = [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json",
                "Accept": "application/json",
                "Accept-Charset": "utf-8"
            ]
            
            Alamofire.request(.GET, url, headers: headers)
                .responseJSON { response in
                    
                    if let value: AnyObject = response.result.value {
                        
                        let responseJSON = JSON(value)
                        let credentialsJSON = responseJSON["data"]
                        
                        if credentialsJSON != "null" {
                            let userID = responseJSON["data"]["id"].string
                            self.credentialsJSON = credentialsJSON
                            if userID != nil {
                                self.userDefaults.setObject(userID, forKey: "mediumUserID")
                                completionHandler("success", self.userDefaults.objectForKey("mediumUserID")! as! String)
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
    func userPublicationsListRequest(completionHandler: (String, String, JSON) -> Void) {
        
        if userDefaults.boolForKey("mediumIsAuthorized") {
            
            let token = userDefaults.objectForKey("mediumToken")!
            let userID = userDefaults.objectForKey("mediumUserID")! as! String
            let url = baseURL + "/users/" + userID + "/publications"
            let headers = [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json",
                "Accept": "application/json",
                "Accept-Charset": "utf-8"
            ]
            
            Alamofire.request(.GET, url, headers: headers)
                .responseJSON { response in
//                    print(response)
                    
                    if let value: AnyObject = response.result.value {
                        
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
    func getListOfContributors(publicationId: String, completionHandler: (String, String, JSON) -> Void) {
        
        if userDefaults.boolForKey("mediumIsAuthorized") {
            
            let token = userDefaults.objectForKey("mediumToken")!
            let url = baseURL + "/publications/" + publicationId + "/contributors"
            let headers = [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json",
                "Accept": "application/json",
                "Accept-Charset": "utf-8"
            ]
            
            Alamofire.request(.GET, url, headers: headers)
                .responseJSON { response in
//                    print(response)
                    
                    if let value: AnyObject = response.result.value {
                        
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
    func createPost(title: String, contentFormat: String, content: String, canonicalUrl: String?=nil, tags: [String]?=nil,  publishStatus: MediumPublishStatus?=nil, license: MediumLicense?=nil, completionHandler: (String, String) -> Void) {
        
        if userDefaults.boolForKey("mediumIsAuthorized") {
            
            let token = userDefaults.objectForKey("mediumToken")!
            let userID = self.userDefaults.objectForKey("mediumUserID")! as! String
            let url = baseURL + "/users/" + userID + "/posts"
            let headers = [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json",
                "Accept": "application/json",
                "Accept-Charset": "utf-8"
            ]
            var parameters: [String : AnyObject] = [
                "title": title,
                "contentFormat": contentFormat,
                "content": content
            ]
            
            if canonicalUrl != nil {
                parameters["canonicalUrl"] = canonicalUrl!
            }
            if tags != nil {
                parameters["tags"] = tags!
            }
            if publishStatus != nil {
                parameters["publishStatus"] = publishStatus!.rawValue
            }
            if license != nil {
                parameters["license"] = license!.rawValue
            }
            
            Alamofire.request(.POST, url, parameters: parameters, headers: headers, encoding: .JSON)
                .responseJSON { response in
//                    print(response)
                    
                    if let value: AnyObject = response.result.value {
                        
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
    func createPostUnderPublication(rootPublication: String, title: String, contentFormat: String, content: String, canonicalUrl: String?=nil, tags: [String]?=nil, publishStatus: MediumPublishStatus?=nil, license: MediumLicense?=nil, completionHandler: (String, String) -> Void) {
        
        if userDefaults.boolForKey("mediumIsAuthorized") {
            
            let token = userDefaults.objectForKey("mediumToken")!
            let url = baseURL + "/publications/" + rootPublication + "/posts"
            let headers = [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json",
                "Accept": "application/json",
                "Accept-Charset": "utf-8"
            ]
            var parameters: [String : AnyObject] = [
                "title": title,
                "contentFormat": contentFormat,
                "content": content,
                ]
            
            if canonicalUrl != nil {
                parameters["canonicalUrl"] = canonicalUrl!
            }
            if tags != nil {
                parameters["tags"] = tags!
            }
            if publishStatus != nil {
                parameters["publishStatus"] = publishStatus!.rawValue
            }
            if license != nil {
                parameters["license"] = license!.rawValue
            }
            
            Alamofire.request(.POST, url, parameters: parameters, headers: headers, encoding: .JSON)
                .responseJSON { response in
//                    print(response)
                    
                    if let value: AnyObject = response.result.value {
                        
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
