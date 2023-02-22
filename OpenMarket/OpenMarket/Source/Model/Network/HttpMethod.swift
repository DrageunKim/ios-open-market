//
//  HttpMethod.swift
//  OpenMarket
//
//  Created by Dragon on 2023/02/22.
//

enum HttpMethod {
    case get
    case post
    case patch
    case delete
    
    var name: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        case .patch:
            return "PATCH"
        case .delete:
            return "DELETE"
        }
    }
}
