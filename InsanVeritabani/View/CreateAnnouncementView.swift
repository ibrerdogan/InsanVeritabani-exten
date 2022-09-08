//
//  CreateAnnouncementView.swift
//  InsanVeritabani
//
//  Created by İbrahim Erdogan on 28.07.2022.
//

import SwiftUI

struct CreateAnnouncementView: View {
    @State var name : String = ""
    @State var detail : String = ""
    @State var eventLocation : String = ""
    @State var eventDate : Date = Date.now
    @State var DatabaseName : DatabaseTypes = .DertlesecekInsan
    @State var CreatErrorText : String = ""
    @State var CreatErrorDisplay : Bool = false
    @ObservedObject var manager : FirebaseHelper
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        ZStack(alignment:.leading)
        {
            Color.green
                .ignoresSafeArea()
            
            VStack(alignment:.leading,spacing: 10)
            {
                Group
                {
                    HStack{
                        Text("kime bakmıştın")
                    }
                    HStack {
                        Menu {
                            Picker(selection: $DatabaseName) {
                                ForEach(DatabaseTypes.allCases) { value in
                                    Text(value.rawValue)
                                        .tag(value)
                                        .font(.title)
                                }
                            } label: {}
                        } label: {
                            HStack(alignment:.center){
                                Text(DatabaseName.rawValue.lowercased())
                                    .font(.title2)
                                    .foregroundColor(.white)
                            }.frame(maxWidth:.infinity)
                    }
                    }.padding()
                    
                    Text("kısaca anlat bakalım").foregroundColor(.black)
                    TextField("", text: $name)
                        .padding()
                        .background()
                    
                    Text("az biraz detay ver").foregroundColor(.black)
                    TextEditor(text: $detail)
                        .padding()
                        .background()
                        .lineLimit(10)
                        .frame(maxHeight:200)
                    
                    HStack
                    {
                        VStack(alignment:.leading)
                        {
                            Text("yer/mekan").foregroundColor(.black)
                            TextField("", text: $eventLocation)
                                .padding()
                                .background()
    

                        }
                        Spacer()
                        VStack(alignment:.trailing)
                        {
                            
                            DatePicker("", selection: $eventDate, displayedComponents: .date)
                                .datePickerStyle(.automatic)
                               

                        }
                    }

                }
                
                Button {
                    if (eventLocation != "" && detail != "" && name != "")
                    {
                        manager.createNewAnnouncement(announce: AnnouncementModel(id: UUID().uuidString,
                                                                                         name: name,
                                                                                         createdUserMail: manager.user.email, creationDate: Date.now,
                                                                                          detail: detail,
                                                                                         eventDate: eventDate,
                                                                                         eventLocation: eventLocation,
                                                                                         databaseType: DatabaseName,
                                                                                         evetRequests: [], requestCount : 0,
                                                                                         isActive : true, displayedName: manager.user.username)) { result, error in
                            if let error = error {
                                CreatErrorText = error.localizedDescription
                                CreatErrorDisplay = true
                            }
                            else
                            {
                                if result {
                                    presentationMode.wrappedValue.dismiss()
                                }
                                else
                                {
                                    CreatErrorText = "bir şeyler oldu dur bakalım"
                                    CreatErrorDisplay = true
                                }
                            }
                        }
                    }
                    else
                    {
                        CreatErrorText = "boş bilgi bırakmazsak sevinirim"
                        CreatErrorDisplay = true
                    }
                    
                } label: {
                    Text("kaydet")
                        .padding()
                        .frame(maxWidth:.infinity)
                        .background(Color.black)
                        .cornerRadius(20)
                        .foregroundColor(.white)
                        .padding(.vertical)
                }

              
            }
            .padding()
            
        }
        .alert(CreatErrorText, isPresented: $CreatErrorDisplay) {
            Button(role: .destructive) {
                
            } label: {
                Text("anladım")
            }

        }
       
    }
}

struct CreateAnnouncementView_Previews: PreviewProvider {
    static var previews: some View {
        CreateAnnouncementView(manager: FirebaseHelper())
    }
}
