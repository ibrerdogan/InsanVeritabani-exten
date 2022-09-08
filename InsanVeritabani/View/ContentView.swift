//
//  ContentView.swift
//  InsanVeritabani
//
//  Created by İbrahim Erdogan on 25.07.2022.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var dbManager : FirebaseHelper
    
    @State var DatabaseName : String = "dertleşecek insan"
    @State var SearchOrNot : Bool = false
    @State var AnnouncementList : [AnnouncementModel] = []
    @State var requesting : Bool = false
    
    @State var contentError : Bool = false
    @State var contentErrorText : String = ""
    
    func createRequest(check : String) -> ()
    {
        if dbManager.user.eksiNick != ""
        {
            dbManager.createRequestForAnnouncement(email: dbManager.user.email,
                                                          announcementId: check) { added, error in
                if let error = error {
                    contentError.toggle()
                    contentErrorText = error.localizedDescription
                   
                }
                else
                {
                    contentError.toggle()
                    contentErrorText = "başvurunuz inanılmaz şekilde yapıldı"
                   
                }
               
            }
        }
        else
        {
            contentError.toggle()
            contentErrorText = "sıradan insanlar başvuru yapamaz kanka."
        }
        
       
    }
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea(edges: .all)
                VStack {
                    HStack{
                        Spacer()
                       // Image(systemName: "bell")
                       //     .foregroundColor(.white)
                       //     .font(.system(size: 25))
                       //     .padding(.horizontal,5)
                        NavigationLink {
                            ProfileView(manager: dbManager)
                                .navigationBarHidden(true)
                        } label: {
                            Image(systemName: "person")
                                .foregroundColor(.white)
                                .font(.system(size: 25))
                                .padding(.horizontal,5)
                        }

                    }
                    .padding(.horizontal)
                    HStack {
                        Menu {
                            Picker(selection: $DatabaseName) {
                                ForEach(DatabaseTypes.allCases) { value in
                                    Text(value.rawValue)
                                        .tag(value)
                                        .font(.largeTitle)
                                }
                            } label: {}
                        } label: {
                            HStack{
                                Image(systemName: "magnifyingglass.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                                Text(DatabaseName.lowercased())
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                    }
                    }.padding()
                    
                    Button {
                        withAnimation(.easeInOut) {
                            AnnouncementList.removeAll()
                        }
                        dbManager.getAnnouncementWithType(annType: DatabaseName) { list, error in
                            if let error = error {
                                contentError.toggle()
                                contentErrorText = error.localizedDescription
                            }
                            else
                            {
                                guard let ann = list else
                                {
                                    contentError.toggle()
                                    contentErrorText = "bir sıkıntılar söz konusu ama bakıcaz"
                                    return
                                }
                                withAnimation(.easeInOut) {
                                    AnnouncementList.append(ann)
                                }
                            }
                            
                        }
                        
                        
                    } label: {
                        HStack
                        {
                            Text("insan ara")
                                .foregroundColor(.white)
                                .font(.body)
                                .bold()
                                .padding()
                        }
                        .frame(maxWidth:.infinity)
                        .background(.blue)
                        .cornerRadius(30)
                        .padding(.horizontal)
                        .shadow(color: .blue, radius: 10, x: 1, y: 2)
                        
                    }

                    
                    VStack(spacing:20)
                    {
                      ScrollView
                        {
                            ForEach(AnnouncementList) { element in
                                LazyVStack{
                                    DatabaseAnnDetailView(callback : createRequest,databaseAnn: element , UserId: dbManager.user.email)
                                        .cornerRadius(20)
                                        .padding(.horizontal)
                                    
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarHidden(true)
        }
        .alert(contentErrorText, isPresented: $contentError, actions: {
            Button {
                contentError.toggle()
            } label: {
                Text("anladım")
            }

        })
        
        .onAppear {
            let randomType = DatabaseTypes.allCases.randomElement()
            DatabaseName = randomType?.rawValue ?? "dertleşecek insan"
            withAnimation(.easeInOut) {
                AnnouncementList.removeAll()
            }
            dbManager.getAnnouncementWithType(annType: DatabaseName) { list, error in
                if let error = error {
                    contentError.toggle()
                    contentErrorText = error.localizedDescription
                }
                else
                {
                    guard let ann = list else
                    {
                        contentError.toggle()
                        contentErrorText = "bir sıkıntılar söz konusu ama bakıcaz"
                        return
                    }
                    withAnimation(.easeInOut) {
                        AnnouncementList.append(ann)
                    }
                }
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(dbManager: FirebaseHelper())
    }
}
