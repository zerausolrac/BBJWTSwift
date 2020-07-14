import Foundation
import Crypto




public struct JWTHeader:BbHeader, Encodable64 {
    public var alg: String
    public var typ: String
    
    public init(alg:String, typ:String) {
        self.alg = alg
        self.typ = typ
    }
    
    public func encode64Url() -> String {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .useDefaultKeys
        do{
            let json = try encoder.encode(self)
            let encode64 = json.base64EncodedData()
            return encode64.base64EncodedString()
        }catch{
            fatalError("Error Encode JSON - header")
        }
    }
}


public struct JWTPayload:BbPayload, Encodable64{
    
    public var iss: String
    public var sub: String
    public var exp: String
    
    public  init(iss: String, sub: String, exp: String) {
        self.iss = iss
        self.sub = sub
        self.exp = exp
    }
    
    
    public func encode64Url() -> String {
        let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .useDefaultKeys
            do{
                let json = try encoder.encode(self)
                let encode64 = json.base64EncodedData()
                return encode64.base64EncodedString()
            }catch{
                fatalError("Error Encode JSON - Payload")
            }
        }
    }



public struct JWTSignature:BbSignature{
    
    public var payload: String
    public var header: String
    
    public init(){}
    
    public func sign(data: Data, secret: String) -> String {
       let preSign  = header + "." + payload
        let data = preSign.data(using: .utf8)!
       return signer(data: data, secret: secret)
    }
}



