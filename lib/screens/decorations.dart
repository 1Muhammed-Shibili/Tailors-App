import 'package:flutter/material.dart';

BoxDecoration customContainer() {
  return const BoxDecoration(
    color: Color(0xFFfdebea),
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(35),
      topRight: Radius.circular(35),
    ),
  );
}

TextStyle forgotstyle() {
  return const TextStyle(
    fontSize: 16,
    color: Colors.black,
    fontWeight: FontWeight.w400,
  );
}

TextStyle customTextStyle() {
  return const TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );
}

InputDecoration customInputDecoration(String hintText) {
  return InputDecoration(
    border: const OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    hintText: hintText,
    filled: true,
    fillColor: Colors.white,
  );
}

TextStyle customTextStyle2() {
  return const TextStyle(
    fontSize: 16,
    color: Colors.black,
    fontWeight: FontWeight.w500,
  );
}
