//
//  ViewController.swift
//  medium-sdk-swift-sample
//
//  Created by drinkius on 02/05/16.
//  Copyright © 2016 96problems. All rights reserved.
//

import UIKit
import MediumSDKSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //
    var mediumSession = MediumSDKManager.sharedInstance
    
    // Tableview setup
    
    var tableView: UITableView  =   UITableView()
    var historySessions = [AnyObject]()
    var buttons : [String] = [
        "Authorize on Medium.com",
        "Check token",
        "Own profile info request",
        "Own publications request",
        "Publications's contributors request",
        "Create a post",
        "Create a post under publication",
        "Sign out"
    ]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buttons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        cell.textLabel!.text = buttons[indexPath.row]
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            mediumSession.doOAuthMedium() { state, message in
                if state == "success" {
                    self.showAlert("Success! \n\n Your Medium token is: \(message)")
                } else {
                    self.showAlert("Error: \n\n \(message)")
                }
            }
        case 1:
            mediumSession.checkCred() { state, message in
                if state == "success" {
                    self.showAlert("Success! \n\n Your Medium token is: \(message)")
                } else {
                    self.showAlert("Error: \n\n \(message)")
                }
            }
        case 2:
            mediumSession.ownCredentialsRequest() { state, message in
                if state == "success" {
                    self.showAlert("Success! \n\n  Your user ID is: \(message)")
                } else {
                    self.showAlert("Error: \n\n \(message)")
                }
            }
        case 3:
            mediumSession.userPublicationsListRequest() { state, message, _ in
                if state == "success" {
                    self.showAlert("Success! \n\n Number of own publications: \n\n \(message)")
                } else {
                    self.showAlert("Error: \n\n \(message)")
                }
            }
        case 4:
            // Sample postID, feel free to use any other post ID of yours to test this function
            let postID = "b6bdc04b3925"
            mediumSession.getListOfContributors(postID) { state, message, _ in
                if state == "success" {
                    self.showAlert("Success! \n\n Number of contributors: \n\n \(message)")
                } else {
                    self.showAlert("Error: \n\n \(message)")
                }
            }
        case 5:
            let title = "The first post published with SDK CC license"
            let contentFormat = "html"
            let content = "<h1>The first post</h1><p>Published with SDK</p>"
            let canonicalUrl = "http://jamietalbot.com/posts/liverpool-fc"
            let tags = ["football", "sport", "Liverpool"]
            let publishStatus = MediumPublishStatus.published
            let licence = MediumLicense.cc40bync
            
            //        mediumSession.createPost(title, contentFormat: contentFormat, content: content, canonicalUrl: canonicalUrl)
            mediumSession.createPost(title, contentFormat: contentFormat, content: content, canonicalUrl: canonicalUrl, tags: tags, publishStatus: publishStatus, license: licence) { state, message in
                if state == "success" {
                    self.showAlert("Success! \n\n \(message)")
                } else {
                    self.showAlert("Error: \n\n \(message)")
                }
            }
        case 6:
            // In order to check this functionality - enter the root publication ID you got edit rights to
            let rootPublication = ""
            let title = "New post under publication"
            let contentFormat = "html"
            let content = "<h1>Test in progress</h1><p>Functions seem to be working well</p>"
            let canonicalUrl = "http://phirotto.com/"
            let tags = ["medium-sdk", "swift", "swiftlang"]
            let publishStatus = MediumPublishStatus.published
            let licence = MediumLicense.publicDomain
            
            //        mediumSession.createPostUnderPublication(rootPublication, title: title, contentFormat: contentFormat, content: content, tags: tags)
            mediumSession.createPostUnderPublication(rootPublication, title: title, contentFormat: contentFormat, content: content, canonicalUrl: canonicalUrl, tags: tags, publishStatus: publishStatus, license: licence) { state, message in
                if state == "success" {
                    self.showAlert("Success! \n\n \(message)")
                } else {
                    self.showAlert("Error: \n\n \(message)")
                }
            }
        case 7:
            mediumSession.signOutMedium() { state, message in
                if state == "success" {
                    self.showAlert("Success: \n\n \(message)")
                } else {
                    self.showAlert("Error: \n\n \(message)")
                }
            }
        default:
            return
        }
//        print(buttons[indexPath.row])
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView(frame: UIScreen.main.bounds, style: UITableViewStyle.plain)
        tableView.delegate      =   self
        tableView.dataSource    =   self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.view.addSubview(self.tableView)
    }
    
    fileprivate func showAlert(_ message: String) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel) { [unowned self] _ in
            //            self.dismissViewControllerAnimated(true, completion: nil)
            })
        present(alert, animated: true, completion: nil)
    }

}

