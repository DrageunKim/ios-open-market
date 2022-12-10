//
//  OpenMarket - HttpMethod.swift
//  Created by Zhilly, Dragon. 22/11/16
//  Copyright © yagom. All rights reserved.
//

enum HttpMethod: String {
    case get
    case post
    case patch
    case delete
    
    var name: String { rawValue.uppercased() }
}
