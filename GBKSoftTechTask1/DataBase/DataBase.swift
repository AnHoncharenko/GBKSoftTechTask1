//
//  DataBase.swift
//  GBKSoftTechTask1
//
//  Created by Anton Honcharenko on 19.11.2020.
//

import Foundation
import SQLite

class DataBase {
    static let shared: DataBase = DataBase()
    public var connection: Connection?

    private init() {
        do {
            if let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
                print(path)
                connection = try Connection("\(path)/cfon.sqlite3")
            } else {
                connection = nil
            }
        } catch {
            connection = nil
            print ("Cannot connect to Database. Error is: \(error)")
        }
    }

    func makeTables() {
        StoredContacts.shared.makeTable()
    }
}
