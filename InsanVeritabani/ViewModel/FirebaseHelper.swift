//
//  FirebaseHelper.swift
//  InsanVeritabani
//
//  Created by İbrahim Erdogan on 27.07.2022.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirebaseHelper : ObservableObject
{
    @Published var changeLoginScreen : Bool = false
    
    
    private var auth = FirebaseAuth.Auth.auth()
    private var db = Firestore.firestore()
    @Published var usersAnnouncementList : [AnnouncementModel] = []
    @Published var announcementList : [AnnouncementModel] = []
    @Published var userRequestList : [requestModel] = []
    @Published var requestList : [requestModel] = []
    @Published var user = UserModel(email: "", username: "", profileImage: "", profileType: "", lastLoginData: Date.now,createdDate: Date.now,profileDetail: "",
    eksiNick: "")
    @Published var displayedUser = UserModel(email: "", username: "", profileImage: "", profileType: "", lastLoginData: Date.now,createdDate: Date.now,profileDetail: "",
    eksiNick: "")
    
    @Published var displayedUserInfo = UserInfoModel(id: "", userMail: "", userNick: "", openedAnnouncement: 0, appliedAnnouncement: 0, deniedAnnouncement: 0, acceptedAnnouncement: 0)
    
    
    
    //MARK: create new user from login view
    func createUserFirebase(email: String,password : String, completionHandler: @escaping (_ user : UserModel? , _ error : Error?) -> ())
    {
        auth.createUser(withEmail: email.lowercased(), password: password) { result, error in
            if let err = error{
                completionHandler(nil,err)
            }
            else
            {
                DispatchQueue.main.async { [weak self] in
                    self?.user.email = email
                    self?.createNewUserTable(email: email.lowercased() ) { error in
                        guard error == nil else {
                            self?.user.email = ""
                            completionHandler(nil,error)
                            return
                        }
                        self?.signUserFirebase(email: email.lowercased(), password: password, complatitionHander: { user, error in
                            guard error == nil else {
                                completionHandler(nil,error)
                                return
                            }
                            completionHandler(user,nil)

                        })
                       // completionHandler(self?.user,nil)
                        
                    }
                    
                }
            }
        }
    }
    
    //MARK: get displayed user from info table.
    func getDisplayedUserInformations(email : String , result : @escaping(_ error : Error?) ->())
    {
        db.collection("info").whereField("userMail", isEqualTo: email).getDocuments { Query, error in
            if let error = error {
                result(error)
            }
            else
            {
                if let Query = Query
                {
                    do{
                        let first = Query.documents.first
                        if let first = first
                        {
                            self.displayedUserInfo = try first.data(as: UserInfoModel.self)
                        }
                        
                        self.db.collection("users").whereField("email", isEqualTo: email).getDocuments { query, error in
                            if let error = error
                            {
                                result(error)
                            }
                            else
                            {
                                if let query = query
                                {
                                   let first = query.documents.first
                                    if let first = first
                                    {
                                        do
                                        {
                                            self.displayedUser = try first.data(as: UserModel.self)
                                        }
                                        catch
                                        {
                                            result(nil)
                                        }
                                    }
                                }
                                else
                                {
                                    result(error)
                                }
                            }
                        }
                        
                        
                    }
                    catch
                    {
                        result(error)
                    }
                }
                else
                {
                    result(nil)
                }
            }
        }
    }
    
    //MARK: get username or nick. first seek for nick
    func getUsernameOrNickFromMail(email : String , result : @escaping(_ name : String?, _ error : Error?) ->())
    {
        db.collection("users").whereField("email", isEqualTo: email.lowercased()).getDocuments { snapshot, error in
            if let error = error
            {
                result(nil,error)
            }
            else
            {
                let userDocument = snapshot?.documents.first
                do{
                    let user = try userDocument?.data(as: UserModel.self)
                    if user?.eksiNick == ""
                    {
                        result(user?.username,nil)
                    }
                    else
                    {
                        result(user?.eksiNick,nil)
                    }
                }
                catch{
                    result(nil,error)
                }
            }
            
        }
    }
    
    //MARK: signed user check
    func checkCurrentUser(complatitionHander : @escaping(_ user : UserModel?, _ error : Error?) ->())
    {
        let mail = auth.currentUser?.email
        if let mail = mail {
            if mail != "" {
                DispatchQueue.main.async { [weak self] in
                    self?.getUserTableFromFirebase(email: mail.lowercased(),signOrUpdate: true) { user, error in
                        if let error = error {
                            complatitionHander(nil,error)
                        }
                        else
                        {
                            complatitionHander(user,nil)
                        }
                    }
                    
                }
            }
            else
            {
               
                complatitionHander(nil,nil)
            }
        }
        else
        {
            complatitionHander(nil,nil)
        }
       
       
    }
    //MARK: signout and remove all fields
    func signOut(result : (_ error : Error?, _ okOrNot : Bool?) ->())
    {
        do{
            try auth.signOut()
            userRequestList.removeAll()
            usersAnnouncementList.removeAll()
            announcementList.removeAll()
            user = UserModel(email: "", username: "", profileImage: "", profileType: "", lastLoginData: Date.now,createdDate: Date.now,profileDetail: "",
                             eksiNick: "")
            requestList.removeAll()
            result(nil,true)
        }
        catch
        {
           result(error,false)
        }
    }
    
    //MARK: create new user table
    func createNewUserTable(email : String? , createResult : @escaping (_ error : Error?) -> ())
    {
        guard let email = email else {
            return
        }
        let data = [
            "id" : UUID().uuidString,
            "email" : email,
            "username" : "",
            "profileImage" : "",
            "profileType" : "",
            "lastLoginData" : Date.now,
            "createdDate" : Date.now,
            "profileDetail" : "",
            "eksiNick" : ""
        ] as [String: Any]
        
        db.collection("users").addDocument(data: data) { error in
            if let error = error
            {
                createResult(error)
            }
            else
            {
                self.createUserInformationToFirebase(email: email, nick: "") { error in
                    if let error = error {
                        createResult(error)
                        return
                    }
                    else
                    {
                        createResult(nil)
                    }
                }
                createResult(nil)
            }
        }
    }
    
    func createUserInformationToFirebase(email : String, nick : String, createResult : @escaping(_ error : Error?) -> ())
    {
        let data = [
            "id" : UUID().uuidString,
            "userMail" : email,
            "userNick" : "",
            "openedAnnouncement" : 0,
            "appliedAnnouncement" : 0,
            "deniedAnnouncement" : 0,
            "acceptedAnnouncement" : 0
        ] as [String: Any]
        db.collection("info").addDocument(data: data){error in
            if let error = error
            {
                createResult(error)
            }
            else
            {
                createResult(nil)
            }
        }
    }
    
    func signUserFirebase(email : String , password : String , complatitionHander : @escaping(_ user : UserModel? , _ error : Error?) -> ())
    {
        auth.signIn(withEmail: email.lowercased(), password: password) { result, error in
            if let error = error{
                complatitionHander(nil, error)
            }
            else
            {
                DispatchQueue.main.async { [weak self] in
                    self?.getUserTableFromFirebase(email: email.lowercased(),signOrUpdate: true) { user, error in
                        if let error = error {
                            complatitionHander(nil,error)
                        }
                        else
                        {
                            complatitionHander(user,nil)
                        }
                    }
                    
                }
            }
        }
    }
    
    func getUserTableFromFirebase(email : String , signOrUpdate : Bool, readDocumentResult : @escaping(_ user : UserModel?, _ error : Error?) -> ())
    {
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
            if let error = error {
                readDocumentResult(nil,error)
            }
            else
            {
                do{
                    if signOrUpdate {
                        snapshot?.documents.first?.reference.updateData(["lastLoginData" : Date.now])
                    }
                    let user = try snapshot?.documents.first?.data(as: UserModel.self)
                    readDocumentResult(user,nil)
                }
                catch
                {
                    readDocumentResult(nil,error)
                }
            }
        }
    }
    
    func updateUserFields(user : UserModel, updateDocumentResult : @escaping (_ updateResult : UserModel? , _ error : Error?) ->())
    {
        
        db.collection("users").whereField("email", isEqualTo: user.email).getDocuments { snapshot, error in
            if let error = error
            {
                updateDocumentResult(nil,error)
            }
            else
            {
                snapshot?.documents.first?.reference.updateData(["username" : user.username, "eksiNick" : user.eksiNick, "profileDetail" : user.profileDetail], completion: { err in
                    if let err = err
                    {
                        updateDocumentResult(nil,err)
                    }
                    else
                    {
                        self.getUserTableFromFirebase(email: user.email, signOrUpdate: false) {user, error in
                            if let error = error {
                                updateDocumentResult(nil,error)
                            }
                            else
                            {
                                updateDocumentResult(user,nil)
                            }
                        }
                    }
                    
                })
                   
            }
        }
    }
    
    func checkEksiNickAndTakeUrl(email : String,eksiNick : String , result :@escaping(_ errorString : String , _ errorActive : Bool) ->())
    {
        checkEksiNick(nick: eksiNick, email: email) { okOrNot, error in
            if let error = error {
                result(error.localizedDescription,true)
            }
            else
            {
                if okOrNot
                {
                    let name = eksiNick.replacingOccurrences(of: " ", with: "-")
                    let url = URL(string:"https://eksisozluk.com/biri/\(name)")
                    URLSession.shared.dataTask(with: url!) { data, response, error in
                        guard let data = data else {
                            result("senin sen olduğundan emin değiliz.",true)
                            return
                        }
                        let array = String(data: data, encoding: .ascii)
                        
                        let dizi = array?.description.components(separatedBy: "profile-logo")
                        
                       guard let dizi = dizi
                                else
                        {
                           result("senin sen olduğundan emin değiliz.",true)
                            return
                        }
                        
                        let second =  dizi[1].description.components(separatedBy: "=\"")
                        let link = second[1].replacingOccurrences(of: "\" alt", with: "")
                        self.user.eksiNick = eksiNick
                        self.user.profileImage = link
                        self.updateProfileImage(email: email,
                                                nick: self.user.eksiNick,
                                                url:  self.user.profileImage) { imageUploaded, error in
                            if let error = error {
                                result(error.localizedDescription,true)
                            }
                            else
                            {
                                if imageUploaded
                                {
                                    result("seni tanıdık, aklımıza yazdık",true)
                                }
                                else
                                {
                                    result("seni tanıdık ama bir terslik var gibi",true)
                                }
                            }
                        }
              
                    }.resume()
                }
                else
                {
                    result("böyle biri zaten var...",true)
                }
            }
        }
    }
    
    
    func updateProfileImage(email : String, nick : String , url : String , result : @escaping(_ imageUploaded : Bool , _ error : Error?)->()){
        
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { snapshot, error in
            if let error = error{
                result(false,error)
            }
            else
            {
                snapshot?.documents.first?.reference.updateData(["profileImage" : url])
                snapshot?.documents.first?.reference.updateData(["eksiNick" : nick])
                result(true,nil)
            }
        }
    }
    
    func checkUsername(username : String, email : String, result : @escaping (_ okOrNot : Bool , _ error : Error?) -> ())
    {
        db.collection("users").whereField("username", isEqualTo: username).getDocuments { querysnapshot, error in
            if let error = error
            {
                result(false,error)
            }
            else
            {
                if let querysnapshot = querysnapshot {
                    
                    let usersCount = querysnapshot.documents.count
                    if usersCount == 0
                    {
                        result(true,nil)
                    }
                    else
                    {
                        let docUser = try? querysnapshot.documents.first?.data(as: UserModel.self)
                        let docMail = docUser?.email
                        if docMail == email
                        {
                            result(true,nil)
                        }
                        else
                        {
                            result(false,nil)
                        }
                        
                
                    }
                }
                else
                {
                    result(false,nil)
                }
            }
        }
    }
    
    func checkEksiNick(nick : String , email : String , result : @escaping (_ okOrNot : Bool , _ error : Error?) ->())
    {
        db.collection("users").whereField("eksiNick", isEqualTo: nick).getDocuments { querysnapshot, error in
            if let error = error
            {
                result(false,error)
            }
            else
            {
                let users = querysnapshot?.documents.count
                if users == 0
                {
                    result(true,nil)
                }
                else
                {
                    let mail = try? querysnapshot?.documents.first?.data(as: UserModel.self).email
                    if mail == email
                    {
                        result(true,nil)
                    }
                    else
                    {
                        result(false,nil)
                    }
                }
                
            }
        }
    }
    // duyuruyu oluşturur. kullanıcı bilgilerinde açılan duyuru sayısını bir arttırıp günceller
    func createNewAnnouncement(announce : AnnouncementModel,result : @escaping(_ result : Bool , _ error : Error?) ->())
    {
      
        getUsernameOrNickFromMail(email: announce.createdUserMail.lowercased()) { [weak self] name, error in
            if let error = error {
                result(false,error)
            }
            else
            {
                let data = [
                    "id" : announce.id,
                    "name" : announce.name,
                    "createdUserMail" : announce.createdUserMail.lowercased(),
                    "detail" : announce.detail,
                    "eventDate" : announce.eventDate,
                    "eventLocation" : announce.eventLocation,
                    "databaseType" : announce.databaseType.rawValue,
                    "evetRequests" : [],
                    "creationDate" : Date.now,
                    "requestCount" : 0,
                    "isActive" : true,
                    "displayedName" : name ?? "bir insan"
                ] as [String : Any]
                
                self?.db.collection("announcement").addDocument(data: data) { err in
                    if let err = err {
                        result(false,err)
                    }
                    else
                    {
                        self?.db.collection("info").whereField("userMail", isEqualTo: announce.createdUserMail.lowercased()).getDocuments(completion: { query, err in
                            let doc = query?.documents.first
                            if let doc = doc{
                                let info = try? doc.data(as: UserInfoModel.self)
                                if let info = info
                                {
                                    doc.reference.updateData(["openedAnnouncement" : info.openedAnnouncement + 1])
                                }
                                else
                                {
                                    result(false,err)
                                }
                            }
                            else
                            {
                                result(false,err)
                            }
                            
                            
                                
                        })
                        result(true,nil)
                    }
                }
            }
        }
      
    }
    
    func disableAnnouncement(announce : AnnouncementModel)
    {
        db.collection("announcement").whereField("id", isEqualTo: announce.id).getDocuments { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
            }
            else
            {
                snapshot?.documents.first?.reference.delete()
                self.db.collection("request").whereField("requestedAnnouncement", isEqualTo: announce.id).getDocuments { snap, error in
                    if let error = error{
                        print(error.localizedDescription)
                    }
                    else
                    {
                        for doc in snap!.documents
                        {
                            doc.reference.delete()
                        }
                    }
                }
            }
        }
    }

    //kullanıcının oluşturduğu duyuruları alıyoruz.
    func getUserAnnouncements(email : String)
    {
        
        db.collection("announcement").whereField("createdUserMail", isEqualTo: email.lowercased()).whereField("isActive", isEqualTo: true).addSnapshotListener(includeMetadataChanges: true) {snapshot, error in
            if let err = error
             {
                print(err.localizedDescription)
            }
             else
             {
                 self.usersAnnouncementList.removeAll()
                 if let snap = snapshot
                 {
                     let docs = snap.documents
                     for d in docs
                     {
                         do {
                             let ann = try d.data(as: AnnouncementModel.self)
                             self.usersAnnouncementList.append(ann)
                         }
                         catch
                         {
                             print(error.localizedDescription)
                         }
                     }
                 }
                 else
                 {
                     print("snapshot bos")
                 }
             }
             
         }
    }
    
    func getAnnouncementWithType(annType : String, result : @escaping( _ list : AnnouncementModel? , _ error : Error?) ->())
    {
        self.announcementList.removeAll()
        db.collection("announcement").whereField("databaseType", isEqualTo: annType).whereField("isActive", isEqualTo: true).order(by: "creationDate").getDocuments { snapshot, error in
            if let error = error
            {
                result(nil,error)
            }
            else
            {
                guard let docs = snapshot
                else {return}
                for d in docs.documents
                {
                    do
                    {
                        let ann = try d.data(as: AnnouncementModel.self)
                       result(ann,nil)
                    }
                    catch
                    {
                        result(nil,error)
                    }
                }
                
            }
        }
    }
    //MARK: kullanmıyorum bunu
    func getAnnouncementWithTypeAndAsyn(annType : String , result : @escaping( _ list : AnnouncementModel , _ error : Error?) ->())
    {
        self.announcementList.removeAll()
        db.collection("announcement").whereField("databaseType", isEqualTo: annType).addSnapshotListener { snapshot, error in
            if let error = error
            {
                print(error.localizedDescription)
            }
            else
            {
                guard let docs = snapshot
                else {return}
                
                
                for d in docs.documents
                {
                    do
                    {
                       
                        let ann = try d.data(as: AnnouncementModel.self)
                        result(ann,nil)

                        
                    }
                    catch
                    {
                        print(error.localizedDescription)
                    }
                }
                
            }
        }
    }
    
    
    func createRequestForAnnouncement(email : String,announcementId : String , result : @escaping(_ added : Bool, _ error : Error?) ->())
    {
        getCreatedUserFromRequestId(announcementID: announcementId) { createdEmail, error in
            if let error = error {
                result(false,error)
            }
            else
            {
                let data = [
                    "id": UUID().uuidString,
                    "appliedUser" : email,
                    "requestedAnnouncement" : announcementId,
                    "status" : 0,
                    "requestDate" : Date.now,
                    "displayedName" : self.user.eksiNick,
                    "announceCreaterEmail" : createdEmail ?? "boş"
                ] as [String : Any]
                
                self.db.collection("request").addDocument(data: data) { [weak self] err in
                    if let err = err
                    {
                        result(false,err)
                    }
                    else
                    {
                        self?.db.collection("announcement").whereField("id",isEqualTo: announcementId).getDocuments { query, error in
                            query?.documents.first?.reference.updateData(["evetRequests" : FieldValue.arrayUnion([email.lowercased()])])
                            query?.documents.first?.reference.getDocument(completion: { doc, err in
                                let count = try? doc?.data(as: AnnouncementModel.self).requestCount
                                query?.documents.first?.reference.updateData(["requestCount" : (count ?? 0) + 1])
                                
                                self?.db.collection("info").whereField("userMail", isEqualTo: email.lowercased()).getDocuments(completion: { query, error in
                                   if let error = error
                                    {
                                       result(false,error)
                                   }
                                    else
                                    {
                                        let info = try? query?.documents.first?.data(as: UserInfoModel.self)
                                        if let info = info
                                        {
                                            query?.documents.first?.reference.updateData(["appliedAnnouncement" : info.appliedAnnouncement + 1])
                                            
                                        }
                                        else
                                        {
                                            result(false,err)
                                        }
                                        
                                    }
                                })
                            })
                          
                        }
                        result(true,nil)
                    }
                }
            }
                
        }
        
        
    }
    
    
    func checkIsUserAppliedRequestAnnouncement(email : String,announcementId : String, checkResult : @escaping(_ result : Bool, _ error : Error?) ->())
    {
        db.collection("announcement").whereField("id", isEqualTo: announcementId).getDocuments { snapshot, error in
            if let error = error
            {
                checkResult(false,error)
            }
            else
            {
                let announcement = try? snapshot?.documents.first?.data(as: AnnouncementModel.self)
                guard let announce = announcement
                else{
                    checkResult(false,nil)
                    return
                }
                
                if announce.evetRequests.contains(where: { $0 == email }) {
                     checkResult(true,nil)
                } else {
                    checkResult(false,nil)
                }
            }
        }
    }
    
    func getUserAppliedAnnouncement(email : String)
    {
        userRequestList.removeAll()
        db.collection("request").whereField("appliedUser", isEqualTo: email).getDocuments { querySnapShot, error in
            if let error = error
            {
               // result(nil,error)
                return
            }
            else
            {
                let documents = querySnapShot?.documents
                guard let documents = documents else {return}
                
                for doc in documents{
                    let d = try? doc.data(as: requestModel.self)
                   // result(d,nil)
                    self.userRequestList.append(d!)
                    
                }
            }
        }
    }
    
    func getUserAppliedAnnouncements(email : String, result : @escaping( _ announce : AnnouncementModel)->())
    {
        db.collection("request").whereField("appliedUser", isEqualTo: email).getDocuments { snapshot, error in
            if let error = error {
                print(error.localizedDescription)
            }
            else
            {
                if let snap = snapshot {
                    let docs = snap.documents
                    for doc in docs {
                        let announcement = try? doc.data(as: requestModel.self)
                        if let announcement = announcement
                        {
                            print(announcement.appliedUser)
                            self.db.collection("announcement").whereField("id", isEqualTo: announcement.requestedAnnouncement).getDocuments { snap, error in
                                if let error = error {
                                    print(error)
                                }
                                else
                                {
                                    if let snap = snap {
                                        let annoucements = snap.documents
                                        for announcement in annoucements {
                                            let announce = try? announcement.data(as: AnnouncementModel.self)
                                            result(announce!)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getAnnouncementApplications(AnnouncementId : String , result : @escaping(_ request : requestModel?, _ error : Error?) ->())
    {
        db.collection("request").whereField("requestedAnnouncement", isEqualTo: AnnouncementId).getDocuments { querysnapshot, error in
            if let error = error{
                result(nil,error)
            }
            let documents = querysnapshot?.documents
            guard let documents = documents else
            {
                return
            }
            for doc in documents{
                let request = try? doc.data(as: requestModel.self)
               result(request,nil)
            }
            
        }
    }
    
    func acceptOrCancelRequest(announcementId : String, appliedUserId : String,okOrNot : Bool , result : @escaping(_ complated : Bool , _ error : Error? ) ->())
    {
        db.collection("request").whereField("requestedAnnouncement",
                                            isEqualTo: announcementId).whereField("appliedUser", isEqualTo: appliedUserId).getDocuments
        { snapshot, error in
            if let error = error
            {
                result(false,error)
            }
            else
            {
                if let snapshot = snapshot {
                    if okOrNot
                    {
                        snapshot.documents.first?.reference.updateData(["status" : 2])
                        self.db.collection("info").whereField("userMail", isEqualTo: appliedUserId).getDocuments { query, error in
                            if let error = error
                            {
                                result(false,error)
                            }
                            else
                            {
                                let info = try? query?.documents.first?.data(as: UserInfoModel.self)
                                if let info = info
                                {
                                    query?.documents.first?.reference.updateData(["acceptedAnnouncement" : info.acceptedAnnouncement + 1])
                                }
                            }
                        }
                        result(true,nil)
                    }
                    else{
                        snapshot.documents.first?.reference.updateData(["status" : 1])
                        self.db.collection("info").whereField("userMail", isEqualTo: appliedUserId).getDocuments { query, error in
                            if let error = error
                            {
                                result(false,error)
                            }
                            else
                            {
                                let info = try? query?.documents.first?.data(as: UserInfoModel.self)
                                if let info = info
                                {
                                    query?.documents.first?.reference.updateData(["deniedAnnouncement" : info.deniedAnnouncement + 1])
                                }
                            }
                        }
                        result(true,nil)
                    }

                }
            }
        }
    }
    
    
    func getCreatedUserFromRequestId(announcementID : String, result : @escaping(_ email : String? ,_ error : Error?) ->())
    {
        db.collection("announcement").whereField("id", isEqualTo: announcementID).getDocuments { query, error in
            if let error = error
            {
                result(nil,error)
            }
            else
            {
                if let query = query
                {
                    do{
                        let announcement = try query.documents.first?.data(as: AnnouncementModel.self)
                        result(announcement?.createdUserMail,nil)
                    }
                    catch
                    {
                        result(nil,error)
                    }
                }
                else
                {
                    result(nil,nil)
                }
            }
        }
    }
   
   
    

   
    
    
}
