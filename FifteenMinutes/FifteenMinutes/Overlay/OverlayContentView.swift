import SwiftUI

struct OverlayContentView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.85)

            VStack(spacing: 20) {
                Image(systemName: "eye.slash.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.white.opacity(0.8))

                Text("Focus Session in Progress")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(.white)

                Text("This app is blocked. Switch to another app to continue working.")
                    .font(.system(size: 18))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)

                Text("Press \u{2318}+Tab to switch apps")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.top, 8)
            }
            .padding(40)
        }
        .ignoresSafeArea()
    }
}
