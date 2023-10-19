# JourneyMetric

The **JourneyMetric** is an iOS application developed with SwiftUI, designed to enhance your travel experience. It provides information about train stations, allows you to search for stations based on keywords, and calculates distances between selected start and end stations. The app incorporates a caching mechanism to optimize data retrieval from the Koleo API.

## Features

- **Search Stations:** Enter station names to search for matching stations.
- **Calculate Distance:** Select start and end stations to calculate the distance between them.
- **Error Handling:** Gracefully handle errors, allowing users to retry fetching data.

## Installation

To run the app locally, follow these steps:

1. **Clone the repository**
2. **Open in Xcode**
3. **Build and run the project using the Xcode simulator or a connected iOS device.**

## Usage

1. **Launch the app:**
Launch the app on the simulator or your iOS device.

2. **Enter station names:**
Enter the names of start and end stations.

3. **Select stations:**
The app will display matching stations and allow you to select them.

4. **Calculate distance:**
Once stations are selected, the app will calculate the distance between them.

## Notes

The app incorporates a caching mechanism to store station and keyword data locally, reducing the need for frequent API calls.
Data is refreshed from the API if more than 24 hours have passed since the last fetch.
