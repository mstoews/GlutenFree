import Foundation

enum Formatters {
    private static let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    /// 0 = Sunday … 6 = Saturday.
    static func weekday(_ day: Int) -> String {
        guard day >= 0 && day < weekdays.count else { return "?" }
        return weekdays[day]
    }

    /// "1100" -> "11:00".
    static func clock(_ hhmm: String) -> String {
        let digits = hhmm.filter(\.isNumber)
        guard digits.count == 4 else { return hhmm }
        return "\(digits.prefix(2)):\(digits.suffix(2))"
    }

    static func yen(_ amount: Int) -> String {
        "¥\(amount.formatted(.number.grouping(.automatic)))"
    }

    /// ISO-8601 string -> medium localized date, or the raw string on failure.
    static func date(_ iso: String?) -> String? {
        guard let iso else { return nil }
        let parser = ISO8601DateFormatter()
        parser.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = parser.date(from: iso) ?? ISO8601DateFormatter().date(from: iso)
        guard let date else { return iso }
        return date.formatted(date: .abbreviated, time: .omitted)
    }
}
