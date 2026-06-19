import Foundation

enum Formatters {
    /// Localized full weekday name for the current locale.
    /// 0 = Sunday … 6 = Saturday (matches the backend convention).
    /// ja → "月曜日", en → "Monday".
    static func weekday(_ day: Int, locale: Locale = .current) -> String {
        guard (0..<7).contains(day) else { return "" }
        let formatter = DateFormatter()
        formatter.locale = locale
        let symbols = formatter.standaloneWeekdaySymbols ?? formatter.weekdaySymbols ?? []
        return day < symbols.count ? symbols[day] : ""
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
    static func date(_ iso: String?, locale: Locale = .current) -> String? {
        guard let iso else { return nil }
        let parser = ISO8601DateFormatter()
        parser.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = parser.date(from: iso) ?? ISO8601DateFormatter().date(from: iso)
        guard let date else { return iso }
        return date.formatted(Date.FormatStyle(date: .abbreviated, time: .omitted).locale(locale))
    }
}
