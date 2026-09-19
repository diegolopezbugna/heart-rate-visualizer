# Bluetooth Setup Instructions

## Required: Add Bluetooth Permissions

You need to add the following entries to your app's Info.plist file:

### For iOS 13 and later:
1. Open your project in Xcode
2. Select your target
3. Go to the "Info" tab
4. Add these keys by clicking the "+" button:

**NSBluetoothAlwaysUsageDescription**
- Key: `Privacy - Bluetooth Always Usage Description`
- Value: `This app needs Bluetooth to connect to your Cycplus H2 heart rate sensor`

**NSBluetoothPeripheralUsageDescription** (for iOS 12 and earlier compatibility)
- Key: `Privacy - Bluetooth Peripheral Usage Description`
- Value: `This app needs Bluetooth to connect to your heart rate sensor`

## Alternative: Edit Info.plist as Source Code

If you prefer to edit the raw plist file, add these lines:

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs Bluetooth to connect to your Cycplus H2 heart rate sensor</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app needs Bluetooth to connect to your heart rate sensor</string>
```

## How to Use the App

1. **Enable Bluetooth** on your device
2. **Turn on your Cycplus H2 sensor** and ensure it's in pairing mode
3. **Launch the app** and tap "Scan for Devices"
4. **Select your Cycplus H2** from the list of discovered devices
5. The app will connect and start displaying your heart rate in real-time

## Features Implemented

✅ Bluetooth LE scanning for heart rate devices
✅ Connection management (connect/disconnect)
✅ Real-time heart rate display with animated heart icon
✅ Sensor location information
✅ Connection status indicator
✅ Device selection interface
✅ Standard Bluetooth Heart Rate Profile (compatible with most HR sensors)

## Troubleshooting

- **No devices found**: Make sure your sensor is on and in pairing mode
- **Connection fails**: Try turning the sensor off and on again
- **No heart rate data**: Ensure the sensor is properly positioned on your body
- **Bluetooth permission denied**: Go to Settings > Privacy > Bluetooth and enable it for this app

## Technical Details

The app uses the standard Bluetooth Heart Rate Service (UUID: 180D) which is implemented by most heart rate monitors, including the Cycplus H2. The implementation:

- Automatically discovers heart rate services
- Subscribes to heart rate measurement notifications
- Parses both 8-bit and 16-bit heart rate values
- Reads sensor body location information
- Uses SwiftUI's @Observable for reactive updates
