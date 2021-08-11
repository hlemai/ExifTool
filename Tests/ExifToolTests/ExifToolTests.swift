    import XCTest
    @testable import ExifTool

    @available(macOS 11.00, *)
    final class ExifToolTests: XCTestCase {
        func testGoodImage() {
            var testFilePath:String
            if let filepath = Bundle.module.pathForImageResource("DSC04247.jpg") {
                testFilePath = filepath
            } else {
                testFilePath = "/Users/hlemai/Dev/next/common/ExifTool/Tests/ExifToolTests/Resources/DSC04247.jpg"
            }
            
            let url = URL(fileURLWithPath: testFilePath)
            let exifData = ExifTool.read(fromurl: url).getMetadata(lang: "en")
            XCTAssert(exifData["File Path"]==testFilePath)
            XCTAssert(exifData["File Type"]=="JPEG")
            XCTAssert(exifData.count == 258)
        }
        func testBadImage() {
            var testFilePath:String
            if let filepath = Bundle.module.pathForImageResource("fakeimage.txt.jpg") {
                testFilePath = filepath
            } else {
                testFilePath = "/Users/hlemai/Dev/next/common/ExifTool/Tests/ExifToolTests/Resources/fakeimage.txt.jpg"
            }
            let url = URL(fileURLWithPath: testFilePath)
            let exifData = ExifTool.read(fromurl: url).getMetadata(lang: "en")
            XCTAssert(exifData["File Path"]==testFilePath)
            XCTAssert(exifData["File Type"]=="TXT")
        }
        func testNoImage() {
            var testFilePath:String
            if let filepath = Bundle.module.pathForImageResource("fakeimage.arw") {
                testFilePath = filepath
            } else {
                testFilePath = "/Users/hlemai/Dev/next/common/ExifTool/Tests/ExifToolTests/Resources/fakeimage.arw"
            }
            let url = URL(fileURLWithPath: testFilePath)
            let exifData = ExifTool.read(fromurl: url).getMetadata(lang: "en")
            XCTAssert(exifData["File Path"]==testFilePath)
            XCTAssert(exifData["File Type"]==nil)
        }

        func testWithnoExifTool() {
            let backup = ExifTool.exifToolPath
            ExifTool.setExifTool("/path/to/fake")
            var testFilePath:String
            if let filepath = Bundle.module.pathForImageResource("DSC04247.jpg") {
                testFilePath = filepath
            } else {
                testFilePath = "/Users/hlemai/Dev/next/common/ExifTool/Tests/ExifToolTests/Resources/DSC04247.jpg"
            }
            let url = URL(fileURLWithPath: testFilePath)
            let exifData = ExifTool.read(fromurl: url).getMetadata(lang: "en")
            ExifTool.setExifTool(backup)
            XCTAssert(exifData["File Path"]==testFilePath)
            XCTAssert(exifData["File Type"]==nil)
        }
        func testDirectory() {
            var testFilePath:String
            let filepath = Bundle.module.bundlePath 
            testFilePath = filepath
            
            let url = URL(fileURLWithPath: testFilePath)
            let exifData = ExifTool.read(fromurl: url).getMetadata(lang: "en")
            XCTAssert(exifData["File Path"]==testFilePath)
            XCTAssert(exifData["File Type"]==nil)
        }
        func testRawAndfilteredMeta() {
            var testFilePath:String
            if let filepath = Bundle.module.pathForImageResource("_DSC5130.ARW") {
                testFilePath = filepath
            } else {
                testFilePath = "/Users/hlemai/Dev/next/common/ExifTool/Tests/ExifToolTests/Resources/_DSC5130.ARW"
            }
            
            let url = URL(fileURLWithPath: testFilePath)
            let exifData = ExifTool.read(fromurl: url,tags:["SequenceLength","FocusLocation"]).getMetadata(lang: "en")
            XCTAssert(exifData["ISO"] == nil)
            XCTAssert( (exifData["Sequence Length"] ?? "").starts(with: "1 "))
            XCTAssert(exifData.count == 3)
            

        }
    }
