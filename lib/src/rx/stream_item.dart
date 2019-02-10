import 'package:rxdart/rxdart.dart';

/// Similar to [BehaviorSubject<T>], do not forget to call 'close' on this object when disposing!
/// TODO: Is there any way to make this object create a 'close stream' warning when forgetting implement a call to close?, similir to the warning produced by BehaviorSubject<T> when not implementing .close()?
/// TODO: Is there a way to make this closing behaviour more safe / automatic? Like a weak reference and a deinitializer in Swift?
class DataStream<T> {
  T _actualValue;
  final _streamController = BehaviorSubject<T>();

  DataStream(T initialValue) {
    value = initialValue;
  }

  ValueObservable<T> get valueObservable =>
      _streamController.stream.distinct().shareValue(seedValue: _actualValue);

  T get value {
    return _actualValue;
  }

  set value(T newValue) {
    _actualValue = newValue;
    _streamController.sink.add(_actualValue);
  }

  close() {
    _streamController.close();
  }
}
