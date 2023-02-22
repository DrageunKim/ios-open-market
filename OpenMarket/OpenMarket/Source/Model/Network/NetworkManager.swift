//
//  NetworkManager.swift
//  OpenMarket
//
//  Created by Dragon on 2023/02/22.
//

import Foundation

class NetworkManager {
    private let urlSession: URLSession
    
    init(urlSession: URLSession) {
        self.urlSession = urlSession
    }
}
