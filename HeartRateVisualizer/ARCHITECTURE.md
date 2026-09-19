# Arquitectura del Sistema - Heart Rate Visualizer

## Diagrama de Flujo

```
┌─────────────────────────────────────────────────────────┐
│                     ContentView                          │
│  (Detecta automáticamente el entorno)                   │
└─────────────────┬───────────────────────────────────────┘
                  │
                  │ #if targetEnvironment(simulator)
                  │
        ┌─────────┴─────────┐
        │                   │
        ▼                   ▼
┌───────────────┐   ┌──────────────────┐
│ MockBluetooth │   │  BluetoothManager│
│   Manager     │   │  (CoreBluetooth) │
│  (Simulator)  │   │    (Device)      │
└───────┬───────┘   └────────┬─────────┘
        │                    │
        │                    │
        ▼                    ▼
┌───────────────┐   ┌──────────────────┐
│ Mock Devices  │   │  Real Cycplus H2 │
│  - Cycplus H2 │   │   Heart Rate     │
│  - HR Monitor │   │     Sensor       │
│  - HR Pro     │   │                  │
└───────────────┘   └──────────────────┘
```

## Flujo de Conexión

### En Simulador (Mock):
```
1. Usuario abre app
   ↓
2. App detecta: targetEnvironment(simulator) = true
   ↓
3. Crea MockBluetoothManager
   ↓
4. Usuario presiona "Scan for Devices"
   ↓
5. Mock genera 3 dispositivos dummy (1 segundo)
   ↓
6. Usuario selecciona "Cycplus H2"
   ↓
7. Mock simula conexión (1.5 segundos)
   ↓
8. Timer comienza a generar BPM (60-100, cada 1s)
   ↓
9. UI se actualiza con valores simulados
```

### En Dispositivo Real:
```
1. Usuario abre app
   ↓
2. App detecta: targetEnvironment(simulator) = false
   ↓
3. Crea BluetoothManager (CoreBluetooth)
   ↓
4. Usuario presiona "Scan for Devices"
   ↓
5. CoreBluetooth escanea dispositivos BLE reales
   ↓
6. Usuario selecciona Cycplus H2 real
   ↓
7. CoreBluetooth establece conexión BLE
   ↓
8. App suscribe a notificaciones Heart Rate (UUID: 2A37)
   ↓
9. Sensor envía datos BPM reales
   ↓
10. UI se actualiza con valores del sensor
```

## Estructura de Archivos

```
HeartRateVisualizer/
│
├── ContentView.swift
│   ├── ContentView (main UI)
│   ├── DeviceListView (para dispositivos reales)
│   └── MockDeviceListView (para dispositivos mock)
│
├── BluetoothManager.swift
│   └── Gestiona CoreBluetooth real
│       ├── CBCentralManager
│       ├── CBPeripheral
│       └── Heart Rate Service (0x180D)
│
├── MockBluetoothManager.swift
│   └── Simula funcionalidad Bluetooth
│       ├── Genera dispositivos dummy
│       ├── Simula conexiones
│       └── Genera BPM con algoritmo
│
├── MockPeripheral.swift (en MockBluetoothManager)
│   └── Estructura de dispositivo simulado
│
├── SETUP_INSTRUCTIONS.md
│   └── Guía de configuración general
│
└── MOCK_GUIDE.md
    └── Guía detallada del sistema mock
```

## Estados de la App

```
┌──────────────┐
│ Disconnected │ ◄─┐
└──────┬───────┘   │
       │           │
       │ startScanning()
       │           │
       ▼           │
┌──────────────┐   │
│   Scanning   │   │ disconnect()
└──────┬───────┘   │
       │           │
       │ connect(device)
       │           │
       ▼           │
┌──────────────┐   │
│  Connecting  │   │
└──────┬───────┘   │
       │           │
       │ didConnect
       │           │
       ▼           │
┌──────────────┐   │
│  Connected   │───┘
│ (Receiving   │
│   HR Data)   │
└──────────────┘
```

## Protocolo Bluetooth Heart Rate Service

```
Service: Heart Rate (0x180D)
│
├── Characteristic: Heart Rate Measurement (0x2A37)
│   ├── Properties: Notify
│   ├── Format: Flags (1 byte) + HR Value (1-2 bytes)
│   └── Updates: Cada 1 segundo aprox.
│
└── Characteristic: Body Sensor Location (0x2A38)
    ├── Properties: Read
    ├── Format: 1 byte (0-6)
    └── Values: 0=Other, 1=Chest, 2=Wrist, etc.
```

## Parsing de Heart Rate Data

```
Byte 0 (Flags):
┌─┬─┬─┬─┬─┬─┬─┬─┐
│0│ │ │ │ │ │ │ │
└─┴─┴─┴─┴─┴─┴─┴─┘
 │
 └─ Bit 0: 0 = UINT8, 1 = UINT16

Si Bit 0 = 0:
  Byte 1 = Heart Rate (0-255 BPM)

Si Bit 0 = 1:
  Byte 1 + Byte 2 = Heart Rate (little-endian)
```

## Dependencias

### Simulator Build:
- SwiftUI
- Foundation
- Timer (para simulación)

### Device Build:
- SwiftUI
- Foundation
- CoreBluetooth
  - CBCentralManager
  - CBPeripheral
  - CBService
  - CBCharacteristic

## Permisos Requeridos

Solo para dispositivo real (no necesario en simulador):

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Necesario para conectar al sensor Cycplus H2</string>
```
```

Esto crea una documentación visual completa de cómo funciona el sistema. ¿Hay algo más específico que quieras que explique o alguna funcionalidad adicional que quieras añadir al mock?

