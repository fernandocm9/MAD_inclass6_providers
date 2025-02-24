import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';

void main() {
  setupWindow();
  runApp(
    // Provide the model to all widgets within the app. We're using
    // ChangeNotifierProvider because that's a simple way to rebuild
    // widgets when a model changes. We could also just use
    // Provider, but then we would have to listen to Counter ourselves.
    //
    // Read Provider's docs to learn about all the available providers.
    ChangeNotifierProvider(
      // Initialize the model in the builder. That way, Provider
      // can own Counter's lifecycle, making sure to call `dispose`
      // when not needed anymore.
      create: (context) => Counter(),
      child: const MyApp(),
    ),
  );
}

const double windowWidth = 360;
const double windowHeight = 640;
void setupWindow() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    WidgetsFlutterBinding.ensureInitialized();
    setWindowTitle('Provider Counter');
    setWindowMinSize(const Size(windowWidth, windowHeight));
    setWindowMaxSize(const Size(windowWidth, windowHeight));
    getCurrentScreen().then((screen) {
      setWindowFrame(
        Rect.fromCenter(
          center: screen!.frame.center,
          width: windowWidth,
          height: windowHeight,
        ),
      );
    });
  }
}

// Simplest possible model, with just one field.
//
// [ChangeNotifier] is a class in `flutter:foundation`. [Counter] does
// _not_ depend on Provider.
class Counter with ChangeNotifier {
  int value = 0;
  void increment() {
    if (value >= 100) {
      return;
    }

    value += 1;
    notifyListeners();
  }
  
  void decrement() {
    if (value <= 0) {
      return;
    }
    value -= 1;
    notifyListeners();
  }

  void setValue(int newValue) {
    value = newValue;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // String milestoneMessage = 'You\'re a child';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const MyHomePage(),
    );
  }
}


class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Age counter'), backgroundColor: Colors.blue,),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Consumer looks for an ancestor Provider widget
            // and retrieves its model (Counter, in this case).
            // Then it uses that model to build widgets, and will trigger
            // rebuilds if the model is updated.
            Consumer<Counter>(
              builder:
                  (context, counter, child){
                  String milestoneMessage = '';
                  Color backgroundColor = Colors.white;

                  if (counter.value < 13) {
                    milestoneMessage = 'You\'re a child!';
                    backgroundColor = Colors.lightBlue;
                  } else if (counter.value < 20) {
                    milestoneMessage = 'Teenager time!';
                    backgroundColor = Colors.lightGreen;
                  } else if (counter.value < 31) {
                    milestoneMessage = 'You\'re a young adult!';
                    backgroundColor = Colors.yellow;
                  } else if (counter.value < 51) {
                    milestoneMessage = 'You\'re an adult now!';
                    backgroundColor = Colors.orange;
                  } else {
                    milestoneMessage = 'Golden years!';
                    backgroundColor = Colors.grey;
                  };

                  return Container(
                  // width: double.infinity,  // Ensures full width
                  // padding: EdgeInsets.all(16),  // Adds spacing inside the container
                  color: backgroundColor,
                  child: Column(
                    children: [
                      Text(
                        'I am ${counter.value} years old.',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        milestoneMessage,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            ElevatedButton(onPressed: () {context.read<Counter>().increment();}, child: Text('Increase Age')),
            ElevatedButton(onPressed: () {context.read<Counter>().decrement();}, child: Text('Decrease Age')),
            Consumer<Counter>(
              builder: (context, counter, child) {
                return Slider(
                  value: counter.value.toDouble(),
                  min: 0,
                  max: 100,
                  onChanged: (newValue) {
                    counter.setValue(newValue.toInt());
                  },
                );
              },
            ),
            Consumer<Counter>(
              builder: (context, counter, child) {
                double progress = (counter.value ~/ 33) / 3;
                Color barColor;

                if (progress < 0.34) {
                  barColor = Colors.green;
                } else if (progress < 0.67) {
                  barColor = Colors.yellow;
                } else {
                  barColor = Colors.red;
                }

                return LinearProgressIndicator(
                  value: progress, 
                  backgroundColor: Colors.grey,
                  color: barColor,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // You can access your providers anywhere you have access
          // to the context. One way is to use Provider.of<Counter>(context).
          // The provider package also defines extension methods on the context
          // itself. You can call context.watch<Counter>() in a build method
          // of any widget to access the current state of Counter, and to ask
          // Flutter to rebuild your widget anytime Counter changes.
          //
          // You can't use context.watch() outside build methods, because that
          // often leads to subtle bugs. Instead, you should use
          // context.read<Counter>(), which gets the current state
          // but doesn't ask Flutter for future rebuilds.
          //
          // Since we're in a callback that will be called whenever the user
          // taps the FloatingActionButton, we are not in the build method here.
          // We should use context.read().
          var counter = context.read<Counter>();
          counter.increment();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
