import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/planning.dart';

class MissionListScreen extends StatelessWidget {
  final List<Planning> plannings;

  const MissionListScreen({
    Key? key,
    required this.plannings, required missionEffUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des missions'),
      ),
      body: ListView.builder(
        itemCount: plannings.length,
        itemBuilder: (context, index) {
          final Planning planning = plannings[index];

          return Card(
            child: ListTile(
              title: Text(planning.salle),
              subtitle: Text(planning.lieu),
              trailing: Text(planning.duree.toString()),
              isThreeLine: true,

            ),
          );
        },
      ),
    );
  }
}
