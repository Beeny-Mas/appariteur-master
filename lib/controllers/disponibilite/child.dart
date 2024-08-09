import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../data/apihelper.dart';
import '../../models/disponibilites.dart';

class DisponibiliteScreen extends StatefulWidget {
  const DisponibiliteScreen({Key? key}) : super(key: key);

  @override
  _DisponibiliteScreenState createState() => _DisponibiliteScreenState();
}

class _DisponibiliteScreenState extends State<DisponibiliteScreen> {
  bool isMorningSelected = false;
  bool isEveningSelected = false;
  TimeOfDay _startMorning = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _endMorning = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _startEvening = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _endEvening = TimeOfDay(hour: 0, minute: 0);
  DateTime? _selectedStartDay;
  DateTime? _selectedEndDay;
  Set<DateTime> _selectedDates = {};
  Map<String, Disponibilite> allAvailabilities = {};
  DateTime? _lastSelectedDate;
  DateTime _lastTapTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchAllAvailabilities();
  }

  Future<void> _fetchAllAvailabilities() async {
    List<Disponibilite>? availabilities = await AuthApi.getDisponibilites();
    setState(() {
      for (var availability in availabilities ?? []) {
        allAvailabilities[availability.date] = availability;
      }
    });
  }

  Future<void> _handleDaySelected(DateTime day, DateTime focusedDay) async {
    final now = DateTime.now();
    if (_lastSelectedDate != null &&
        day == _lastSelectedDate &&
        now.difference(_lastTapTime) < Duration(milliseconds: 300)) {
      _showAvailabilityDetails(day);
    } else {
      _handleDaySelectionLogic(day);
    }
    _lastSelectedDate = day;
    _lastTapTime = now;
  }

  Future<void> _handleDayLongPressed(DateTime day, DateTime focusedDay) async {
    _showAvailabilityDetails(day);
  }

  void _handleDaySelectionLogic(DateTime day) {
    if (_selectedStartDay == null || _selectedEndDay != null ||
        day.isBefore(_selectedStartDay!) ||
        day.difference(_selectedStartDay!).inDays > 30) {
      _selectedStartDay = day;
      _selectedEndDay = null;
      _selectedDates = {day};
    } else if (_selectedStartDay != null && _selectedEndDay == null &&
        day.isAfter(_selectedStartDay!)) {
      _selectedEndDay = day;
      _selectedDates = _daysInRange().toSet();
    }
    setState(() {});
  }

  List<DateTime> _daysInRange() {
    List<DateTime> daysInRange = [];
    if (_selectedStartDay != null && _selectedEndDay != null) {
      for (DateTime day = _selectedStartDay!;
      day.isBefore(_selectedEndDay!.add(Duration(days: 1)));
      day = day.add(Duration(days: 1))) {
        daysInRange.add(day);
      }
    }
    return daysInRange;
  }

  Future<void> _showAvailabilityDetails(DateTime selectedDay) async {
    String selectedDateString = DateFormat('yyyy-MM-dd').format(selectedDay);
    Disponibilite? availability = allAvailabilities[selectedDateString];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Disponibilités pour $selectedDateString'),
          content: availability != null
              ? SingleChildScrollView(
            child: ListBody(
              children: [
                ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text("Disponibilité"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: [
                          Icon(Icons.wb_sunny),
                          SizedBox(width: 8),
                          Text("${availability.heureDebutMatin.substring(0,5)} - ${availability.heureFinMatin.substring(0,5)}"),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.nights_stay),
                          SizedBox(width: 8),
                          Text("${availability.heureDebutSoir.substring(0,5)} - ${availability.heureFinSoir.substring(0,5)}"),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
              : Text('Aucune disponibilité trouvée pour cette date.'),
          actions: <Widget>[
            TextButton(
              child: Text("Fermer"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
    double _h = MediaQuery.of(context).size.height;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
      ],
      home: Scaffold(
        backgroundColor: Colors.grey[200],
        body: SingleChildScrollView(
          child: Column(
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
                  "Choisir une plage de dates et indiquer la disponibilité.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: _w / 24,
                  ),
                ),
              ),
              SizedBox(height: _h * 0.03),
              Container(
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(_w / 20),
                        ),
                        child: TableCalendar(
                          availableCalendarFormats: const {
                            CalendarFormat.month: 'Month',
                          },
                          locale: 'fr_FR',
                          calendarFormat: CalendarFormat.month,
                          firstDay: DateTime.utc(2023, 1, 1),
                          lastDay: DateTime.utc(2029, 12, 31),
                          focusedDay: _selectedStartDay ?? DateTime.now(),
                          selectedDayPredicate: (day) => _selectedDates.contains(day),
                          onDaySelected: _handleDaySelected,
                          onDayLongPressed: _handleDayLongPressed,
                          eventLoader: (day) {
                            String dateString = DateFormat('yyyy-MM-dd').format(day);
                            return allAvailabilities.containsKey(dateString) ? [allAvailabilities[dateString]] : [];
                          },
                        ),
                      ),
                      SizedBox(height: _h * 0.02),
                      ElevatedButton(
                        onPressed: _openForm,
                        child: const Text('Renseigner les disponibilités'),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: _h * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  void _openForm() async {
    double _w = MediaQuery.of(context).size.width;

    if (_selectedDates.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                padding: EdgeInsets.all(_w / 20),
                child: Wrap(
                  children: <Widget>[
                    _buildToggle("Disponible en Matinée", isMorningSelected, 'morning', setModalState),
                    _buildToggle("Disponible en Soirée", isEveningSelected, 'evening', setModalState),
                    _buildTimePicker("Heure début matinée", 'startMorning', setModalState),
                    _buildTimePicker("Heure fin matinée", 'endMorning', setModalState),
                    _buildTimePicker("Heure début soirée", 'startEvening', setModalState),
                    _buildTimePicker("Heure fin soirée", 'endEvening', setModalState),
                    ElevatedButton(
                        child: Text('Enregistrer les disponibilités'),
                        onPressed: () {
                          List<Map<String, dynamic>> disponibilites = _selectedDates.map((date) {
                            return {
                              'date': DateFormat('yyyy-MM-dd').format(date),
                              'heure_debutMatin': _formatTimeOfDay(_startMorning),
                              'heure_finMatin': _formatTimeOfDay(_endMorning),
                              'heure_debutSoir': _formatTimeOfDay(_startEvening),
                              'heure_finSoir': _formatTimeOfDay(_endEvening),
                            };
                          }).toList();
                          sendDisponibilites(disponibilites);
                          Navigator.pop(context);
                        }
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }
  }

  Future<void> sendDisponibilites(List<Map<String, dynamic>> disponibilites) async {
    try {
      var tokenVar = await SharedPreferences.getInstance().then((prefs) {
        return prefs.getString('token');
      });
      print(tokenVar);
      if (tokenVar == null) {
        return;
      }

      const url = 'https://appariteur.com/api/users/disponibilites.php';
      final Map<String, dynamic> requestBody = {'updates': disponibilites};

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tokenVar',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Succès'),
              content: const Text('Disponibilités renseignées avec succès'),
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
        _fetchAllAvailabilities();
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Erreur'),
              content: const Text('Une erreur est survenue, veuillez réessayer plus tard'),
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
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erreur'),
            content: Text('Une erreur est survenue: $e'),
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
  }
  void _handleToggleChange(bool value, String identifier) {
    if (identifier == 'morning') {
      isMorningSelected = value;
      if (value) {
        _startMorning = TimeOfDay(hour: 8, minute: 0);
        _endMorning = TimeOfDay(hour: 12, minute: 0);
      } else {
        _startMorning = TimeOfDay(hour: 0, minute: 0);
        _endMorning = TimeOfDay(hour: 0, minute: 0);
      }
    } else if (identifier == 'evening') {
      isEveningSelected = value;
      if (value) {
        _startEvening = TimeOfDay(hour: 13, minute: 0);
        _endEvening = TimeOfDay(hour: 17, minute: 0);
      } else {
        _startEvening = TimeOfDay(hour: 0, minute: 0);
        _endEvening = TimeOfDay(hour: 0, minute: 0);
      }
    }
  }

  Widget _buildToggle(String title, bool isSelected, String identifier, StateSetter setModalState) {
    return ListTile(
      title: Text(title),
      trailing: Switch(
        value: isSelected,
        onChanged: (value) {
          setModalState(() {
            _handleToggleChange(value, identifier);
          });
        },
      ),
    );
  }

  Widget _buildTimePicker(String label, String identifier, StateSetter setModalState) {
    bool isEditable = (identifier.contains('Morning') && isMorningSelected) ||
        (identifier.contains('Evening') && isEveningSelected);

    return ListTile(
      title: Text(label),
      trailing: isEditable ? DropdownButton<TimeOfDay>(
        value: _getTime(identifier),
        onChanged: (TimeOfDay? newValue) {
          if (newValue != null) {
            setModalState(() {
              _setTime(identifier, newValue);
            });
          }
        },
        items: _getTimeDropdownMenuItems(),
      ) : SizedBox(),
    );
  }
  List<DropdownMenuItem<TimeOfDay>> _getTimeDropdownMenuItems() {
    return List.generate(24, (index) {
      return DropdownMenuItem<TimeOfDay>(
        value: TimeOfDay(hour: index, minute: 0),
        child: Text(DateFormat('HH:mm').format(DateTime(0, 0, 0, index, 0))),
      );
    });
  }
  void _setTime(String identifier, TimeOfDay time) {
    setState(() {
      if (identifier == 'startMorning') {
        _startMorning = time;
      } else if (identifier == 'endMorning') {
        _endMorning = time;
      } else if (identifier == 'startEvening') {
        _startEvening = time;
      } else if (identifier == 'endEvening') {
        _endEvening = time;
      }
    });
  }
  TimeOfDay _getTime(String identifier) {
    switch (identifier) {
      case 'startMorning':
        return _startMorning;
      case 'endMorning':
        return _endMorning;
      case 'startEvening':
        return _startEvening;
      case 'endEvening':
        return _endEvening;
      default:
        return TimeOfDay.now();
    }
  }


  String _formatTimeOfDay(TimeOfDay tod) {
    if (tod.hour == 0 && tod.minute == 0) {
      return "00:00";
    }
    final dt = DateTime(0, 0, 0, tod.hour, tod.minute);
    return DateFormat('HH:mm').format(dt);
  }
}

