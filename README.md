# WarmBar for macOS

A lightweight, menu bar application that provides manual control over your display's color temperature, similar to f.lux but with a simpler, more direct interface.

## Features

- Toggle between multiple color temperature presets
- Simple, lightweight menu bar interface
- No unnecessary features or bloat
- Open source and privacy-focused
- Runs in the background with minimal system impact

## Installation

### Prerequisites

- macOS 12.0 or later
- Xcode Command Line Tools (for building from source)

### Building from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/warmbar-macos.git
   cd warmbar-macos
   ```

2. Make the build script executable:
   ```bash
   chmod +x build.sh
   ```

3. Run the build script:
   ```bash
   ./build.sh
   ```

4. Launch the application:
   ```bash
   open WarmBar.app
   ```

## Usage

1. Click on the sun icon in your menu bar
2. Select your desired color temperature:
   - Everyday Warm (3400K)
   - Normal Warm (2500K)
   - Warm (1900K)
   - Warm-ish (1400K)
   - Very Warm-ish (1000K)
   - Darkroom (600K)
3. The display will immediately adjust to the selected temperature

## How It Works

WarmBar modifies the gamma tables of your display to adjust the color temperature. This is done at the system level, providing smooth transitions and low resource usage.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by f.lux and other blue light reduction tools
- Built with Swift and SwiftUI
