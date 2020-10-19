//
//  BBJWT.swift
//  
//
//  Created by Carlos Suarez on 7/13/20.
//

import Foundation



public protocol BbHeader:Encodable{
     var alg:B { get }
     var typ:B { get }
}


public protocol BbPayload:Encodable{
    var iss:B { get }
    var sub:B { get }
    var exp:I{ get }
}


public protocol Encodable64{
    func encode64Url() -> B
}


public protocol BbSignature{
    var header:B {get}
    var payload:B {get}
    func sign(secret:B) -> B
}


public protocol BbAssertion{
    var key:B {get}
    var secret:B {get}
    func buildJot() -> B
}


public protocol BbLearnAssertion{
    var key:B {get}
    var secret:B{get}
    func buildCredential()->B
}







