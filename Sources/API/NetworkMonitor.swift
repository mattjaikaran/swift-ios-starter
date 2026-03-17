import Foundation
import Network
import Combine

/// Connection type representing the current network interface
public enum ConnectionType: String, Sendable {
    case wifi
    case cellular
    case wired
    case unknown
}

/// Monitors network connectivity using NWPathMonitor
@MainActor
public final class NetworkMonitor: ObservableObject {
    public static let shared = NetworkMonitor()

    @Published public private(set) var isConnected: Bool = true
    @Published public private(set) var connectionType: ConnectionType = .unknown

    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "com.myapp.networkmonitor")

    private init() {
        startMonitoring()
    }

    deinit {
        monitor.cancel()
    }

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.isConnected = path.status == .satisfied
                self.connectionType = self.resolveConnectionType(path)
            }
        }
        monitor.start(queue: monitorQueue)
    }

    private func resolveConnectionType(_ path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) {
            return .wifi
        } else if path.usesInterfaceType(.cellular) {
            return .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            return .wired
        } else {
            return .unknown
        }
    }
}
