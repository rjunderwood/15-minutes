import SwiftUI
import SwiftData
import ServiceManagement

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \BlockedApp.appName) private var blockedApps: [BlockedApp]
    @State private var showingAppPicker = false
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Toggle("Launch at Login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, newValue in
                        do {
                            if newValue {
                                try SMAppService.mainApp.register()
                            } else {
                                try SMAppService.mainApp.unregister()
                            }
                        } catch {
                            launchAtLogin = SMAppService.mainApp.status == .enabled
                        }
                    }
            }
            .padding(16)

            Divider()

            HStack {
                Text("Blocked Apps")
                    .font(.title3.weight(.semibold))
                Spacer()
                Button {
                    showingAppPicker = true
                } label: {
                    Label("Add App", systemImage: "plus")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding(16)

            Divider()

            if blockedApps.isEmpty {
                ContentUnavailableView(
                    "No Blocked Apps",
                    systemImage: "app.dashed",
                    description: Text("Add apps that distract you during focus sessions.")
                )
            } else {
                List {
                    ForEach(blockedApps) { app in
                        HStack {
                            if let iconData = app.iconData,
                               let nsImage = NSImage(data: iconData) {
                                Image(nsImage: nsImage)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            } else {
                                Image(systemName: "app.fill")
                                    .frame(width: 24, height: 24)
                            }

                            VStack(alignment: .leading) {
                                Text(app.appName)
                                    .font(.body)
                                Text(app.bundleIdentifier)
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }

                            Spacer()

                            Button(role: .destructive) {
                                modelContext.delete(app)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
        }
        .frame(minWidth: 400, idealWidth: 400, maxWidth: 400, minHeight: 300, maxHeight: 500)
        .sheet(isPresented: $showingAppPicker) {
            AppPickerView()
        }
    }
}
