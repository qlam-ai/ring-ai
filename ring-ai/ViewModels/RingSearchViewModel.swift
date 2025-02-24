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
    @Published var todayCalories: Int = 0
    @Published var todayDistance: Int = 0
    @Published var stepsHistory: [Int] = []

    private var centralManager: CBCentralManager!
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
        statusMessage = "Searching for device..."
        deviceFound = false
        deviceName = ""

        if centralManager.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: nil, options: nil)

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
        scanTimeout?.cancel()
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            print("Bluetooth is not powered on.")
        }
    }

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

        if deviceName == "R02_9406" {
            self.isSearching = false
            self.statusMessage = "Found R02_9406"
            self.deviceFound = true
            self.centralManager.stopScan()
            self.deviceName = "R02_9406"
            
            self.connectedPeripheral = peripheral
            peripheral.delegate = self
            central.connect(peripheral, options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "device")")
        statusMessage = "Connected to device"
        isConnected = true
        peripheral.discoverServices(nil)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            print("Service UUID: \(service.uuid)")
            if service.uuid == uartServiceUUID {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            print("Characteristic UUID: \(characteristic.uuid)")
            if characteristic.uuid == rxCharacteristicUUID {
                rxCharacteristic = characteristic
            }
            if characteristic.uuid == txCharacteristicUUID {
                txCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }

        requestBatteryLevel()
        requestSteps(dayOffset: 0)
    }

    func requestBatteryLevel() {
        guard let peripheral = connectedPeripheral, let rxCharacteristic = rxCharacteristic else { return }

        var packet = Data(repeating: 0, count: 16)
        packet[0] = 0x03 // Battery command
        
        let checksum = packet[0..<15].reduce(0, +) % 255
        packet[15] = UInt8(checksum)
        
        peripheral.writeValue(packet, for: rxCharacteristic, type: .withResponse)
    }
    
    func fetchStepsForLast7Days() {
            self.stepsHistory.removeAll()
            for dayOffset in 0..<7 {
                self.requestSteps(dayOffset: dayOffset)
            }
        }

    func requestSteps(dayOffset: Int) {
        guard let peripheral = connectedPeripheral, let rxCharacteristic = rxCharacteristic else { return }
        
        print(UInt8(dayOffset))
        var packet = Data(repeating: 0, count: 16)
        packet[0] = 0x43 // Step command
        packet[1] = UInt8(dayOffset)
        //packet[1] = 0x00
        packet[2] = 0x0F
        packet[3] = 0x00
        packet[4] = 0x5F
        packet[5] = 0x01
        
        let checksum = packet[0..<15].reduce(0, +) % 255
        packet[15] = UInt8(checksum)
        
        peripheral.writeValue(packet, for: rxCharacteristic, type: .withResponse)
    }
    
    func fetchSportDetails(for date: Date) {
            // Convert date to day offset
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let selectedDay = calendar.startOfDay(for: date)
            let dayOffset = calendar.dateComponents([.day], from: selectedDay, to: today).day ?? 0
            
            requestSteps(dayOffset: dayOffset)
            print("calling with \(dayOffset)")
            
        }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard characteristic.uuid == txCharacteristicUUID,
              let data = characteristic.value,
              data.count == 16 else { return }

        if data[0] == 0x03 { // Battery level response
            let batteryPercentage = Int(data[1])
            DispatchQueue.main.async {
                self.batteryLevel = batteryPercentage
                self.statusMessage = "Battery Level: \(batteryPercentage)%"
                print("Battery Level: \(batteryPercentage)%")
            }
        }

        if data[0] == 0x43 { // Step data response
            let steps = Int(data[9]) | (Int(data[10]) << 8)
            let calories = Int(data[7]) | (Int(data[8]) << 8)
            let distance = Int(data[11]) | (Int(data[12]) << 8)

            DispatchQueue.main.async {
                self.stepsHistory.append(steps)
                            if self.stepsHistory.count > 7 {
                                self.stepsHistory.removeFirst()
                            }
                self.todaySteps = steps
                self.todayCalories = calories
                self.todayDistance = distance
                print("Steps: \(steps), Calories: \(calories), Distance: \(distance)m")
            }
        }
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect: \(error?.localizedDescription ?? "Unknown error")")
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
