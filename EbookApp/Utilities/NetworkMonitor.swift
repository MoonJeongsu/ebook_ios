import Foundation
import Network

final class NetworkMonitor: ObservableObject {
    @Published private(set) var isConnected = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.moons.ebook.network-monitor")

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
        // start() 직후의 currentPath는 첫 콜백 전까지 unsatisfied로 보고될 수 있어
        // 여기서 동기로 읽으면 안 된다. 첫 pathUpdateHandler 콜백이 실제 상태를 반영한다.
    }

    deinit {
        monitor.cancel()
    }
}
