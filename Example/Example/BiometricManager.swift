//
//  BiometricManager.swift
//  Created by Nattapong Unaregul on 19/4/18.
//  Copyright © 2018 Toyata. All rights reserved.
//

import UIKit
import LocalAuthentication

var BiometricManager = BiometricManagerInstance.shared

protocol BiometricManagerDelegate : AnyObject {
    func didFinishLocalAuthentication(isSuccess : Bool,error : Error?)
}
class BiometricManagerInstance : NSObject {
    enum BiometricType {
        case none, touchId, faceId
    }
    lazy var authenticationType: BiometricType = {
        let context = LAContext()
        
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            if let error = error {
                return BiometricType.none
            }
            if #available(iOS 11, *) {
                if context.biometryType == .faceID {
                    return BiometricType.faceId
                } else {
                    return BiometricType.touchId
                }

            } else {
                return BiometricType.touchId
            }
        } else {
            return BiometricType.none
        }
    }()
    
    static var shared = BiometricManagerInstance()
    weak var delegate : BiometricManagerDelegate?
    func authenticationWithBiometric(completion : ((_ isSuccess : Bool ,_ error : Error?)->Void)? ) {
        let context = LAContext()
        
        context.localizedFallbackTitle = "Use Passcode"
        var authError: NSError?
        let reasonString = "To access the secure data"
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics , localizedReason: reasonString)
            {[unowned self] success, evaluateError in
                completion?(success , evaluateError)
                self.delegate?.didFinishLocalAuthentication(isSuccess: success, error: evaluateError)
            }
        } else {
            completion?(false  , authError)
            self.delegate?.didFinishLocalAuthentication(isSuccess: false, error: authError)
        }
    }
    func evaluatePolicyFailErrorMessageForLA(errorCode: Int) -> String {
        var message = ""
        if #available(iOS 11.0, macOS 10.13, *) {
            switch errorCode {
            case LAError.biometryNotAvailable.rawValue:
                message = "Authentication could not start because the device does not support biometric authentication."
                
            case LAError.biometryLockout.rawValue:
                message = "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."

            case LAError.biometryNotEnrolled.rawValue:
                message = "Authentication could not start because the user has not enrolled in biometric authentication."

            default:
                message = "Did not find error code on LAError object"
            }
        } else {
            switch errorCode {
            case LAError.touchIDLockout.rawValue:
                message = "Too many failed attempts."
            case LAError.touchIDNotAvailable.rawValue:
                message = "TouchID is not available on the device"

            case LAError.touchIDNotEnrolled.rawValue:
                message = "TouchID is not enrolled on the device"
            default:
                message = "Did not find error code on LAError object"
            }
        }

        print("evaluatePolicyFailErrorMessageForLA:\(message)")
        return message;
    }

    func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {

        var message = ""

        switch errorCode {

        case LAError.authenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"

        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application"

        case LAError.invalidContext.rawValue:
            message = "The context is invalid"

        case LAError.notInteractive.rawValue:
            message = "Not interactive"

        case LAError.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"

        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"

        case LAError.userCancel.rawValue:
            message = "The user did cancel"

        case LAError.userFallback.rawValue:
            message = "The user chose to use the fallback"

        default:
            message = evaluatePolicyFailErrorMessageForLA(errorCode: errorCode)
        }
        print("evaluateAuthenticationPolicyMessageForLA:\(message)")
        return message
    }
}
