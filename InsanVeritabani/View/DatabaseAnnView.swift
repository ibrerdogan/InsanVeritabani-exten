//
//  DatabaseAnnView.swift
//  InsanVeritabani
//
//  Created by İbrahim Erdogan on 25.07.2022.
//

import SwiftUI

struct DatabaseAnnView: View {
    var Db : AnnouncementModel
    var body: some View {
        VStack {
            VStack(alignment: .leading){
                Text(Db.name.lowercased())
                    .font(.title3)
                    .padding(.vertical)
                Text(Db.detail.lowercased()).font(.body)
                    .padding(.vertical)
                HStack
                {
                    Text(Db.createdUserMail).font(.caption)
                    Spacer()
                    Text("\(Db.creationDate.getFormattedDate(format: "yyyy-MM-dd"))").font(.caption)
                   
                }
               
                
            }
            .padding()
            .frame(maxWidth:.infinity)
            .background(.green)
            .cornerRadius(20)
            .padding(.horizontal)
            .shadow(color: .black, radius: 10, x: 2, y: 1)
        }
        
        
       

    }
}


extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}
