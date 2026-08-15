import SwiftUI

struct NetworkGate<Content: View>: View {
    @ObservedObject var networkMonitor: NetworkMonitor
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            content()

            if !networkMonitor.isConnected {
                AppTheme.background
                    .ignoresSafeArea()
                ErrorView(message: "네트워크 연결을 확인해 주세요.\n연결되면 자동으로 이어집니다.")
            }
        }
        .animation(.default, value: networkMonitor.isConnected)
    }
}
