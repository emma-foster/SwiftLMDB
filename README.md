# SwiftLMDB

This is a fork of [agisboye/SwiftLMDB](https://github.com/agisboye/SwiftLMDB) but the functionality has been altered to better suit its purpose in an internal project.

## Features

- [x] Small and lightweight
- [x] Fast
- [x] Unit tested
- [x] Xcode documentation
- [x] Cross platform

SwiftLMDB has been tested on iOS and macOS, however it should also run on Linux. Feel free to test it out.

## Requirements

- iOS 11.0+ or macOS 10.11+
- Swift 4.1

## Installation

### Swift Package Manager

```swift
// swift-tools-version:4.0

import PackageDescription

let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/jernejstrasner/SwiftLMDB.git", .branch("master"))
    ],
    ...
)
```

## Usage

Start by importing the module.
```swift
import SwiftLMDB
```

### Creating a database
Databases are contained within an environment. An environment may contain multiple databases, each identified by their name.
```swift
let environment: Environment
let database: Database

do {
    // The folder in which the environment is opened must already exist.
    try FileManager.default.createDirectory(at: envURL, withIntermediateDirectories: true, attributes: nil)

    environment = try Environment(path: envURL.path, flags: [], maxDBs: 32)
    database = try environment.openDatabase(named: "db1", flags: [.create])

} catch {
    print(error)
}

```

### Put a value

```swift
do {
    let val = "Hello World!".data(using: .utf8)
    ley key = "key1".data(using: .utf8)
    try database.put(value: val, forKey: key)
} catch {
    print(error)
}
```

### Get a value

```swift
do {
    ley key = "key1".data(using: .utf8)
    if let value = try database.get(forKey: key) {
        // Data
    }
} catch {
    print(error)
}
```

### Delete a value

```swift
do {
    ley key = "key1".data(using: .utf8)
    try database.deleteValue(forKey: key)
} catch {
    print(error)
}
```

## Contributing

Contributions are very welcome. Open an issue or submit a pull request.

## License

SwiftLMDB is available under the MIT license. See the LICENSE file for more info.
LMDB is licensen under the [OpenLDAP Public License](http://www.openldap.org/software/release/license.html).
