# VonViz — 3D Data & Function Visualization for visionOS

VonViz is an immersive 3D visualization tool for **Apple Vision Pro**, created by **Team Neumann**. It provides two core capabilities:  
1) **3D CSV-based data visualization**, and  
2) **3D mathematical surface plotting**,  
all built natively for visionOS using SwiftUI and RealityKit.

---

## Team Neumann
- **Joseph King** — Project Manager, Software Engineer  
- **Michael Plescia** — Front-End UI Designer  
- **Seth Holtzman** — Technical Lead, Backend Software Engineer  

---

## Project Documents
- **Team Charter**  
  https://docs.google.com/document/d/1Z1tSg39N_xnam7r9qQaTl4dNRwwwGKFiFNJWs4M-CiI/edit?usp=sharing
- **Requirements Document**  
  https://docs.google.com/document/d/1di0hmVVpLvBlKFenA-8kkR31mgci4VnPpNHRg9MaDP0  
- **Functional Specification**  
  https://docs.google.com/document/d/1SQBXQbUjqS2LLoCnjhjYLIRzyWLuwVce7hs8QsRnFZk  
- **User Manual**  
  https://docs.google.com/document/d/1ao8-fAkPDrW8zezHz3fVqypJ6h8nPMJtJ3KifFBYjvQ  
- **Technical Specification**  
  https://docs.google.com/document/d/11fTf_E0Clvp9A4P2IAW9uu3e8qef3HVIG9u9lEMx0Hk/edit?usp=sharing
- **Poster**  
  https://www.canva.com/design/DAG6ZHPJUC8/A-RY883y2lH5J_84XUorOg/edit  
**presentation**
  https://www.canva.com/design/DAG7aiiZ0u0/vUppF1caZCLd3sxKoDP6Kw/edit?utm_content=DAG7aiiZ0u0&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton
---

## Features

### Data Visualization (CSV Mode)
- Upload CSV files  
- Auto-detect numeric columns  
- Map any numeric column to X, Y, or Z  
- Edit axis domains (min, max, steps)  
- Visualize points in 3D using Swift Charts  
- Real-time updates driven by model `@Published` properties  

### Function Visualization (Surface Plot Mode)
- Enter math expressions like:  
  ```
  sin(2 * x) * cos(y)
  ```
- Fully custom expression grammar + AST parser  
- Surface plot rendered from `(x, y) → z` function  
- Adjustable domains for all axes  
- Custom math keyboard ensures valid input  

---

## Prerequisites

### Hardware
- Mac with **Apple Silicon (M1/M2/M3)**  
- Optional: physical **Apple Vision Pro**  

### Software
- **macOS 15+**  
- **Xcode 15.2+**  
- **visionOS 26.0+ SDK**  
- Apple Developer Account (required for device deployment)

---

## Installation

### Clone and Open
```bash
git clone https://github.com/SethMC26/Neumann.git
open Neumann/src/VonViz.xcodeproj
```

### Run in Simulator
1. Select **Vision Pro (Simulator)** target  
2. Press **Run** ▶  

---

## Running on Apple Vision Pro (Device)

### 1. Configure Signing
- Xcode → Settings → Accounts → Add Apple ID  
- Target → *Signing & Capabilities* → Select your Team  
- Enable **Automatically manage signing**

### 2. Pair the Device
- Vision Pro → *Settings → General → Remote Devices*  
- Xcode → *Window → Devices and Simulators* → Pair

### 3. Enable Developer Mode
- Vision Pro → *Settings → Privacy & Security → Developer Mode*  
- Restart when prompted

### 4. Deploy
- Select Vision Pro as the run destination  
- Click **Run** ▶  

### 5. Free Team Users Must Trust the App
- Vision Pro → *Settings → General → Device Management* → Trust Developer  

---

## Project Structure

```
src/
 ├── VonViz/                # Main app source
 │    ├── Model/            # DataChartModel, FuncChartModel, AxisInfo, Grammar System
 │    ├── Views/            # UI for modes, 3D charts, toolbars, keyboard
 │    ├── Utils/            # Logging helpers
 │    └── VonVizApp.swift   # App entry point
 ├── VonVizTests/           # Parser & model unit tests
 ├── Packages/
 ├── VonViz.xcodeproj
 └── VonViz.xctestplan
```

---

## Architecture Overview

### DataChartModel
- Loads CSV → DataFrame  
- Extracts numeric columns  
- Stores axis metadata via `AxisInfo`  
- Generates `[Row]` for 3D plotting  

### FuncChartModel
- Stores parsed AST  
- Evaluates `z = f(x, y)`  
- Manages axis configuration  

### Grammar System
- CharStream → Lexer → Parser → AST  
- Supports:  
  - `+ - * / **`  
  - `sin(), cos(), tan()`  
  - Variables: `x`, `y`  

### View Layer
- SwiftUI tab-based navigation (`ContentView`)  
- Volumetric window for 3D spatial placement  
- DataChart & FuncChart views for visualization  
- Custom keyboard for function input  

---

