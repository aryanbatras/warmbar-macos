import SwiftUI
import AppKit
import CoreGraphics
import ServiceManagement

struct WarmBarApp: App {
    init() {
        setupLoginItem()
    }
    
    var body: some Scene {
        MenuBarExtra("WarmBar", systemImage: "sun.max") {
            ContentView()
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

struct ContentView: View {
    @State private var temperature: Double = 3400 
    @State private var enabled = true

    var body: some View {
        VStack(spacing: 12) {

            Button(action: {
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

                if enabled {
                    applyWarmth(temperature)
                }
            }, label: {
                Text(
                    temperature == 3400 ? "Everyday Warm (3400K)" :
                    temperature == 2500 ? "Normal Warm (2500K)" :
                    temperature == 1900 ? "Warm (1900K)" :
                    temperature == 1400 ? "Warm-ish (1400K)" :
                    temperature == 1000 ? "Very Warm-ish (1000K)" :
                    temperature == 600 ? "Darkroom (600K)" :
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
            // Apply default warmth on app launch
            if enabled {
                applyWarmth(temperature)
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
