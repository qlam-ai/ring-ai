import SwiftUI
import Charts


struct DeviceFoundView: View {
    @ObservedObject var viewModel: RingSearchViewModel
    
    var batteryColor: Color {
        switch viewModel.batteryLevel {
        case 50...100:
            return .green
        case 20..<50:
            return .orange
        default:
            return .red
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Connected to \(viewModel.deviceName)")
                    .font(.title2)
                    .bold()
                    .padding(.top, 20)
                
                VStack {
                    ZStack {
                        Circle()
                            .trim(from: 0, to: CGFloat(viewModel.batteryLevel) / 100)
                            .stroke(batteryColor, lineWidth: 10)
                            .frame(width: 100, height: 100)
                            .rotationEffect(.degrees(-90))
                        
                        Text("\(viewModel.batteryLevel)%")
                            .font(.headline)
                            .bold()
                            .foregroundColor(batteryColor)
                    }
                    Text("Battery Level")
                        .font(.subheadline)
                }
                .padding(.vertical, 20)
                
                
                VStack(spacing: 20) {
                    NavigationLink(destination: HealthTrackingView(viewModel: viewModel)) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .font(.title)
                                .foregroundColor(.white)
                            Text("Health Tracking")
                                .font(.headline)
                                .bold()
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 60)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(30)
                        .shadow(radius: 5)
                        .padding(.horizontal, 20)
                    }
                    
                    NavigationLink(destination: AISummaryView()) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .font(.title)
                                .foregroundColor(.white)
                            Text("AI Summary")
                                .font(.headline)
                                .bold()
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 60)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(30)
                        .shadow(radius: 5)
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            .navigationBarHidden(true)
        }
    }
}

struct DateSelectionView: View {
    let title: String
    @Binding var selectedDate: Date
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            
            Spacer()
            
            DatePicker(
                "",
                selection: $selectedDate,
                in: ...Date(),
                displayedComponents: [.date]
            )
            .datePickerStyle(CompactDatePickerStyle())
            .frame(width: 150)
        }
        .padding(.horizontal)
    }
}


struct DateNavigatorView: View {
    let title: String
    @Binding var selectedDate: Date
    
    var body: some View {
        HStack {
            Button(action: {
                if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
                    selectedDate = newDate
                }
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
            }
            
            Spacer()
            
            Button(action: {
                selectedDate = Date()
            }) {
                Text(isToday ? "Today" : formattedDate)
                    .font(.headline)
            }
            
            Spacer()
            
            Button(action: {
                if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate),
                   newDate <= Date() {
                    selectedDate = newDate
                }
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(canGoForward ? .blue : .gray)
            }
        }
        .padding(.horizontal)
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }
    
    private var canGoForward: Bool {
        if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
            return nextDay <= Date()
        }
        return false
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: selectedDate)
    }
}


struct MetricBoxView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
            Text(value)
                .font(.headline)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}


struct StepsChartView: View {
    let stepsHistory: [(date: Date, steps: Int)]
    @Binding var tappedPoint: (date: Date, steps: Int)?
    
    var body: some View {
        VStack {
            Text("Steps History (Last 7 Days)")
                .font(.headline)
                .padding(.top, 10)
            
            if !stepsHistory.isEmpty {
                Chart {
                    ForEach(stepsHistory, id: \.date) { stepData in
                        LineMark(
                            x: .value("Date", stepData.date),
                            y: .value("Steps", stepData.steps)
                        )
                    }
                    .foregroundStyle(Color.blue)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    ForEach(stepsHistory, id: \.date) { stepData in
                        PointMark(
                            x: .value("Date", stepData.date),
                            y: .value("Steps", stepData.steps)
                        )
                        .foregroundStyle(Color.red)
                        .symbolSize(100)
                        .annotation(position: .top) {
                            if tappedPoint?.date == stepData.date {
                                VStack {
                                    Text("\(stepData.date, style: .date)")
                                        .font(.caption)
                                    Text("\(stepData.steps) steps")
                                        .font(.caption)
                                }
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                                .shadow(radius: 4)
                            }
                        }
                    }
                }
                .frame(height: 250)
                .padding()
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(Color.clear)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let currentPoint = value.location
                                        if let closestPoint = findClosestPoint(at: currentPoint, proxy: proxy, geometry: geometry) {
                                            tappedPoint = closestPoint
                                        }
                                    }
                            )
                    }
                }
            } else {
                Text("Loading...")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
    }
    
    private func findClosestPoint(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> (date: Date, steps: Int)? {
        let relativeXPosition = location.x - geometry.frame(in: .local).minX
        let relativeYPosition = location.y - geometry.frame(in: .local).minY
        
        guard let date = proxy.value(atX: relativeXPosition) as Date?,
              let steps = proxy.value(atY: relativeYPosition) as Double? else {
            return nil
        }
        
        // Find the closest point using both X and Y coordinates
        var closestPoint: (date: Date, steps: Int, distance: CGFloat)? = nil
        
        for point in stepsHistory {
            if let xPosition = proxy.position(forX: point.date),
               let yPosition = proxy.position(forY: point.steps) {
                
                let distance = sqrt(
                    pow(xPosition - relativeXPosition, 2) +
                    pow(yPosition - relativeYPosition, 2)
                )
                
                if closestPoint == nil || distance < closestPoint!.distance {
                    closestPoint = (point.date, point.steps, distance)
                }
            }
        }
        
        // Only return if we're within a reasonable distance (e.g., 30 points)
        if let closest = closestPoint, closest.distance < 30 {
            return (closest.date, closest.steps)
        }
        
        return nil
    }
}

// MARK: - Main View
struct HealthTrackingView: View {
    @ObservedObject var viewModel: RingSearchViewModel
    @State private var selectedDate = Date()
    @State private var stepsHistory: [(date: Date, steps: Int)] = []
    @State private var tappedPoint: (date: Date, steps: Int)? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            DateNavigatorView(title: "Select Date", selectedDate: $selectedDate)
            
            HStack(spacing: 15) {
                MetricBoxView(
                    title: "Steps",
                    value: "\(viewModel.todaySteps)",
                    icon: "figure.walk",
                    color: .blue
                )
                MetricBoxView(
                    title: "Calories",
                    value: "\(viewModel.todayCalories)",
                    icon: "flame",
                    color: .red
                )
                MetricBoxView(
                    title: "Distance",
                    value: "\(viewModel.todayDistance) m",
                    icon: "location.north.fill",
                    color: .green
                )
            }
            
            StepsChartView(stepsHistory: stepsHistory, tappedPoint: $tappedPoint)
            
            
            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.fetchStepsForLast7Days()
        }
        .onChange(of: selectedDate) { newDate, _ in
            viewModel.fetchSportDetails(for: newDate)
        }
        .onChange(of: viewModel.stepsHistory) { newHistory, _ in
            stepsHistory = newHistory.enumerated().map { (index, steps) in
                let date = Calendar.current.date(byAdding: .day, value: -index, to: Date()) ?? Date()
                return (date: date, steps: steps)
            }
        }
    }
}


struct MetricBox: View {
    var title: String
    var value: String
    var icon: String
    var color: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(color)
            Text(value)
                .font(.headline)
                .bold()
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(width: 150, height: 100)
        .background(RoundedRectangle(cornerRadius: 15).fill(Color(.systemGray6)))
        .shadow(radius: 3)
    }
}

#Preview {
    DeviceFoundView(viewModel: RingSearchViewModel())
}
