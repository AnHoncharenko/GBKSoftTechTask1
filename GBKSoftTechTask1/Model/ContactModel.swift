//
//  ContactModel.swift
//  GBKSoftTechTask1
//
//  Created by Anton Honcharenko on 19.11.2020.
//

import Foundation
import SwiftyJSON

class ContactModel {
    var gender: String = ""
    var name: Name
    var email: String = ""
    var picture: Picture
    var location: UserLocation
    var phone: String = ""
    var uuid: String = ""

    init(json: JSON) {
        gender = json["gender"].stringValue
        name = Name(json: json["name"])
        email = json["email"].stringValue
        picture = Picture(json: json["picture"])
        location = UserLocation(json: json["location"])
        phone = json["phone"].stringValue
        uuid = json["login"]["uuid"].stringValue
    }
}

class Name {
    var title: String = ""
    var first: String = ""
    var last: String = ""

    init(json: JSON) {
        title = json["title"].stringValue
        first = json["first"].stringValue
        last = json["last"].stringValue
    }
}

class UserLocation {
    var street: String = ""
    var city: String = ""
    var state: String = ""
    var postcode: String = ""
    var coordinates: Coordinates
    

    init(json: JSON) {
        street = json["street"].string ?? "not indicated"
        city = json["city"].stringValue
        state = json["state"].stringValue
        postcode = json["postcode"].stringValue
        coordinates = Coordinates(json: json["coordinates"])
    }
}

class Coordinates {
    var latitude: Double = 0
    var longitude: Double = 0

    init(json: JSON) {
        latitude = json["latitude"].doubleValue
        longitude = json["longitude"].doubleValue
    }
}

class Picture {
    var large: URL?
    var medium: URL?
    var thumbnail: URL?

    init(json: JSON) {
        large = URL(string: json["large"].stringValue)
        medium = URL(string: json["medium"].stringValue)
        thumbnail = URL(string: json["thumbnail"].stringValue)
    }
}


