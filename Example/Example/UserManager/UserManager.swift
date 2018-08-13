//
//  UserManager.swift
//  TLT
//
//  Created by Pattadon on 1/22/2561 BE.
//  Copyright © 2561 Toyata. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import Firebase
import GoogleSignIn
import LineSDK
import BCryptSwift
var UserManager = UserManagerInstance.shared

enum UserManagerError : Error {
    case hashCannotBeGenerated
}
enum SocialAuthenticationError : Error {
    case invalidResponse,
    userCancelled,
    invalidResponseFromFacebook,
    invalidResponseFromLine
}
enum SocialAuthenticationPlatform : Int {
    case none = 0 ,
    facebook ,
    google ,
    line
}
struct SocialAuthenticationPayload {
    var platform: SocialAuthenticationPlatform
    var providerId: String?
    var email: String?
    var birthday: String?
    var fullName: String?
    var firstName: String?
    var lastName: String?
    var imageURL: String?
    var token: String?
    var statusMessage: String?
    init(platform: SocialAuthenticationPlatform,
         providerId: String? = nil,
         email: String? = nil,
         birthday: String? = nil,
         fullName: String? = nil,
         firstName: String? = nil,
         lastName: String? = nil,
         imageURL: String? = nil,
         token: String? = nil,
         statusMessage: String? = nil) {
        
        self.platform = platform
        self.providerId = providerId
        self.email = email
        self.birthday = birthday
        self.fullName = fullName
        self.firstName = firstName
        self.lastName = lastName
        self.imageURL = imageURL
        self.token = token
        self.statusMessage = statusMessage
    }
}
protocol UserManagerSocialAuthenticationDelegate : class {
    func didFinishRequestingLogin(socialAuthentication : SocialAuthenticationPlatform , isSuccess : Bool , payload : SocialAuthenticationPayload? , error : Error?)
}
let userModelKey = "UserModel"
class UserManagerInstance : NSObject {
    var holdingAssignFCMTokenForTesting : Bool = false
    enum UserManagerError : Error {
        case hashCannotBeGenerated
    }
    
    weak var externalServiceAuthentiationDelegate : UserManagerSocialAuthenticationDelegate?
    static var shared = UserManagerInstance()
    
    fileprivate var _token : String? = nil
    var token : String {
        get{
            if _token == nil {
                _token =  KeychainAdapter.retrieveToken()
            }
            return _token ?? ""
        }set{
            _token = newValue
        }
    }
    var hasToken : Bool {
        return token == "" ? false : true
    }
    var isAuthenticated : Bool {
        get{
          return User.state == .authenticated
        }
    }
    func saveState(){
        
    }
    
    var timeCounterOnAuthorization : Int?
    
    func saveToken(credentailData : String?) -> Bool  {
        guard let credentailData = credentailData , credentailData != "" else {return false}
        if UserManager.token != credentailData {
            self.token = credentailData
            KeychainAdapter.save(token: credentailData)
            //print("function saveToken token:\(self.token)")
            //print("function saveToken credentailData:\(credentailData)")
        }
        return true
    }
    func setupPinForRegistration(pinPassword : String) -> (String?,Error?)  {
        let salt =  BCryptSwift.generateSaltWithNumberOfRounds(10)
        let hashPassword = BCryptSwift.hashPassword(pinPassword, withSalt: salt)
        guard  hashPassword != nil else {
            return (nil , UserManagerError.hashCannotBeGenerated )
        }
        KeychainAdapter.save(salt: salt)
        return (hashPassword,nil)
    }
    func setupPinForLogin(pinPassword : String , completion : @escaping (String?) -> Void )   {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let salt = KeychainAdapter.retrieveSalt()
                else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
            }
            guard let hash1 = BCryptSwift.hashPassword(pinPassword, withSalt: salt)
                else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
            }
            let saltForRound2 =  BCryptSwift.generateSaltWithNumberOfRounds(10)
            guard let hash2 = BCryptSwift.hashPassword(hash1, withSalt: saltForRound2) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            DispatchQueue.main.async {
                completion(hash2)
            }
        }
    }
    func removeToken() {
        _ = KeychainAdapter.removeToken(token: self._token)
        self._token = nil
    }
    func save(){
        UserInstance.save(object: User)
    }
    
    func loginWithFacebook(viewController: UIViewController) {
        let fbLoginManager = LoginManager()
        fbLoginManager.logIn(
            readPermissions: [.publicProfile, .email, .userBirthday, .userLikes],
            viewController: viewController
        ) { [weak self] result in
            switch result {
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print(grantedPermissions)
                print(declinedPermissions)
                
                GraphRequest(
                    graphPath: "/me",
                    parameters: ["fields": "id,name,first_name,last_name,picture.type(large),email,birthday,link"],
                    accessToken: accessToken
                ).start { [weak self] (response, result) in
                    switch result {
                    case GraphRequestResult.success(let response):
                        guard let resultDict = response.dictionaryValue else {
                            self?.externalServiceAuthentiationDelegate?.didFinishRequestingLogin(
                                socialAuthentication: .facebook, isSuccess: false, payload: nil, error: SocialAuthenticationError.invalidResponseFromFacebook
                            )
                            
                            return
                        }
                        
                        print(resultDict)
                        
                        let payload = SocialAuthenticationPayload(
                            platform: .facebook,
                            providerId: resultDict["id"] as? String,
                            email: resultDict["email"] as? String,
                            birthday: resultDict["birthday"] as? String
                        )
                        self?.externalServiceAuthentiationDelegate?.didFinishRequestingLogin(
                            socialAuthentication: .facebook, isSuccess: true, payload: payload, error: nil
                        )
                    case GraphRequestResult.failed(let error):
                        self?.externalServiceAuthentiationDelegate?.didFinishRequestingLogin(
                            socialAuthentication: .facebook, isSuccess: false, payload: nil, error: error
                        )
                    }
                }
            case .cancelled:
                self?.externalServiceAuthentiationDelegate?.didFinishRequestingLogin(
                    socialAuthentication: .facebook, isSuccess: false, payload: nil, error: SocialAuthenticationError.userCancelled
                )
            case .failed(let error):
                self?.externalServiceAuthentiationDelegate?.didFinishRequestingLogin(
                    socialAuthentication: .facebook, isSuccess: false, payload: nil, error: error
                )
            }
            
        }
    }
    
    func facebookLogout() {
        let fbLoginManager = LoginManager()
        fbLoginManager.logOut()
    }
    
    func loginWithGoogleSignin(viewController: UIViewController) {
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = viewController as? GIDSignInUIDelegate
        GIDSignIn.sharedInstance().signIn()
    }
    
    func googleLogout() {
        GIDSignIn.sharedInstance().signOut()
    }
    
    func loginWithLine() {
        LineSDKLogin.sharedInstance().delegate = self
        LineSDKLogin.sharedInstance().start()
    }
    
    func lineLogout() {
        let apiClient = LineSDKAPI.init(configuration: .defaultConfig())
        apiClient.logout(queue: DispatchQueue.main) { (success, error) in
            if let error = error {
                print(error)
            }
        }
    }
    func validateTokenOnChanged(){
        if !holdingAssignFCMTokenForTesting {
            _ = API.updateToken()
        }
    }
}
extension UserManagerInstance : LineSDKLoginDelegate {
    func didLogin(_ login: LineSDKLogin, credential: LineSDKCredential?, profile: LineSDKProfile?, error: Error?) {
        if let error = error {
            print(error)
            externalServiceAuthentiationDelegate?.didFinishRequestingLogin(
                socialAuthentication: .line, isSuccess: false, payload: nil, error: error
            )
            return
        }
        
        guard let profile = profile, let credential = credential, let _ = credential.accessToken else {
            externalServiceAuthentiationDelegate?.didFinishRequestingLogin(
                socialAuthentication: .line, isSuccess: false, payload: nil, error: SocialAuthenticationError.invalidResponseFromLine
            )
            return
        }
        
        let payload = SocialAuthenticationPayload(
            platform: .line,
            providerId: profile.userID,
            fullName: profile.displayName,
            imageURL: profile.pictureURL?.absoluteString,
            statusMessage: profile.statusMessage
        )
        externalServiceAuthentiationDelegate?.didFinishRequestingLogin(
            socialAuthentication: .line, isSuccess: true, payload: payload, error: nil
        )
    }
}
extension UserManagerInstance : GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error)
            externalServiceAuthentiationDelegate?.didFinishRequestingLogin(
                socialAuthentication: .google, isSuccess: false, payload: nil, error: error
            )
            return
        }
        
        let payload = SocialAuthenticationPayload(
            platform: .google,
            providerId: user.userID,
            email: user.profile.email,
            fullName: user.profile.name,
            firstName: user.profile.givenName,
            lastName: user.profile.familyName,
            imageURL: user.profile.imageURL(withDimension: 400).absoluteString,
            token: user.authentication.idToken
        )
        externalServiceAuthentiationDelegate?.didFinishRequestingLogin(
            socialAuthentication: .google, isSuccess: true, payload: payload, error: nil
        )
    }
}
