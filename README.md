# ExifTool
<p align="center">
    <a href="https://github.com/hlemai/ExifTool/actions">
        <img src="https://github.com/hlemai/ExifTool/workflows/test/badge.svg" alt="Continuous Integration">
    </a>
</p>

Simple swiftWrapper to ExifTool (https://exiftool.org)

## Usage

Get all metadata in a [String:String] dictionnary.

```swift
ExifTool.setExifTool("/path/to/exiftool")
let testFilePath = "DSC04247.jpg"
let url = URL(fileURLWithPath: testFilePath)
let exifData = ExifTool.read(fromurl: url)

for meta in exifData {
    print("\(meta.key)->\(meta.value)")
}
```