import Foundation
import PhoneNumberKit

/// Observable state and formatting options for ``PhoneNumberField``.
@Observable
public final class PhoneNumberStore {
    let utility: PhoneNumberUtility
    let partialFormatter: PartialFormatter
    
    /// The national number digits, without the current country calling code.
    public var rawDigits: String
    /// The formatted text displayed in the field.
    public var text: String
    
    /// Enables PhoneNumberKit partial formatting while the user types.
    public var isPartialFormatterEnabled: Bool
    /// The maximum number of national digits allowed.
    public var maxDigits: Int?
    
    /// Shows and formats the international calling code.
    public var withPrefix: Bool {
        didSet {
            guard oldValue != withPrefix else { return }
            partialFormatter.withPrefix = withPrefix
            rawDigits = nationalDigits(from: text)
            text = formattedText(for: rawDigits)
        }
    }
    /// Prefills the current region prefix when the field receives focus.
    public var withPrefixPrefill: Bool
    /// Shows a flag button that opens the country picker.
    public var withFlag: Bool
    /// Uses PhoneNumberKit example numbers as the placeholder.
    public var withExamplePlaceholder: Bool
    /// The example and validation type used by PhoneNumberKit.
    public var ofType: PhoneNumberType
    
    var isPickerPresented: Bool = false
    
    public var error: Bool = false
    
    private var defaultRegionCode: String
    
    /// Creates a phone number store.
    /// - Parameters:
    ///   - rawDigits: Initial national number digits.
    ///   - utility: The PhoneNumberKit utility used for parsing, formatting, and metadata.
    ///   - defaultRegion: The initial ISO region code.
    ///   - withPrefix: Whether international prefix formatting is enabled.
    ///   - withPrefixPrefill: Whether to prefill the prefix on focus.
    ///   - withFlag: Whether to show the country picker flag button.
    ///   - withExamplePlaceholder: Whether to show an example number placeholder.
    ///   - ofType: The PhoneNumberKit number type used for examples.
    ///   - maxDigits: Optional maximum national digit count.
    ///   - isPartialFormatterEnabled: Whether to format as the user types.
    public init(rawDigits: String = "", utility: PhoneNumberUtility = PhoneNumberUtility(), defaultRegion: String = PhoneNumberUtility.defaultRegionCode(), withPrefix: Bool = true, withPrefixPrefill: Bool = false, withFlag: Bool = false, withExamplePlaceholder: Bool = true, ofType: PhoneNumberType = .mobile, maxDigits: Int? = nil, isPartialFormatterEnabled: Bool = true) {
        self.utility = utility
        self.defaultRegionCode = defaultRegion
        self.withPrefix = withPrefix
        self.withPrefixPrefill = withPrefixPrefill
        self.withFlag = withFlag
        self.withExamplePlaceholder = withExamplePlaceholder
        self.ofType = ofType
        self.maxDigits = maxDigits
        self.isPartialFormatterEnabled = isPartialFormatterEnabled
        self.rawDigits = rawDigits
        
        let formatter = PartialFormatter(utility: utility, defaultRegion: defaultRegion, withPrefix: withPrefix, ignoreIntlNumbers: true)
        formatter.maxDigits = maxDigits
        self.partialFormatter = formatter
        
        self.text = isPartialFormatterEnabled ? formatter.formatPartial(rawDigits) : rawDigits
    }
    
    /// The current ISO region code inferred by the formatter.
    public var currentRegion: String { partialFormatter.currentRegion }
    
    /// The current national number without country calling code or formatting separators.
    public var nationalNumber: String {
        let raw = text
        return partialFormatter.nationalNumber(from: raw)
    }
    
    /// A Boolean value indicating whether PhoneNumberKit can parse the current text.
    public var isValidNumber: Bool {
        do {
            _ = try utility.parse(text, withRegion: currentRegion)
            return true
        } catch {
            return false
        }
    }
    
    /// The parsed PhoneNumberKit value, or `nil` when the current text is invalid.
    public var phoneNumber: PhoneNumber? {
        do {
            return try utility.parse(text, withRegion: currentRegion)
        } catch {
            return nil
        }
    }
    
    /// The flag emoji for the current region.
    public var flagEmoji: String {
        let base: UInt32 = 127397
        return currentRegion.uppercased().unicodeScalars.compactMap { UnicodeScalar(base + $0.value).map { String($0) } }.joined()
    }
    
    /// Returns the current region's formatted example placeholder.
    public func examplePlaceholder() -> String? {
        guard withExamplePlaceholder else { return nil }
        let format: PhoneNumberFormat = withPrefix ? .international : .national
        return utility.getFormattedExampleNumber(forCountry: currentRegion, ofType: ofType, withFormat: format, withPrefix: withPrefix)
    }
    
    /// Updates the store from user-entered text.
    public func updateFromUserInput(_ newText: String) {
        guard isPartialFormatterEnabled else {
            text = newText
            rawDigits = newText.filter { $0.isNumber }
            return
        }
        
        let digits = nationalDigits(from: newText)
        if let maxDigits, digits.count > maxDigits { return }
        
        rawDigits = digits
        let formatted = formattedText(for: digits, source: newText)
        if formatted != text {
            text = formatted
        }
        error = false
    }
    
    /// Sets the current national digits programmatically.
    public func setProgrammaticRawDigits(_ digits: String) {
        let cleaned = digits.filter { $0.isNumber }
        if let maxDigits, cleaned.count > maxDigits {
            rawDigits = String(cleaned.prefix(maxDigits))
        } else {
            rawDigits = cleaned
        }
        if isPartialFormatterEnabled {
            text = formattedText(for: rawDigits)
        } else {
            text = rawDigits
        }
        error = false
    }

    /// Sets the field to PhoneNumberKit's example number for the current region and number type.
    public func setExampleNumber() {
        guard let example = utility.getExampleNumber(forCountry: currentRegion, ofType: ofType) else { return }
        let format: PhoneNumberFormat = withPrefix ? .international : .national
        let formatted = utility.format(example, toType: format, withPrefix: withPrefix)
        text = formatted
        rawDigits = nationalDigits(from: formatted)
        error = false
    }

    /// Prefills the current region prefix when prefix prefill is enabled.
    public func applyPrefixPrefillIfNeeded() {
        guard withPrefix, withPrefixPrefill, text.isEmpty else { return }
        if let code = utility.countryCode(for: currentRegion)?.description {
            text = "+" + code + " "
        }
    }
    
    /// Clears the field if it only contains the current region prefix.
    public func clearIfOnlyPrefix() {
        guard withPrefix else { return }
        if let code = utility.countryCode(for: currentRegion)?.description {
            let prefix = "+" + code
            if text == prefix || text == prefix + " " {
                text = ""
                rawDigits = ""
            }
        }
    }
    
    func selectCountry(code: String) {
        guard let prefix = utility.countryCode(for: code)?.description else { return }
        defaultRegionCode = code
        partialFormatter.defaultRegion = code
        if rawDigits.isEmpty && withPrefix {
            text = "+" + prefix + " "
        } else {
            text = formattedText(for: rawDigits)
        }
    }

    private func nationalDigits(from source: String) -> String {
        let trimmed = source.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.hasPrefix("+"),
           let parsed = try? utility.parse(trimmed, withRegion: currentRegion, ignoreType: true) {
            if let region = utility.getRegionCode(of: parsed) {
                defaultRegionCode = region
                partialFormatter.defaultRegion = region
            }
            return (parsed.leadingZero ? "0" : "") + parsed.nationalNumber.description
        }

        return partialFormatter.nationalNumber(from: source).filter { $0.isNumber }
    }

    private func formattedText(for nationalDigits: String, source: String? = nil) -> String {
        guard !nationalDigits.isEmpty else {
            if let source, isOnlyCurrentPrefix(source) {
                return prefixText()
            }
            return ""
        }

        if withPrefix, let callingCode = utility.countryCode(for: currentRegion)?.description {
            return partialFormatter.formatPartial("+" + callingCode + nationalDigits)
        }

        return partialFormatter.formatPartial(nationalDigits)
    }

    private func isOnlyCurrentPrefix(_ source: String) -> Bool {
        source.trimmingCharacters(in: .whitespacesAndNewlines) == prefixText().trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func prefixText() -> String {
        guard withPrefix, let code = utility.countryCode(for: currentRegion)?.description else { return "" }
        return "+" + code + " "
    }
}
