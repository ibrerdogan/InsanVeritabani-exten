//
//  UserInformation.swift
//  InsanVeritabani
//
//  Created by İbrahim Erdogan on 19.08.2022.
//

import Foundation

struct UserInfoModel : Identifiable , Codable
{
    var id = UUID().uuidString
    var userMail : String
    var userNick : String
    var openedAnnouncement : Int
    var appliedAnnouncement : Int
    var deniedAnnouncement : Int
    var acceptedAnnouncement : Int
    
    
}
