//
//  CheckEksiNickName.swift
//  InsanVeritabani
//
//  Created by İbrahim Erdogan on 4.08.2022.
//

import SwiftUI

struct CheckEksiNickName: View {
    @State var nick : String = ""
    @State var image = ""
    var body: some View {
        
        VStack
        {
            TextField("şaslkdasd", text: $nick).padding()
                .disableAutocorrection(true)
            Button {
                CheckSomething()
            } label: {
                Text("bak")
            }

        }
       
    }
    
    func CheckSomething()
    {
        let name =  nick.replacingOccurrences(of: " ", with: "-").lowercased()
        let url = URL(string:"https://eksisozluk.com/biri/\(name)")
        URLSession.shared.dataTask(with: url!) { data, response, error in
            guard let data = data else {
                print(error?.localizedDescription ?? "data error")
                return
            }
            let array = String(data: data, encoding: .ascii)
            
            let dizi = array?.description.components(separatedBy: "profile-logo")
            
           guard let dizi = dizi
                    else
            {
                return
            }
            
          let second =  dizi[1].description.components(separatedBy: "=\"")
            let link = second[1].replacingOccurrences(of: "\" alt", with: "")
            print(link)
            
           
          
           
           
          
        }.resume()
    }
}

struct CheckEksiNickName_Previews: PreviewProvider {
    static var previews: some View {
        CheckEksiNickName()
    }
}
