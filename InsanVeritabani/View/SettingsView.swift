//
//  SettingsView.swift
//  InsanVeritabani
//
//  Created by İbrahim Erdogan on 28.07.2022.
//

import SwiftUI

struct SettingsView: View {
    
    func getProfileImage()
    {
       
        let name =  manager.user.eksiNick.replacingOccurrences(of: " ", with: "-")
        let url = URL(string:"https://eksisozluk.com/biri/\(name)")
        URLSession.shared.dataTask(with: url!) { data, response, error in
            guard let data = data else {
                settingsError.toggle()
                settingsErrorText = "senin sen olduğundan emin değiliz."
                return
            }
            let array = String(data: data, encoding: .ascii)
            
            let dizi = array?.description.components(separatedBy: "profile-logo")
            
           guard let dizi = dizi
                    else
            {
               settingsError.toggle()
               settingsErrorText = "senin sen olduğundan emin değiliz."
                return
            }
            
            let second =  dizi[1].description.components(separatedBy: "=\"")
            let link = second[1].replacingOccurrences(of: "\" alt", with: "")
            manager.user.profileImage = link
            manager.updateProfileImage(email: manager.user.email,
                                       nick: manager.user.eksiNick,
                                       url:  manager.user.profileImage) { imageUploaded, error in
                if let error = error {
                    settingsError.toggle()
                    settingsErrorText = error.localizedDescription
                }
                else
                {
                    if imageUploaded
                    {
                        settingsError.toggle()
                        settingsErrorText = "seni tanıdık aklımıza yazdık"
                    }
                    else
                    {
                        settingsError.toggle()
                        settingsErrorText = "seni tanıdık ama bir terslik var"
                    }
                }
            }
  
        }.resume()
    }
    
    
    
    
    @Binding var show : Bool
    @ObservedObject var manager : FirebaseHelper
    @State var settingsError : Bool = false
    @State var settingsErrorText : String = ""
    @State var usernameChecked : Bool = false
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        ZStack
        {
            Color.white
                .ignoresSafeArea()
            VStack {
                Group
                {
                    HStack{
                        Text("ayarlar")
                            .font(.title)
                            .foregroundColor(.green).bold()
                            .padding(.horizontal)
                        Spacer()
                        Button {
                            show.toggle()
                        } label: {
                            Image(systemName: "chevron.down").font(.title)
                                .foregroundColor(.green)
                                .padding(.horizontal)
                        }

                    }
                    .padding(.horizontal)
                }
                ScrollView{
                    VStack(alignment:.leading){
                        HStack
                        {
                            Text("kullanıcı adın").foregroundColor(.green)
                                .padding(.horizontal)
                            Spacer()
                            

                        }
                        TextField("", text: $manager.user.username)
                            .padding()
                            .frame(maxWidth:.infinity)
                            .background(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .shadow(color: .black, radius: 10, x: 1, y: 1)
                        Divider()
                        HStack
                        {
                            Text("eksi nicki").foregroundColor(.green)
                                .padding(.horizontal)
                            Spacer()

                        }
                        TextField("", text: $manager.user.eksiNick)
                            .padding()
                            .frame(maxWidth:.infinity)
                            .background(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .shadow(color: .black, radius: 10, x: 1, y: 1)
                            .disabled(true)
                        Divider()
                        Text("hakkında").foregroundColor(.green)
                            .padding(.horizontal)
                        TextEditor(text: $manager.user.profileDetail)
                            .frame(height:100)
                            .padding()
                            .frame(maxWidth:.infinity)
                            .background(.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                            .shadow(color: .black, radius: 10, x: 1, y: 1)
                        Button {
                            if manager.user.username != ""
                            {
                                manager.checkUsername(username: manager.user.username,
                                                             email: manager.user.email) { usernameOk, error in
                                    if let error = error {
                                        settingsError.toggle()
                                        settingsErrorText = error.localizedDescription
                                    }
                                    else
                                    {
                                        if usernameOk {
                                            
                                            manager.updateUserFields(user: manager.user) { updateResult, error in
                                                if let error = error {
                                                    settingsError.toggle()
                                                    settingsErrorText = error.localizedDescription
                                                }
                                                else
                                                {
                                                    settingsError.toggle()
                                                    settingsErrorText = "hepsini düzelttik"
                                                }
                                            }
                                          
                                        }
                                        else
                                        {
                                            settingsError.toggle()
                                            settingsErrorText = "böyle biri var ki"
                                        }
                                    }
                                }
                            }
                            else
                            {
                                settingsError.toggle()
                                settingsErrorText = "isimsiz kahraman mı olucan sen??"
                            }
                        } label: {
                            Text("düzelt")
                                .font(.body)
                                .foregroundColor(.white)
                                .frame(maxWidth:.infinity)
                                .padding()
                                .background(.blue)
                                .cornerRadius(20)
                                .padding()
                            
                        }
                        
                        Button {
                            manager.signOut { error, okOrNot in
                                if let error = error {
                                    settingsError = true
                                    settingsErrorText = error.localizedDescription
                                }
                                else
                                {
                                    if let okOrNot = okOrNot {
                                        if okOrNot{
                                            manager.changeLoginScreen = false
                                            presentationMode.wrappedValue.dismiss()
                                        }
                                        else
                                        {
                                            settingsError = true
                                            settingsErrorText = "cikis olmadı"
                                        }
                                    }
                                    else
                                    {
                                        settingsError = true
                                        settingsErrorText = "cikis yok"
                                    }
                                }
                            }
                        } label: {
                            Text("terk et")
                                .font(.body)
                                .foregroundColor(.white)
                                .frame(maxWidth:.infinity)
                                .padding()
                                .background(.red)
                                .cornerRadius(20)
                                .padding(.horizontal)
                            
                        }

                            
                        
                    }
                }
                .padding()
            }
            .alert(settingsErrorText, isPresented: $settingsError) {
                Button {
                    settingsError.toggle()
                } label: {
                   Text("tamam anladım.")

                }

            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(show: .constant(true),manager: FirebaseHelper())
    }
}


