# Mock Bluetooth Manager - Guía de Uso

## ¿Por qué necesitamos un Mock?

El simulador de iOS **no tiene acceso a Bluetooth real**, por lo que no puedes probar apps que usen CoreBluetooth en el simulador sin un mock. Este mock simula completamente la funcionalidad de un sensor de frecuencia cardíaca Bluetooth.

## Características del Mock

### 🎭 Dispositivos Simulados
El mock simula 3 dispositivos de frecuencia cardíaca:
1. **Cycplus H2** - Tu sensor objetivo
2. **Heart Rate Monitor** - Monitor genérico
3. **HR Sensor Pro** - Sensor profesional

### ❤️ Simulación de Frecuencia Cardíaca
- **Rango**: 60-100 BPM (rango normal en reposo)
- **Variación**: Ciclos lentos y suaves que simulan cambios naturales
- **Ruido aleatorio**: ±3 BPM para simular variabilidad real
- **Actualización**: Cada 1 segundo (como un sensor real)

### ⚡ Comportamiento Simulado
- ✅ Escaneo con retraso de 1 segundo
- ✅ Conexión con retraso de 1.5 segundos
- ✅ Desconexión instantánea
- ✅ Estados de conexión realistas
- ✅ Ubicación del sensor: "Chest" (pecho)

## Detección Automática

La app usa **compilación condicional** para detectar automáticamente si está corriendo en simulador:

```swift
#if targetEnvironment(simulator)
    // Usa MockBluetoothManager
#else
    // Usa BluetoothManager real con CoreBluetooth
#endif
```

Esto significa:
- 📱 **En dispositivo real**: Usa CoreBluetooth y se conecta a tu Cycplus H2
- 💻 **En simulador**: Usa el mock automáticamente

## Cómo Probar

### En el Simulador:
1. Ejecuta la app en cualquier simulador de iOS
2. Verás un badge naranja que dice "Simulator Mode"
3. Toca "Scan for Devices"
4. Aparecerán 3 dispositivos mock después de ~1 segundo
5. Selecciona "Cycplus H2"
6. ¡Observa cómo la frecuencia cardíaca varía de forma realista!

### En Dispositivo Real:
1. Asegúrate de que tu Cycplus H2 esté encendido
2. Ejecuta la app en tu iPhone/iPad
3. NO verás el badge "Simulator Mode"
4. La app usará CoreBluetooth real
5. Busca y conecta tu sensor físico

## Estructura del Mock

### MockBluetoothManager
Clase principal que simula toda la funcionalidad de Bluetooth:
- `startScanning()` - Simula búsqueda de dispositivos
- `stopScanning()` - Detiene la búsqueda
- `connect(to:)` - Simula conexión con retraso
- `disconnect()` - Desconecta y detiene la simulación
- `startHeartRateSimulation()` - Genera frecuencias cardíacas realistas

### MockPeripheral
Estructura simple que representa un dispositivo Bluetooth simulado:
```swift
struct MockPeripheral: Identifiable {
    let id: String
    let name: String
    let identifier: String
}
```

## Algoritmo de Simulación de Frecuencia Cardíaca

El mock usa una fórmula que combina:
1. **Frecuencia base**: 75 BPM
2. **Ciclo sinusoidal**: ±10 BPM con período de 20 segundos
3. **Ruido aleatorio**: ±3 BPM
4. **Límites**: Mantiene valores entre 60-100 BPM

```swift
let time = Date().timeIntervalSince1970
let cycle = sin(time / 10.0) * 10.0
let noise = Double.random(in: -3...3)
let heartRate = Int(75.0 + cycle + noise)
```

Esto crea una curva natural que simula variaciones reales en la frecuencia cardíaca.

## Ventajas

✅ **Desarrollo más rápido** - No necesitas el sensor físico para desarrollar
✅ **Testing consistente** - Comportamiento predecible y reproducible
✅ **UI/UX testing** - Prueba la interfaz sin hardware
✅ **Demo fácil** - Muestra la app a otras personas sin sensor
✅ **Sin configuración** - Funciona automáticamente en simulador

## Archivos Creados

- `MockBluetoothManager.swift` - Implementación del mock
- `BluetoothManager.swift` - Implementación real con CoreBluetooth
- `ContentView.swift` - UI que detecta automáticamente qué usar

## Próximos Pasos

Puedes mejorar el mock añadiendo:
- [ ] Diferentes perfiles de frecuencia cardíaca (ejercicio, reposo, recuperación)
- [ ] Simulación de desconexiones aleatorias
- [ ] Simulación de batería baja
- [ ] Múltiples sensores conectados simultáneamente
- [ ] Configuración de BPM personalizado desde la UI
