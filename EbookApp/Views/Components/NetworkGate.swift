import SwiftUI

struct NetworkGate<Content: View>: View {
    @ObservedObject var networkMonitor: NetworkMonitor
    @ViewBuilder var content: () -> Content

    @State private var showAlert = false
    @State private var didCheckLaunchNetwork = false

    var body: some View {
        content()
            .onAppear {
                guard !didCheckLaunchNetwork else { return }
                didCheckLaunchNetwork = true
                if !networkMonitor.isConnected {
                    showAlert = true
                }
            }
            .alert("무료 한국문학집", isPresented: $showAlert) {
                Button("확인", role: .cancel) {
                    exit(0)
                }
            } message: {
                Text("네트워크 연결을 확인해 주세요.")
            }
    }
}
