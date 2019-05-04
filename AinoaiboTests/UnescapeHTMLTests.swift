//
//  UnescapeHTMLTests.swift
//  AinoaiboTests
//
//  Created by Zheng Li on 2019/4/21.
//  Copyright © 2019 ain. All rights reserved.
//

import Foundation
import XCTest
import Ainoaibo

class UnescapeHTMLTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testUnescapeHTML1() {
        let input = "如果主题是&quot;人类创作的音乐有着AI永远无法企及的魅力&quot;, 后面的主线应该如何安排?"
        let output = """
            如果主题是"人类创作的音乐有着AI永远无法企及的魅力", 后面的主线应该如何安排?
            """

        let result = input.aibo_stringByUnescapingFromHTML()

        XCTAssertEqual(result, output)
    }

    func testUnescapeHTML2() {
        let input = "&quot;&quot;&quot;&quot;&;;&&quot;"
        let output = "\"\"\"\"&;;&\""

        let result = input.aibo_stringByUnescapingFromHTML()

        XCTAssertEqual(result, output)
    }

    func testUnescapeHTML3() {
        let input = "&#65;&#66;&#67;"
        let output = "ABC"

        let result = input.aibo_stringByUnescapingFromHTML()

        XCTAssertEqual(result, output)
    }

    func testUnescapeHTML4() {
        let input = "&#x30;&#x31;&#X32;"
        let output = "012"

        let result = input.aibo_stringByUnescapingFromHTML()

        XCTAssertEqual(result, output)
    }

    func testUnescapeHTML5() {
        let input = "🤦‍♂️&#x30;😅&#x31;&#😭X32;"
        let output = "🤦‍♂️0😅1&#😭X32;"

        let result = input.aibo_stringByUnescapingFromHTML()

        XCTAssertEqual(result, output)
    }

    func testUnescapeHTML6() {
        let input = ["&#;", "&;", ";&", "&", ";"]
        let output = ["&#;", "&;", ";&", "&", ";"]

        let result = input.map { $0.aibo_stringByUnescapingFromHTML() }

        XCTAssertEqual(result, output)
    }

}
