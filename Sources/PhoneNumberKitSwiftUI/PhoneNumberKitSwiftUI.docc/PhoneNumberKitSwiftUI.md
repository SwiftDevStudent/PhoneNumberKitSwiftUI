# ``PhoneNumberKitSwiftUI``

Build SwiftUI phone number fields with PhoneNumberKit formatting, validation, country selection, and example placeholders.

## Overview

PhoneNumberKitSwiftUI gives iOS apps a focused phone number input component backed by PhoneNumberKit. It handles partial formatting while users type, validates the current number, supports optional international prefixes and prefix prefill, and can show a searchable country picker with flag selection.

PhoneNumberKitSwiftUI provides two primary types:

- ``PhoneNumberField``: A SwiftUI field for entering and formatting phone numbers.
- ``PhoneNumberStore``: The observable state object that owns formatting options, raw digits, validation, and the parsed PhoneNumberKit value.

Create a store with the behavior you want, then pass it to the field:

```swift
import SwiftUI
import PhoneNumberKitSwiftUI

struct ContentView: View {
    @State private var phoneStore = PhoneNumberStore(
        withPrefix: true,
        withPrefixPrefill: true,
        withFlag: true
    )

    var body: some View {
        PhoneNumberField(store: phoneStore, title: "Phone number")
    }
}
```

Use the store to read the field state:

```swift
phoneStore.text
phoneStore.rawDigits
phoneStore.currentRegion
phoneStore.isValidNumber
phoneStore.phoneNumber
```

## Topics

### Views

- ``PhoneNumberField``

### State

- ``PhoneNumberStore``
