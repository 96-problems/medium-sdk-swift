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
    
    private let baseURL = "https://api.medium.com/v1"
    private var oauthswift: OAuth2Swift!
    private var credential: OAuthSwiftCredential!
    private var mediumToken: String?
    private var credentialsJSON: JSON!
    private var userID: String?
    var isAuthorized: Bool = false
    
    func doOAuthMedium() {
        
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
            self.isAuthorized = true
            self.mediumToken = self.credential.oauth_token
            
            print("Token \(self.credential.oauth_token)")
            print("Refresh token \(self.credential.oauth_refresh_token)")
            
            self.ownCredentialsRequestWithCompletion() { response in
                if response != "error" {
                    print("Got credentials")
                    print("Own credentials JSON: \(self.credentialsJSON)")
                    print("User ID: \(self.userID)" )
                } else {
                    print("Couldn't handle your request")
                }
            }
            
            }, failure: { error in
                print(error.localizedDescription, terminator: "")
        })
        
    }
    
    func checkCred() {
        
        if isAuthorized {
            print("Authorized! Token: \(self.mediumToken!)")
        } else {
            print("Not authorized on Medium")
        }
    }
    
    func ownCredentialsRequest() {
        
        isAuthorized = true
        
        if isAuthorized {
            
            ownCredentialsRequestWithCompletion() { response in
                if response != "error" {
                    print("Got credentials")
                    print("Own credentials JSON: \(self.credentialsJSON)")
                    print("User ID: \(self.userID)" )
                } else {
                    print("Couldn't handle your request")
                }
            }
        } else {
            print("Not authorized on Medium")
        }
    }
    
    private func ownCredentialsRequestWithCompletion(completionHandler: String -> Void) {
        
        let token = self.mediumToken!
        let url = baseURL + "/me"
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Accept-Charset": "utf-8"
        ]
        
        Alamofire.request(.GET, url, headers: headers)
            .responseJSON { response in
                print(response)  // print original HTTP response
                
                if let value: AnyObject = response.result.value {
                    
                    let responseJSON = JSON(value)
                    let credentialsJSON = responseJSON["data"]
                    
                    if credentialsJSON != "null" {
                        self.userID = responseJSON["data"]["id"].string
                        self.credentialsJSON = credentialsJSON
                        if self.userID != nil {
                            completionHandler(self.userID!)
                        } else {
                            completionHandler("error")
                        }
                    }
                } else {
                    completionHandler("error")
                }
        }
    }
    
    
    func userPublicationsListRequest() {
        
        if isAuthorized {
            if self.userID != nil {
                publicationsListRequestWithUserID()
            } else {
                ownCredentialsRequestWithCompletion() { response in
                    if response != "error" {
                        self.publicationsListRequestWithUserID()
                    } else {
                        print("Couldn't get user ID")
                    }
                }
            }
            
        } else {
            print("Not authorized on Medium")
        }
    }
    
    private func publicationsListRequestWithUserID() {
        
        let token = self.mediumToken!
        let url = baseURL + "/users/" + self.userID! + "/publications"
        let headers = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Accept-Charset": "utf-8"
        ]
        
        Alamofire.request(.GET, url, headers: headers)
            //            .responseJSON { response in
            //                print(response)  // original URL request
            //        }
            .responseString { response in
                print(response)
        }
    }
    
    func getListOfContributors(publicationId: String) {
        
        if isAuthorized {
            
            let token = self.mediumToken!
            let url = baseURL + "/publications/" + publicationId + "/contributors"
            let headers = [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json",
                "Accept": "application/json",
                "Accept-Charset": "utf-8"
            ]
            
            Alamofire.request(.GET, url, headers: headers)
                .responseJSON { response in
                    print(response)  // original URL request
            }
        } else {
            print("Not authorized on Medium")
        }
    }
    
    func createPost(title: String, contentFormat: String, content: String, canonicalUrl: String?=nil, tags: [String]?=nil,  publishStatus: MediumPublishStatus?=nil, license: MediumLicense?=nil) {
        
        if isAuthorized {
            
            let token = self.mediumToken!
            let url = baseURL + "/users/" + self.userID! + "/posts"
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
                .responseString { response in
                    print(response)
            }
        } else {
            print("Not authorized on Medium")
        }
        
    }
    
    func createPostUnderPublication(rootPublication: String, title: String, contentFormat: String, content: String, canonicalUrl: String?=nil, tags: [String]?=nil, publishStatus: MediumPublishStatus?=nil, license: MediumLicense?=nil) {
        
        if isAuthorized {
            
            let token = self.mediumToken!
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
                .responseString { response in
                    print(response)
            }
            
        } else {
            print("Not authorized on Medium")
        }
    }

}
