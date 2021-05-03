    import XCTest
    @testable import ExifTool

    final class ExifToolTests: XCTestCase {
        func testGoodImage() {
            var testFilePath:String
            if let filepath = Bundle.module.pathForImageResource("DSC04247.jpg") {
                testFilePath = filepath
            } else {
                testFilePath = "/Users/hlemai/Dev/next/common/ExifTool/Tests/ExifToolTests/Resources/DSC04247.jpg"
            }
            
            let url = URL(fileURLWithPath: testFilePath)
            let exifData = ExifTool.read(fromurl: url)
            XCTAssert(exifData["FilePath"]==testFilePath)
            XCTAssert(exifData["File Type"]=="JPEG")
            XCTAssert(exifData.count == 280)
        }
        func testBadImage() {
            var testFilePath:String
            if let filepath = Bundle.module.pathForImageResource("fakeimage.txt.jpg") {
                testFilePath = filepath
            } else {
                testFilePath = "/Users/hlemai/Dev/next/common/ExifTool/Tests/ExifToolTests/Resources/fakeimage.txt.jpg"
            }
            let url = URL(fileURLWithPath: testFilePath)
            let exifData = ExifTool.read(fromurl: url)
            XCTAssert(exifData["FilePath"]==testFilePath)
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
            let exifData = ExifTool.read(fromurl: url)
            XCTAssert(exifData["FilePath"]==testFilePath)
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
            let exifData = ExifTool.read(fromurl: url)
            ExifTool.setExifTool(backup)
            XCTAssert(exifData["FilePath"]==testFilePath)
            XCTAssert(exifData["File Type"]==nil)
        }
    }
