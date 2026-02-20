import SwiftUI
import SwiftData

struct SessionLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    var timerManager: TimerManager

    @State private var workDescription = ""

    @Query(filter: #Predicate<FocusSession> { session in
        session.endTime != nil
    }, sort: \FocusSession.startTime, order: .reverse)
    private var completedSessions: [FocusSession]

    private var previousDescription: String? {
        completedSessions.first?.workDescription
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.title2)
                Text("What did you accomplish?")
                    .font(.title3.weight(.semibold))
            }

            TextEditor(text: $workDescription)
                .font(.body)
                .frame(minHeight: 100)
                .scrollContentBackground(.hidden)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.textBackgroundColor))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.separatorColor), lineWidth: 1)
                )

            if let previous = previousDescription, !previous.isEmpty {
                Button {
                    workDescription = previous
                } label: {
                    Label("Same as Previous Session", systemImage: "doc.on.doc")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }

            HStack {
                Spacer()
                Button("Save") {
                    timerManager.completeLog(description: workDescription, modelContext: modelContext)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(workDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .keyboardShortcut(.return, modifiers: .command)
            }
        }
        .padding(20)
        .frame(width: 400, height: 280)
    }
}
