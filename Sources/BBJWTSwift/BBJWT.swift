//
//  BBJWT.swift
//  
//
//  Created by Carlos Suarez on 7/13/20.
//

import Foundation

public protocol BbHeader:Encodable{
     var alg:String { get }
     var typ:String { get }
    
}

public protocol BbPayload:Encodable{
    var iss:String { get }
    var sub:String { get }
    var exp:String { get }
}


public protocol Encodable64{
    func encode64Url() -> String
}


public protocol BbSignature{
    var header:String {get}
    var payload:String {get}
    func sign(data:Data, secret:String) -> String
}
