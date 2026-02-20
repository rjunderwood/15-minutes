import AppKit

struct AppInfo: Identifiable, Hashable {
    let id: String // bundle identifier
    let name: String
    let icon: NSImage?
    let bundleURL: URL

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: AppInfo, rhs: AppInfo) -> Bool {
        lhs.id == rhs.id
    }
}

final class InstalledAppsProvider {
    static func getInstalledApps() -> [AppInfo] {
        var seen = Set<String>()
        var apps: [AppInfo] = []

        let directories = [
            URL(fileURLWithPath: "/Applications"),
            URL(fileURLWithPath: "/System/Applications"),
            URL(fileURLWithPath: "/System/Cryptexes/App/System/Applications"),
            URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Applications")
        ]

        for directory in directories {
            for app in scanDirectory(directory) {
                if seen.insert(app.id).inserted {
                    apps.append(app)
                }
            }
        }

        // Also pick up any running apps not found via filesystem scan
        for runningApp in NSWorkspace.shared.runningApplications {
            guard let bundleID = runningApp.bundleIdentifier,
                  let bundleURL = runningApp.bundleURL,
                  !seen.contains(bundleID) else { continue }
            let name = runningApp.localizedName ?? bundleURL.deletingPathExtension().lastPathComponent
            let icon = runningApp.icon
            apps.append(AppInfo(id: bundleID, name: name, icon: icon, bundleURL: bundleURL))
            seen.insert(bundleID)
        }

        return apps
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    private static func scanDirectory(_ url: URL) -> [AppInfo] {
        var results: [AppInfo] = []

        guard let contents = try? FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else { return results }

        for item in contents {
            if item.pathExtension == "app" {
                if let appInfo = appInfoFromBundle(at: item) {
                    results.append(appInfo)
                }
            } else if item.hasDirectoryPath {
                results.append(contentsOf: scanDirectory(item))
            }
        }

        return results
    }

    private static func appInfoFromBundle(at url: URL) -> AppInfo? {
        guard let bundle = Bundle(url: url),
              let bundleID = bundle.bundleIdentifier else { return nil }

        let name = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? url.deletingPathExtension().lastPathComponent

        let icon = NSWorkspace.shared.icon(forFile: url.path)

        return AppInfo(id: bundleID, name: name, icon: icon, bundleURL: url)
    }
}
