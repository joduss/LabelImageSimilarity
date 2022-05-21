//Created by Jonathan Duss on 19.05.22.
//  
//

import Foundation
import SwiftCSV


fileprivate struct DatasetRow : Hashable {
    var imageAPath: String
    var imageBPath: String
    var areDuplicate: Bool
    var added: Date
}


public class Dataset {
    
    private static let imageAColumnName = "imageA"
    private static let imageBColumnName = "imageB"
    private static let duplicateColumnName = "similar"
    private static let addedColumnName = "added"

    private let fileManager: FileManager = FileManager.default
    private let dateFormatter = Date.ISO8601FormatStyle()

    private var content = Set<DatasetRow>()
    
    public let pathUrl: URL

    public var path: String {
        return pathUrl.path
    }
    
    public var count: Int {
        return content.count
    }
    
    
    init(path: URL) {
        self.pathUrl = path
    }
    
    
    public func load() throws {
        guard fileManager.fileExists(atPath: path) == true else {
            try Data().write(to: pathUrl)
            return
        }
        
        try self.parseCsv(try CSV.init(url: pathUrl))
    }
    
    private func parseCsv(_ csv: CSV) throws {
        content.reserveCapacity(csv.namedRows.count)
        
        for row in csv.namedRows {
            guard let imageAPath = row[Dataset.imageAColumnName],
                  let imageBPath = row[Dataset.imageBColumnName],
                  let areDuplicate = (row[Dataset.duplicateColumnName] as? NSString)?.boolValue,
                  let addedString = row[Dataset.addedColumnName],
                  let added = try? dateFormatter.parse(addedString) else {
                throw DatasetError.InvalidDataset("""
                    One value is invalid.
                    Image A: \(String(describing: row[Dataset.imageAColumnName]))
                    Image B: \(String(describing: row[Dataset.imageBColumnName]))
                    areDuplucate: : \(String(describing: row[Dataset.duplicateColumnName]))
                    added: \(String(describing: row[Dataset.addedColumnName]))
                    """
                )
            }
            
            let datasetRow = DatasetRow(
                imageAPath: imageAPath,
                imageBPath: imageBPath,
                areDuplicate: areDuplicate,
                added: added)
            
            content.insert(datasetRow)
        }
    }
    
    public func save() throws {
        let file = try FileHandle(forWritingTo: pathUrl)
        
        // Header
        try file.write(contentsOf: "\(Dataset.imageAColumnName),\(Dataset.imageBColumnName),\(Dataset.duplicateColumnName),\(Dataset.addedColumnName)".data(using: .utf8)!)
        
        for row in content {
            try file.write(contentsOf: "\n".data(using: .utf8)!)
            try file.write(contentsOf: "\(row.imageAPath),\(row.imageBPath),\(row.areDuplicate ? 1 : 0),\(dateFormatter.format(row.added))".data(using: .utf8)!)
        }
        
        try file.close()
    }
    
    public func add(imageAPath: URL, imageBPath: URL, areDuplicate: Bool) {
        var row: DatasetRow!

        if imageAPath.path < imageBPath.path {
            row = DatasetRow(imageAPath: imageAPath.path, imageBPath: imageBPath.path, areDuplicate: areDuplicate, added: Date.now)
        } else {
            row = DatasetRow(imageAPath: imageBPath.path, imageBPath: imageAPath.path, areDuplicate: areDuplicate, added: Date.now)
        }

        content.insert(row)
    }
    
}
