//
//  File.swift
//  
//
//  Created by Carlos Suarez on 10/19/20.
//

import Foundation
import Combine


public protocol BbLearnRequestable{
    var baseURL:B {get set}
    var endPoint:B {get}
    var key:B {get}
    var secret:B {get}
    init(baseURL:B, endPoint:B, key:B, secret:B)
    func getToken<T:Codable>(completado:@escaping (T?)->Void)
    func getTokenFuture() -> Future<B?,TokenError>
}


public enum TokenError:Error{
    case badRequest
    case notAuthorized
    case responseError(String)
    
}


extension BbLearnRequestable{

    private func finalEndPoint(endPoint:B) -> B{
        if endPoint.hasPrefix("/"){
            return endPoint
        }
        return "/" + endPoint
    }
    
    
    
    public func getToken<T:Codable>(completado:@escaping (T?)->Void) {
        var urlComponent = URLComponents()
        urlComponent.scheme = "https"
        urlComponent.host = baseURL
        urlComponent.path = endPoint
        let payload = TokenLearnAssertion(key: key, secret: secret).buildCredential()
        
        var request = URLRequest(url: urlComponent.url!)
        request.httpMethod = "POST"
        request.httpBody = "grant_type=client_credentials".data(using: .utf8)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic " + payload, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if error == nil{
                guard let response = response as? HTTPURLResponse else{
                  return
                }
                
                switch response.statusCode{
                    
                case 200:
                   let decoder = JSONDecoder()
                    do {
                        let jsonData = try decoder.decode(BbToken.self, from: data!)
                        let bbResponse = BbResponse(token: jsonData, error: nil) as! T
                        completado(bbResponse)
                        
                    } catch {
                        
                    }
                
                case 400:
                    let cerror = BbError(error: "Invalid", message: "Invalid access token request")
                    let bbResponse = BbResponse(token: nil, error: cerror) as! T
                    completado(bbResponse)
                case 401:
                    let cerror = BbError(error: "Invalid", message: "Invalid client credentials, or no access granted to this Learn server.")
                    let bbResponse = BbResponse(token: nil, error: cerror) as! T
                    completado(bbResponse)
                    
                default:
                    let cerror = BbError(error: "Error:", message: "Unkown error")
                    let bbResponse = BbResponse(token: nil, error: cerror) as! T
                    completado(bbResponse)
                
                
                }
                
             
                
            } else {
                
            }
            
            
        }.resume()
        
        
    }
    
    
    
    
    public func getTokenFuture() -> Future<B?,TokenError>{
        
        var urlComponent = URLComponents()
        urlComponent.scheme = "https"
        urlComponent.host = baseURL
        urlComponent.path = finalEndPoint(endPoint: endPoint)
        
        
        let payload = TokenLearnAssertion(key: key, secret: secret).buildCredential()
        
        var request = URLRequest(url: urlComponent.url!)
        request.httpMethod = "POST"
        request.httpBody = "grant_type=client_credentials".data(using: .utf8)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("Basic " + payload, forHTTPHeaderField: "Authorization")
        
        var futureResponse:Result<B?,TokenError>!
        let semaphore = DispatchSemaphore(value: 0)
        
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            
            if error != nil {
                futureResponse = Result.failure(TokenError.badRequest)
            }
            guard let _ = response, let data = data else {
                futureResponse = Result.failure(TokenError.badRequest)
                return
            }
            let decoder = JSONDecoder()
            do{
                let jsonData = try decoder.decode(BbToken.self, from: data)
                
                futureResponse = Result.success(jsonData.access_token)
            } catch {
                futureResponse = Result.failure(TokenError.badRequest)
            }
            semaphore.signal()
        }.resume()
        
        _ = semaphore.wait(wallTimeout: .distantFuture)
        return Future(){promise in promise(futureResponse)}
        
    }
}



public struct  BbLearnRequest:BbLearnRequestable{
    public  var baseURL: B
    public var endPoint: B
    public var key: B
    public var secret: B
    
    public init(baseURL: B, endPoint: B, key: B, secret: B) {
        self.baseURL = baseURL
        self.endPoint = endPoint
        self.key = key
        self.secret = secret
    }
    
    
    
    
    
}
