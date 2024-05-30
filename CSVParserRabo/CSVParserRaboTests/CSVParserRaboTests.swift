//
//  CSVParserRaboTests.swift
//  CSVParserRaboTests
//
//  Created by Krishnappa, Harsha on 27/05/2024.
//

import XCTest
@testable import CSVParserRabo

final class CSVParserRaboTests: XCTestCase {
    var viewModel : CSVParserViewModel!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        viewModel = CSVParserViewModel()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        viewModel = nil
    }

    func testLocalCSVFileDataParsing() async throws {
        //check first local file exists
        XCTAssertNotNil(Bundle.main.url(forResource: "issues", withExtension: "csv"))
        if let localfileURL = Bundle.main.url(forResource: "issues", withExtension: "csv") {
            let _ = try await viewModel.getCSVTableData(filePath: localfileURL)
            //check if data parsed and if its correct
            XCTAssertNotNil(viewModel.csvData)
            XCTAssertEqual(viewModel.csvData?.rows.count, 4)
        }
    }
    
    func testDataParsing_withinvalidFilePath() async throws {
        let invalidFileURL = URL(filePath: "path/issues/invalid.csv")
        let result = try await viewModel.getCSVTableData(filePath: invalidFileURL)
        XCTAssertFalse(result)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
