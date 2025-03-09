# Building a Smart Ring App: An Open-Source Alternative to Oura Ring

Like many health enthusiasts, I've been fascinated by smart rings like the Oura Ring. These devices offer comprehensive health tracking, from sleep patterns to daily activity levels. However, the steep price point and recurring subscription fees made me look for alternatives. I realized that for my basic needs—primarily tracking steps and heart rate—there had to be a more cost-effective solution.

## Colmi R02

My research led me to the Colmi R02, a budget-friendly smart ring available on platforms like Aliexpress and DHgate from various vendors for around 20-25 euros. Online reviews suggest that while it can't compete with premium devices like Whoop or Apple Watch, it offers decent health tracking capabilities for its price point. The main drawback mentioned in reviews is its subpar battery life.

While the ring comes with its own app, it's from an unknown vendor with unclear data privacy practices. This uncertainty about data handling and tracking was a significant concern.

That's when I discovered [Tahnok's open-source Python client](https://github.com/tahnok/colmi_r02_client) for the Colmi R02. This project demonstrated how to extract essential metrics like heart rate, SPO2, and step counts directly from the device. However, the need to connect the ring to a laptop for data access was inconvenient, which inspired me to develop my own iOS app.

### Python to Swift

Converting Tahnok's Python implementation to Swift enabled direct communication with the ring via Bluetooth Low Energy (BLE) on iOS. The conversion process involved:

- Implementing BLE device discovery and connection handling
- Translating the ring's data protocols to Swift
- Creating a clean, intuitive UI for data visualization

The BLE implementation proved challenging, especially given my lack of experience and the limited documentation for Swift's BLE library. Fortunately, I found excellent resources in [Adafruit's guide](https://cdn-learn.adafruit.com/downloads/pdf/build-a-bluetooth-app-using-swift-5.pdf) and [this Medium article](https://medium.com/@bhumitapanara/ble-bluetooth-low-energy-with-ios-swift-7ef0de0dff78), which helped jumpstart the development process (Thanks to Claude as well!).

The only downside is that developing without a paid Apple developer account means the app expires every 7 days, requiring weekly re-provisioning. While this works for my personal use case, it's frustrating that Apple restricts how long self-developed apps can remain active on your own device. It seems counterintuitive that we can't control the lifespan of apps we build for our personal use.

## Adding AI Integration
Whats an article without AI buzzwords? 
Since I wanted to embrace the recent AI trends, I incorporated an AI feature that generates weekly health summaries. The app aggregates weekly metrics and uses an LLM to provide human-readable insights. While I initially explored running Phi-3 locally using Apple's MLX framework or llama.cpp, memory constraints on my older iPhone led me to adopt an API-based approach. Users with newer devices can experiment with local Phi-3 implementation using [this guide](https://github.com/ml-explore/mlx-swift-examples/blob/main/Applications/LLMEval/README.md).

## The App Interface

The interface maintains a minimalist design with two core functions:

1. **Daily Stats View**: Monitor current metrics and review weekly data
2. **AI Summary View**: Receive AI-generated health trend analysis

While it may not offer all the features of premium devices, it provides a solid foundation for basic health tracking without subscription fees—and might inspire you to build your own solution!

## Getting Started

To try the app yourself, you'll need:

- An iPhone running iOS 14 or later
- A Colmi R02 ring
- Xcode for building and deploying the app

Just clone this repository, adapt the code to your liking, and build to your device.

---





