//
//  KeychainAdapter.swift
//  TLT
//
//  Created by Nattapong Unaregul on 2/3/18.
//  Copyright © 2018 Toyata. All rights reserved.
//

import UIKit

var KeychainAdapter = KeychainAdapterInstance.center

class KeychainAdapterInstance: NSObject {
    static var center = KeychainAdapterInstance()
    fileprivate let account = "tylerlantern"
    fileprivate let defaultCredentailService = "defaultCredentailService"
    fileprivate let savingSaltCredentailService = "savingSaltCredentailService"
    override init() {
        super.init()
    }
    func save( salt : String ){
        KeychainService.saveKey(type: ValueTypeOfKeychain.secret , credential: salt, account: account, service: savingSaltCredentailService)
    }
    func retrieveSalt() -> String? {
        return KeychainService.retrieveKey(type: .secret , account: account, service: savingSaltCredentailService)
    }
    func removeSalt() -> Bool {
        guard let salt = self.retrieveSalt() else {
            return true
        }
        let result = KeychainService.removeKey(type: ValueTypeOfKeychain.secret, credential: salt, account: account, service: savingSaltCredentailService)
        return result == nil ? true : false
    }
    func save(token : String)  {
        KeychainService.saveKey(type: .secret, credential: token, account: self.account, service: defaultCredentailService)
    }
    func retrieveToken() -> String? {
        return KeychainService.retrieveKey(type: .secret , account: account, service: defaultCredentailService)
    }
    func removeToken(token : String?) -> Bool{
        guard let token = token else {return false}
        let error = KeychainService.removeKey(type: ValueTypeOfKeychain.secret, credential: token, account:account , service: defaultCredentailService)
        
        guard error != nil else {
            return false
        }
        return true
    }
}
