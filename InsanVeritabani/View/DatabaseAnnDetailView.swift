//
//  DatabaseAnnDetailView.swift
//  InsanVeritabani
//
//  Created by İbrahim Erdogan on 26.07.2022.
//

import SwiftUI

struct DatabaseAnnDetailView: View {
    var databaseAnn : AnnouncementModel
    var UserId: String
    let callback : (String)->()
    @State var applied : Bool = false
    
    init(callback: @escaping(String)->(),databaseAnn : AnnouncementModel, UserId : String)
    {
        self.callback = callback
        self.databaseAnn = databaseAnn
        self.UserId = UserId

    }
    var body: some View {
        
        
        ZStack{
            Color.black
                .ignoresSafeArea(edges: .top)
            
            VStack
            {
                VStack(alignment:.leading){
                    Text(databaseAnn.name).font(.title).foregroundColor(.white)
                        .padding()
                        .lineLimit(3)
                    Text(databaseAnn.detail).font(.title3).foregroundColor(.white)
                        .padding()
                        .lineLimit(10)
                    
                    Group
                    {

                        VStack(spacing:15){
                            HStack{
                                Text("\(databaseAnn.eventLocation == "" ? "belli değil" :databaseAnn.eventLocation )")
                                Spacer()
                                Text("\(databaseAnn.eventDate.getFormattedDate(format: "yyyy-MM-dd"))")
                            }
                            .padding(.horizontal)
                            Divider()
                            HStack{
                              VStack
                                {
                                    Button {
                                        if applied != true
                                        {
                                            self.callback(self.databaseAnn.id)
                                            applied.toggle()
                                        }
                                       
                                        
                                    } label: {
                                        Image(systemName: applied ? "checkmark.circle.fill" : "plus.circle")
                                            .font(.system(size: 35))
                                    }

                                    Text(applied ? "seni de yazdım" : "beni de yaz..").font(.footnote)
                                }
                                Spacer()
                                VStack(alignment:.trailing)
                                {
                                    //Text("\(databaseAnn.displayedName)")
                                    Text("\(databaseAnn.creationDate.getFormattedDate(format: "yyyy-MM-dd"))")
                                    
                                }
                                Image("default-pp") .resizable()
                                    .frame(width: 50, height: 50, alignment: .center)
                                    .clipShape(Circle())
        
                                
                            }
                            .padding(.horizontal)
                        }.foregroundColor(.white)
                    }
                }.frame(maxWidth:.infinity)
                    .padding(.vertical)
                    .background(.green)
                   
                   
                
            }
            
            
        }
        .onAppear {
            DispatchQueue.main.async {
                if self.databaseAnn.evetRequests.contains(where: { $0 == self.UserId.lowercased() }) {
                    applied = true
                }
                else
                {
                    applied = false
                }
                
                
            }
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

//struct DatabaseAnnDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DatabaseAnnDetailView(databaseAnn: DatabaseModel(id: UUID().uuidString, name: "Db name", //createdUserMail: "erdogan", creationDate: Date.now, detail: "ilan detayları", //eventDate: Date.now, eventLocation: "ankara", databaseType: .DertlesecekInsan), //evetRequests: [])
//    }
//}
