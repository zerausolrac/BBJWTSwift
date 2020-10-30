//
//  File.swift
//  
//
//  Created by Carlos Suarez on 7/14/20.
//

import Foundation
import Combine

 public protocol BBCollabRequestable{
     var baseURL:B { get }
     var endPoint:B { get }
     var jwt:B {get}
    init(baseURL:B, endPoint:B, jwt:B)
    func getFutureCollabToken<T:Codable>(as type: T.Type) -> Future<T?, CollabTokenError>
    
}



public enum CollabTokenError:Error{
    case bad_Request
    case unauthorized
    case forbidden
    case method_not_allowed
    case internal_error
    case empty_data
    case json_not_decoded
}


extension BBCollabRequestable {
        
    public  func getFutureCollabToken<T:Codable>(as type: T.Type) -> Future<T?, CollabTokenError>{
        
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
                    futureResponse = Result.failure(CollabTokenError.empty_data)
                    return
                }
                
                switch response.statusCode {
                case 200:
                    let decoder = JSONDecoder()
                    do{
                        let jsonData = try decoder.decode(T.self, from: data)
                        futureResponse = Result.success(jsonData)
                    } catch{
                        futureResponse = Result.failure(CollabTokenError.json_not_decoded)
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
    
    
    
    
    
public struct BBCollabRequest:BBCollabRequestable{
    public var baseURL: B
    public var endPoint: B
    public var jwt: B
    
    public init(baseURL:B, endPoint:B,jwt: B) {
        self.baseURL = baseURL
        self.endPoint = endPoint
        self.jwt = jwt
    }
}
