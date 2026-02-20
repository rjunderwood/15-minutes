import SwiftUI
import SwiftData

struct AppPickerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var blockedApps: [BlockedApp]

    @State private var searchText = ""
    @State private var installedApps: [AppInfo] = []
    @State private var manualBundleID = ""
    @State private var manualAppName = ""
    @State private var showingManualEntry = false

    private var blockedBundleIDs: Set<String> {
        Set(blockedApps.map { $0.bundleIdentifier })
    }

    private var filteredApps: [AppInfo] {
        if searchText.isEmpty { return installedApps }
        return installedApps.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.id.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Add Blocked App")
                    .font(.title3.weight(.semibold))
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            }
            .padding(16)

            HStack {
                TextField("Search apps...", text: $searchText)
                    .textFieldStyle(.roundedBorder)

                Button {
                    showingManualEntry.toggle()
                } label: {
                    Image(systemName: "keyboard")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .help("Enter bundle ID manually")
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)

            if showingManualEntry {
                manualEntryView
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
            }

            Divider()

            List(filteredApps) { app in
                HStack {
                    if let icon = app.icon {
                        Image(nsImage: icon)
                            .resizable()
                            .frame(width: 24, height: 24)
                    } else {
                        Image(systemName: "app.fill")
                            .frame(width: 24, height: 24)
                    }

                    VStack(alignment: .leading) {
                        Text(app.name)
                            .font(.body)
                        Text(app.id)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }

                    Spacer()

                    if blockedBundleIDs.contains(app.id) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else {
                        Button("Block") {
                            addBlockedApp(appInfo: app)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
            }
        }
        .frame(width: 450, height: 500)
        .onAppear {
            Task.detached(priority: .userInitiated) {
                let apps = InstalledAppsProvider.getInstalledApps()
                await MainActor.run {
                    installedApps = apps
                }
            }
        }
    }

    private var manualEntryView: some View {
        VStack(spacing: 8) {
            TextField("Bundle ID (e.g. com.google.Chrome)", text: $manualBundleID)
                .textFieldStyle(.roundedBorder)
            TextField("App Name", text: $manualAppName)
                .textFieldStyle(.roundedBorder)
            Button("Add") {
                let app = BlockedApp(bundleIdentifier: manualBundleID, appName: manualAppName)
                modelContext.insert(app)
                manualBundleID = ""
                manualAppName = ""
                showingManualEntry = false
            }
            .disabled(manualBundleID.isEmpty || manualAppName.isEmpty)
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.controlBackgroundColor)))
    }

    private func addBlockedApp(appInfo: AppInfo) {
        var iconData: Data?
        if let icon = appInfo.icon {
            if let tiffData = icon.tiffRepresentation,
               let bitmapRep = NSBitmapImageRep(data: tiffData) {
                iconData = bitmapRep.representation(using: .png, properties: [:])
            }
        }
        let blocked = BlockedApp(
            bundleIdentifier: appInfo.id,
            appName: appInfo.name,
            iconData: iconData
        )
        modelContext.insert(blocked)
    }
}
