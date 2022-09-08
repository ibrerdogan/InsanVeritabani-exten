//
//  DatabaseAnnouncementView.swift
//  InsanVeritabani
//
//  Created by İbrahim Erdogan on 1.08.2022.
//

import SwiftUI

struct DatabaseAnnouncementView: View {
    var announcementId : AnnouncementModel
    @State var requestList : [requestModel] = []
    @ObservedObject var manager : FirebaseHelper
    @Environment(\.presentationMode) var presentationMode
   // var announcement : AnnouncementModel
    @State var changeDetailView : Bool = false
    @State var detailedUserEmail : String = ""
    @State var detailError : Bool = false
    @State var detailErrorText : String = ""
    var body: some View {
      ZStack
        {
            Color.black
                .ignoresSafeArea()
            VStack(alignment:.leading)
            {   HStack
                {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title)
                            .padding(.horizontal)
                            .foregroundColor(.white)
                            Spacer()
                    }

                }
                switch(announcementId.databaseType)
                {
                case .BiraIcmelikInsan:
                    Text("bira içmelik insan").font(.title).bold().padding()
                        .foregroundColor(.white)
                case .DertlesecekInsan:
                    Text("dertleşecek insan").font(.title).bold().padding()
                        .foregroundColor(.white)
                case .DisariCikmalikInsan:
                    Text("dışarı çıkmalık insan").font(.title).bold().padding()
                        .foregroundColor(.white)
                case .EvlenmelikInsan:
                    Text("evlenmelik insan").font(.title).bold().padding()
                        .foregroundColor(.white)
                case .HediyelesmelikInsan:
                    Text("hediyeleşmelik insan").font(.title).bold().padding()
                        .foregroundColor(.white)
                case .TatileGitmelikInsan:
                    Text("tatile gitmelik insan").font(.title).bold().padding()
                        .foregroundColor(.white)
                case .KampYapmalikInsan:
                    Text("kamp yapmalık insan").font(.title).bold().padding()
                        .foregroundColor(.white)
                case .SevismelikInsan:
                    Text("sevişmelik insan").font(.title).bold().padding()
                        .foregroundColor(.white)
                case .OyunOynamalikInsan:
                    Text("oyun oynamalık insan").font(.title).bold().padding()
                        .foregroundColor(.white)
                case .DersCalismalikInsan:
                    Text("ders çalışmalık insan").font(.title).bold().padding()
                        .foregroundColor(.white)
                }
                
                Text(announcementId.name).font(.title2).bold().padding()
                    .foregroundColor(.white)
                Text(announcementId.detail)
                    .font(.title2)
                    .frame(maxWidth:.infinity)
                    .foregroundColor(.black)
                    .lineLimit(10)
                    .background()
                    .padding()
                
                HStack
                {
                    Text(announcementId.eventDate.getFormattedDate(format: "yyyy-MM-dd"))
                    Spacer()
                    Text(announcementId.eventLocation)
                }.padding(.horizontal)
                
                if announcementId.createdUserMail == manager.user.email {
                    Button {
                        manager.disableAnnouncement(announce: announcementId )
                        presentationMode.wrappedValue.dismiss()
                        
                    } label: {
                        Text("artık duyurma bunu")
                            .padding()
                            .frame(maxWidth:.infinity)
                            .background(.green)
                            .cornerRadius(20)
                            .padding()
                            .foregroundColor(.black)
                }
                } else {
                    EmptyView()
                }

                
                if announcementId.createdUserMail == manager.user.email {
                    ScrollView{
                        ForEach(requestList){ req in
                            HStack
                            {
                                NavigationLink {
                                    DisplayedUserView(manager: manager,displayedUserMail: req.appliedUser)
                                        .navigationBarHidden(true)
                                } label: {
                                    Text(req.displayedName)
                                        .foregroundColor(.white)
                                      
                                }

                                
                                Spacer()
                                Button {
                                    manager.acceptOrCancelRequest(announcementId: announcementId.id, appliedUserId: req.appliedUser, okOrNot: true) { complated, error in
                                        if let error = error {
                                            detailError.toggle()
                                            detailErrorText = error.localizedDescription
                                        }
                                        else if complated
                                        {
                                            DispatchQueue.main.async {
                                                requestList.removeAll()
                                                manager.getAnnouncementApplications(AnnouncementId: announcementId.id) { request, error in
                                                    if let error = error {
                                                        detailError.toggle()
                                                        detailErrorText = error.localizedDescription
                                                    }
                                                    else
                                                    {
                                                        requestList.append(request!)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    if req.status == 0
                                    {
                                        Image(systemName: "plus.circle").foregroundColor(.green)
                                            .font(.title3)
                                    }
                                   
                                }
                                .padding()
                                Button {
                                    manager.acceptOrCancelRequest(announcementId: announcementId.id, appliedUserId: req.appliedUser, okOrNot: false) { complated, error in
                                        if let error = error {
                                            detailError.toggle()
                                            detailErrorText = error.localizedDescription
                                        }
                                        else if complated
                                        {
                                            
                                            DispatchQueue.main.async {
                                                requestList.removeAll()
                                                manager.getAnnouncementApplications(AnnouncementId: announcementId.id) { request, error in
                                                    if let error = error {
                                                        detailError.toggle()
                                                        detailErrorText = error.localizedDescription
                                                    }
                                                    else
                                                    {
                                                       
                                                        requestList.append(request!)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    if req.status == 0
                                    {
                                        Image(systemName: "x.circle").foregroundColor(.red)
                                            .font(.title3)
                                    }
                                    
                                }
                                .padding()


                            }
                            .padding(.horizontal)
                        }
                    }
                } else {
                    ScrollView{
                        ForEach(requestList){ req in
                            HStack{
                                if req.status == 0
                                {
                                    Text("")
                                    Spacer()
                                    Text("cevaplanmadı")
                                }
                                else if req.status == 2
                                {
                                    
                                    NavigationLink {
                                        DisplayedUserView(manager: manager,displayedUserMail: req.announceCreaterEmail)
                                            .navigationBarHidden(true)
                                    } label: {
                                        Text("yayınlayan")
                                            .foregroundColor(.white)
                                          
                                    }
                                    
                                    
                                  //  Button {
                                  //      detailedUserEmail = req.announceCreaterEmail
                                  //      print(detailedUserEmail)
                                  //      changeDetailView.toggle()
                                  //  } label: {
                                  //      Text("yayınlayan")
                                  //          .foregroundColor(Color.white)
                                  //  }


                                    
                                    Spacer()
                                    Text("hadi yine iyisin")
                                }
                                else
                                {
                                    Text("")
                                    Spacer()
                                    Text("sen başka tarafa bak ya.")
                                }
                            }
                            .foregroundColor(.white)
                            .padding()
                        }
                    }
                    
                }
            }
            .frame(maxWidth:.infinity)
            .foregroundColor(.green)
            .onAppear {
                requestList.removeAll()
                DispatchQueue.main.async {
                    manager.getAnnouncementApplications(AnnouncementId: announcementId.id) { request, error in
                        if let error = error {
                            detailError.toggle()
                            detailErrorText = error.localizedDescription
                        }
                        else
                        {
                            if announcementId.createdUserMail == manager.user.email {
                                requestList.append(request!)
                            }
                            else if request?.appliedUser == manager.user.email
                            {
                                requestList.append(request!)
                            }
                            
                        }
                    }
                }
            }
            
       
        }
        .alert(isPresented: $detailError) {
            Alert(title: Text("mesaj"), message: Text(detailErrorText))
            
        }
        .fullScreenCover(isPresented: $changeDetailView) {
            DisplayedUserView(manager: manager, displayedUserMail: detailedUserEmail )
        }
    }
}

//struct DatabaseAnnouncementView_Previews: PreviewProvider {
//    static var previews: some View {
//        DatabaseAnnouncementView()
//    }
//}
