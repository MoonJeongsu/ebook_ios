import Foundation

enum QueryNormalizer {
    static func normalize(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\([^)]*\\)", with: "", options: .regularExpression)
            .replacingOccurrences(of: "[\\s_\\-·\\[\\]「」『』\"'.,!?]", with: "", options: .regularExpression)
            .lowercased()
    }
}
