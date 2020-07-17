//
//  File.swift
//  
//
//  Created by Carlos Suarez on 7/14/20.
//

import Foundation

 public protocol BBJWTRequestable{
    var baseURL:B { get }
     var endPoint:B { get }
     var jwt:B {get}
    init(baseURL:B, endPoint:B, jwt:B)
    func getToken<T:Codable>(completado:@escaping (T?)->Void)
}





extension BBJWTRequestable {
    
    public func getToken<T:Codable>(completado:@escaping (T?)->Void) {
        
        var requestURL = URLComponents()
        requestURL.scheme = "https"
        requestURL.host = self.baseURL
        requestURL.path = self.endPoint
        
        let componentes:[URLQueryItem] = [URLQueryItem(name: "grant_type", value: "urn:ietf:params:oauth:grant-type:jwt-bearer"),
            URLQueryItem(name: "assertion", value: self.jwt)]
        
        
        requestURL.queryItems = componentes
        let authURL = requestURL.url!
        var request = URLRequest(url: authURL)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let sesion = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data else {
                completado(nil)
                fatalError("JWT Request token Data Error")
            }
             let decoder = JSONDecoder()
            do{
                let json = try decoder.decode(T.self, from: data)
                completado(json)
                
            } catch{
                completado(nil)
                fatalError("JWT Request token decode json error")
            }
        }
        sesion.resume()
        
    }
    
}


public struct BBJWTRequest:BBJWTRequestable{
    public var baseURL: B
    public var endPoint: B
    public var jwt: B
    
    public init(baseURL:B, endPoint:B,jwt: B) {
        self.baseURL = baseURL
        self.endPoint = endPoint
        self.jwt = jwt
    }
}
