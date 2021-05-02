import Foundation

@available(macOS 10.13, *)
public class ExifTool {
    
    //static var exifToolPath = "/opt/homebrew/bin/exiftool"
    private static var exifToolPath = "/Users/hlemai/Dev/next/common/ext/exiftool/exiftool"

    public static func read(fromurl:URL) -> ExifTool {
        let exif = ExifTool(filepath:fromurl.path)
        exif.fillMetataData()
        return exif
    }

    public static func setExifTool(_ path:String) {
        exifToolPath = path
    }

    let filepath:String

    var metadatas:[String:String]

    private init(filepath:String) {
        self.filepath=filepath
        self.metadatas = [:] 
    }


    private func fillMetataData() {
        metadatas["FilePath"]=filepath

        let task = Process()
        task.executableURL=URL(fileURLWithPath: ExifTool.exifToolPath)
        task.arguments = [filepath]
        let outputPipe = Pipe()
        task.standardOutput = outputPipe
         
        do {
            try task.run()
        }
        catch {
            print("ERROR")
            task.terminate()
        }

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(decoding: outputData, as: UTF8.self)        
        
        for lines in output.split(separator: "\n") {
            let cols = lines.split(separator: ":")
            let key = String(cols[0]).trimmingCharacters(in: .whitespacesAndNewlines)
            metadatas[key]=String(cols[1]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    subscript(string:String) -> String? {
        get {
            metadatas[string]
        }
        set(newValue) {
            metadatas[string] = newValue
        }
    }
}
