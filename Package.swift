// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PhoneNumberKitSwiftUI",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PhoneNumberKitSwiftUI",
            targets: ["PhoneNumberKitSwiftUI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/PhoneNumberKit/PhoneNumberKit", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "PhoneNumberKitSwiftUI",
            dependencies: [
                .product(name: "PhoneNumberKit", package: "PhoneNumberKit")
            ],
            path: "Sources/PhoneNumberKitSwiftUI"
        )
    ]
)
