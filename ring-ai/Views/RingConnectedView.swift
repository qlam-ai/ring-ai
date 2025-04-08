import SwiftUI

struct RingConnectedView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HealthView()
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
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            
            Text("Activity Tab")
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
    }
}

struct HealthView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ActivityCard()
                SleepCard()
                HeartRateCard()
            }
            .padding(.horizontal)
        }
    }
}

struct ActivityCard: View {
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
                    
                    Text("Please wear a smart ring to know your activities")
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
    RingConnectedView()
}
