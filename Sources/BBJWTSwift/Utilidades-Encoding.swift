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



func convetidorB64URL<T:Codable>(_ a:T) -> B{
    
        let encoder = JSONEncoder()
        encoder.dataEncodingStrategy = .base64
        do{
            let j = try encoder.encode(a.self)
            return  base64Url(desde:j.base64EncodedString())
        }catch {
            fatalError("Encode Failed")
        }
}
     


func tiempoExp() -> I{
    return Int(Date().timeIntervalSince1970 + 5*60)
}

//Route builer

public enum RutaType{
    case path([B])
    case query([B:B])
}

public struct Router{
    var option:RutaType
    var method:B
    var token:B
    var endPoint:B
    var host:B
}

public func routerBuilder(_ route:Router) -> URL{
    
    switch route.option {
        //   /endPoint/{courseId}/data
    case .path(let array):
        let domainPath = "https://" + route.host + route.endPoint
        var finalRoute = URL(string: domainPath)
        array.forEach { path in
            finalRoute?.appendPathComponent(path)
        }
        return finalRoute!
        
        // /endPoint/extCourseId=coding0001&startTime=20203
    case .query(let dic):
        var finalRoute = URLComponents()
        var queryItems:[URLQueryItem] = []
        finalRoute.scheme = "https"
        finalRoute.path = route.endPoint
        finalRoute.host = route.host
        queryItems = dic.map { (key: B, value: B) -> URLQueryItem in
            return URLQueryItem(name: key, value: value)
        }
        finalRoute.queryItems = queryItems
        return finalRoute.url!
    }
}


public func RequestBuilder(_ route:Router, path:URL) -> URLRequest{
    var request:URLRequest = URLRequest(url: path)
    request.httpMethod = route.method
    request.addValue("Bearer " + route.token, forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    return request
}
