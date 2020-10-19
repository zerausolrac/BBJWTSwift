import Foundation
import Crypto


//Bb Collab

public struct JWTHeader:BbHeader, Encodable64, CustomStringConvertible, Codable {
    public var description: B{ return "alg: \(alg) typ:\(typ)"}
    public var alg: B
    public var typ: B
    
    public init(alg:B, typ:B) {
        self.alg = alg
        self.typ = typ
    }
    
    public func encode64Url() -> B {
      return convetidorB64URL(self)
    }
}


public struct JWTPayload:BbPayload, Encodable64,CustomStringConvertible,Codable{
    public var description: B{ return "iss:\(iss) sub:\(sub) exp:\(String(exp))"}
    public var iss: B
    public var sub: B
    public var exp: I = tiempoExp()
    
    public  init(iss: B, sub: B) {
        self.iss = iss
        self.sub = sub
        
    }
    
      public func encode64Url() -> B {
        return convetidorB64URL(self)
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



public struct JwtAssertion:BbAssertion{
    public var key: B
    public var secret: B
    
    public init(key:B,secret:B){
        self.key = key
        self.secret = secret
    }
    public func buildJot() -> B {
        let header = JWTHeader(alg: "HS256", typ: "JWT").encode64Url()
        let payload = JWTPayload(iss: self.key, sub: self.key).encode64Url()
        let signature = JWTSignature(header: header, payload: payload).sign(secret: self.secret)
        return header + "." + payload + "." + signature
    }
}

//Bb Learn

public struct TokenLearnAssertion:BbLearnAssertion{
    public var key:B
    public var secret:B
    
    public init(key:B,secret:B){
        self.key = key
        self.secret = secret
    }
    
    public func buildCredential()->B{
        let payload = key + ":" + secret
        let encodedPayload = payload.data(using: .utf8)!.base64EncodedString()
        return encodedPayload
    }

}

//Generic Types

public struct BbToken:Codable{
   public var access_token: B
    public var expires_in:I
}


public struct BbError:Codable{
    public var error:B
    public var message: B
    init(error:B,message:B){
        self.error = error
        self.message = message
    }
    enum Llaves:String, CodingKey{
        case error
        case message
    }
    public func encode(to encoder: Encoder) throws{
        var container =  encoder.container(keyedBy: Llaves.self)
        try container.encode(error, forKey: Llaves.error)
        try container.encode(message, forKey: Llaves.message)
    }
    
}

public struct BbResponse:Codable{
    public var token:BbToken?
    public var error:BbError?
}


