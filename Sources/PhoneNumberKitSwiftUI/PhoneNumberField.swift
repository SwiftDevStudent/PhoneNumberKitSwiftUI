import SwiftUI

/// A SwiftUI phone number input field backed by ``PhoneNumberStore``.
public struct PhoneNumberField: View {
    @Bindable var store: PhoneNumberStore
    var title: String = ""
    @FocusState private var isFocused: Bool
    
    /// Creates a phone number field.
    /// - Parameters:
    ///   - store: The observable store that owns text, formatting, validation, and options.
    ///   - title: The text field title used by SwiftUI.
    public init(store: PhoneNumberStore, title: String = "") {
        self.store = store
        self.title = title
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            if store.withFlag {
                Button {
                    store.isPickerPresented = true
                } label: {
                    Text(store.flagEmoji + " ")
                }
                .buttonStyle(.plain)

                Divider()
            }

            TextField(title, text: $store.text, prompt: placeholderView)
                .phoneFormat(store)
                .keyboardType(store.withPrefix ? .phonePad : .numberPad)
                .textContentType(.telephoneNumber)
                .autocorrectionDisabled()
                .focused($isFocused)
                .onChange(of: isFocused) {
                    isFocused ? store.applyPrefixPrefillIfNeeded() : store.clearIfOnlyPrefix()
                }
        }
        .sheet(isPresented: $store.isPickerPresented) {
            CountryCodePickerSheet(store: store)
        }
    }
    
    private var placeholderView: Text? {
        guard let example = store.examplePlaceholder(), store.text.isEmpty else { return nil }
        return Text(example)
    }
}
extension View {
    func phoneFormat(_ store: PhoneNumberStore) -> some View {
        onChange(of: store.text) { _, newValue in
            store.updateFromUserInput(newValue)
        }
        .keyboardType(store.withPrefix ? .phonePad : .numberPad)
        .textContentType(.telephoneNumber)
        .autocorrectionDisabled()
    }
}
