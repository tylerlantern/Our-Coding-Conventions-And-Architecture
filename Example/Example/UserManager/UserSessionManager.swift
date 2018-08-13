//
//  UserSessionManager.swift
//  TLT
//
//  Created by Santi Ma-Oun on 28/5/2561 BE.
//  Copyright © 2561 Toyata. All rights reserved.
//

import Foundation
protocol UserSessionManagerDelegate {
    func sessionDidExpire()
}
class UserSessionManager {
    static let shared = UserSessionManager()
    fileprivate init() { }
    let sessionTime: Double = 300
    var delegate: UserSessionManagerDelegate?
    var sessionTimer: Timer?
    var isSessionAlive = false
    var isPresentingAuthenticationPage = false
    //    func startSession() {
    //        print("startSession")
    //        sessionTimer?.invalidate()
    //        sessionTimer = nil
    //        sessionTimer = Timer.scheduledTimer(timeInterval: sessionTime, target: self, selector: #selector(sessionExpire), userInfo: nil, repeats: false)
    //        isSessionAlive = true
    //    }
    func startSessionWoCounter() {
        print(#function)
        sessionTimer?.invalidate()
        sessionTimer = nil
        isSessionAlive = true
    }
    func startCounterOnAppWillResignAction(){
        print(#function)
        sessionTimer?.invalidate()
        sessionTimer = nil
        sessionTimer = Timer.scheduledTimer(timeInterval: sessionTime, target: self, selector: #selector(sessionExpire), userInfo: nil, repeats: false)
        isSessionAlive = true
    }
    func shallRequestingAuthenticationOnExpiredAtDidBecomeActive(){
        if isSessionAlive  {
            sessionTimer?.invalidate()
            sessionTimer = nil
        }else {
             delegate?.sessionDidExpire()
        }
    }
    @objc func sessionExpire() {
        if !isPresentingAuthenticationPage && !Global.shallDisableUserSessionManagerForDebug {
            isSessionAlive = false
            delegate?.sessionDidExpire()
        }
    }
}
