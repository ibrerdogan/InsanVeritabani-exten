//
//  DisplayedUserView.swift
//  InsanVeritabani
//
//  Created by İbrahim Erdogan on 5.08.2022.
//

import SwiftUI
import URLImage

struct DisplayedUserView: View {
    @ObservedObject var manager : FirebaseHelper
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.openURL) var openURL
    var displayedUserMail : String
    @State var eksiNick : String = ""
    var body: some View {
        
       ZStack
        {
            Color.green
                .ignoresSafeArea()
            VStack{
                HStack
                {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title)
                            .padding(.horizontal)
                            .foregroundColor(.black)
                            Spacer()
                    }

                }
                if manager.displayedUser.profileImage != "" {
                    URLImage(URL(string: manager.displayedUser.profileImage)!,
                            empty: {
                        Image("default-pp")
                            .resizable()
                            .frame(width: 200, height: 200, alignment: .center)
                            .clipShape(Circle())
                            .shadow(color: .black, radius: 10, x: 2, y: 2)
                            .padding()
                            },
                            inProgress: { progress in
                            Image("default-pp")
                                .resizable()
                                .frame(width: 200, height: 200, alignment: .center)
                                .clipShape(Circle())
                                .shadow(color: .black, radius: 10, x: 2, y: 2)
                                .padding()
                            },
                            failure: { error, retry in
                        Image("default-pp")
                            .resizable()
                            .frame(width: 200, height: 200, alignment: .center)
                            .clipShape(Circle())
                            .shadow(color: .black, radius: 10, x: 2, y: 2)
                            .padding()
                            },
                            content: { image, info in
                                image
                                    .resizable()
                                    .frame(width: 200, height: 200, alignment: .center)
                                    .clipShape(Circle())
                                    .shadow(color: .black, radius: 10, x: 2, y: 2)
                                    .shadow(color: .black, radius: 10, x: 2, y: 2)
                                    .padding()
                    })
                } else {
                    Image("default-pp")
                        .resizable()
                        .frame(width: 200, height: 200, alignment: .center)
                        .clipShape(Circle())
                        .shadow(color: .black, radius: 10, x: 2, y: 2)
                        .padding()

                }
               
                
                VStack
                {
                    Button(manager.displayedUser.eksiNick) {
                        
                        let name = manager.displayedUser.eksiNick.lowercased()
                        eksiNick = name.replacingOccurrences(of: " ", with: "-")
                               openURL(URL(string: "https://www.eksisozluk.com/biri/\(eksiNick)")!)
                           }
                }
                .frame(maxWidth:.infinity)
                
                ScrollView
                {
                    VStack(spacing: 15){
                            TextEditor(text: $manager.displayedUser.profileDetail)
                                .padding(.horizontal)
                                .lineLimit(20)
                                .disabled(true)
                                .frame(height:150)
                                .cornerRadius(10)
                      
                        HStack{
                            Text("açtığı duyuru ")
                            Text("\(manager.displayedUserInfo.openedAnnouncement)").bold()
                            Spacer()
                        }
                        .padding(.horizontal)
                        HStack{
                            Text("red yediği duyuru ")
                            Text("\(manager.displayedUserInfo.deniedAnnouncement)").bold()
                            Spacer()
                        }
                        .padding(.horizontal)
                        HStack{
                            Text("kabul edildiği duyuru ")
                            Text("\(manager.displayedUserInfo.acceptedAnnouncement)").bold()
                            Spacer()
                        }
                        .padding(.horizontal)
                        HStack{
                            Text("başvurduğu duyuru ")
                            Text("\(manager.displayedUserInfo.appliedAnnouncement)").bold()
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                      
                            
                            
                    }
                    
                }
                .frame(maxWidth:.infinity)
                .padding(.horizontal)
                
                
                
                
                
            }.frame(maxWidth:.infinity)
            
        }.onAppear {

            manager.getDisplayedUserInformations(email: displayedUserMail) { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
            
        }
    }
}

struct DisplayedUserView_Previews: PreviewProvider {
    static var previews: some View {
        DisplayedUserView(manager: FirebaseHelper(),displayedUserMail: "")
    }
}


/**
 ZStack(alignment : .bottomTrailing)
 {
     Image(systemName: "bell")
         .resizable()
         .frame(width: 100, height: 100, alignment: .center)
         .font(.title)
         
     Circle()
         .frame(width: 30, height: 30, alignment: .center)
         .padding()
         .foregroundColor(.red)
         .overlay {
             Text("1")
         }
 }
 */
