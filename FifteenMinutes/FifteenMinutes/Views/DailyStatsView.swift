import SwiftUI
import SwiftData

struct DailyStatsView: View {
    @Query(filter: #Predicate<FocusSession> { session in
        session.endTime != nil
    }, sort: \FocusSession.startTime, order: .reverse)
    private var allSessions: [FocusSession]

    private var todaySessions: [FocusSession] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        return allSessions.filter { $0.startTime >= startOfDay }
    }

    private var totalMinutesToday: Int {
        todaySessions.reduce(0) { $0 + $1.durationSeconds } / 60
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            sessionList
        }
        .frame(minWidth: 400, idealWidth: 400, maxWidth: 400, minHeight: 300, maxHeight: 500)
    }

    private var header: some View {
        HStack(spacing: 24) {
            statBox(value: "\(todaySessions.count)", label: "Sessions")
            statBox(value: "\(totalMinutesToday)", label: "Minutes")
        }
        .padding(20)
    }

    private func statBox(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 36, weight: .bold, design: .rounded))
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var sessionList: some View {
        Group {
            if todaySessions.isEmpty {
                ContentUnavailableView(
                    "No Sessions Today",
                    systemImage: "clock",
                    description: Text("Start a focus session to see your progress here.")
                )
            } else {
                List(todaySessions) { session in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(session.startTime, style: .time)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(session.durationSeconds / 60) min")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        if !session.workDescription.isEmpty {
                            Text(session.workDescription)
                                .font(.body)
                                .lineLimit(3)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}
