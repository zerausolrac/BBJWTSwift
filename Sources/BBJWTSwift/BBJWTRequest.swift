//
//  File.swift
//  
//
//  Created by Carlos Suarez on 7/14/20.
//

import Foundation

 protocol BBJWTRequestable{
    var baseURL:String? { get }
    var endPoint:String? { get }
    var jwt:String {get}
    init(baseURL:String?, endPoint:String?, jwt:String)
    
    func getToken<T:Codable>(completado:@escaping (T?)->Void)
}





extension BBJWTRequestable {
    
    public func getToken<T:Codable>(completado:@escaping (T?)->Void) {
        
        var requestURL = URLComponents()
        requestURL.scheme = "https"
        requestURL.host = self.baseURL!
        requestURL.path = self.endPoint!
        
        let componentes:[URLQueryItem] = [URLQueryItem(name: "grant_typ", value: "urn:ietf:params:oauth:grant-type:jwt-bearer"),
            URLQueryItem(name: "assertion", value: self.jwt)]
        
        requestURL.queryItems = componentes
        let authURL = requestURL.url!
        var request = URLRequest(url: authURL)
        request.httpMethod = "POST"
        
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
    
    var baseURL: String?
    var endPoint: String?
    var jwt: String
    
    public init(baseURL:String? = nil, endPoint:String? = nil,jwt: String) {
        self.jwt = jwt
    }
}
