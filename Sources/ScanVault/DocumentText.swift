import Foundation

enum DocumentText {
    static func normalize(_ text: String) -> String {
        let lines = text
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .components(separatedBy: "\n")
            .map { line in
                line.split(whereSeparator: { $0.isWhitespace }).joined(separator: " ")
            }
            .filter { !$0.isEmpty }
        return lines.joined(separator: "\n")
    }

    static func generateTitle(from text: String, fallback: String = "Untitled Scan") -> String {
        let normalized = normalize(text)
        guard let firstLine = normalized.split(separator: "\n").first else {
            return fallback
        }
        let candidate = String(firstLine).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !candidate.isEmpty else {
            return fallback
        }
        let limit = 48
        return candidate.count > limit ? String(candidate.prefix(limit - 1)) + "…" : candidate
    }

    static func snippet(from text: String, limit: Int = 120) -> String {
        let normalized = normalize(text)
        guard normalized.count > limit else {
            return normalized
        }
        return String(normalized.prefix(limit - 1)) + "…"
    }

    static func matches(title: String, recognizedText: String, query: String) -> Bool {
        let needle = normalize(query).lowercased()
        guard !needle.isEmpty else {
            return true
        }
        return normalize(title).lowercased().contains(needle)
            || normalize(recognizedText).lowercased().contains(needle)
    }
}
