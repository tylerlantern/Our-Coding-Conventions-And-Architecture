//
//  AuthenticationManager.swift
//  Created by Nattapong Unaregul on 25/4/18.
//  Copyright © 2018 Toyata. All rights reserved.
//

import UIKit
var AuthenticationManager = AuthenticationManagerInstance.center
class AuthenticationManagerInstance: NSObject {
    static var center = AuthenticationManagerInstance()
    override init() {
        super.init()
    }
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: .now() , repeating: .seconds(1))
        t.setEventHandler(handler: { [weak self] in
            self?.eventHandler?()
        })
        return t
    }()
    var eventHandler: (() -> Void)?
    private enum State {
        case suspended
        case resumed
    }
    private var state: State = .suspended
    func resume() {
        if state == .resumed {
            return
        }
        state = .resumed
        timer.resume()
    }
    func suspend() {
        if state == .suspended {
            return
        }
        state = .suspended
        timer.suspend()
    }
    
}
