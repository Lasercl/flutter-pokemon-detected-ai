# Flutter Pokemon Detected AI 🚀

A modern Flutter application that brings a retro Pokédex to life using edge AI (TensorFlow Lite). This application allows users to identify Pokémon from images using a custom-trained image classification model, all running locally on the device!

## 🌟 Features
- **AI-Powered Pokémon Detection**: Uses a custom TensorFlow Lite model (`model_flutter.tflite`) running at the native Android layer via a Kotlin bridge for fast, on-device image classification.
- **Retro Pokédex Aesthetic**: A beautifully crafted UI inspired by the classic Pokédex, complete with dynamic form-selection for identified Pokémon.
- **Deep PokeAPI Integration**: Fetches real-time, comprehensive data including species information, alternate forms, and Mega evolutions directly from [PokeAPI](https://pokeapi.co/).
- **Optimized for Mobile**: Avoids heavy TFLite "Flex Ops" by utilizing standard Float32 precision for seamless Android compatibility and reduced app size.

## 🛠️ Tech Stack
- **Frontend**: Flutter & Dart
- **Machine Learning**: TensorFlow Lite (Float32 Precision)
- **Native Android Bridge**: Kotlin (JNI `Interpreter` integration for fast inference)
- **External API**: [PokeAPI](https://pokeapi.co/)

## 📂 Project Architecture
The project heavily relies on native Android integration for ML inference to bypass common Flutter TFLite plugin limitations:
- **`lib/`**: Contains the Flutter UI (Screens, Widgets, Core styling) and API Services.
- **`android/app/src/main/kotlin/.../MainActivity.kt`**: Houses the native TensorFlow Lite execution engine, running image decoding and classification seamlessly.
- **`assets/`**: Contains the custom-trained TFLite model (`model_flutter.tflite`) and label maps.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.11.5 or higher)
- Android Studio / Android SDK (for native compilation)
- A physical Android device (Recommended for camera/TFLite inference)

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/Lasercl/flutter-pokemon-detected-ai.git
   ```
2. Navigate to the project directory:
   ```bash
   cd flutter-pokemon-detected-ai
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```
   > **Note:** Please ensure your physical device is adequately charged (>20%) and not in extreme battery-saving mode, as the Android OS may forcefully restrict the native JNI initialization process.

## 🧠 Model Details & Architecture
The AI model was trained using TensorFlow/Keras and exported to a standard TensorFlow Lite format. It is specifically optimized to avoid `ERROR_NEEDS_FLEX_OPS` by relying purely on standard TensorFlow Lite operations (Float32). This allows it to run smoothly natively without the heavy `tensorflow-lite-select-tf-ops` dependency, preventing native loading crashes.

### Architecture
The model uses **EfficientNetB0** as its base feature extractor, combined with a custom classification head to classify 150 different Pokémon species.
- **Base Model**: EfficientNetB0 (ImageNet weights, fine-tuned).
- **Input Shape**: 224x224 RGB images.
- **Custom Head**:
  - `Conv2D` (1280 filters, 1x1, ReLU) for dimensionality expansion.
  - `MaxPooling2D` (3x3, strides 1x1) for spatial downsampling.
  - `GlobalAveragePooling2D` to flatten spatial dimensions.
  - `Dropout` (0.4) to prevent overfitting.
  - `Dense` (150 units, Softmax) for final classification probabilities.

### Training Strategy
- **Mixed Precision**: Trained using `mixed_float16` for faster GPU computation, while keeping the output layer in `float32` for numerical stability.
- **Progressive Fine-Tuning**: Trained across 4 progressive phases with decaying learning rates (from `1e-4` down to `1e-7`) to carefully adjust the pre-trained EfficientNet weights without causing catastrophic forgetting.
- **Performance**: Achieved **~85.5%** accuracy on the unseen testing dataset.

---
*Created with ❤️ by Lasercl*