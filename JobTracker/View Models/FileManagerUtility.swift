//
//  FileManagerUtility.swift
//  JobTracker
//

import SwiftUI

final class FileManagerUtility {
    
    static private let main: FileManager = FileManager.default
    static var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MM-YYYY"
        return df
    }
    
    
    public static func openDocumentsDirectory() {
        let documentsURL = main.urls(for: .documentDirectory, in: .userDomainMask).first!
        NSWorkspace.shared.open(documentsURL)
    }

    
    public static func createNewDirectory(_ pathExtension: String) throws {
        guard let documentsURL = main.urls(for: .documentDirectory, in: .userDomainMask).first else { throw NSError(domain: "Could not load documents URL", code: 0, userInfo: nil) }
        let newPath = documentsURL.appendingPathComponent(pathExtension)
        
        do { try main.createDirectory(at: newPath, withIntermediateDirectories: true) }
        catch { throw error }
    }
    
    
    public static func saveToDirectory(_ object: Data,_ path: String) throws {
        guard let documentsURL = main.urls(for: .documentDirectory, in: .userDomainMask).first else { throw NSError(domain: "Could not load documents URL", code: 0, userInfo: nil) }
        let fileURL = documentsURL.appendingPathComponent(path)
        
        do {
            try object.write(to: fileURL)
            NSLog("[FileManagerUtility] Successfully saved object to \(fileURL)")
        } catch { throw error }
    }
    
    
    public static func loadPDFData(_ filePath: String) throws -> Data {
        guard let documentsURL = main.urls(for: .documentDirectory, in: .userDomainMask).first else { throw NSError(domain: "Could not load documents URL", code: 0, userInfo: nil) }
        let fileURL = documentsURL.appendingPathComponent(filePath)
        
        do {
            let pdf = try Data(contentsOf: fileURL)
            return pdf
        } catch { throw error }
    }
    
}
