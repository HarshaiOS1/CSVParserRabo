//
//  CSVParserViewModel.swift
//  CSVParserRabo
//
//  Created by Krishnappa, Harsha on 27/05/2024.
//

import Foundation
import SwiftCSV

class CSVParserViewModel: NSObject {
    
    func getCSVTableData(filePath: String) async throws -> ([CSVRow]?, String?) {
        if let url = URL(string: filePath) {
            do {
                let row = try await CSVParser.parse(contentsOf: url)
            } catch let err {
                return (nil, err.localizedDescription)
            }
            return (nil,"Invalid file path")
        } else {
            return (nil,"Invalid file path")
        }
    }
}

//MARK: CSVParser
struct CSVParser {
    static func parse(contentsOf url: URL) async throws -> [CSVRow] {
        let data = try Data(contentsOf: url)
        guard let content = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "CSVParser", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to decode data to string."])
        }
        
        let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
        var rows: [CSVRow] = []
        for line in lines {
            let columns = line.split(separator: ",").map { String($0) }
            rows.append(CSVRow(columns: columns))
        }
        return rows
    }
}
