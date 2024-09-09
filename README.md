# Flutter Google Maps 3D Pins

<p align="center">
  <img src="https://i.giphy.com/media/v1.Y2lkPTc5MGI3NjExaGhnOGJjNHc1dm1uMjdpaDJrdnJjZWY2OTVxcjg1amJlcG04MWx3MyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/KJWtNdFPrDYPrfXFer/giphy.gif" alt="Bouncing Ball Tab Animation" width="300">
</p>

## Overview

This Flutter project demonstrates how to add 3D vehicle models on top of Google Maps, creating an interactive and visually appealing map experience similar to ride-sharing apps like Uber. The project uses pre-rendered 3D models and real-time coordinate conversion to achieve smooth animations and rotations of vehicles on the map.

# Welcome to Day 5 of my 7-Day Flutter Challenge! 🚀
What's This All About?


https://github.com/user-attachments/assets/b9eb6d63-28e4-44d0-9ba2-1a97c22d80be


https://codinglollypop.medium.com/7-days-of-flutter-fun-a-visual-journey-through-animations-4caeb556403e

## Features

- Integration with Google Maps in Flutter
- Custom 3D vehicle markers using pre-rendered images
- Smooth animation of vehicle position and rotation
- Real-time conversion of geographic coordinates to screen coordinates
- Multiple vehicle support with independent movements
- Optimized performance for mobile devices

## Prerequisites

- Google Maps API key

## Installation

1. Clone this repository:

```git clone https://github.com/yourusername/flutter_google_maps_3d_pins.git```

2. Navigate to the project directory:

```cd flutter_google_maps_3d_pins```

3. Install dependencies:

```flutter pub get```

4. Add your Google Maps API key:
- Replace `YOUR_API_KEY` with your actual API key

5. Run the app:

```flutter run```

## Project Structure

- `lib/main.dart`: Entry point of the application
- `lib/map_with_overlay.dart`: Main widget for Google Maps integration and 3D vehicle rendering
- `lib/car_marker_widget.dart`: Widget for rendering the 3D vehicle marker
- `lib/route.dart`: Classes for handling route data
- `lib/data/notifier.dart`: State management for vehicle positions and rotations

## How It Works

1. **3D Model Preparation**: We use pre-rendered images of a 3D vehicle model from 60 different angles.

2. **Google Maps Integration**: The app uses the Google Maps Flutter plugin to display the map.

3. **Coordinate Conversion**: Geographic coordinates (latitude, longitude) are converted to screen coordinates in real-time.

4. **Animation**: Vehicle markers are animated using Flutter's animation system for smooth movement and rotation.

5. **State Management**: The app uses Riverpod for efficient state management of vehicle positions and rotations.

## Customization

- To use a different 3D model, replace the images in the `assets/images/truck/` directory.
- Adjust the number of pre-rendered images by modifying the `imageCount` constant in `car_marker_widget.dart`.
- Customize vehicle movement patterns by modifying the `updateRoute` method in `data/notifier.dart`.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

- [Google Maps Flutter Plugin](https://pub.dev/packages/google_maps_flutter)
- [Flutter Riverpod](https://pub.dev/packages/flutter_riverpod)
- [Kenny 3d cars kit](https://opengameart.org/content/car-kit)
