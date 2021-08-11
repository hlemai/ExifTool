import Foundation
import os.log

@available(macOS 11.00, *)
public class ExifTool : Sequence {
    
    //MARK: Static part
    
    /// path for exiftool tool (https://exiftool.org)
    static var exifToolPath = "/opt/homebrew/bin/exiftool"
    static var catalog : MetaCatalog?
    static var flatenedCatalog: [String:Meta]?
    
    /// factory to create and exiftool dictitionnary from a local url
    public static func read(fromurl:URL) -> ExifTool {
        buildMetaCatalog()
        let exif = ExifTool(filepath:fromurl.path)
        exif.fillMetataData(tags:[])
        return exif
    }

    /// factory to create and exiftool dictitionnary from a local url limited to specific tags
    public static func read(fromurl:URL, tags:[String]) -> ExifTool {
        buildMetaCatalog()
        let exif = ExifTool(filepath:fromurl.path)
        exif.fillMetataData(tags:tags)
        return exif
    }

    /// ability to change the exifTool location. On X86 mac, homebrew location should be
    /// /usr/local/Cellar/bin/exiftool
    public static func setExifTool(_ path:String) {
        exifToolPath = path
    }
    /// Once collect metadata translator
    private static func buildMetaCatalog() {
        if catalog == nil {
            // use external process to get info from pipe
            let task = Process()
            task.executableURL=URL(fileURLWithPath: ExifTool.exifToolPath)
            task.arguments = ["-listx"]
            let outputPipe = Pipe()
            let errorPipe = Pipe()
            task.standardOutput = outputPipe
            task.standardError = errorPipe
            do {
                try task.run()
            }
            catch {
                logger.error("Error retrieving information catalog")
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
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            if !errorData.isEmpty {
                logger.error("Detailled of stderror : \(String(decoding:errorData,as : UTF8.self))")
            }
            do {
                let xmlDoc = try XMLDocument(data: outputData)
                catalog = MetaCatalog.buildfrom(xmlDocument: xmlDoc)
                flatenedCatalog = catalog?.flattenDic
            } catch {
                logger.error("Error Parsing XML : \(error.localizedDescription)")
            }
        }
    }
    
    /// logger
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "ExifTool", category: "ExifTool Wrapper")

    //MARK: Non static
    /// path of image file
    private let filepath:String

    /// metadata dictionnary with keys
    public var metadata:[String:String]
    
    /// get dictionnary with lang desc
    public func getMetadata(lang:String) -> [String:String] {
        
        var metaInLocal = [String : String](minimumCapacity: metadata.capacity)
        
        guard let cata = ExifTool.flatenedCatalog else {
            return metadata
        }
        
        metadata.forEach { (key,value) in
            let newkey = cata[key]?.descDict[lang] ?? cata[key]?.descDict["en"] ?? key
            metaInLocal[newkey] = value
        }
        return metaInLocal
    }
    
    /// private initializer (use Factory)
    private init(filepath:String) {
        self.filepath=filepath
        self.metadata = [:] 
    }
    
    /// main function to set metadata from files
    private func fillMetataData(tags:[String]) {
        metadata["FilePath"]=filepath
        ExifTool.logger.debug("Starting to retreive metadata for \(self.filepath)")
        // use external process to get info from pipe
        let task = Process()
        task.executableURL=URL(fileURLWithPath: ExifTool.exifToolPath)
        task.arguments = ["-s"]
        task.arguments?.append(contentsOf: tags.map({"-"+$0}))
        task.arguments?.append(filepath)
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        do {
            try task.run()
        }
        catch {
            ExifTool.logger.error("Error retrieving information from \(self.filepath)")
            if(task.isRunning) {
                task.terminate()
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                ExifTool.logger.info("Detailled of stderror : \(String(decoding:errorData,as : UTF8.self))")
            } else {
                ExifTool.logger.warning("cannot run \(ExifTool.exifToolPath)")
            }
            return
        }

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(decoding: outputData, as: UTF8.self)        
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        if !errorData.isEmpty {
            ExifTool.logger.error("Detailled of stderror : \(String(decoding:errorData,as : UTF8.self))")
        }
        
        for lines in output.split(separator: "\n") {
            let cols = lines.split(separator: ":")
            if(cols.count==2){
                let key = String(cols[0]).trimmingCharacters(in: .whitespacesAndNewlines)
                metadata[key]=String(cols[1]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        ExifTool.logger.info("Retreive \(self.metadata.count) metadata for \(self.filepath)")
    }
    
    // MARK: iterator and access to meta
    /// implementation of iterator to fetch metadata
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
