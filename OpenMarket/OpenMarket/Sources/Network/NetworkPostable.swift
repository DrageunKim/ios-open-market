//
//  OpenMarket - NetworkPostable.swift
//  Created by Zhilly, Dragon. 22/12/01
//  Copyright © yagom. All rights reserved.
//

import Foundation

protocol NetworkPostable {
    func post(to url: URL?)
    func checkDeleteURI(to url: URL?, completion: @escaping (String) -> Void)
}
