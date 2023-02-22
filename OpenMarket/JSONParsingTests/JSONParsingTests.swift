//
//  JSONParsingTests.swift
//  JSONParsingTests
//
//  Created by Dragon on 2023/02/22.
//

import XCTest
@testable import OpenMarket

final class JSONParsingTests: XCTestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
    }
    
    func test_JSON파일이름이JSONParsingTest이고_dataAsset을실행하면_결과가nil이아닌지() {
        // given - JSON파일명으로 JSONParsingTestFile이 주어짐
        let dataAssetName: String = "JSONParsingTest"
        
        // when - decodeAsset을 실행했을 때
        let result = JSONDecoder.decodeAsset(name: dataAssetName, to: Product.self)
        
        // then - 결과가 nil이 아닌지
        XCTAssertNotNil(result)
    }
    
    func test_JSON파일이름이Test이고_dataAsset을실행하면_결과가nil인지() {
        // given - JSON파일명으로 Test가 주어짐
        let dataAssetName = "Test"
        
        // when - decodeAsset을 실행했을 때
        let result = JSONDecoder.decodeAsset(name: dataAssetName, to: Product.self)
        
        // then - 결과가 nil인지
        XCTAssertNil(result)
    }
    
    func test_JSON파일이름이JSONParsingTest이고_dataAsset을실행하면_page_no가1과같다() {
        // given - JSON파일명으로 JSONParsingTestFile이 주어짐
        let dataAssetName = "JSONParsingTest"
        
        // when - decodeAsset을 실행했을 때
        let data = JSONDecoder.decodeAsset(name: dataAssetName, to: Product.self)
        let result = data?.pageNo
        
        // then
        XCTAssertEqual(result, 1)
    }
    
    func test_JSON파일이름이JSONParsingTest이고_dataAsset을실행하면_마지막page의price는_2000과같다() {
        // given - JSON파일명으로 JSONParsingTestFile이 주어짐
        let dataAssetName = "JSONParsingTest"
        
        // when - decodeAsset을 실행했을 때
        let data = JSONDecoder.decodeAsset(name: dataAssetName, to: Product.self)
        let result = data?.pages.last?.price
        
        // then
        XCTAssertEqual(result, 2000)
    }
}
