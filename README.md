# VonViz — Spatial Data & Function Visualization for visionOS

VonViz is a 3D data-visualization and function-plotting application built for **visionOS** and the **Apple Vision Pro**. It allows users to upload CSV datasets or input mathematical functions to generate interactive, immersive 3D visualizations in a spatial computing environment.

---

## Project Documents

### Team
- **Joseph King** — Project Manager, Software Engineer  
- **Michael Plescia** — Front-End UI Designer  
- **Seth Holtzman** — Technical Lead, Backend Software Engineer  

### Documentation Links
- **Team Charter**  
  https://drive.google.com/drive/folders/1CM16wybFIhSwVYIqdR9js68r6Z8kbevn  

- **Requirements Document**  
  https://docs.google.com/document/d/1di0hmVVpLvBlKFenA-8kkR31mgci4VVnPpNHRg9MaDP0/edit?usp=sharing  

- **Functional Specification**  
  https://docs.google.com/document/d/1SQBXQbUjqS2LLoCnjhjYLIRzyWLuwVce7hs8QsRnFZk/edit?usp=drivesdk  

- **User Manual**  
  https://docs.google.com/document/d/1ao8-fAkPDrW8zezHz3fVqypJ6h8nPMJtJ3KifFBYjvQ/edit?usp=sharing  

- **Technical Specification**  
  https://docs.google.com/document/d/11fTf_E0Clvp9A4P2IAW9uu3e8qef3HVIG9u9lEMx0Hk/edit?usp=sharing

- **Poster**  
  https://www.canva.com/design/DAG6ZHPJUC8/A-RY883y2lH5J_84XUorOg/edit

- **Presentation**
  https://www.canva.com/design/DAG7aiiZ0u0/ZxJvV4hc4PgRewnUkLiR_g/view?utm_content=DAG7aiiZ0u0&utm_campaign=designshare&utm_medium=link2&utm_source=uniquelinks&utlId=ha8cd8fc508

---

## Features

### Data Visualization
- Upload CSV datasets  
- Automatic detection of numeric columns  
- 3D scatter plot rendering  
- Editable axis parameters (header, min, max, steps)  
- Real-time updates via SwiftUI `@Published` properties  

### Function Plotting
- Enter functions such as `sin(2 * x) * cos(y)`  
- Custom grammar system: CharStream → Lexer → Parser → AST  
- 3D surface plot of f(x, y) = z  
- Custom math keyboard UI for safe function entry  
- Adjustable axis domains for x, y, and z  

---

## Prerequisites

### Hardware
- Mac with **Apple Silicon** (M1, M2, or M3 required for visionOS development)  
- Optional: **Apple Vision Pro** for on-device testing (otherwise use the simulator)  

### Software
- **macOS 15+**  
- **Xcode 15.2+** (includes visionOS SDK and Vision Pro simulator)  
- **visionOS 26.0 SDK & Simulator** (installed via Xcode’s Components)  

---

## Installation & Dependencies

### Clone the Repository
```bash
git clone https://github.com/SethMC26/Neumann.git
open Neumann/src/VonViz.xcodeproj
```

### Frameworks Used (Bundled with visionOS SDK)
These do **not** require manual installation:
- **SwiftUI**  
- **RealityKit**  
- **Swift Charts**  
- **TabularData**  

---

## Running VonViz in the visionOS Simulator

1. Open the project in Xcode.  
2. In the scheme/device selector, choose a **Vision Pro (Simulator)** target.  
3. Press **Run** ▶.  
4. The app will build and launch in the visionOS Simulator, where you can test CSV upload and function plotting in a simulated spatial environment.

---

## Running VonViz on Apple Vision Pro (Device Build)

### 1. Sign Into Xcode & Configure Signing

1. Open **Xcode → Settings → Accounts**.  
2. Click **Add Account...** and sign in with your Apple ID.  
3. Open the project, select the **VonViz** app target, go to **Signing & Capabilities**.  
4. Under **Team**, select your Personal Team or Organization Team.  
5. Check **Automatically manage signing** so Xcode can create and manage provisioning profiles.

### 2. Prepare the Vision Pro

1. Put on the Apple Vision Pro.  
2. Navigate to **Settings → General → Remote Devices** on the headset.  
3. Leave this screen open so the device is discoverable by Xcode.

### 3. Pair the Vision Pro with Xcode

1. On your Mac, open **Xcode → Window → Devices and Simulators**.  
2. In the **Devices** tab, you should see your Vision Pro listed.  
3. Select the Vision Pro and click **Pair**.  
4. A pairing code is displayed in Xcode and on the headset—enter/confirm the code to complete pairing.  
5. Once paired, the Vision Pro will show up as a valid run destination in Xcode’s scheme/device selector.

### 4. Enable Developer Mode on Vision Pro

1. On the Vision Pro, go to **Settings → Privacy & Security → Developer Mode**.  
2. Toggle **Developer Mode** to **On**.  
3. Confirm when prompted and allow the device to restart.  
4. After reboot, verify that Developer Mode is enabled in the same settings menu.

### 5. Build & Run VonViz on the Device

1. In Xcode, select your **Vision Pro device** in the scheme/device selector.  
2. Click **Run** ▶.  
3. Xcode will:
   - Build the project  
   - Sign it using your selected Team  
   - Install it onto the Vision Pro  
4. If you are wearing the headset, you should see VonViz appear and launch in the spatial environment once deployment completes.

### 6. Trust the Developer Certificate (Free Accounts)

If the app installs but will not launch (commonly with free/Personal Team accounts):

1. On Vision Pro, go to **Settings → General → Device Management** (or **VPN & Device Management**).  
2. Under **Developer App**, select your Apple ID / developer name.  
3. Tap **Trust “[Your Name]”** and confirm.  
4. If prompted, allow a reboot to complete the trust process.  
5. After this, the app will be allowed to run on the device.

   
---

## Project Structure

```text
src/
 ├── VonViz/                # Main app source
 │    ├── Model/            # AppModel, FuncChartModel, AxisInfo, helpers
 │    ├── Views/            # DataChart, FuncChart, toolbars, keyboard
 │    ├── Utils/            # Logging utilities
 │    └── VonVizApp.swift   # App entry point
 ├── VonVizTests/           # Unit tests for models & grammar system
 ├── Packages/              # External Swift packages (if any)
 ├── VonViz.xcodeproj
 └── VonViz.xctestplan
```

---

## Architecture Overview

### Data Chart (CSV Visualization)
- **Model:** `DataChartModel` (sometimes referred to as `AppModel` in code)  
  - Loads CSV files into a `DataFrame`  
  - Detects numeric columns for potential axes  
  - Manages axis headers, min/max, and step values  
  - Produces an array of `Row` structs with `x`, `y`, `z` values for 3D plotting  

- **View:** `DataChart` and supporting SwiftUI views  
  - File picker to ingest CSV files  
  - Axis editing UI (X, Y, Z buttons and dialogs)  
  - Renders 3D chart using the model’s published data  

### Function Chart (Surface Plot)

- **Model:** `FuncChartModel`  
  - Stores the parsed **Abstract Syntax Tree (AST)** for the function  
  - Maintains `AxisInfo` for x, y, and z axes  
  - Exposes APIs like `setInput(_ input: String)` and `setAxis(axis:max:min:steps:)`  

- **View:** `FuncChart` and keyboard/toolbar views  
  - Text field showing the current function string  
  - Custom keyboard containing only valid grammar tokens  
  - Surface plot constructed via a 3D chart that calls `ast.eval(x, y)` to compute z  

### Grammar System

- **CharStream** → Turns the input string into a stream of characters  
- **Lexer** → Consumes characters and produces a stream of tokens  
- **Parser** → Consumes tokens and builds an AST with proper operator precedence  
- **AST** → Evaluates the function for given `(x, y)` inputs

Supported constructs include:
- Basic arithmetic: `+`, `-`, `*`, `/`, `**`  
- Trigonometric functions: `sin`, `cos`, `tan`  
- Variables: `x`, `y`  
- Parentheses for grouping: `( ... )`

---

## Views & UI Structure

- **VonVizApp.swift**  
  - Main entry point, sets up a volumetric window group and loads `ContentView`.

- **ContentView**  
  - Hosts a `TabView` switching between:
    - **Data Chart** tab  
    - **Surface Plot** (Function Chart) tab  

- **DataChart Views**  
  - UI for CSV file selection, axis configuration, and 3D data visualization.

- **FuncChart Views**  
  - UI for function entry, axis editing, and 3D surface plotting.  
  - Custom keyboard view that only exposes valid symbols and functions.
