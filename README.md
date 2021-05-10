# ExifTool
<p align="left">
    <a href="LICENSE">
        <img src="https://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
    </a> <!--
    <a href="https://github.com/hlemai/ExifTool/actions">
        <img src="https://github.com/hlemai/ExifTool/workflows/test/badge.svg" alt="Continuous Integration">
    </a> -->
</p>

Simple swiftWrapper to ExifTool (https://exiftool.org)

## Requirements

- iOS 14.0+ / macOS 11+ / tvOS 14.0+ 
- Xcode 12+
- Swift 5.3+


### Installation with Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. 

Once you have your Swift package set up, adding SunburstDiagram as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/hlemai/ExifTool.git")
]
```

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