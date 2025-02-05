import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../data/apihelper.dart';
import '../../models/planning.dart';
import 'package:http/http.dart' as http;

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _previouslySelectedDay;
  List<Planning>? _plannings;
  bool _isProcessingCancelation = false;

  var heure_Year = "00:00";
  var heure_Month = "00:00";
  var heure_Week = "00:00";

  @override
  void initState() {
    super.initState();
    ShowUserInfo();
    _fetchPlannings();
  }

  void _closeAndRefresh() {
    Navigator.of(context).pop();
    _refreshPlannings();
  }
  void _refreshPlannings() async {
    _fetchPlannings();
  }

  void _fetchPlannings() async {
    _plannings = await AuthApi.getPlanningData();
    setState(() {});
  }

  void _showEditForm(Planning planning) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String salle = planning.salle;
        String heureDebut = planning.heureDebut.substring(0,5);
        String heureFin = planning.heureFin.substring(0,5);

        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start, // Aligne à gauche
                  children: [
                    Text(
                      "Modifier la mission",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A4494),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.red[400], // Couleur plus douce
                    size: 28, // Taille légèrement plus grande
                  ),
                  splashRadius: 24, // Ajoute un effet de splash plus petit
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero, // Réduit le padding par défaut
                  constraints: BoxConstraints(), // Minimise les contraintes
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(
                      Colors.red[100], // Couleur de l'effet hover plus douce
                    ),
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  initialValue: salle,
                  onChanged: (value) => salle = value,
                  decoration: InputDecoration(labelText: 'Salle'),
                ),
                TextFormField(
                  initialValue: heureDebut,
                  onChanged: (value) => heureDebut = value,
                  decoration: InputDecoration(labelText: 'Heure de début'),
                ),
                TextFormField(
                  initialValue: heureFin,
                  onChanged: (value) => heureFin = value,
                  decoration: InputDecoration(labelText: 'Heure de fin'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Soumettre'),
              onPressed: () {
                _confirmEditMission(planning, salle, heureDebut, heureFin);
              },
            ),
          ],
        );
      },
    );
  }

  void _showCancelForm(Planning planning) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          title: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Annuler la mission",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A4494),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.red[400],
                    size: 28,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
          content: Text('Êtes-vous sûr de vouloir annuler cette mission ?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Non'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Oui'),
              onPressed: () {
                Navigator.of(context).pop();
                _confirmCancelMission(planning);
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmEditMission(Planning planning, String salle, String heureDebut, String heureFin) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la modification'),
          content: Text('Voulez-vous vraiment modifier cette mission ?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Non'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Oui'),
              onPressed: () {
                Navigator.of(context).pop();
                AuthApi.updatePlanning(planning, salle, heureDebut, heureFin).then((success) {
                  _handleUpdateResult(success);
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmCancelMission(Planning planning) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Dernière confirmation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 50),
              SizedBox(height: 20),
              Text(
                "Êtes-vous absolument sûr de vouloir annuler cette mission ?",
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                "Cette action est irréversible !",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Non, annuler', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Oui, je suis sûr', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme le dialogue de confirmation
                Navigator.of(context).pop(); // Ferme le dialogue initial
                setState(() {
                  _isProcessingCancelation = true;
                });

                AuthApi.cancelMission(planning.prestationId).then((success) {
                  setState(() {
                    _isProcessingCancelation = false;
                  });
                  _handleCancelResult(success);
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildEventMarker(DateTime date, List<dynamic> events) {
    if (events.isNotEmpty) {
      Planning event = events.first;
      Color dotColor = _getDotColor(event.eventColor);

      return Positioned(
        right: 1,
        bottom: 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dotColor,
          ),
          width: 16.0,
          height: 16.0,
          child: Center(
            child: Text(
              '${events.length}',
              style: TextStyle().copyWith(
                color: Colors.white,
                fontSize: 12.0,
              ),
            ),
          ),
        ),
      );
    }
    return Container();
  }

  Color _getDotColor(String eventColor) {
    switch (eventColor) {
      case 'green':
        return Colors.green;
      case 'gray':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  void _showMissionDetails(DateTime date) {
    final plannings = _getPlanningsForDay(date);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          title:Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start, // Aligne à gauche
                  children: [
                    Icon(Icons.assignment, color: Color(0xFF2A4494)),
                    SizedBox(width: 10),
                    Text(
                      "Missions",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A4494),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: Colors.red[400], // Couleur plus douce
                    size: 28, // Taille légèrement plus grande
                  ),
                  splashRadius: 24, // Ajoute un effet de splash plus petit
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero, // Réduit le padding par défaut
                  constraints: BoxConstraints(), // Minimise les contraintes
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(
                      Colors.red[100], // Couleur de l'effet hover plus douce
                    ),
                  ),
                ),
              ),
            ],
          ),

          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: plannings.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Color(0xFF2A4494)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                plannings[index].lieu,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.meeting_room_rounded, color:Color(0xFF2A4494)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text("N\u00b0 "+plannings[index].salle),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.access_time, color:Color(0xFF2A4494)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(plannings[index].heureDebut.substring(0,5)),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.timer_off, color: Color(0xFF2A4494)),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(plannings[index].heureFin.substring(0,5)),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              child: Text('Modifier'),
                              onPressed: () {
                                _showEditForm(plannings[index]);
                              },
                            ),
                            if (plannings[index].btnCancel && !_isProcessingCancelation)
                              ElevatedButton(
                                child: Text('Annuler'),
                                onPressed: () {
                                  _showCancelForm(plannings[index]);
                                },
                              ),
                            if (_isProcessingCancelation)
                              CircularProgressIndicator(),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('Fermer'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleCancelResult(bool success) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(success ? 'Succès' : 'Échec'),
          content: Text(success
              ? 'Mission annulée avec succès.'
              : 'Erreur lors de l\'annulation de la mission.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _handleUpdateResult(bool success) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(success ? 'Succès' : 'Échec'),
          content: Text(success
              ? 'Opération effectuée avec succès.'
              : 'Échec de l\'opération.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> ShowUserInfo() async {
    final userInfo = await AuthApi.InfoUser();
    if (userInfo != null) {
      setState(() {
        heure_Year = userInfo.heureYear ?? '00:00';
        heure_Month = userInfo.heureMonth ?? '00:00';
        heure_Week = userInfo.heureWeek ?? '00:00';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
    double _h = MediaQuery.of(context).size.height;

    return MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('fr', 'FR'),
        ],
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.grey[200],
          body: ListView(
            children: [
              SizedBox(height: _h * 0.03),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(_w / 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(_w / 20),
                ),
                child: Text(
                  "Planning des missions du mois",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: _w / 24,
                  ),
                ),
              ),
              SizedBox(height: _h * 0.03),
              Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(_w / 20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      _refreshPlannings();
                    },
                    child: TableCalendar(
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Month',
                      },
                      locale: 'fr_FR',
                      focusedDay: _focusedDay,
                      firstDay: DateTime(2000),
                      lastDay: DateTime(2100),
                      calendarFormat: _calendarFormat,
                      eventLoader: _getPlanningsForDay,
                      onDaySelected: _onDaySelected,
                      onDayLongPressed: (selectedDay, focusedDay) {
                        _showMissionDetails(selectedDay);
                      },
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          return _buildEventMarker(date, events);
                        },
                      ),
                    ),
                  )
              ),
              SizedBox(height: _h * 0.03),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(_w / 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(_w / 20),
                ),
                child: Text(
                  "Nombres d'heures de prestation",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: _w / 24,
                  ),
                ),
              ),
              SizedBox(height: _h * 0.03),
              _buildHourContainer("Cette semaine", heure_Week, _w, _h),
              const SizedBox(height: 20.0),
              _buildHourContainer("Ce mois", heure_Month, _w, _h),
              const SizedBox(height: 20.0),
              _buildHourContainer("Cette année", heure_Year, _w, _h),
              const SizedBox(height: 30.0),
            ],
          ),
        ));
  }
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (_previouslySelectedDay != null &&
        selectedDay.day == _previouslySelectedDay!.day &&
        selectedDay.month == _previouslySelectedDay!.month &&
        selectedDay.year == _previouslySelectedDay!.year) {
      _showMissionDetails(selectedDay);
    } else {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
    _previouslySelectedDay = selectedDay;
  }
  Widget _buildHourContainer(String title, String hours, double _w, double _h) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_w / 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_w / 20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            "assets/images/mission.png",
            height: _h * 0.06,
          ),
          Container(
            width: _w * 0.35,
            padding: EdgeInsets.all(_w / 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(_w / 20),
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  hours,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: _w / 24,
                  ),
                ),
                SizedBox(height: _h * 0.005),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: _w / 28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Planning> _getPlanningsForDay(DateTime date) {
    final List<Planning> plannings = _plannings ?? [];
    return plannings
        .where((p) {
      final eventDate = DateTime.tryParse(p.datePres) ?? DateTime(0);
      return eventDate.day == date.day &&
          eventDate.month == date.month &&
          eventDate.year == date.year;
    })
        .toList()
      ..sort((a, b) => a.matinSoir.compareTo(b.matinSoir)); // Trie la liste selon matin/soir
  }



}
