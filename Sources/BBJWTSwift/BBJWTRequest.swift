//
//  File.swift
//  
//
//  Created by Carlos Suarez on 7/14/20.
//

import Foundation
import Combine

 public protocol BBJWTRequestable{
    var baseURL:B { get }
     var endPoint:B { get }
     var jwt:B {get}
    init(baseURL:B, endPoint:B, jwt:B)
    func getToken<T:Codable>(completado:@escaping (T?)->Void)
    func getFutureCollabToken<T:Codable>() -> Future<T?, CollabTokenError>
    
}



public enum CollabTokenError:Error{
    case bad_Request
    case unauthorized
    case forbidden
    case method_not_allowed
    case internal_error
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
            
            if error == nil{
                guard let response = response as? HTTPURLResponse, let data = data else{
                    let cerror = BbError(error: "500", message: "Network error, try again!")
                    let bbResponse = BbResponse(token: nil, error: cerror) as! T
                    completado(bbResponse)
                    return
                }
                
                switch response.statusCode{
                case 200:
                    let decoder = JSONDecoder()
                    do{
                        let jsonToken = try decoder.decode(BbToken.self, from: data)
                        let bbResponse = BbResponse(token: jsonToken, error: nil) as! T
                        completado(bbResponse)
                    } catch{
                        let cerror = BbError(error: "Error Json", message: "Data could not be converted to json")
                        let bbResponse = BbResponse(token: nil, error: cerror) as! T
                        completado(bbResponse)
                        
                    }
                case 400:
                    let cerror = BbError(error: "400: Bad Request", message: "The json was invalid.")
                    let bbResponse = BbResponse(token: nil, error: cerror) as! T
                    completado(bbResponse) 
                case 401:
                    let cerror = BbError(error: "401:Unauthorized", message: "Authentication credential was missing or incorrect")
                    let bbResponse = BbResponse(token: nil, error: cerror)as! T
                    completado(bbResponse)
                case 403:
                    let cerror = BbError(error: "403:Forbidden", message: "You don't have permission to access this resource.")
                    let bbResponse = BbResponse(token: nil, error: cerror)as! T
                    completado(bbResponse)
                case 404:
                    let cerror = BbError(error: "404: Resourse Not found", message: "You don't have read access to this resource or the resource does not exist")
                    let bbResponse = BbResponse(token: nil, error: cerror)as! T
                    completado(bbResponse)
                case 405:
                    let cerror = BbError(error: "405: Method not allowed", message: "The request is not valid")
                    let bbResponse = BbResponse(token: nil, error: cerror) as! T
                    completado(bbResponse)
                case 500:
                    let cerror = BbError(error: "500: Internal error", message: "Something seems to be broken on our side. Can you please contact Technical Support")
                    let bbResponse = BbResponse(token: nil, error: cerror) as! T
                    completado(bbResponse)
                default:
                    let cerror = BbError(error: "Error:", message: "Unkown error")
                    let bbResponse = BbResponse(token: nil, error: cerror) as! T
                    completado(bbResponse)
                }
                
            } else {
                let cerror = BbError(error: "500", message: error!.localizedDescription)
                let bbResponse = BbResponse(token: nil, error: cerror) as! T
                completado(bbResponse)
                return
            }
        }
        sesion.resume()
    }

    
    
    
    public  func getFutureCollabToken<T:Codable>() -> Future<T?, CollabTokenError>{
        
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
        
        var futureResponse:Result<T?,CollabTokenError>!
        let semaphore = DispatchSemaphore(value: 0)
        
        
       URLSession.shared.dataTask(with: request) { (data, response, error) in
        
            if error == nil{
                guard let response = response as? HTTPURLResponse, let data = data else {
                    futureResponse = Result.failure(CollabTokenError.internal_error)
                    return
                }
                
                switch response.statusCode {
                case 200:
                    let decoder = JSONDecoder()
                    do{
                        let jsonData = try decoder.decode(T.self, from: data)
                        futureResponse = Result.success(jsonData)
                    } catch{
                        futureResponse = Result.failure(CollabTokenError.internal_error)
                    }
                    
                default:
                    futureResponse = Result.failure(CollabTokenError.internal_error)
                }
                
                
            
            }else {
                futureResponse = Result.failure(CollabTokenError.internal_error)
            }
            semaphore.signal()
        }.resume()
        
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        return Future(){promise in promise(futureResponse)}
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
