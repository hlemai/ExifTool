    import XCTest
    @testable import ExifTool

    final class ExifToolTests: XCTestCase {
        func testExample() {
            // This is an example of a functional test case.
            // Use XCTAssert and related functions to verify your tests produce the correct
            // results.
            let filepath = "/Users/hlemai/Pictures/DSC04247.jpg"
            let url = URL(fileURLWithPath: filepath)
            let exifData = ExifTool.read(fromurl: url)
            XCTAssert(exifData["FilePath"]==filepath)

            for meta in exifData.metadatas {
                print("key \(meta.key) -> \(meta.value)")
            }
        }
    }
