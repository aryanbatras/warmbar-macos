import SwiftUI
import AppKit
import CoreGraphics
import ServiceManagement

// Add this extension to make it easier to use with @AppStorage
extension Double: RawRepresentable {
    public init?(rawValue: String) {
        self = Double(rawValue) ?? 0.0
    }
    
    public var rawValue: String {
        String(self)
    }
}

struct WarmBarApp: App {
    @StateObject private var tempManager = TemperatureManager()
    
    init() {
        setupLoginItem()
    }
    
    var body: some Scene {
        MenuBarExtra("WarmBar", systemImage: "sun.max") {
            ContentView(tempManager: tempManager)
        }
    }
    
    private func setupLoginItem() {
        do {
            // Register the main app as a login item
            if #available(macOS 13.0, *) {
                try SMAppService.mainApp.register()
            } else {
                // Fallback for older macOS versions
                let bundleID = Bundle.main.bundleIdentifier ?? "com.yourname.warmbar"
                SMLoginItemSetEnabled(bundleID as CFString, true)
            }
        } catch {
            print("Failed to register login item: \(error)")
        }
    }
}

WarmBarApp.main()

class TemperatureManager: ObservableObject {
    @AppStorage("temperature") private var storedTemperature: Double = 3400
    @Published var temperature: Double = 3400
    private var hasInitialized = false
    
    init() {
        self.temperature = storedTemperature
    }
    
    func cycleTemperature() {
        if temperature == 3400 {
            temperature = 2500
        }
        else if temperature == 2500 {
            temperature = 1900
        } else if temperature == 1900 {
            temperature = 1400
        } else if temperature == 1400 {
            temperature = 1000
        } else if temperature == 1000 {
            temperature = 600
        } else if temperature == 600 {
            temperature = 3400
        }
        
        storedTemperature = temperature
        applyWarmth(temperature)
    }
    
    func applyStoredTemperature() {
        if !hasInitialized {
            temperature = storedTemperature
            applyWarmth(temperature)
            hasInitialized = true
        }
    }
}

struct ContentView: View {
    @ObservedObject var tempManager: TemperatureManager
    @State private var enabled = true

    var body: some View {
        VStack(spacing: 12) {

            Button(action: {
                if enabled {
                    tempManager.cycleTemperature()
                }
            }, label: {
                Text(
                    tempManager.temperature == 3400 ? "Everyday Warm (3400K)" :
                    tempManager.temperature == 2500 ? "Normal Warm (2500K)" :
                    tempManager.temperature == 1900 ? "Warm (1900K)" :
                    tempManager.temperature == 1400 ? "Warm-ish (1400K)" :
                    tempManager.temperature == 1000 ? "Very Warm-ish (1000K)" :
                    tempManager.temperature == 600 ? "Darkroom (600K)" :
                    "Everyday Warm (3400K)"
                )
            })
            .buttonStyle(.plain)

            
            Button("Quit") {
                NSApplication.shared.terminate(self)
            }

        }
        .padding()
        .frame(width: 240)
        .onAppear {
            // Only apply warmth on first launch, not every time menu opens
            if enabled {
                tempManager.applyStoredTemperature()
            }
        }
    }
}

func applyWarmth(_ temperature: Double) {
    let displayID = CGMainDisplayID()
    let steps = 256

    var red = [CGGammaValue](repeating: 0, count: steps)
    var green = [CGGammaValue](repeating: 0, count: steps)
    var blue = [CGGammaValue](repeating: 0, count: steps)

    // Convert temperature (1000K-2500K) to warmth factor
    // 6500K = neutral (0 warmth), 1000K = maximum warmth (1.0)
    let warmth = (6500.0 - temperature) / (6500.0 - 1000.0)
    let clampedWarmth = max(0, min(1, warmth))
    
    // Apply exponential curve for more intense effect at lower temperatures
    let intenseWarmth = pow(clampedWarmth, 0.6)

    for i in 0..<steps {
        let x = Double(i) / Double(steps - 1)
        red[i] = CGGammaValue(x)
        green[i] = CGGammaValue(x * (1 - intenseWarmth * 0.6))
        blue[i] = CGGammaValue(x * (1 - intenseWarmth * 0.9))
    }

    CGSetDisplayTransferByTable(
        displayID,
        UInt32(steps),
        &red,
        &green,
        &blue
    )
}
