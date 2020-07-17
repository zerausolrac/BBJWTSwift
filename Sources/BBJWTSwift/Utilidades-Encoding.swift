//
//  File.swift
//  
//
//  Created by Carlos Suarez on 7/13/20.
//

import Foundation
import Crypto

public typealias B = String
public typealias D = Data
public typealias I = Int

func base64Url(desde base64:B) -> B{
    let base64url = base64
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
        .replacingOccurrences(of: "=", with: "")
    return base64url
}



func signer(a:B, secret:B) -> B{
       //base64 header.payload
       let part1 = a.data(using: .utf8)!
       //key
       let keyData = secret.data(using: .utf8)!
       let key = SymmetricKey(data: keyData)
       //sign
       let signed = HMAC<SHA256>.authenticationCode(for: part1, using: key)
       let a = Data(signed)
       return base64Url(desde:a.base64EncodedString())
}



func convetidorB64URL<T:Codable>(_ a:T, t:Int, d:D?) -> B?{
    if let data = d, t == 0 {
        let decoder = JSONDecoder()
        do{
            let json = try decoder.decode(T.self, from: data)
            switch json{
             case is JWTHeader:
                var str:JWTHeader
                str = json as! JWTHeader
                return str.description
            case is JWTPayload:
                var str:JWTPayload
                 str = json as! JWTPayload
                return str.description
            default:
                 fatalError("Type no defined in JWTBB type")
            }
        } catch {
            fatalError("Decode Failed")
        }
        
    } else if t == 1{
        let encoder = JSONEncoder()
        encoder.dataEncodingStrategy = .base64
        do{
            let j = try encoder.encode(a.self)
            return j.base64EncodedString()
        }catch {
            fatalError("Encode Failed")
        }
    } else {
        return nil
    }
     
}

func tiempoExp() -> I{
    return Int(Date().timeIntervalSince1970 + 5*60)
}
