//
//  UserComment.swift
//  InsanVeritabani
//
//  Created by İbrahim Erdogan on 19.08.2022.
//

import Foundation

struct UserCommentModel : Identifiable , Codable
{
    var id = UUID().uuidString
    var userEmail : String
    var writerNick : String
    var comment : String
    var commentDate : Date
}
