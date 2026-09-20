# 🎯 Zonas de Frecuencia Cardíaca - Guía Completa

## ✨ Nuevas Funcionalidades

### 1. **Configuración de Edad**
- Botón de configuración (⚙️) en la toolbar
- Pantalla de configuración para ingresar tu edad
- Guarda automáticamente la edad en UserDefaults

### 2. **Cálculo Automático de Zonas**
- **Frecuencia Cardíaca Máxima**: 220 - edad
- **Zona Objetivo**: 70% - 80% del máximo
- Cálculo automático al ingresar la edad

#### Ejemplo:
- Edad: 30 años
- FC Máxima: 190 BPM (220 - 30)
- Zona Objetivo: 133 - 152 BPM (70% - 80%)

### 3. **Indicador Visual de Zona**
Cuando estás conectado a un dispositivo y has configurado tu edad, verás:

- 🔵 **Azul**: Por debajo del 70% (demasiado bajo)
- 🟢 **Verde**: Entre 70% - 80% (zona perfecta)
- 🔴 **Rojo**: Por encima del 80% (demasiado alto)

El corazón animado cambia de color según la zona en que estés.

### 4. **Barra de Progreso Visual**
- Muestra tu posición actual en un rango de 0% a 100%
- Zona objetivo resaltada en verde (70-80%)
- Punto indicador que se mueve en tiempo real

### 5. **Alertas Sonoras**
El sistema reproduce alertas sonoras cuando sales de la zona objetivo:

#### 🔵 Por Debajo del 70%
- Sonido: Beep grave (System Sound 1054)
- Mensaje: "Below Target Zone"
- Acción sugerida: Aumenta la intensidad

#### 🔴 Por Encima del 80%
- Sonido: Beep agudo (System Sound 1016)
- Mensaje: "Above Target Zone"
- Acción sugerida: Reduce la intensidad

#### 🔁 Repetición de Alertas
- Las alertas se repiten cada 5 segundos mientras estés fuera de la zona
- Se detienen automáticamente cuando vuelves a la zona objetivo

### 6. **Feedback Háptico** (Solo en Dispositivo Real)
- Vibración de advertencia: Al salir de zona
- Vibración de error: Al exceder zona
- Vibración de éxito: Al entrar en zona

## 🎨 Interfaz de Usuario

### Pantalla Principal
```
┌─────────────────────────────┐
│  Heart Rate Monitor    ⚙️   │
├─────────────────────────────┤
│                             │
│    [Simulator Mode]         │ (solo en simulador)
│                             │
│         ❤️  (pulsando)      │ (cambia de color)
│           75                │
│          BPM                │
│                             │
│  ┌───────────────────────┐  │
│  │ ✅ In Target Zone     │  │
│  │    75% of max         │  │
│  │  ━━━━━━●━━━━━━━━━━   │  │
│  │  0%  70% 80%     100% │  │
│  └───────────────────────┘  │
│                             │
│     🟢 Connected to...      │
│   Sensor Location: Chest    │
│                             │
│   [Disconnect]              │
└─────────────────────────────┘
```

### Pantalla de Configuración
```
┌─────────────────────────────┐
│  Cancel         Settings    │
├─────────────────────────────┤
│  PERSONAL INFORMATION       │
│  ┌─────────────────────┐    │
│  │ Age          [30]   │    │
│  └─────────────────────┘    │
│                             │
│  CALCULATED ZONES           │
│  Maximum HR:     190 BPM    │
│  Target (70%):   133 BPM    │
│  Target (80%):   152 BPM    │
│                             │
│  Your Target Zone           │
│  133 - 152 BPM             │
│                             │
│  ZONE DESCRIPTIONS          │
│  🔵 Below Target (<70%)     │
│     Too low - increase      │
│                             │
│  🟢 Target Zone (70-80%)    │
│     Perfect training zone   │
│                             │
│  🔴 Above Target (>80%)     │
│     Too high - reduce       │
│                             │
│  [Save Configuration]       │
└─────────────────────────────┘
```

## 📱 Cómo Usar

### Primera Vez:
1. **Abre la app**
2. **Toca el botón ⚙️** en la esquina superior derecha
3. **Ingresa tu edad** (10-100 años)
4. **Toca "Save Configuration"**
5. Las zonas se calculan automáticamente

### Usando con el Sensor:
1. **Conecta tu Cycplus H2** (o dispositivo mock en simulador)
2. **Comienza tu entrenamiento**
3. **Observa el indicador de zona** en tiempo real
4. **Mantente en la zona verde** (70-80%)
5. **Responde a las alertas**:
   - 🔵 Beep grave → Aumenta intensidad
   - 🔴 Beep agudo → Reduce intensidad

## 🔊 Sonidos del Sistema Usados

| Zona | System Sound ID | Descripción |
|------|----------------|-------------|
| Below Target | 1054 | Beep grave, tono bajo |
| Above Target | 1016 | Beep agudo, tono alto |

Estos sonidos son parte del sistema iOS y no requieren archivos adicionales.

## 💾 Persistencia de Datos

La app guarda automáticamente:
- ✅ Tu edad
- ✅ Zonas calculadas se recalculan al abrir la app

**Ubicación**: `UserDefaults` con key `"userAge"`

## 🧮 Fórmulas Utilizadas

### Frecuencia Cardíaca Máxima
```
FC_max = 220 - edad
```

### Zona Objetivo (70-80%)
```
Zona_min = FC_max × 0.70
Zona_max = FC_max × 0.80
```

### Porcentaje Actual
```
Porcentaje = (FC_actual / FC_max) × 100
```

## 📋 Archivos Creados

### Nuevos Archivos:
1. **HeartRateSettings.swift**
   - Clase `@Observable` para configuración
   - Cálculo de zonas
   - Persistencia en UserDefaults
   - Enum `HeartRateZone`

2. **HeartRateAlertManager.swift**
   - Gestor de alertas sonoras
   - Sistema de repetición de alertas
   - Feedback háptico

3. **SettingsView.swift**
   - UI de configuración
   - Validación de edad
   - Visualización de zonas calculadas
   - Explicación de zonas

4. **HEART_RATE_ZONES_GUIDE.md**
   - Este archivo (documentación completa)

### Archivos Modificados:
1. **ContentView.swift**
   - Integración de settings
   - Integración de alert manager
   - Nuevo componente `ZoneIndicatorView`
   - Toolbar con botón de configuración
   - `onChange` para monitorear FC

2. **MockBluetoothManager.swift**
   - Ajustes en `MockPeripheral`
   - Eliminada conformidad al protocolo deprecated

## 🎯 Casos de Uso

### Caso 1: Usuario de 25 años entrenando
```
Edad: 25
FC Max: 195 BPM
Zona: 137-156 BPM

Durante entrenamiento:
- 120 BPM → 🔵 Alerta grave → "Aumenta intensidad"
- 145 BPM → 🟢 Perfecto → Sin alerta
- 165 BPM → 🔴 Alerta aguda → "Reduce intensidad"
```

### Caso 2: Usuario de 50 años entrenando
```
Edad: 50
FC Max: 170 BPM
Zona: 119-136 BPM

Durante entrenamiento:
- 110 BPM → 🔵 Alerta grave
- 128 BPM → 🟢 Perfecto
- 145 BPM → 🔴 Alerta aguda
```

## 🚀 Mejoras Futuras Posibles

- [ ] Historial de entrenamientos
- [ ] Gráficos de FC en tiempo real
- [ ] Exportar datos a HealthKit
- [ ] Múltiples zonas personalizables
- [ ] Entrenamientos por intervalos
- [ ] Notificaciones locales
- [ ] Sonidos personalizados
- [ ] Apple Watch companion app

## 🔧 Troubleshooting

### No veo el indicador de zona
- ✅ Verifica que ingresaste tu edad en configuración
- ✅ Asegúrate de estar conectado a un dispositivo
- ✅ Espera a que llegue la primera lectura de FC

### No escucho las alertas
- ✅ Verifica que el volumen no esté en silencio
- ✅ Desactiva "No Molestar"
- ✅ Los sonidos del sistema deben estar habilitados

### Las zonas parecen incorrectas
- ✅ Revisa que ingresaste la edad correcta
- ✅ La fórmula 220-edad es estándar pero aproximada
- ✅ Consulta con un profesional médico para zonas personalizadas

## 📚 Referencias

- [Fórmula de FC Máxima](https://www.heart.org/en/healthy-living/fitness/fitness-basics/target-heart-rates)
- [Zonas de Entrenamiento](https://www.polar.com/blog/running-heart-rate-zones-basics/)
- [Apple System Sounds](https://github.com/TUNER88/iOSSystemSoundsLibrary)

---

¡Disfruta tu entrenamiento con monitoreo inteligente de frecuencia cardíaca! ❤️💪
