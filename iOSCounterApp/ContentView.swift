import FlutterPluginRegistrant
import SwiftUI
import Flutter

struct ViewDidLoadModifier: ViewModifier {
    @State private var viewDidLoad = false
    let action: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .onAppear {
                if viewDidLoad == false {
                    viewDidLoad = true
                    action?()
                }
            }
    }
}

extension View {
    func onViewDidLoad(perform action: (() -> Void)? = nil) -> some View {
        self.modifier(ViewDidLoadModifier(action: action))
    }
    
    func placeholder<Content: View>(
            when shouldShow: Bool,
            alignment: Alignment = .center,
            @ViewBuilder placeholder: () -> Content) -> some View {

            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
}

struct ContentView: View {
    // Flutter dependencies are passed in an EnvironmentObject.
    @EnvironmentObject var flutterDependencies: FlutterDependencies

    @State var counter = 0

    @State var flutterMethodChannel: FlutterMethodChannel?
    @State var viewDidLoad = false
    
    @State private var text: String = ""

    var body: some View {
        VStack {
            Text("Counter: \(counter)").font(.largeTitle)
            Button(action: {
                increaseCounter()
            }) {
                Text("Increase counter")
                    .font(.headline)
                    .padding()
                    .background(Color.yellow)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }.padding(.vertical, 8)

            Button(action: {
                sendTextToFlutter()
                showFlutter()
            }) {
                Text("Open Flutter View")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }.padding(.vertical, 10)
            
            TextField("", text: $text)
                .padding(20)
                .multilineTextAlignment(.center)
                .placeholder(when: text.isEmpty) {
                    Text("Placeholder recreated")
                        .padding(20)
                        .background(Color.white)
                        .foregroundColor(.gray).padding(10)
                }
        }.onViewDidLoad{
            handleMethodChannel()
        }
        
    }
        
    // Function to send text input to Flutter
    func sendTextToFlutter() {
        guard !text.isEmpty else { return }  // Check if the text is not empty
        flutterMethodChannel?.invokeMethod("submitText", arguments: text)  // Send text to Flutter
    }

    func increaseCounter() {
        self.counter += 1
        submitCounter()
    }

    func handleMethodChannel() {
        flutterMethodChannel = FlutterMethodChannel(
            name: "flutter_channel/counter",
            binaryMessenger: flutterDependencies.flutterEngine.binaryMessenger)
        flutterMethodChannel?.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            switch call.method {
            case "increaseCounter":
                counter += 1
                submitCounter()
            case "getCounter":
                submitCounter()
            default:
                print("Unrecognized method: \(call.method)")
            }
        })
    }

    func submitCounter() {
        flutterMethodChannel?.invokeMethod("submitCounter", arguments: counter)
    }

    func showFlutter() {
        // Get RootViewController from window scene
        guard
            let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive && $0 is UIWindowScene })
                as? UIWindowScene,
            let window = windowScene.windows.first(where: \.isKeyWindow),
            let rootViewController = window.rootViewController
        else { return }

        // Create a FlutterViewController from pre-warm FlutterEngine
        let flutterViewController = FlutterViewController(
            engine: flutterDependencies.flutterEngine,
            nibName: nil,
            bundle: nil)
        flutterViewController.modalPresentationStyle = .overCurrentContext
        flutterViewController.isViewOpaque = false

        rootViewController.present(flutterViewController, animated: true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
