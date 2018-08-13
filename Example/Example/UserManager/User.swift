//
//  User.swift
//  Created by Pattadon on 1/22/2561 BE.
//  Copyright © 2561 Toyata. All rights reserved.
//

import UIKit
import MapKit
var User = UserInstance.center
enum UserState : Int {
    case anonymous = 0,
    authenticated
}

final class UserInstance: NSObject , NSCoding {
    override init() {
        super.init()
    }
    var hasInitialSetupForFirstTimeInstallation : Bool = false
    var state : UserState = UserState.anonymous
    var id : String = ""
    static fileprivate var _center : UserInstance? = nil
    static var center : UserInstance  {
        get{
            if  let userModel = UserInstance.loadData() , _center == nil {
                _center = userModel
            }
            if _center == nil {
                print("Can not load user's save data initiate new instance")
                _center = UserInstance()
            }
            return _center!
        }
    }
    var isTouchIDEnable : Bool = false
    var firstName : String?
    var lastName : String?
    var email : String?
    var graphApiFB = GraphApiFB()
    var token : String?
    var numberOfAttemptInputWrongPassword = 0
    var fullName : String  {
        get{
            return (firstName ?? "") + (firstName == nil ? "" : " ") + (lastName ?? "")
        }
    }
    var passTutorialYet : Bool = false
    var coordinate : CLLocationCoordinate2D?
    static private var userModelKey = "UserModel"
    func save(){
        UserInstance.save(object: self)
    }
    static func save(object : UserInstance){
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: object )
        UserDefaults.standard.set(encodedData, forKey: UserInstance.userModelKey)
        UserDefaults.standard.synchronize()
    }
    static func loadData() -> UserInstance? {
        if let unarchivedObject = UserDefaults.standard.object(forKey: UserInstance.userModelKey) as? Data {
            return NSKeyedUnarchiver.unarchiveObject(with: unarchivedObject as Data) as? UserInstance
        }
        return nil
    }
    static func removeData() {
        UserDefaults.standard.removeObject(forKey: UserInstance.userModelKey)
    }
    required convenience init(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeObject(forKey: "id") as? String ?? ""
        let firstName = aDecoder.decodeObject(forKey: "firstName") as? String ?? ""
        let lastName = aDecoder.decodeObject(forKey: "lastName") as? String ?? ""
        let stateInt = aDecoder.decodeInt32(forKey: "state")
        let passTutorialYet = aDecoder.decodeBool(forKey: "passTutorialYet")
        let parseedStateInt = Int(stateInt)
        let state = UserState(rawValue: parseedStateInt) ?? UserState.anonymous
        let isTouchIDEnable =  aDecoder.decodeBool(forKey: "isTouchIDEnable")
        let numberOfAttemptInputWrongPassword = aDecoder.decodeInt32(forKey: "numberOfAttemptInputWrongPassword")
        let hasInitialSetupForFirstTimeInstallation = aDecoder.decodeBool(forKey: "hasInitialSetupForFirstTimeInstallation")
        self.init(id : id , firstName: firstName, lastName: lastName
            , state: state
            , isTouchIDEnable : isTouchIDEnable , passTutorialYet : passTutorialYet
            , numberOfAttemptInputWrongPassword : Int(numberOfAttemptInputWrongPassword)
            , hasInitialSetupForFirstTimeInstallation : hasInitialSetupForFirstTimeInstallation)
    }
    init(id : String , firstName : String , lastName : String , state : UserState , isTouchIDEnable : Bool , passTutorialYet : Bool
        , numberOfAttemptInputWrongPassword : Int
        , hasInitialSetupForFirstTimeInstallation : Bool) {
        super.init()
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.state = state
        self.isTouchIDEnable = isTouchIDEnable
        self.passTutorialYet = passTutorialYet
        self.numberOfAttemptInputWrongPassword = numberOfAttemptInputWrongPassword
        self.hasInitialSetupForFirstTimeInstallation = hasInitialSetupForFirstTimeInstallation
    }
    func resetToAnonymous(){
        self.id = ""
        self.firstName = nil
        self.lastName = nil
        self.state = .anonymous
        self.isTouchIDEnable = false
        self.passTutorialYet = false
        self.hasInitialSetupForFirstTimeInstallation = false
        self.numberOfAttemptInputWrongPassword = 0
        save()
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(firstName, forKey: "firstName")
        aCoder.encode(lastName, forKey: "lastName")
        aCoder.encode(state.rawValue, forKey: "state")
        aCoder.encode(isTouchIDEnable, forKey: "isTouchIDEnable")
        aCoder.encode(passTutorialYet, forKey: "passTutorialYet")
        aCoder.encode(numberOfAttemptInputWrongPassword, forKey: "numberOfAttemptInputWrongPassword")
        aCoder.encode(hasInitialSetupForFirstTimeInstallation, forKey: "hasInitialSetupForFirstTimeInstallation")
    }
    func wrongPasswordAttempt() {
        numberOfAttemptInputWrongPassword += 1
        save()
    }
    func correctPasswordAttempt() {
        numberOfAttemptInputWrongPassword = 0
        save()
        UserSessionManager.shared.startSessionWoCounter()
    }
}
struct GraphApiFB {
    var id : String?
    var firstName : String?
    var lastName : String?
    var email : String?
    var isAuthentiate : Bool = false
    var thumbnailUrl :String?
    var mobile : String?
}
