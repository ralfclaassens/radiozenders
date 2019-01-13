import Foundation
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
