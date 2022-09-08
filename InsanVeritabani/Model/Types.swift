//
//  Types.swift
//  InsanVeritabani
//
//  Created by İbrahim Erdogan on 25.07.2022.
//

import Foundation

enum DatabaseTypes : String , CaseIterable , Identifiable , Codable
{
    case DertlesecekInsan = "dertleşecek insan"
    case BiraIcmelikInsan = "bira içmelik insan"
    case DisariCikmalikInsan = "dışarı çıkmalık insan"
    case EvlenmelikInsan = "evlenmelik insan"
    case HediyelesmelikInsan = "hediyeleşmelik insan"
    case TatileGitmelikInsan = "tatile gitmelik insan"
    case KampYapmalikInsan = "kamp yapmalik insan"
    case SevismelikInsan = "seks yapmalik insan"
    case OyunOynamalikInsan = "oyun oynamalik insan"
    case DersCalismalikInsan = "ders çalışmalık insan"
    var id : String{self.rawValue }
}

enum UserTypes : String
{
    case SiradanInsan = "Sıradan İnsan"
    case GuzelInsan = "Güzel İnsan"
    case ArananInsan = "Aranan İnsan"
    case BulunmazInsan = "Bulunmaz İnsan"
    case GorunmezInsan = "Görünmez İnsan"
    case IstenmeyenInsan = "İstenmeyen İnsan"
    
    
}
