//
//  File.swift
//  
//
//  Created by Carlos Suarez on 10/30/20.
//

import Foundation
import Combine


public protocol WebServisable{
    var token:B {get}
    init(token:B)
    func get<T:Codable>(request:URLRequest, as type:T.Type) -> Future<T?,WebServideError>
}

public enum WebServideError:Error{
    case bad_request
    case not_autorized
    case internal_error
    case json_not_decoded
    case time_out
    case custom_error(B)
}


extension WebServisable {
    
    public func get<T:Codable>(request:URLRequest, as type:T.Type) -> Future<T?,WebServideError>{
       
        var futureResponse:Result<T?,WebServideError>!
        let semaphore:DispatchSemaphore = DispatchSemaphore(value: 0)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                futureResponse = Result.failure(.custom_error(error.localizedDescription))
            } else{
                guard let response = response as? HTTPURLResponse, let data = data
                    else {
                        futureResponse = Result.failure(WebServideError.bad_request)
                        return
                }
                switch response.statusCode {
                case 200:
                    let decoder = JSONDecoder()
                    do{
                        let jsonData = try decoder.decode(T.self, from: data)
                        futureResponse = Result.success(jsonData)
                     }
                    catch {
                        futureResponse = Result.failure(.json_not_decoded)
                    }
                    
                default:
                    futureResponse = Result.failure(.bad_request)
                }
            }
            semaphore.signal()
        }.resume()
        if semaphore.wait(timeout: .now() + 15 ) == .timedOut{
            futureResponse = Result.failure(.time_out)
        }
        // _ = semaphore.wait(wallTimeout: .distantFuture)
        return Future(){promise in promise(futureResponse)}
    }
    
}


public struct BBWebService:WebServisable{
    public var token:B
    public init(token: B) {
        self.token = token
    }
}
