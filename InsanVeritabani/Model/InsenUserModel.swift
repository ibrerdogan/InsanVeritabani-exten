//
//  UserModel.swift
//  InsanVeritabani
//
//  Created by İbrahim Erdogan on 25.07.2022.
//

import Foundation

struct UserModel : Identifiable, Codable
{
    var id = UUID().uuidString
    var email : String
    var username : String
    var profileImage : String
    var profileType : String
    var lastLoginData : Date
    var createdDate : Date
    var profileDetail : String
    var eksiNick : String
    
    
    
}
