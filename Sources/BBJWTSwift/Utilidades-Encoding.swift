//
//  File.swift
//  
//
//  Created by Carlos Suarez on 7/13/20.
//

import Foundation
import Crypto


func base64Url(desde base64:String) -> String{
    let base64url = base64
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
        .replacingOccurrences(of: "=", with: "")
    return base64url
}



func signer(data:Data, secret:String) -> String{
   let keyData = secret.data(using: .utf8)!
   let key = SymmetricKey(data: keyData)
   let signedString =  HMAC<HS256>.authenticationCode(for: data, using: key)
   let signed = Data(signedString).base64EncodedData()
    return  base64Url(desde: signed.base64EncodedString())
}


