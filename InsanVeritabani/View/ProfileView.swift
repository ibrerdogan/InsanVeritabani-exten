//
//  ProfileView.swift
//  InsanVeritabani
//
//  Created by İbrahim Erdogan on 25.07.2022.
//

import SwiftUI
import URLImage

struct ProfileView: View {
    @State var eksiNick : String = ""
    @State var imageURL : String = ""
    
    @State var showSettings : Bool = false
    @State var goToMainView : Bool = false
    @State var scrollIndex = 0
    @State var expandDetail : Bool = false
    @State var showAdd : Bool = false
    
    
    @State var profileError : Bool = false
    @State var profileErrorText : String = ""
    
    @State var userAppliedAnnouncements : [AnnouncementModel] = []
    @ObservedObject var manager : FirebaseHelper
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            VStack{
                HStack{
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .font(.system(size: 25))
                    }
                    Spacer()
                   // Image(systemName: "bell")
                   //     .foregroundColor(.white)
                   //     .font(.system(size: 25))
                   //     .padding(.horizontal,2)
                    Button {
                        if manager.user.eksiNick != ""
                        {
                            showAdd.toggle()
                        }
                        else
                        {
                            profileError.toggle()
                            profileErrorText = "sıradan insanlar duyuru açamaz kanka."
                        }
                        
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.system(size: 25))
                            .padding(.horizontal)
                    }
                    Button {
                        showSettings.toggle()
                    } label: {
                        Image(systemName: "gear")
                            .foregroundColor(.white)
                            .font(.system(size: 25))
                    }

                }
                .padding(.horizontal)
                VStack(alignment:.leading) {
                    HStack(alignment:.center){
                        if manager.user.profileImage != "" {
                            URLImage(URL(string: manager.user.profileImage)!,
                                    empty: {
                                Image("default-pp")
                                    .resizable()
                                    .frame(width: 100, height: 100, alignment: .center)
                                    .clipShape(Circle())
                                    .shadow(color: .black, radius: 10, x: 2, y: 2)
                                    .padding()
                                    },
                                    inProgress: { progress in
                                    Image("default-pp")
                                        .resizable()
                                        .frame(width: 100, height: 100, alignment: .center)
                                        .clipShape(Circle())
                                        .shadow(color: .black, radius: 10, x: 2, y: 2)
                                        .padding()
                                    },
                                    failure: { error, retry in
                                Image("default-pp")
                                    .resizable()
                                    .frame(width: 100, height: 100, alignment: .center)
                                    .clipShape(Circle())
                                    .shadow(color: .black, radius: 10, x: 2, y: 2)
                                    .padding()
                                    },
                                    content: { image, info in
                                        image
                                            .resizable()
                                            .frame(width: 100, height: 100, alignment: .center)
                                            .clipShape(Circle())
                                            .shadow(color: .black, radius: 10, x: 2, y: 2)
                                            .shadow(color: .black, radius: 10, x: 2, y: 2)
                                            .padding()
                            })
                        } else {
                            Image("default-pp")
                                .resizable()
                                .frame(width: 100, height: 100, alignment: .center)
                                .clipShape(Circle())
                                .shadow(color: .black, radius: 10, x: 2, y: 2)
                                .padding()

                        }
                        Spacer()
                        VStack(alignment:.center){
                            TextEditor(text: $manager.user.profileDetail)
                                .font(.footnote)
                                .lineLimit(10)
                                .padding()
                                .foregroundColor(.black)
                                .disabled(true)
                            
                            //TODO: buraya kişi tipi gelecek.
                        }
                        .frame(maxWidth:.infinity,maxHeight: expandDetail ? 200 : 80)
                        .background(Color.white)
                        .cornerRadius(10)
                        .onTapGesture {
                            withAnimation(.spring()) {
                                expandDetail.toggle()
                            }
                        }
                    }
                    if manager.user.eksiNick == ""{
                        Text(manager.user.username)
                            .padding(.leading)
                            .foregroundColor(.white)
                            .offset(x: 10)
                            .offset(y: -10)
                    }
                    else
                    {
                        Text(manager.user.eksiNick)
                            .padding(.leading)
                            .foregroundColor(.white)
                            .offset(x: 10)
                            .offset(y: -10)
                    }
                }
               
                if manager.user.eksiNick == ""
                {
                    VStack(alignment:.leading){
                        Text("sıradan insan değil misin?")
                            .padding(.horizontal)
                            .offset(x: 10)
                            .foregroundColor(.gray)
                        VStack{
                            TextField("ekşi nicki", text: $eksiNick)
                                .padding()
                                .background(.white)
                                .frame(maxWidth:.infinity)
                                .cornerRadius(20)
                                .padding(.horizontal)
                                .foregroundColor(.black)
                                .shadow(color: .black, radius: 10, x: 2, y: 2)
                                .disableAutocorrection(true)
                            
                            Button {
                                manager.checkEksiNickAndTakeUrl(email: manager.user.email,
                                                                eksiNick: eksiNick) { errorString, errorActive in
                                    
                                    if errorActive
                                    {
                                        profileError.toggle()
                                        profileErrorText = errorString
                                    }
                                }
                            } label: {
                                Text("bak bakalım ben var mıyım?")
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                
                
                HStack{
                    Text("ilanlarım")
                        .underline(true, color: scrollIndex == 0 ? .white : .green)
                        .padding()
                        .onTapGesture {
                            withAnimation(.spring()) {
                                scrollIndex = 0
                            }
                        }
                    Text("başvurularım")
                        .underline(true, color: scrollIndex == 1 ? .white : .green)
                        .padding()
                        .onTapGesture {
                            withAnimation(.spring()) {
                                scrollIndex = 1
                            }
                        }
                   // Text("geçmiş")
                   //     .underline(true, color: scrollIndex == 2 ? .white : .green)
                   //     .padding()
                   //     .onTapGesture {
                   //         withAnimation(.spring()) {
                   //             scrollIndex = 2
                   //         }
                   //     }
                }.foregroundColor(.white)
                    .frame(maxWidth:.infinity)
                    .background(Color.green)
                    .cornerRadius(20)
                    .padding(.top)
                   
                
                ScrollView{
                   if scrollIndex == 0
                    {
                       if manager.usersAnnouncementList.count != 0 {
                           ForEach(manager.usersAnnouncementList){ item in
                               NavigationLink {
                                   DatabaseAnnouncementView(announcementId: item, manager: manager)
                                       .navigationBarHidden(true)
                               } label: {
                                   HStack{
                                       Text(item.name)
                                       Spacer()
                                       Text("\(item.requestCount)")
                                           .padding(.horizontal)
                                       Image(systemName: "chevron.right")
                                   }
                                   .frame(maxWidth:.infinity)
                                   .padding()
                                   .foregroundColor(.white)
                               }

                           }
                       } else {
                           Text("yok ki öyle bir şey")
                               .padding()
                               .foregroundColor(.white)
                       }
                   }
                    if scrollIndex == 1
                    {
                        if userAppliedAnnouncements.count != 0
                        {
                            ForEach(userAppliedAnnouncements){ i in
                                NavigationLink {
                                    DatabaseAnnouncementView(announcementId: i, manager: manager)
                                        .navigationBarHidden(true)
                                } label: {
                                    HStack{
                                        Text(i.name)
                                        Spacer()
                                            .padding(.horizontal)
                                        Image(systemName: "chevron.right")
                                    }
                                    .frame(maxWidth:.infinity)
                                    .padding()
                                    .foregroundColor(.white)
                                }
                            }
                        }
                        else
                        {
                            Text("yok ki öyle bir şey")
                                .padding()
                                .foregroundColor(.white)
                        }
                    }
                   // if scrollIndex == 2
                   // {
                   //     ForEach(0..<10){i in
                   //         HStack{
                   //             Text("geçmiş")
                   //             Spacer()
                   //             Image(systemName: "chevron.right")
                   //         }
                   //         .frame(maxWidth:.infinity)
                   //         .padding()
                   //         .foregroundColor(.white)
                   //     }
                   // }
                    
                }
                .onAppear {
                    manager.getUserAnnouncements(email: manager.user.email)
                    userAppliedAnnouncements.removeAll()
                    manager.getUserAppliedAnnouncements(email: manager.user.email) { announce in
                        userAppliedAnnouncements.append(announce)
                    }
                }
                if showSettings
                {
                    SettingsView(show: $showSettings,manager: manager)
                        .frame(height: UIScreen.main.bounds.height * 0.4)
                        .cornerRadius(20)
                        .transition(.scale.animation(.spring()))
                        .offset(y: 20)
                      
                }
                
              
                
            }
          
        }
        .sheet(isPresented: $showAdd) {
            CreateAnnouncementView(manager: manager)
        }
        .alert(profileErrorText, isPresented: $profileError) {
            Button {
                profileErrorText = ""
                profileError = false
            } label: {
                Text("okudum anladım")
            }

        }
       
      
    }
    
}



struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(manager: FirebaseHelper())
    }
}
