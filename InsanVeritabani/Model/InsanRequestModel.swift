//
//  InsanRequestModel.swift
//  InsanVeritabani
//
//  Created by İbrahim Erdogan on 26.07.2022.
//

import Foundation


struct requestModel : Identifiable , Codable
{
    var id = UUID().uuidString
    var appliedUser : String
    var requestedAnnouncement : String
    var status : Int
    var requestDate : Date
    var displayedName : String
    var announceCreaterEmail : String
    
}
