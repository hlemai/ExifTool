import Foundation
import os.log

@available(macOS 11.00, *)
public class ExifTool : Sequence {
    
    /// path for exiftool tool (https://exiftool.org)
    static var exifToolPath = "/opt/homebrew/bin/exiftool"
    /// factory to create and exiftool dictitionnary from a local url
    public static func read(fromurl:URL) -> ExifTool {
        let exif = ExifTool(filepath:fromurl.path)
        exif.fillMetataData()
        return exif
    }
    /// factory to create  exiftool dictitionnary from a local url and add lcoalisation of KEYS
    public static func read(fromurl:URL, lang:String) -> ExifTool {
        let exif = ExifTool(filepath:fromurl.path)
        exif.fillMetataData(lang:lang)
        return exif
    }

    /// ability to change the exifTool location. On X86 mac, homebrew location should be
    /// /usr/local/Cellar/bin/exiftool
    public static func setExifTool(_ path:String) {
        exifToolPath = path
    }
    /// path of image file
    private let filepath:String
    /// logger
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ExifTool Wrapper")
    /// metadata dictionnary
    public var metadata:[String:String]
    /// private initializer (use Factory)
    private init(filepath:String) {
        self.filepath=filepath
        self.metadata = [:] 
    }
    /// main function to set metadata from files
    private func fillMetataData(lang:String = "en") {
        metadata["FilePath"]=filepath
        logger.debug("Starting to retreive metadata for \(self.filepath)")
        // use external process to get info from pipe
        let task = Process()
        task.executableURL=URL(fileURLWithPath: ExifTool.exifToolPath)
        task.arguments = ["-lang",lang,filepath]
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        do {
            try task.run()
        }
        catch {
            logger.error("Error retrieving information from \(self.filepath)")
            if(task.isRunning) {
                task.terminate()
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                logger.info("Detailled of stderror : \(String(decoding:errorData,as : UTF8.self))")
            } else {
                logger.warning("cannot run \(ExifTool.exifToolPath)")
            }
            return
        }

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(decoding: outputData, as: UTF8.self)        
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        if !errorData.isEmpty {
            logger.error("Detailled of stderror : \(String(decoding:errorData,as : UTF8.self))")
        }
        
        for lines in output.split(separator: "\n") {
            let cols = lines.split(separator: ":")
            if(cols.count==2){
                let key = String(cols[0]).trimmingCharacters(in: .whitespacesAndNewlines)
                metadata[key]=String(cols[1]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        logger.info("Retreive \(self.metadata.count) metadata for \(self.filepath)")
    }
    /// implemtation of iterator to fetch metadata
    public func makeIterator() -> Dictionary<String, String>.Iterator  {
        return metadata.makeIterator()
    }
    /// subscript to access to metadata
    public subscript(string:String) -> String? {
        get {
            metadata[string]
        }
        set(newValue) {
            metadata[string] = newValue
        }
    }
    /// count
    public var count:Int {
        get {
            return metadata.count
        }
    }
}
