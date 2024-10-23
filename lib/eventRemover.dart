import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'utils.dart';
import 'event.dart';

class Eventremover extends StatefulWidget {
  const Eventremover({super.key});

  @override
  State<Eventremover> createState() => _EventremoverState();
}

class _EventremoverState extends State<Eventremover> {
  final events = Provider.of<MyAppState>(context).events;
  
  
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
