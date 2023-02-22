//
//  JSONDecoder+.swift
//  OpenMarket
//
//  Created by Dragon on 2023/02/22.
//

import UIKit

extension JSONDecoder {
    static func decodeAsset<T: Decodable>(name: String, to type: T.Type) -> T? {
        let jsonDecoder: JSONDecoder = JSONDecoder()
        var decodedData: T?
        
        if let dataAsset: NSDataAsset = NSDataAsset(name: name) {
            do {
                decodedData = try jsonDecoder.decode(type, from: dataAsset.data)
            } catch {
                debugPrint(JSONError.decodeError)
            }
            
            return decodedData
        }
        
        return decodedData
    }
}
