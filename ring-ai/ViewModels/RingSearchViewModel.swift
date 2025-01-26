import SwiftUI
import CoreBluetooth

class RingSearchViewModel: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var isSearching = false
    @Published var statusMessage = "No Device Found"
    @Published var deviceFound = false
    @Published var deviceName = ""
    @Published var discoveredDevices: [CBPeripheral] = []
    @Published var receivedData: String = ""
    @Published var batteryLevel: Int = 0
    @Published var isConnected = false
    
    @Published var todaySteps: Int = 0


    

    private var centralManager: CBCentralManager!
    private let targetServiceUUID = CBUUID(string: "38291DF5-CC76-CD02-B835-52316BD80C45")
    private var discoveredPeripheral: CBPeripheral?
    private var scanTimeout: DispatchWorkItem?
    private var connectedPeripheral: CBPeripheral?
    
    private let uartServiceUUID = CBUUID(string: "6E40FFF0-B5A3-F393-E0A9-E50E24DCCA9E")
    private let rxCharacteristicUUID = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
    private let txCharacteristicUUID = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
    
    
    private var rxCharacteristic: CBCharacteristic?
    private var txCharacteristic: CBCharacteristic?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func searchForDevice() {
        print("Searching for device...")
        isSearching = true
        statusMessage = "Searching for device with target UUID..."
        deviceFound = false
        deviceName = ""

        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)

            // Set a timeout to stop the scan after 15 seconds
            scanTimeout = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                if self.isSearching {
                    self.centralManager.stopScan()
                    self.isSearching = false
                    self.statusMessage = "Search timed out. No device found."
                    self.deviceFound = true
                    print("Search stopped after timeout.")
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 15, execute: scanTimeout!)
        } else {
            statusMessage = "Bluetooth is not powered on."
            isSearching = false
        }
    }

    func stopSearch() {
        centralManager.stopScan()
        isSearching = false
        statusMessage = "Search stopped manually."
        scanTimeout?.cancel() // Cancel the timeout if it hasn't executed yet
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            print("Bluetooth is not powered on.")
        }
    }

//    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
//        print("Discovered device: \(peripheral.name ?? "Unknown")")
//        print(RSSI)
//
//        // Device advertising the target UUID found
//        discoveredPeripheral = peripheral
//        deviceName = peripheral.name ?? "Unnamed Device"
//        deviceFound = true
//        statusMessage = "Device found!"
//        isSearching = false
//
//        // Stop scanning and cancel timeout once the device is found
//        centralManager.stopScan()
//        scanTimeout?.cancel()
//    }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let deviceName = peripheral.name ?? "Unknown Device"
        let deviceUUID = peripheral.identifier.uuidString
        
        print("Discovered device: \(deviceName)")
        print("UUID: \(deviceUUID)")
        print("RSSI: \(RSSI)")
        print("Advertisement Data: \(advertisementData)")
        
        
        if !discoveredDevices.contains(where: { $0.identifier == peripheral.identifier }) {
                    discoveredDevices.append(peripheral)
                }
        
        if deviceName == "R02_5C07"{
            self.isSearching = false
            self.statusMessage = "Found R02_5C07"
            self.deviceFound = true
            self.centralManager.stopScan()
            self.deviceName = "R02_5C07"
            
            self.connectedPeripheral = peripheral
            peripheral.delegate = self
            central.connect(peripheral, options: nil)
            
            
            
            
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
            print("Connected to \(peripheral.name ?? "device")")
            statusMessage = "Connected to device"
            isConnected = true
            
            // Discover services
            peripheral.discoverServices(nil)
        }

        // CBPeripheralDelegate method for service discovery
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            print("Service UUID: \(service.uuid)")
            if service.uuid.uuidString == "6E40FFF0-B5A3-F393-E0A9-E50E24DCCA9E" {
                        peripheral.discoverCharacteristics(nil, for: service)
                    }
            
        }
    }

    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            print("Characteristic UUID: \(characteristic.uuid)")
            print("Properties: \(characteristic.properties)")
            if characteristic.uuid == rxCharacteristicUUID {
                rxCharacteristic = characteristic
            }
            if characteristic.uuid == txCharacteristicUUID {
                txCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
        
        requestBatteryLevel()
        requestSteps()
    }
    
    func requestBatteryLevel() {
            guard let peripheral = connectedPeripheral,
                  let rxCharacteristic = rxCharacteristic else { return }
            
            var packet = Data(repeating: 0, count: 16)
            packet[0] = 0x03 // Battery level command
            
            // Calculate checksum
            let checksum = packet[0..<15].reduce(0, +) % 255
            packet[15] = UInt8(checksum)
            
            peripheral.writeValue(packet, for: rxCharacteristic, type: .withResponse)
        }
    
    func requestSteps() {
            guard let peripheral = connectedPeripheral,
                  let rxCharacteristic = rxCharacteristic else { return }
            
            var packet = Data(repeating: 0, count: 16)
            packet[0] = 0x43 // Step command
            packet[1] = 0x00 // Today's steps
            packet[2] = 0x0F // Constant
            packet[3] = 0x00 // Unknown
            packet[4] = 0x5F // Less than 95
            packet[5] = 0x01 // Constant
            
            // Calculate checksum
            let checksum = packet[0..<15].reduce(0, +) % 255
            packet[15] = UInt8(checksum)
            
            peripheral.writeValue(packet, for: rxCharacteristic, type: .withResponse)
        }

        // CBPeripheralDelegate method for receiving characteristic values
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard characteristic.uuid.uuidString == txCharacteristicUUID.uuidString,
              let data = characteristic.value,
              data.count == 16 else { return }
        
        // Battery level check
        if data[0] == 0x03 {
            let batteryPercentage = Int(data[1])
            
            DispatchQueue.main.async {
                self.batteryLevel = batteryPercentage
                self.statusMessage = "Battery Level: \(batteryPercentage)%"
                print("Battery Level: \(batteryPercentage)%")
            }
        }
        
        // Steps check
        if data[0] == 0x43 {
            let steps = Int(data[9]) | (Int(data[10]) << 8)
            
            DispatchQueue.main.async {
                self.todaySteps = steps
                print("Today's Steps: \(steps)")
            }
        }
    }
    
    

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to device: \(error?.localizedDescription ?? "Unknown error")")
        statusMessage = "Connection failed"
    }

    func disconnectDevice() {
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
            connectedPeripheral = nil
            statusMessage = "Disconnected"
        }
    }
    
    
    
    
}
