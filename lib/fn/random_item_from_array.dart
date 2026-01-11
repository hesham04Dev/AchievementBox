import 'dart:math';

getRandom(List items){
  if (items.isEmpty) return null;
  int random = Random().nextInt(items.length - 1);
  print("rad $random");
return items[random];
}
