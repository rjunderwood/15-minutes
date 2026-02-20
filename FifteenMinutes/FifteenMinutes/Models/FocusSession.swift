import Foundation
import SwiftData

@Model
final class FocusSession {
    var id: UUID
    var startTime: Date
    var endTime: Date?
    var workDescription: String
    var durationSeconds: Int

    init(startTime: Date = .now, durationSeconds: Int = 900) {
        self.id = UUID()
        self.startTime = startTime
        self.durationSeconds = durationSeconds
        self.workDescription = ""
    }

    var isCompleted: Bool {
        endTime != nil && !workDescription.isEmpty
    }
}
