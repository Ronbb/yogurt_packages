A library that provides support for synchronous and asynchronous event bus functionality.

## Features

- Supports both synchronous and asynchronous event handling.
- Allows easy communication between different parts of your Dart application.

## Getting started

To start using the library, add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  yogurt_event_bus: any
```

## Usage

Here's a simple example demonstrating how to use the library:

```dart
final bus = AsyncEventBus(
    state: const _TestState(null),
    plugins: [_TestPlugin()],
);

final result = await bus.invoke(const _TestEvent(null));
```
