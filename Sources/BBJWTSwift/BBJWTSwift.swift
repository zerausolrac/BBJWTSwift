import Foundation
import Crypto




public struct JWTHeader:BbHeader, Encodable64, CustomStringConvertible {
    public var description: B{ return "alg: \(alg) typ:\(typ)"}
    public var alg: B
    public var typ: B
    
    public init(alg:B, typ:B) {
        self.alg = alg
        self.typ = typ
    }
    
    public func encode64Url() -> B {
        let encoder = JSONEncoder()
        encoder.dataEncodingStrategy = .base64
        do{
            let json = try encoder.encode(self)
            let encode64 = json.base64EncodedString()
            return base64Url(desde: encode64)
        }catch{
            fatalError("Error Encode JSON - header")
        }
    }
}


public struct JWTPayload:BbPayload, Encodable64,CustomStringConvertible{
    public var description: B{ return "iss:\(iss) sub:\(sub) exp:\(String(exp))"}
    public var iss: B
    public var sub: B
    public var exp: I = tiempoExp()
    
    public  init(iss: B, sub: B) {
        self.iss = iss
        self.sub = sub
        
    }
    
    public func encode64Url() -> B {
        let encoder = JSONEncoder()
            encoder.dataEncodingStrategy = .base64
            do{
                let json = try encoder.encode(self)
                let encode64 = json.base64EncodedString()
                return base64Url(desde: encode64)
            }catch{
                fatalError("Error Encode JSON - Payload")
            }
        }
    }



public struct JWTSignature:BbSignature{
    public var payload: B
    public var header: B
    
    public init(header: B, payload: B) {
        self.payload = payload
        self.header = header
    }
    
    public func sign(secret: B) -> B {
       let preSign  = header + "." + payload
       return signer(a: preSign, secret: secret)
    }
}



