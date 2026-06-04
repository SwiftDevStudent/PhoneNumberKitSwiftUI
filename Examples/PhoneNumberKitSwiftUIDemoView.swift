import SwiftUI
import PhoneNumberKitSwiftUI

public struct PhoneNumberKitSwiftUIDemoView: View {
    @State private var store = PhoneNumberStore(
        withPrefix: true,
        withPrefixPrefill: true,
        withFlag: true,
        withExamplePlaceholder: true
    )

    private var isClearDisabled: Bool {
        store.text.isEmpty && store.rawDigits.isEmpty
    }

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    PhoneNumberField(store: store, title: "Phone number")
                } header: {
                    Text("Phone Number")
                } footer: {
                    Text(store.isValidNumber ? "Valid phone number" : "Enter a valid phone number")
                        .font(.footnote)
                        .foregroundStyle(store.isValidNumber ? .green : .secondary)
                }

                Section("Controls") {
                    Toggle("Show country picker flag", isOn: $store.withFlag)
                    Toggle("Use international prefix", isOn: $store.withPrefix)
                    Toggle("Prefill prefix on focus", isOn: $store.withPrefixPrefill)
                    Toggle("Show example placeholder", isOn: $store.withExamplePlaceholder)
                }

                Section("Current value") {
                    LabeledContent("Region", value: store.currentRegion)
                    LabeledContent("Formatted", value: store.text.isEmpty ? "Empty" : store.text)
                    LabeledContent("Raw digits", value: store.rawDigits.isEmpty ? "Empty" : store.rawDigits)
                    LabeledContent("National", value: store.nationalNumber.isEmpty ? "Empty" : store.nationalNumber)
                }
            }
            .navigationTitle("PhoneNumberKitSwiftUI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Demo") {
                        store.setExampleNumber()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Clear") {
                        store.setProgrammaticRawDigits("")
                    }
                    .disabled(isClearDisabled)
                }
            }
        }
    }
}

#Preview {
    PhoneNumberKitSwiftUIDemoView()
}
