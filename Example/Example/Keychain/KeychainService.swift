
import UIKit
enum ValueTypeOfKeychain  : Int {
   case secret = 0
    var keyDescription : String {
        switch self {
        case .secret :
            return "secret"
        }
    }
    var secClassType : String {
        switch self {
        case .secret :
          return  KeychainService.secClassGenericPassword()
        }
    }
}

public class KeychainService: NSObject {
    enum KeychainError: Error {
        case noPassword
        case unexpectedPasswordData
        case unexpectedItemData
        case unhandledError(status: OSStatus)
    }
    
//    public let kSecClassInternetPassword: CFString
//    @available(iOS 2.0, *)
//    public let kSecClassGenericPassword: CFString
//
//    @available(iOS 2.0, *)
//    public let kSecClassCertificate: CFString
//
//    @available(iOS 2.0, *)
//    public let kSecClassKey: CFString
//
//    @available(iOS 2.0, *)
//    public let kSecClassIdentity: CFString
    
    class func secClassGenericPassword() -> String {
        return NSString(format: kSecClassGenericPassword) as String
    }
    class func secClassKey() -> String {
        return NSString(format: kSecClassKey) as String
    }
    class func secClass() -> String {
        return NSString(format: kSecClass) as String
    }
    class func secAttrService() -> String {
        return NSString(format: kSecAttrService) as String
    }
    class func secAttrAccount() -> String {
        return NSString(format: kSecAttrAccount) as String
    }
    class func secValueData() -> String {
        return NSString(format: kSecValueData) as String
    }
    class func secReturnData() -> String {
        return NSString(format: kSecReturnData) as String
    }
    class func saveKey( type :  ValueTypeOfKeychain, credential: String, account: String = "Auth", service: String = "keyChainDefaultService")  {
        let secret: NSData = credential.data(using: String.Encoding.utf8, allowLossyConversion: false)! as NSData
        let objects: Array = [type.secClassType , service, account, secret] as [Any]
        let keys = [secClass() , secAttrService(), secAttrAccount(), secValueData()] as [NSCopying]
        let queryAttributes = NSDictionary(objects: objects, forKeys: keys)
        SecItemDelete(queryAttributes as CFDictionary)
        SecItemAdd(queryAttributes as CFDictionary, nil)
    }
    class func retrieveKey(type :  ValueTypeOfKeychain , account: String = "Auth", service: String = "keyChainDefaultService") -> String? {
        let objects: Array = [type.secClassType , service, account, true] as [Any]
        let keys = [secClass() , secAttrService(), secAttrAccount(), secReturnData()] as [NSCopying]
        let queryAttributes = NSDictionary(objects: objects, forKeys: keys)
        var dataTypeRef : AnyObject?
        SecItemCopyMatching(queryAttributes, &dataTypeRef)
        if let data = dataTypeRef as? Data
            ,let credentialData = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue){
            return (credentialData as String)
        }
        return nil
    }
    class func removeKey(type :  ValueTypeOfKeychain  , credential:String,account: String = "AuthToken", service: String = "keyChainDefaultService") -> Error? {
        //let secret: NSData = credential.data(using: String.Encoding.utf8, allowLossyConversion: false)! as NSData
        let objects: Array =  [type.secClassType , service, account] as [Any]
        let keys: Array = [secClass() , secAttrService(), secAttrAccount()] as [NSCopying]
        let query = NSDictionary(objects: objects, forKeys: keys)
        let status = SecItemDelete(query as CFDictionary)
        guard status == noErr || status == errSecItemNotFound
            else { return KeychainError.unhandledError(status: status) }
        return nil
    }
}

