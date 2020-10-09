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
            
            guard let error = error, let response = response as? HTTPURLResponse else{
                let cerror = JwtError(error: "500", message: "Network error, try again!")
                completado((cerror as! T))
                return
            }
            
            switch response.statusCode{
            case 200:
                guard let data = data else {
                    completado(nil)
                    let cerror = JwtError(error: "No data", message: "Any data was returned")
                    completado((cerror as! T))
                    return 
                }
                 let decoder = JSONDecoder()
                do{
                    let json = try decoder.decode(T.self, from: data)
                    completado(json)
                    
                } catch{
                    let cerror = JwtError(error: "Error Json", message: "Data couldn't conver to json")
                    completado((cerror as! T))
                }
            case 400:
                let cerror = JwtError(error: "400: Bad Request", message: "The json was invalid.")
                completado((cerror as! T))
            case 401:
                let cerror = JwtError(error: "401:Unauthorized", message: "Authentication credential was missing or incorrect")
                completado((cerror as! T))
            case 403:
                let cerror = JwtError(error: "403:Forbidden", message: "You don't have permission to access this resource.")
                completado((cerror as! T))
            case 404:
                let cerror = JwtError(error: "404: Resourse Not found", message: "You don't have read access to this resource or the resource does not exist")
                completado((cerror as! T))
            case 405:
                let cerror = JwtError(error: "405: Method not alloweb", message: "The request is not valid")
                completado((cerror as! T))
            case 500:
                let cerror = JwtError(error: "500: Internal error", message: "Something seems to be broken on our side. Can you please contact Technical Support")
                completado((cerror as! T))
            default:
                let cerror = JwtError(error: "Error:", message: error.localizedDescription)
                completado((cerror as! T))
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
