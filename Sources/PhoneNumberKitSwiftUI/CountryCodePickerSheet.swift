import SwiftUI

struct CountryCodePickerSheet: View {
    @Bindable var store: PhoneNumberStore
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    private var filteredCountries: [CountryCodeOption] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return countries }
        
        return countries.filter { country in
            country.name.localizedStandardContains(query)
            || country.regionCode.localizedStandardContains(query)
            || country.callingCode.localizedStandardContains(query.filter { $0.isNumber })
        }
    }
    
    private var countries: [CountryCodeOption] {
        store.utility.allCountries()
            .filter { $0.count == 2 }
            .compactMap { regionCode in
                guard let callingCode = store.utility.countryCode(for: regionCode) else { return nil }
                return CountryCodeOption(regionCode: regionCode, callingCode: callingCode.description)
            }
            .sorted { lhs, rhs in
                lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
            }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredCountries) { country in
                Button {
                    store.selectCountry(code: country.regionCode)
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        Text(country.flagEmoji)
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(country.name)
                                .foregroundStyle(.primary)
                            
                            Text("+\(country.callingCode) \(country.regionCode)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if country.regionCode == store.currentRegion {
                            Image(systemName: "checkmark")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.tint)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Country Code")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct CountryCodeOption: Identifiable {
    let regionCode: String
    let callingCode: String
    
    var id: String { regionCode }
    
    var name: String {
        Locale.current.localizedString(forRegionCode: regionCode) ?? regionCode
    }
    
    var flagEmoji: String {
        let base: UInt32 = 127397
        return regionCode.uppercased().unicodeScalars.compactMap { scalar in
            UnicodeScalar(base + scalar.value).map { String($0) }
        }.joined()
    }
}
