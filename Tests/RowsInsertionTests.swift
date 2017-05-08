//
//  RowsInsertionTests.swift
//  Eureka
//
//  Created by Miguel Revetria on 5/8/17.
//  Copyright © 2017 Xmartlabs. All rights reserved.
//

import XCTest
@testable import Eureka

class RowsInsertionTests: XCTestCase {
    
    func testAppendingRows() {
        let form = Form()
        let section = Section("section_01")

        form.append(section)
        section.append(NameRow(tag: "row_01"))
        section.append(NameRow(tag: "row_02"))
        section.append(NameRow(tag: "row_03"))

        hideAndShowRows(form: form, expectedTags: ["row_01", "row_02", "row_03"])
    }

    func testAppendingRowsWithCustomOperator() {
        let form = Form()
        let section = Section("section_01")

        form +++ section
            <<< NameRow(tag: "row_01")
            <<< NameRow(tag: "row_02")
            <<< NameRow(tag: "row_03")

        hideAndShowRows(form: form, expectedTags: ["row_01", "row_02", "row_03"])
    }

    func testInsertingRowsWithSubscript() {
        let form = Form()
        let section = Section("section_01")

        form[0] = section
        form[0][0] = NameRow(tag: "row_01")
        form[0][1] = NameRow(tag: "row_02")
        form[0][2] = NameRow(tag: "row_03")

        hideAndShowRows(form: form, expectedTags: ["row_01", "row_02", "row_03"])
    }

    func testMovingAppendedRows() {
        let formInit: () -> Form = {
            let form = Form()
            let section = Section()

            form.append(section)
            section.append(NameRow(tag: "tag_01"))
            section.append(NameRow(tag: "tag_02"))
            section.append(NameRow(tag: "tag_03"))

            return form
        }

        let append: (Section, BaseRow) -> Void = { section, row in
            section.append(row)
        }

        movingRows(formInit: formInit, sectionAppend: append)
    }

    func testMovingAppendedRowsWithCustomOperator() {
        let formInit: () -> Form = {
            let form = Form()
            let section = Section()

            form +++ section
            section <<< NameRow(tag: "tag_01")
            section <<< NameRow(tag: "tag_02")
            section <<< NameRow(tag: "tag_03")

            return form
        }

        let append: (Section, BaseRow) -> Void = { section, row in
            section <<< row
        }

        movingRows(formInit: formInit, sectionAppend: append)
    }

    func testMovingInsertedRowsWithSubscript() {
        let formInit: () -> Form = {
            let form = Form()
            let section = Section()

            form[0] = section
            section[0] = NameRow(tag: "tag_01")
            section[1] = NameRow(tag: "tag_02")
            section[2] = NameRow(tag: "tag_03")

            return form
        }

        let append: (Section, BaseRow) -> Void = { section, row in
            section[section.count] = row
        }

        movingRows(formInit: formInit, sectionAppend: append)
    }

    private func hideAndShowRows(form: Form, expectedTags tags: [String]) {
        form.first?.forEach { row in
            XCTAssertNotNil(row.section)
        }

        XCTAssertEqual(form[0].count, 3)

        var tag1 = form[0][0].tag!
        var tag2 = form[0][1].tag!
        var tag3 = form[0][2].tag!

        XCTAssertEqual(tag1, tags[0])
        XCTAssertEqual(tag2, tags[1])
        XCTAssertEqual(tag3, tags[2])

        var row = form[0][1]
        row.hidden = true
        row.evaluateHidden()
        XCTAssertNotNil(row.section)

        XCTAssertEqual(form[0].count, 2)
        XCTAssertEqual(form.allRows.count, 3)

        tag1 = form[0][0].tag!
        tag3 = form[0][1].tag!
        XCTAssertEqual(tag1, tags[0])
        XCTAssertEqual(tag3, tags[2])

        row = form[0][0]
        row.hidden = true
        row.evaluateHidden()
        XCTAssertNotNil(row.section)

        XCTAssertEqual(form[0].count, 1)
        XCTAssertEqual(form.allRows.count, 3)

        tag3 = form[0][0].tag!
        XCTAssertEqual(tag3, tags[2])

        row = form[0][0]
        row.hidden = true
        row.evaluateHidden()
        XCTAssertNotNil(row.section)

        XCTAssertEqual(form[0].count, 0)
        XCTAssertEqual(form.allRows.count, 3)

        form.allRows
            .map { $0.tag! }
            .enumerated()
            .forEach { ind, tag in
                XCTAssertEqual(tag, tags[ind])
            }

        form.allRows[1].hidden = false
        form.allRows[1].evaluateHidden()

        XCTAssertEqual(form[0].count, 1)
        XCTAssertEqual(form.allRows.count, 3)

        tag2 = form[0][0].tag!
        XCTAssertEqual(tag2, tags[1])
    }

    private func movingRows(formInit: () -> Form, sectionAppend: (Section, BaseRow) -> Void) {
        var form = formInit()
        var tmp = form[0].remove(at: 0)
        XCTAssertNil(tmp.section)
        sectionAppend(form[0], tmp)
        XCTAssertNotNil(tmp.section)

        hideAndShowRows(form: form, expectedTags: ["tag_02", "tag_03", "tag_01"])

        form = formInit()
        tmp = form[0].remove(at: 1)
        XCTAssertNil(tmp.section)
        sectionAppend(form[0], tmp)
        XCTAssertNotNil(tmp.section)

        hideAndShowRows(form: form, expectedTags: ["tag_01", "tag_03", "tag_02"])

        form = formInit()
        tmp = form[0].remove(at: 2)
        XCTAssertNil(tmp.section)
        sectionAppend(form[0], tmp)
        XCTAssertNotNil(tmp.section)

        hideAndShowRows(form: form, expectedTags: ["tag_01", "tag_02", "tag_03"])
    }
}
