//
//  NewView.swift
//  ring-ai
//
//  Created by Naim Sassine on 09/04/2025.
//

import SwiftUI

// Update NewRingView to use ActivityDetailView in the Activity tab
struct NewRingView: View {
    @ObservedObject var viewModel: RingSearchViewModel
    var body: some View {
        TabView {
            NavigationStack {
                HealthView(viewModel: viewModel)
                    .navigationTitle("Health")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {}) {
                                Image(systemName: "line.horizontal.3")
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {}) {
                                Image(systemName: "link")
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {}) {
                                Image(systemName: "square.and.arrow.up")
                            }
                        }
                    }
                    .navigationBarBackButtonHidden(true)
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            
            NavigationStack {
                ActivityDetailView(viewModel: viewModel)
                    .navigationTitle("Activity")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {}) {
                                Image(systemName: "square.and.arrow.up")
                            }
                        }
                    }
                    .navigationBarBackButtonHidden(true)
            }
            .tabItem {
                Image(systemName: "bolt.fill")
                Text("Activity")
            }
            
            Text("Sleep Tab")
                .tabItem {
                    Image(systemName: "moon.fill")
                    Text("Sleep")
                }
            
            Text("Me Tab")
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Me")
                }
        }
        .preferredColorScheme(.dark) // To match the dark theme in the screenshot
    }
}

// New Activity Detail View matching the Oura-style design
struct ActivityDetailView: View {
    @ObservedObject var viewModel: RingSearchViewModel
    // Use real Date objects for the date selector
    let dateCount = 7
    let calendar = Calendar.current
    let today = Calendar.current.startOfDay(for: Date())
    var dates: [Date] {
        (0..<dateCount).map { calendar.date(byAdding: .day, value: -$0, to: today)! }.reversed()
    }
    @State private var selectedDateIndex = 6 // default to today (last in array)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Date selector
                HStack(spacing: 8) {
                    ForEach(0..<dates.count, id: \.self) { index in
                        let date = dates[index]
                        let (dayStr, dateStr) = formattedDateParts(date)
                        DateTab(day: dayStr, date: dateStr, isSelected: index == selectedDateIndex)
                            .onTapGesture {
                                selectedDateIndex = index
                                viewModel.fetchSportDetails(for: date)
                            }
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.blue)
                            .font(.system(size: 20))
                    }
                }
                .padding(.horizontal)
                
                // Activity bar chart
                ZStack(alignment: .bottom) {
                    // Background for the chart
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black)
                        .frame(height: 180)
                    
                    // Bar chart
                    HStack(alignment: .bottom, spacing: 8) {
                        // Use real data if available, otherwise fallback to sample
                        ForEach(viewModel.stepsHistory.prefix(12).enumerated().map { $0 }, id: \.offset) { index, steps in
                            ActivityBar(
                                lowHeight: CGFloat(steps) / 12000.0, // scale for demo
                                mediumHeight: 0.3, // placeholder
                                highHeight: 0.1 // placeholder
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                    
                    // Legend
                    VStack {
                        Spacer()
                        HStack {
                            HStack {
                                Rectangle()
                                    .fill(Color(red: 0.1, green: 0.4, blue: 0.8))
                                    .frame(width: 12, height: 12)
                                Text("Low")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14))
                            }
                            
                            HStack {
                                Rectangle()
                                    .fill(Color(red: 0.3, green: 0.6, blue: 1.0))
                                    .frame(width: 12, height: 12)
                                Text("Medium")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14))
                            }
                            
                            HStack {
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(width: 12, height: 12)
                                Text("High")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 14))
                            }
                        }
                        .padding(.bottom, 5)
                    }
                }
                .frame(height: 180)
                .padding(.horizontal)
                
                // Stats grid - top row
                HStack(spacing: 16) {
                    ActivityStatCard(
                        title: "Goal progress",
                        value: "\(viewModel.todayCalories) / 300 Cal",
                        showChevron: true
                    )
                    
                    ActivityStatCard(
                        title: "Total burn",
                        value: "\(viewModel.todayCalories) Cal",
                        showChevron: true
                    )
                }
                .padding(.horizontal)
                
                // Stats grid - second row
                HStack(spacing: 16) {
                    ActivityStatCard(
                        title: "Walking equivalency",
                        value: String(format: "%.2f mi", Double(viewModel.todayDistance) / 1609.34),
                        showChevron: true
                    )
                    
                    ActivityStatCard(
                        title: "Steps",
                        value: "\(viewModel.todaySteps)",
                        showChevron: true
                    )
                }
                .padding(.horizontal)
                
                // Activity score
                ActivityScoreCard(score: String(viewModel.todaySteps / 100), status: "Optimal")
                    .padding(.horizontal)
                
                // Activity contributors section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Activity contributors")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .semibold))
                        .padding(.horizontal)
                    
                    ActivityContributorCard(
                        title: "Stay active",
                        value: "4h 59m inactivity",
                        progress: 0.7,
                        valueColor: .blue
                    )
                    
                    ActivityContributorCard(
                        title: "Move every hour",
                        value: "0 alerts",
                        progress: 0.3,
                        valueColor: .blue
                    )
                    
                    ActivityContributorCard(
                        title: "Meet daily goals",
                        value: "Optimal",
                        progress: 1.0,
                        valueColor: .blue
                    )
                    
                    ActivityContributorCard(
                        title: "Training frequency",
                        value: "Optimal",
                        progress: 1.0,
                        valueColor: .blue
                    )
                }
                .padding(.top, 8)
            }
            .padding(.vertical)
        }
        .background(Color.black)
    }
    
    // Helper to format date as two lines: day and date
    func formattedDateParts(_ date: Date) -> (String, String) {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "E"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d"
        return (dayFormatter.string(from: date), dateFormatter.string(from: date))
    }
}

// Date selector tab
struct DateTab: View {
    let day: String
    let date: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 2) {
            Text(day)
                .foregroundColor(isSelected ? .blue : .gray)
                .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                .lineLimit(1)
            Text(date)
                .foregroundColor(isSelected ? .blue : .gray)
                .font(.system(size: 14))
                .lineLimit(1)
        }
        .frame(width: 44)
        .padding(.vertical, 4)
        .background(Color.clear)
        .overlay(
            isSelected ? Rectangle()
                .fill(Color.blue)
                .frame(height: 3)
                .offset(y: 16) : nil
        )
    }
}

// Activity bar component
struct ActivityBar: View {
    let lowHeight: CGFloat
    let mediumHeight: CGFloat
    let highHeight: CGFloat
    
    private let maxHeight: CGFloat = 120
    
    var body: some View {
        VStack(spacing: 0) {
            // High intensity
            Rectangle()
                .fill(Color.white)
                .frame(width: 18, height: highHeight * maxHeight)
            
            // Medium intensity
            Rectangle()
                .fill(Color(red: 0.3, green: 0.6, blue: 1.0))
                .frame(width: 18, height: mediumHeight * maxHeight)
            
            // Low intensity
            Rectangle()
                .fill(Color(red: 0.1, green: 0.4, blue: 0.8))
                .frame(width: 18, height: lowHeight * maxHeight)
        }
        .cornerRadius(4)
    }
}

// Activity stat card component
struct ActivityStatCard: View {
    let title: String
    let value: String
    let showChevron: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
                
                Text(value)
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .bold))
            }
            
            Spacer()
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.15))
        )
        .frame(maxWidth: .infinity)
    }
}

// Activity score card component
struct ActivityScoreCard: View {
    let score: String
    let status: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Activity Score")
                    .foregroundColor(.gray)
                    .font(.system(size: 16))
                
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(score)
                        .foregroundColor(.white)
                        .font(.system(size: 40, weight: .bold))
                    
                    Image(systemName: "crown.fill")
                        .foregroundColor(.white)
                    
                    Text(status)
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.15))
        )
        .frame(maxWidth: .infinity)
    }
}

// Activity contributor card component
struct ActivityContributorCard: View {
    let title: String
    let value: String
    let progress: CGFloat
    let valueColor: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(title)
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                    
                    Spacer()
                    
                    Text(value)
                        .foregroundColor(valueColor)
                        .font(.system(size: 16))
                }
                
                // Progress bar
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(white: 0.3))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(valueColor)
                        .frame(width: progress * (UIScreen.main.bounds.width - 64), height: 4)
                        .cornerRadius(2)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(white: 0.15))
        )
        .padding(.horizontal)
    }
}

// Keep the rest of your previous implementation (HealthView, etc.)
struct HealthView: View {
    @ObservedObject var viewModel: RingSearchViewModel
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ActivityCard(viewModel: viewModel)
                SleepCard()
                HeartRateCard()
            }
            .padding(.horizontal)
        }
        .background(
            Image("run.jpg") // Replace with your asset name
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
    }
}

struct ActivityCard: View {
    @ObservedObject var viewModel: RingSearchViewModel
    var body: some View {
        CardView(title: "Activity", date: nil) {
            ZStack {
                Image("mountain_background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .brightness(-0.1)
                    .overlay {
                        LinearGradient(
                            colors: [.clear, Color.blue.opacity(0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                
                VStack {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                    
                    Text("Steps: \(viewModel.todaySteps)")
                        .foregroundColor(.white)
                        .padding(.top, 8)
                }
            }
            .frame(height: 120)
        }
        .background(Color(red: 0.2, green: 0.5, blue: 0.7))
    }
}

struct SleepCard: View {
    var body: some View {
        CardView(title: "Sleep", date: "07 Mar 2025") {
            ZStack {
                Image("night_sky")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                
                VStack {
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 10)
                            .frame(width: 160, height: 160)
                        
                        Circle()
                            .trim(from: 0, to: 0.7)
                            .stroke(Color.white, lineWidth: 10)
                            .frame(width: 160, height: 160)
                            .rotationEffect(.degrees(-90))
                        
                        VStack(spacing: 0) {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                            
                            Text("61")
                                .foregroundColor(.white)
                                .font(.system(size: 70, weight: .bold))
                            
                            Text("General")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        SleepProgressView()
                        
                        HStack {
                            Image(systemName: "bed.double.fill")
                                .foregroundColor(.white)
                            
                            Text("04 H 21 M")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .medium))
                            
                            Spacer()
                        }
                    }
                }
                .padding()
            }
            .frame(height: 260)
        }
        .background(Color(red: 0.05, green: 0.1, blue: 0.2))
    }
}

struct SleepProgressView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 2) {
                RoundedRectangle(cornerRadius: 3)
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width * 0.50, height: 6)
                
                RoundedRectangle(cornerRadius: 3)
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width * 0.12, height: 6)
                
                RoundedRectangle(cornerRadius: 3)
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width * 0.05, height: 6)
                
                RoundedRectangle(cornerRadius: 3)
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width * 0.05, height: 6)
                
                Spacer()
            }
            .background(
                RoundedRectangle(cornerRadius: 3)
                    .foregroundColor(.white.opacity(0.3))
                    .frame(height: 6)
            )
            
            HStack {
                Text("01:06")
                    .foregroundColor(.white)
                    .font(.system(size: 14))
                
                Spacer()
                
                Text("05:27")
                    .foregroundColor(.white)
                    .font(.system(size: 14))
            }
        }
    }
}

struct HeartRateCard: View {
    var body: some View {
        CardView(title: "Heart Rate", date: "07 Mar 2025") {
            VStack(alignment: .trailing) {
                HStack {
                    Spacer()
                    Text("160")
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                }
                
                Rectangle()
                    .foregroundColor(.white.opacity(0.3))
                    .frame(height: 1)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(Color.blue.opacity(0.15))
                        .frame(height: 80)
                }
                .padding(.top, 8)
            }
            .padding()
            .frame(height: 120)
        }
        .background(Color(red: 0.3, green: 0.5, blue: 0.65))
    }
}

struct CardView<Content: View>: View {
    let title: String
    let date: String?
    let content: Content
    
    init(title: String, date: String?, @ViewBuilder content: () -> Content) {
        self.title = title
        self.date = date
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if let date = date {
                        Text(date)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white)
            }
            .padding()
            
            content
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    NewRingView(viewModel: RingSearchViewModel())
}



// Preview provider
//struct NewRingView_Previews: PreviewProvider {
//    static var previews: some View {
//        NewRingView()
//    }
//}

// For SwiftUI app entry point
//@main
//struct HealthApp: App {
//    var body: some Scene {
//        WindowGroup {
//            NewRingView()
//        }
//    }
//}
