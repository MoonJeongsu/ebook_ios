import SwiftUI

struct LoadingView: View {
    var body: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorView: View {
    let message: String
    var onRetry: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppTheme.onSurface)

            if let onRetry {
                Button("다시 시도", action: onRetry)
                    .foregroundStyle(AppTheme.primary)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptyStateView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.body)
            .multilineTextAlignment(.center)
            .foregroundStyle(AppTheme.onSurface.opacity(0.7))
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
