//
//  CSVParserViewModel.swift
//  CSVParserRabo
//
//  Created by Krishnappa, Harsha on 27/05/2024.
//

import Foundation
import SwiftCSV

class CSVParserViewModel: NSObject {
    var csvData: CSVData?
    
    func getCSVTableData(filePath: URL) async throws -> Bool {
        do {
            let rows = try await CSVParser.parse(contentsOf: filePath)
            if rows.count > 0 {
                csvData = CSVData(rows: rows)
                return true
            } else {
                return false
            }
        } catch _ {
            return false
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

extension URL {
    func changingFileExtension(to newExtension: String) -> URL {
        return self.deletingPathExtension().appendingPathExtension(newExtension)
    }
}
