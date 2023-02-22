//
//  URLManager.swift
//  OpenMarket
//
//  Created by Dragon on 2023/02/22.
//

import Foundation

enum URLManager {
    case healthChecker
    
    var url: String {
        let host: String = "https://openmarket.yagom-academy.kr"
        
        switch self {
        case .healthChecker:
            return host + "/healthChecker"
        }
    }
}
