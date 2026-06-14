import Foundation

/// Whether a store is open right now, derived from its weekly opening hours.
enum OpenState {
    case open
    case closed
    case unknown   // no hours on file

    var label: String {
        switch self {
        case .open: return String(localized: "営業中")
        case .closed: return String(localized: "営業時間外")
        case .unknown: return String(localized: "時間未掲載")
        }
    }

    var isOpen: Bool { self == .open }
}

enum OpenStatus {
    /// Backend weekday convention is 0 = Sunday … 6 = Saturday. Close times that
    /// are ≤ the open time are treated as crossing midnight (e.g. 23:00–02:00).
    static func now(_ hours: [OpeningHour], at date: Date = Date(), calendar: Calendar = .current) -> OpenState {
        guard !hours.isEmpty else { return .unknown }
        let comps = calendar.dateComponents([.weekday, .hour, .minute], from: date)
        guard let weekday = comps.weekday, let hour = comps.hour, let minute = comps.minute else {
            return .unknown
        }
        let today = weekday - 1                 // Calendar: 1=Sun → backend 0=Sun
        let yesterday = (today + 6) % 7
        let nowMinutes = hour * 60 + minute

        for slot in hours {
            guard let open = minutes(slot.open), let close = minutes(slot.close) else { continue }
            let crossesMidnight = close <= open

            if slot.day == today {
                if crossesMidnight {
                    if nowMinutes >= open { return .open }            // before midnight
                } else if nowMinutes >= open && nowMinutes < close {
                    return .open
                }
            }
            // A slot that opened yesterday and runs past midnight into today.
            if slot.day == yesterday && crossesMidnight && nowMinutes < close {
                return .open
            }
        }
        return .closed
    }

    private static func minutes(_ hhmm: String) -> Int? {
        let digits = hhmm.filter(\.isNumber)
        guard digits.count == 4, let value = Int(digits) else { return nil }
        return (value / 100) * 60 + (value % 100)
    }
}
