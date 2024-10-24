import Flutter
import FlutterPluginRegistrant
import SwiftUI

class FlutterDependencies: ObservableObject {
    let flutterEngine = FlutterEngine(name: "flutter-engine")
    init() {
        flutterEngine.run()
        // If you added a plugin to Flutter module, you also need to register plugin to flutter engine
        GeneratedPluginRegistrant.register(with: self.flutterEngine)
    }
}

@main
struct iOSCounterApp: App {
    @StateObject var flutterDependencies = FlutterDependencies()

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(flutterDependencies)
        }
    }
}
