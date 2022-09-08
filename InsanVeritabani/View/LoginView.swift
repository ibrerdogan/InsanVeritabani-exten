//
//  LoginView.swift
//  InsanVeritabani
//
//  Created by İbrahim Erdogan on 27.07.2022.
//

import SwiftUI

struct LoginView: View {
    @State var email : String = ""
    @State var password : String = ""

    @State var createOrLogin : Bool = false
    @State var progressing : Bool = false
    
    //alert
    @State var alertTitle = ""
    @State var alert = false
    
    // @ObservedObject
    @ObservedObject var manager = FirebaseHelper()
    
    init()
    {
       
        progressing.toggle()

       
    }
    
 
  
    var body: some View {
        ZStack{
            
            //MARK: background
            Color.black
                .ignoresSafeArea()
            
            //MARK: prossesing
            VStack{
                ProgressView()
                    .scaleEffect(2)
                    .font(.system(size:8))
                    
                }.zIndex(progressing ? 1 : 0)
            
            VStack(spacing:12)
            {
                Image("eksi_logo")
                    .resizable()
                    .frame(width: 300, height: 300, alignment: .center)
                
                TextField("email", text: $email).modifier(EditTextModifier()).disableAutocorrection(true)
                SecureField("password", text: $password).modifier(EditTextModifier())
                
                Button {
                    progressing = true
                    if createOrLogin
                    {
                        manager.createUserFirebase(email: email, password: password) {user, error in
                                if let error = error {
                                    progressing = false
                                    alertTitle = error.localizedDescription
                                    alert = true
                                }
                                else
                                {
                                    manager.user = user!
                                    progressing = false
                                    manager.changeLoginScreen = true
                                }
                            }
                    }
                    else
                    {
                        manager.signUserFirebase(email: email.lowercased(), password: password) { user, error in
                            if let error = error {
                                progressing = false
                                alertTitle = error.localizedDescription
                                alert = true
                            }
                            else
                            {
                                manager.user = user!
                                progressing = false
                                manager.changeLoginScreen = true
                            }
                        }
                    }
                    
                } label: {
                    Text(createOrLogin ? "kayıt ol" : "giriş yap")
                        .padding()
                        .frame(maxWidth:.infinity)
                        .background(Color.green)
                        .cornerRadius(20)
                        .padding(.horizontal)
                }

                HStack
                {
                    
                    Button {
                        withAnimation(.spring()) {
                            createOrLogin.toggle()
                        }
                    } label: {
                        Text(createOrLogin ? "zaten bir hesabın mı var?"  : "hesabın yok mu ?")
                    }
                   
                }.foregroundColor(.white)

                    
            }
            .foregroundColor(.black)
            .blur(radius: progressing ? 20 : 0)
            .alert(alertTitle, isPresented: $alert) {
                Button(role: .cancel) {
                    alertTitle = ""
                    alert = false
                } label: {
                    Text("anladım")
                }

            }
    
            
        }
        .onAppear(perform: {
            progressing = true
            manager.checkCurrentUser { user, error in
                if let error = error {
                    alert.toggle()
                    alertTitle = error.localizedDescription
                    progressing = false
                }
                else
                {
                    if let user = user {
                        manager.user = user
                        progressing.toggle()
                        manager.changeLoginScreen = true
                    }
                    else
                    {
                       // alert.toggle()
                       // alertTitle = "bilmediğimiz bir hata ile karşılaştık valla biz de şaşkınız"
                        progressing = false
                    }
                }
               
            }
        })
        .fullScreenCover(isPresented: $manager.changeLoginScreen) {
           ContentView(dbManager: manager)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

struct EditTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth:.infinity)
            .background(Color.white)
            .cornerRadius(20)
            
    }
}
