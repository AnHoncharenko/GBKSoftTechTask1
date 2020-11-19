//
//  StoredContacts.swift
//  GBKSoftTechTask1
//
//  Created by Anton Honcharenko on 19.11.2020.
//

import Foundation
import SQLite
import PromiseKit

struct StoredContactsItem {
    var firstName: String!
    var lastName: String!
    var phone: String!
    var email: String!
    var image: String!
    var gender: String!
    var street: String!
    var city: String!
    var state: String!
    var postcode: String!
    var latitude: Double!
    var longitude: Double!
    var uuid: String!
}

class StoredContacts {
    static let shared: StoredContacts = StoredContacts()
    let table = Table("contacts")
    let firstName = Expression<String>("firstName")
    let lastName = Expression<String>("lastName")
    let phone = Expression<String>("phone")
    let email = Expression<String>("email")
    let image = Expression<String>("image")
    let gender = Expression<String>("gender")
    let street = Expression<String>("street")
    let city = Expression<String>("city")
    let state = Expression<String>("state")
    let postcode = Expression<String>("postcode")
    let latitude = Expression<Double>("latitude")
    let longitude = Expression<Double>("longitude")
    let uuid = Expression<String>("uuid")

    private init() { }

    func loadContacts() -> Promise<Void> {
        let pendingPromise = Promise<Void>.pending()
        WebService.shared.getContacts(count: "20")
            .done({ results in
                results.forEach({ StoredContacts.shared.insert(contact: StoredContactsItem(firstName: $0.name.first,
                                                                                           lastName: $0.name.last,
                                                                                           phone: $0.phone,
                                                                                           email: $0.email,
                                                                                           image: ($0.picture.medium?.absoluteString)!,
                                                                                           gender: $0.gender,
                                                                                           street: $0.location.street,
                                                                                           city: $0.location.city,
                                                                                           state: $0.location.state,
                                                                                           postcode: $0.location.postcode,
                                                                                           latitude: $0.location.coordinates.latitude,
                                                                                           longitude: $0.location.coordinates.longitude,
                                                                                           uuid: $0.uuid)) })
                pendingPromise.resolver.fulfill(())
            })
            .cauterize()
        return pendingPromise.promise
    }

    func makeTable() {
        do {
            try DataBase.shared.connection?.run(table.create(ifNotExists: true) { table in
                table.column(firstName)
                table.column(lastName)
                table.column(phone)
                table.column(email)
                table.column(image)
                table.column(gender)
                table.column(street)
                table.column(city)
                table.column(state)
                table.column(postcode)
                table.column(latitude)
                table.column(longitude)
                table.column(uuid)
            })
        } catch {
            print("table error \(error)")
        }
    }

    func all(completion: @escaping(_ result: [StoredContactsItem]?) -> ()) {
        do {
            if DataBase.shared.connection != nil {
                let filtered = table.filter(uuid == uuid)
                var items: [StoredContactsItem]! = []
                for contact in try DataBase.shared.connection!.prepare(filtered) {
                    items.append(StoredContactsItem(firstName: contact[firstName],
                                                    lastName: contact[lastName],
                                                    phone: contact[phone],
                                                    email: contact[email],
                                                    image: contact[image],
                                                    gender: contact[gender],
                                                    street: contact[street],
                                                    city: contact[city],
                                                    state: contact[state],
                                                    postcode: contact[postcode],
                                                    latitude: contact[latitude],
                                                    longitude: contact[longitude],
                                                    uuid: contact[uuid]))
                }
                completion(items.reversed())
            }
        } catch {
            print("fetch error \(error)")
        }
    }

    func insert(contact: StoredContactsItem!) {
        do {
            try DataBase.shared.connection?.run(table.insert(
                firstName <- contact.firstName,
                lastName <- contact.lastName,
                phone <- contact.phone,
                email <- contact.email,
                image <- contact.image,
                gender <- contact.gender,
                street <- contact.street,
                city <- contact.city,
                state <- contact.state,
                postcode <- contact.postcode,
                latitude <- contact.latitude,
                longitude <- contact.longitude,
                uuid <- contact.uuid))
        } catch {
            print("insert error \(error)")
        }
    }

    func clear() {
        do {
            let filtered = table.filter(firstName == firstName)
            try DataBase.shared.connection?.run(filtered.delete())
        } catch {
            print("error \(error)")
        }
    }

    func clearFor(_ name: String) {
        do {
            guard let connection = DataBase.shared.connection else { return }
            let filtered = table.filter(uuid == uuid)
            let toDelete = filtered.filter(firstName == name)
            try connection.run(toDelete.delete())
        } catch {
            print("clear error \(error)")
        }
    }

    func update(model: StoredContactsItem, compleation: @escaping(_ status: Bool) -> ()) {
        let filtered = table.filter(uuid == model.uuid)
        do {
            try DataBase.shared.connection?.run(filtered.update(firstName <- model.firstName,
                                                                lastName <- model.lastName,
                                                                phone <- model.phone,
                                                                email <- model.email,
                                                                image <- model.image,
                                                                gender <- model.gender,
                                                                street <- model.street,
                                                                city <- model.city,
                                                                state <- model.state,
                                                                postcode <- model.postcode,
                                                                latitude <- model.latitude,
                                                                longitude <- model .longitude,
                                                                uuid <- model.uuid))
            compleation(true)
        } catch {
            compleation(true)
            print("Error updating user \(error)")
        }
    }

}
