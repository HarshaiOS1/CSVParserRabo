//
//  CSVParserViewModel.swift
//  CSVParserRabo
//
//  Created by Krishnappa, Harsha on 27/05/2024.
//

import Foundation
import SwiftCSV
import UIKit

class CSVParserViewModel: NSObject {
    var csvData: CSVData?
    let tempDirectory = FileManager.default.temporaryDirectory
    
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
    
    func tempSaveFile(selectedFileURL: URL) -> (URL?,String?) {
        if selectedFileURL.startAccessingSecurityScopedResource() {
            defer {
                selectedFileURL.stopAccessingSecurityScopedResource()
            }
            
            let newFileName = selectedFileURL.deletingPathExtension().lastPathComponent + ".csv"
            let tempFileURL = tempDirectory.appendingPathComponent(newFileName)
            do {
                try FileManager.default.copyItem(at: selectedFileURL, to: tempFileURL)
                return(tempFileURL, nil)
            } catch {
                return(nil, error.localizedDescription)
            }
        } else {
            return(nil, "error copying file")
        }
    }
    
    func clearTemporaryDirectory() {
        do {
            let tempFiles = try FileManager.default.contentsOfDirectory(atPath: tempDirectory.path)
            for file in tempFiles {
                let fileURL = tempDirectory.appendingPathComponent(file)
                try FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            print("Error cleaning temporary directory: \(error.localizedDescription)")
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
