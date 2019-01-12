import Foundation
//
//
//class Categories:NSObject{
//    var name:String?
//    var categories:[Category]?
//}
//
//class Category:NSObject{
//    var id:String?
//    var name:String?
//    var stations:[Station]?
//}
//
//class Station:NSObject{
//    var id:String?
//    var name:String?
//    var streamUrl:String?
//    var imageUrl:String?
//}

import UIKit

struct Category: Decodable {
    let id: String
    let name: String
    let Infos: Infos
    let Stations: [Station]
}

struct Station: Decodable {
    let id: String
    let name: String
    let stream: String
    let image: String
    let slug: String
}

struct Infos: Decodable {
    let title: String
}
