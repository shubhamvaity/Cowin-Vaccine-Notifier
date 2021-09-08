import 'dart:async';

main() {
  const oneSec = const Duration(seconds: 1);
  new Timer.periodic(oneSec, (Timer t) => print('hi!'));
}
