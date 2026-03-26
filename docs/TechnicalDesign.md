# SpaceKat Mac Driver - Technical Design Document

**Version**: 1.0  
**Date**: March 22, 2026  
**Author**: SpaceKat Mac Driver Development Team  
**Status**: Draft

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [System Overview](#2-system-overview)
3. [Functional Requirements](#3-functional-requirements)
4. [Architecture Design](#4-architecture-design)
5. [HID Protocol Specification](#5-hid-protocol-specification)
6. [Virtual HID Device Design](#6-virtual-hid-device-design)
7. [User Interface Design](#7-user-interface-design)
8. [Calibration Wizard Design](#8-calibration-wizard-design)
9. [Data Persistence](#9-data-persistence)
10. [Testing & Deployment](#10-testing--deployment)
11. [Appendices](#11-appendices)

---

## 1. Executive Summary

### 1.1 Purpose

This document provides a comprehensive technical design for the **SpaceKat Mac Driver** — a macOS utility application that bridges the SpaceKat Wireless 6DOF (6 Degrees of Freedom) Bluetooth mouse to standard HID input, enabling CAD applications like FreeCAD, Blender, and BambuLab Studio to recognize the device as a native 3D navigation input.

### 1.2 Problem Statement

The SpaceKat Wireless is an open-source 6DOF Bluetooth mouse that appears to macOS as a generic Bluetooth gamepad device named "SpaceMouse Compact." While the hardware is capable of 3D navigation, macOS has no native driver to translate raw HID reports into standard HID joystick format that 3D CAD applications expect.

### 1.3 Solution

```
┌─────────────────┐    IOKit HID     ┌──────────────────┐    Virtual HID    ┌─────────────────┐
│  SpaceKat 6DOF  │ ──────────────► │  SpaceKat Driver │ ───────────────► │  CAD Application │
│   Bluetooth     │   Raw Reports   │   (Transform)    │   6DOF HID       │  (FreeCAD, etc)  │
│   Gamepad       │                 │                  │                  │                  │
└─────────────────┘                 └──────────────────┘                  └─────────────────┘
```

### 1.4 Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **Virtual HID** | foohid (IOKit kext) | No Apple entitlement required; proven in production |
| **Input** | IOKit HID Manager | Full raw report access |
| **UI** | SwiftUI + AppKit | Native menu bar support |
| **Architecture** | LSUIElement | Menu bar only, no dock icon |
| **Min macOS** | macOS 12.0 | foohid compatibility |

---

## 2. System Overview

### 2.1 Target Platform

- **OS**: macOS 12.0 (Monterey) and later
- **Architecture**: Universal Binary (Intel + Apple Silicon)
- **Languages**: Swift 5.9+ (primary), Objective-C (IOKit)

### 2.2 Compatibility

| Application | Support | Notes |
|-------------|---------|-------|
| FreeCAD 1.0+ | ✅ | Native HID reading |
| BambuLab Studio | ✅ | Standard HID |
| Blender 3.0+ | ✅ | Input System |
| Fusion 360 | ✅ | Gamepad support |

---

## 3. Functional Requirements

### 3.1 Core Features

| ID | Feature | Priority |
|----|---------|----------|
| FR-001 | Device Detection & Connection | Critical |
| FR-002 | 6DOF Input Capture (125Hz) | Critical |
| FR-003 | Virtual HID Device Creation | Critical |
| FR-004 | Global Sensitivity (10-500%) | High |
| FR-005 | Global Deadzone (0-50%) | High |
| FR-006 | Axis Calibration Wizard | High |
| FR-007 | Device Selection Menu | High |
| FR-008 | Settings Panel | High |
| FR-009 | Menu Bar Presence | High |

---

## 4. Architecture Design

### 4.1 High-Level Architecture

```
┌───────────────────────────────────────────────────────────────┐
│                    SpaceKat Driver                             │
│  ┌───────────────────────────────────────────────────────┐   │
│  │                 App Layer (SwiftUI)                    │   │
│  │  MenuBarView | SettingsView | CalibrationWizardView    │   │
│  └───────────────────────────────────────────────────────┘   │
│                            │                                  │
│  ┌─────────────────────────┼─────────────────────────────┐   │
│  │              Service Layer (Swift)                     │   │
│  │  BluetoothManager | HIDInputService | SettingsService  │   │
│  │  DeviceManager | CalibrationEngine | ProfileManager   │   │
│  └─────────────────────────┼─────────────────────────────┘   │
│                            │                                  │
│  ┌─────────────────────────┼─────────────────────────────┐   │
│  │              Core Layer (Swift + C)                    │   │
│  │  HIDManager (IOKit) | VirtualHIDDeviceManager (foohid)│   │
│  │  HIDParser | CalibrationEngine                         │   │
│  └───────────────────────────────────────────────────────┘   │
└───────────────────────────────────────────────────────────────┘
```

### 4.2 Data Flow

```
[SpaceKat] → [IOKit HID] → [HIDParser] → [CalibrationEngine]
                                              │
                                              ▼
                                    [Sensitivity/Deadzone]
                                              │
                                              ▼
                                  [VirtualHIDDeviceManager]
                                              │
                                              ▼
                                  [foohid] → [CAD Applications]
```

### 4.3 Data Structures

```swift
struct Vector6D {
    var translationX: Int16  // ±350
    var translationY: Int16
    var translationZ: Int16
    var rotationPitch: Int16
    var rotationRoll: Int16
    var rotationYaw: Int16
    var buttons: UInt8
}

struct NormalizedVector6D {
    var translation: SIMD3<Double>  // ±1.0
    var rotation: SIMD3<Double>     // ±1.0
    var buttons: UInt8
}

struct HID6DOFReport {
    var reportID: UInt8 = 0x01
    var translationX: Int16  // Little-endian
    var translationY: Int16
    var translationZ: Int16
    var rotationPitch: Int16
    var rotationRoll: Int16
    var rotationYaw: Int16
    var buttons: UInt8
    // Total: 16 bytes
}
```

---

## 5. HID Protocol Specification

### 5.1 SpaceKat HID Report Format

Based on 3Dconnexion SpaceMouse Compact protocol:

| Report | Size | Content |
|--------|------|---------|
| ID 1 | 7B | Translation (X, Y, Z) |
| ID 2 | 7B | Rotation (Pitch, Roll, Yaw) |
| ID 3 | 3B | Buttons |

### 5.2 Report Structure

```
Report ID 1 (Translation):
  Byte 0: Report ID (0x01)
  Byte 1-2: X (Int16 LE, -350 to +350)
  Byte 3-4: Y (Int16 LE)
  Byte 5-6: Z (Int16 LE)

Report ID 2 (Rotation):
  Byte 0: Report ID (0x02)
  Byte 1-2: Pitch/Rx (Int16 LE)
  Byte 3-4: Roll/Ry (Int16 LE)
  Byte 5-6: Yaw/Rz (Int16 LE)

Report ID 3 (Buttons):
  Byte 0: Report ID (0x03)
  Byte 1: Button bitmap (bit 0 = btn1, bit 1 = btn2)
  Byte 2: Reserved
```

### 5.3 Coordinate System

```
          Z (Up)
          │
          ├──────► X (Right)
          │
          ▼
         Y (Toward User)
```

| Axis | Positive | Description |
|------|----------|-------------|
| X | Right | Horizontal |
| Y | Away | Forward/Back |
| Z | Up | Vertical |
| Rx | Forward tilt | Pitch |
| Ry | Side tilt | Roll |
| Rz | Twist CW | Yaw |

### 5.4 Decoding Implementation

```swift
func decodeTranslationReport(_ report: Data) -> (x: Int16, y: Int16, z: Int16) {
    let x = Int16(littleEndian: report.withUnsafeBytes { $0.load(fromByteOffset: 1, as: Int16.self) })
    let y = Int16(littleEndian: report.withUnsafeBytes { $0.load(fromByteOffset: 3, as: Int16.self) })
    let z = Int16(littleEndian: report.withUnsafeBytes { $0.load(fromByteOffset: 5, as: Int16.self) })
    return (x, y, z)
}
```

---

## 6. Virtual HID Device Design

### 6.1 Approach Selection

| Approach | macOS | Entitlements | Status |
|----------|-------|--------------|--------|
| foohid | 10.11+ | None | **Selected** |
| HIDVirtualDevice | 15+ only | Apple approval | Future |

### 6.2 foohid API

| Selector | Function | Description |
|----------|----------|-------------|
| 0 | FOOHID_CREATE | Create virtual device |
| 1 | FOOHID_DESTROY | Destroy device |
| 2 | FOOHID_SEND | Send HID report |
| 3 | FOOHID_LIST | List devices |

### 6.3 Virtual Device HID Descriptor

```swift
let virtualDeviceDescriptor: [UInt8] = [
    // Application Collection
    0x05, 0x01,         // Usage Page (Generic Desktop)
    0x09, 0x08,         // Usage (Multi-axis Controller)
    0xA1, 0x01,         // Collection (Application)
    
    // Physical - Translation Axes
    0x09, 0x01,         //   Usage (Pointer)
    0xA1, 0x00,         //   Collection (Physical)
    0x16, 0x00, 0x80,   //   Logical Min (-32768)
    0x26, 0xFF, 0x7F,   //   Logical Max (32767)
    0x09, 0x30,         //   Usage (X)
    0x09, 0x31,         //   Usage (Y)
    0x09, 0x32,         //   Usage (Z)
    0x75, 0x10,         //   Report Size (16 bits)
    0x95, 0x03,         //   Report Count (3)
    0x81, 0x02,         //   Input (Data, Var, Abs)
    
    // Rotation Axes
    0x09, 0x33,         //   Usage (Rx)
    0x09, 0x34,         //   Usage (Ry)
    0x09, 0x35,         //   Usage (Rz)
    0x95, 0x03,         //   Report Count (3)
    0x81, 0x02,         //   Input
    
    0xC0,               //   End Collection
    
    // Buttons
    0x05, 0x09,         //   Usage Page (Button)
    0x19, 0x01,         //   Usage Min
    0x29, 0x02,         //   Usage Max
    0x15, 0x00,         //   Logical Min (0)
    0x25, 0x01,         //   Logical Max (1)
    0x75, 0x01,         //   Report Size (1)
    0x95, 0x02,         //   Report Count (2)
    0x81, 0x02,         //   Input
    0x95, 0x06,         //   Padding
    0x81, 0x01,         //   Constant
    
    0xC0                // End Collection
]
// Report size: 16 bytes
```

### 6.4 foohid Bridge Implementation

```swift
class foohidBridge {
    private var connection: io_connect_t = 0
    
    func create(name: String, descriptor: Data, vendorID: UInt16, productID: UInt16) -> Bool {
        var input: [UInt64] = [
            UInt64(bitPattern: strdup(name)),
            UInt64(name.utf8.count),
            UInt64(bitPattern: descriptor.withUnsafeBytes { UnsafeRawPointer($0.baseAddress!) }),
            UInt64(descriptor.count),
            UInt64(bitPattern: strdup("SN-000001")),
            8, UInt64(vendorID), UInt64(productID)
        ]
        
        let result = IOConnectCallScalarMethod(connection, 0, &input, Int32(input.count), nil, nil)
        return result == KERN_SUCCESS
    }
    
    func send(report: Data) {
        var input: [UInt64] = [
            UInt64(bitPattern: report.withUnsafeBytes { UnsafeRawPointer($0.baseAddress!) }),
            UInt64(report.count), 0, 0, 0, 0
        ]
        IOConnectCallScalarMethod(connection, 2, &input, 6, nil, nil)
    }
}
```

---

## 7. User Interface Design

### 7.1 Menu Bar Icon States

| State | Icon | Description |
|-------|------|-------------|
| Disconnected | 🖱⚪ | Gray outline |
| Connected | 🖱⚫ | Solid black |
| Active | 🖱⬤ | Filled with pulse |
| Calibrating | 🎯 | Crosshair |
| Error | 🖱⚠ | Warning |

### 7.2 Menu Structure

```
┌─────────────────────────────────┐
│ SpaceKat Driver                 │
├─────────────────────────────────┤
│ ● SpaceMouse Compact (BT)   ──┐ │
│   SpaceKat Pro (BT)           │ │
│   No Device Found              │ │
├─────────────────────────────────┤
│ ⚙ Settings...              ⌘,  │
│ 🎯 Calibrate Device...         │
├─────────────────────────────────┤
│ ☑ Launch at Login               │
├─────────────────────────────────┤
│ About SpaceKat Driver           │
├─────────────────────────────────┤
│ Quit                       ⌘Q  │
└─────────────────────────────────┘
```

### 7.3 Settings View

```
┌────────────────────────────────────────────────┐
│  SpaceKat Driver Settings                      │
├────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────┐  │
│  │ Sensitivity: [==========│===] 100%      │  │
│  └──────────────────────────────────────────┘  │
│                                                  │
│  ┌──────────────────────────────────────────┐  │
│  │ Deadzone:    [====|=========] 5%        │  │
│  └──────────────────────────────────────────┘  │
│                                                  │
│  ┌──────────────────────────────────────────┐  │
│  │ Axis Inversion:                         │  │
│  │ ☑ X   ☐ Y   ☐ Z   ☐ Rx   ☐ Ry   ☐ Rz  │  │
│  └──────────────────────────────────────────┘  │
│                                                  │
│              [Reset]  [Done]                    │
└────────────────────────────────────────────────┘
```

---

## 8. Calibration Wizard Design

### 8.1 Calibration Steps

```
1. Welcome → 2. X Axis → 3. Y Axis → 4. Z Axis
   → 5. Pitch → 6. Roll → 7. Yaw → 8. Deadzone → 9. Complete
```

### 8.2 Axis Detection Algorithm

```swift
func detectAxis(from samples: [Vector6D]) -> AxisMappingResult {
    var axisVariance: [(axis: Int, variance: Double)] = []
    
    for axis in 0..<6 {
        let values = samples.map { getAxisValue($0, axis: axis) }
        let variance = calculateVariance(values)
        axisVariance.append((axis, variance))
    }
    
    axisVariance.sort { $0.variance > $1.variance }
    let primary = axisVariance.first { $0.variance > threshold }
    
    return AxisMappingResult(
        physicalAxis: primary!.axis,
        polarity: determinePolarity(samples: samples, axis: primary!.axis),
        confidence: primary!.variance / maxVariance
    )
}
```

---

## 9. Data Persistence

### 9.1 UserDefaults Keys

| Key | Type | Description |
|-----|------|-------------|
| `spacekat.settings` | JSON | Global settings |
| `spacekat.calibration` | JSON | Axis calibration |
| `spacekat.profiles` | JSON | App profiles |
| `spacekat.devices` | JSON | Known devices |

### 9.2 Settings Model

```swift
struct Settings: Codable {
    var sensitivity: Double = 1.0
    var globalDeadzone: Double = 0.05
    var launchAtLogin: Bool = false
    var invertedAxes: Set<Int> = []
}

struct CalibrationData: Codable {
    var axisMapping: [Int: Int] = [0:0, 1:1, 2:2, 3:3, 4:4, 5:5]
    var polarity: [Int: AxisPolarity] = [:]
    var perAxisDeadzone: [Int: Double] = [:]
}
```

---

## 10. Testing & Deployment

### 10.1 Test Categories

| Category | Target |
|----------|--------|
| Unit Tests | XCTest - parsers, calibration |
| Integration | HID pipeline with mock device |
| E2E | FreeCAD, Blender, BambuLab |
| Performance | Latency < 5ms, CPU < 5% |

### 10.2 Build Configuration

```yaml
name: SpaceKatDriver
options:
  deploymentTarget:
    macOS: "12.0"
targets:
  SpaceKatDriver:
    type: application
    settings:
      CODE_SIGN_ENTITLEMENTS: SpaceKatDriver.entitlements
      LSUIElement: YES
    dependencies:
      - sdk: IOKit.framework
      - sdk: CoreBluetooth.framework
```

---

## 11. Appendices

### A. HID Usage Tables

| Page | Usage | Name |
|------|-------|------|
| 0x01 | 0x08 | Multi-axis Controller |
| 0x01 | 0x30 | X |
| 0x01 | 0x31 | Y |
| 0x01 | 0x32 | Z |
| 0x01 | 0x33 | Rx |
| 0x01 | 0x34 | Ry |
| 0x01 | 0x35 | Rz |
| 0x09 | 0x01+ | Button N |

### B. Reference Projects

| Project | Purpose |
|---------|---------|
| foohid | Virtual HID kernel extension |
| spacenavd | Linux SpaceMouse daemon |
| Karabiner-Elements | Virtual HID keyboard/mouse |

### C. Glossary

| Term | Definition |
|------|------------|
| **6DOF** | Six Degrees of Freedom |
| **HID** | Human Interface Device |
| **foohid** | Virtual HID for macOS |
| **LSUIElement** | Hide dock icon |
| **dext** | DriverKit Extension |

---

*Document Version: 1.0 | March 22, 2026*
