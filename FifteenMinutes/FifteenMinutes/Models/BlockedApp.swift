import Foundation
import SwiftData

@Model
final class BlockedApp {
    var id: UUID
    var bundleIdentifier: String
    var appName: String
    var iconData: Data?

    init(bundleIdentifier: String, appName: String, iconData: Data? = nil) {
        self.id = UUID()
        self.bundleIdentifier = bundleIdentifier
        self.appName = appName
        self.iconData = iconData
    }
}
