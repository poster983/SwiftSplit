#!/usr/bin/swift
//
//  main.swift
//  SwiftSplit
//
//  Created by Joseph Hassell on 6/20/24.
//


import Foundation
import SwiftCSV
import CoreXLSX
//func splitCSV(inputFile: String, parts: Int, keepHeader: Bool) {
//    do {
//        let csv = try CSV<Enumerated>(url: URL(fileURLWithPath: inputFile))
//        let rows = csv.rows
//        let headers = csv.header
//        let totalRows = rows.count
//        let chunkSize = (totalRows + parts - 1) / parts
//
//        for i in 0..<parts {
//            let startIndex = i * chunkSize
//            let endIndex = min(startIndex + chunkSize, totalRows)
//            let chunkRows = Array(rows[startIndex..<endIndex])
//            
//            let outputFileName = "\(inputFile)-part\(i+1).csv"
//            var outputContent = ""
//            
//            if keepHeader {
//                outputContent += headers.joined(separator: ",") + "\n"
//            }
//            
//            for row in chunkRows {
//                outputContent += row.joined(separator: ",") + "\n"
//            }
//            
//            try outputContent.write(toFile: outputFileName, atomically: true, encoding: .utf8)
//        }
//    } catch {
//        print("Error reading CSV file: \(error)")
//    }
//}
//
//func writeCSV(rows: [[String]], headers: [String]?, to fileName: String) {
//    var content = ""
//    if let headers = headers {
//        content += headers.joined(separator: ",") + "\n"
//    }
//    for row in rows {
//        content += row.joined(separator: ",") + "\n"
//    }
//    do {
//        try content.write(toFile: fileName, atomically: true, encoding: .utf8)
//    } catch {
//        print("Failed to write to \(fileName): \(error)")
//    }
//}
//
//func splitXLSX(inputFile: String, parts: Int, keepHeader: Bool) {
//    do {
//        guard let file = XLSXFile(filepath: inputFile) else {
//            print("Failed to open the Excel file")
//            return
//        }
//        
//        guard let sharedStrings = try file.parseSharedStrings() else {
//            print("Failed to parse shared strings")
//            return
//        }
//        
////        guard  else {
////            print("Failed to parse worksheet paths")
////            return
////        }
//        let sheets = try file.parseWorksheetPaths()
//        
//        for path in sheets {
//            let worksheet = try file.parseWorksheet(at: path)
//            let rows = worksheet.data?.rows ?? []
//            let totalRows = rows.count
//            let chunkSize = (totalRows + parts - 1) / parts
//            let headers = keepHeader ? rows.first?.cells.map { $0.stringValue(sharedStrings) ?? "" } : nil
//            
//            for i in 0..<parts {
//                let startIndex = i * chunkSize
//                let endIndex = min(startIndex + chunkSize, totalRows)
//                let chunkRows = rows[startIndex..<endIndex]
//                let chunkValues = chunkRows.map { $0.cells.map { $0.stringValue(sharedStrings) ?? "" } }
//
//                let outputFileName = "\(inputFile)-part\(i+1).csv"
//                writeCSV(rows: chunkValues, headers: headers, to: outputFileName)
//            }
//        }
//    } catch {
//        print("Error reading XLSX file: \(error)")
//    }
//}
//
//func main() {
//    guard CommandLine.arguments.count > 1 else {
//        print("Usage: SwiftSplit <input_file> -n <parts> [-h]")
//        return
//    }
//    
//    let inputFile = CommandLine.arguments[1]
//    var parts = 1
//    var keepHeader = false
//    
//    for (index, arg) in CommandLine.arguments.enumerated() {
//        if arg == "-n", index + 1 < CommandLine.arguments.count {
//            parts = Int(CommandLine.arguments[index + 1]) ?? 1
//        }
//        if arg == "-h" {
//            keepHeader = true
//        }
//    }
//    
//    let fileExtension = URL(fileURLWithPath: inputFile).pathExtension.lowercased()
//    
//    switch fileExtension {
//    case "csv":
//        splitCSV(inputFile: inputFile, parts: parts, keepHeader: keepHeader)
//    case "xlsx":
//        splitXLSX(inputFile: inputFile, parts: parts, keepHeader: keepHeader)
//    default:
//        print("Unsupported file type. Supported types are CSV and XLSX.")
//    }
//}
//
//main()
//
//
//


func getOutputFilePath(inputFile: String, part: Int, outputDir: String?) -> String {
    let inputFileName = URL(fileURLWithPath: inputFile).deletingPathExtension().lastPathComponent
    let outputFileName = "\(inputFileName)-part\(part+1).csv"
    
    if let outputDir = outputDir {
        return URL(fileURLWithPath: outputDir).appendingPathComponent(outputFileName).path
    } else {
        return FileManager.default.currentDirectoryPath + "/" + outputFileName
    }
}

func splitCSV(inputFile: String, parts: Int, keepHeader: Bool, outputDir: String?) {
    do {
        let csv = try CSV<Enumerated>(url: URL(fileURLWithPath: inputFile))
        let rows = csv.rows
        let headers = csv.header
        let totalRows = rows.count
        let chunkSize = (totalRows + parts - 1) / parts

        for i in 0..<parts {
            let startIndex = i * chunkSize
            let endIndex = min(startIndex + chunkSize, totalRows)
            let chunkRows = Array(rows[startIndex..<endIndex])
            
            let outputFilePath = getOutputFilePath(inputFile: inputFile, part: i, outputDir: outputDir)
            var outputContent = ""
            
            if keepHeader {
                outputContent += headers.joined(separator: ",") + "\n"
            }
            
            for row in chunkRows {
                outputContent += row.joined(separator: ",") + "\n"
            }
            
            try outputContent.write(toFile: outputFilePath, atomically: true, encoding: .utf8)
        }
    } catch {
        print("Error reading CSV file: \(error)")
    }
}

func writeCSV(rows: [[String]], headers: [String]?, to filePath: String) {
    var content = ""
    if let headers = headers {
        content += headers.joined(separator: ",") + "\n"
    }
    for row in rows {
        content += row.joined(separator: ",") + "\n"
    }
    do {
        try content.write(toFile: filePath, atomically: true, encoding: .utf8)
    } catch {
        print("Failed to write to \(filePath): \(error)")
    }
}

func splitXLSX(inputFile: String, parts: Int, keepHeader: Bool, outputDir: String?) {
    do {
        guard let file = XLSXFile(filepath: inputFile) else {
            print("Failed to open the Excel file")
            return
        }
        
        guard let sharedStrings = try file.parseSharedStrings() else {
            print("Failed to parse shared strings")
            return
        }
        
        let sheets = try file.parseWorksheetPaths()
        
        for path in sheets {
            let worksheet = try file.parseWorksheet(at: path)
            let rows = worksheet.data?.rows ?? []
            let totalRows = rows.count
            let chunkSize = (totalRows + parts - 1) / parts
            let headers = keepHeader ? rows.first?.cells.map { $0.stringValue(sharedStrings) ?? "" } : nil
            
            for i in 0..<parts {
                let startIndex = i * chunkSize
                let endIndex = min(startIndex + chunkSize, totalRows)
                let chunkRows = rows[startIndex..<endIndex]
                let chunkValues = chunkRows.map { $0.cells.map { $0.stringValue(sharedStrings) ?? "" } }
                
                let outputFilePath = getOutputFilePath(inputFile: inputFile, part: i, outputDir: outputDir)
                writeCSV(rows: chunkValues, headers: headers, to: outputFilePath)
            }
        }
    } catch {
        print("Error reading XLSX file: \(error)")
    }
}

func main() {
    guard CommandLine.arguments.count > 1 else {
        print("Usage: SwiftSplit <input_file> -n <parts> [-h] [-o <output_directory>]")
        return
    }
    
    let inputFile = CommandLine.arguments[1]
    var parts = 1
    var keepHeader = false
    var outputDir: String? = nil
    
    for (index, arg) in CommandLine.arguments.enumerated() {
        if arg == "-n", index + 1 < CommandLine.arguments.count {
            parts = Int(CommandLine.arguments[index + 1]) ?? 1
        }
        if arg == "-h" {
            keepHeader = true
        }
        if arg == "-o", index + 1 < CommandLine.arguments.count {
            outputDir = CommandLine.arguments[index + 1]
        }
    }
    
    let fileExtension = URL(fileURLWithPath: inputFile).pathExtension.lowercased()
    
    switch fileExtension {
    case "csv":
        splitCSV(inputFile: inputFile, parts: parts, keepHeader: keepHeader, outputDir: outputDir)
    case "xlsx":
        splitXLSX(inputFile: inputFile, parts: parts, keepHeader: keepHeader, outputDir: outputDir)
    default:
        print("Unsupported file type. Supported types are CSV and XLSX.")
    }
}

main()
