//
//  WebServiceAPI.swift
//  GBKSoftTechTask1
//
//  Created by Anton Honcharenko on 19.11.2020.
//

import Foundation
import PromiseKit

extension WebService {

    func getContacts(count: String) -> Promise<[ContactModel]> {
        let resource = Resource(path: "/api/", method: .GET, urlParam: ["results": count])
        return request(with: resource).map({ $0["results"].arrayValue.map({ ContactModel(json: $0) }) })
    }
}
