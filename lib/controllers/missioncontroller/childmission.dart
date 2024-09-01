import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import '../../data/apihelper.dart';
import '../../models/missionuser.dart';
import 'package:pdf/pdf.dart';
class BodyM extends StatefulWidget {
  @override
  _BodyMState createState() => _BodyMState();
}

class _BodyMState extends State<BodyM> {
  DateTime now = DateTime.now();
  bool _hasSearched = false;
  DateTime? _startDate = DateTime.now();
  DateTime? _endDate = DateTime.now();
  List<Mission>? _missions = [];
  String? _totalHours = '';

  Widget _buildDateButton(BuildContext context, bool isStart, String label, DateTime? date) {
    double _w = MediaQuery.of(context).size.width;
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blueAccent,
          padding: EdgeInsets.symmetric(vertical: _w / 40),
        ),
        onPressed: () => _pickDate(context, isStart),
        child: Text('$label${DateFormat('dd/MM/yyyy', 'fr_FR').format(date!)}'),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, Function onPressed, String label, Color color) {
    double _w = MediaQuery.of(context).size.width;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: _w / 40),
      ),
      onPressed: () => onPressed(),
      child: Text(label, style: TextStyle(color: Colors.white)),
    );
  }

  String formatTotalHours(String totalHours) {
    List<String> parts = totalHours.split(':');
    String hours = parts[0].padLeft(2, '0');
    String minutes = parts[1].padLeft(2, '0');
    return '${hours}h ${minutes}';
  }

  Widget _buildTotalHoursDisplay() {
    double _w = MediaQuery.of(context).size.width;
    return _totalHours != null && _totalHours!.isNotEmpty
        ? Padding(
      padding: EdgeInsets.symmetric(vertical: _w / 40, horizontal: _w / 40),
      child: Text(
        'Heures Totales: ${formatTotalHours(_totalHours!)}',
        style: TextStyle(
          fontSize: _w / 20,
          fontWeight: FontWeight.bold,
          color: Colors.teal,
        ),
      ),
    )
        : SizedBox();
  }

  Widget _buildMissionsList() {
    if (_missions == null || _missions!.isEmpty) {
      String message = _hasSearched
          ? 'Aucune mission à afficher'
          : 'Sélectionnez une période pour chercher les missions';
      return Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: 18,
            fontStyle: FontStyle.italic,
            color: Colors.red,
          ),
        ),
      );
    } else {
      return RefreshIndicator(
        onRefresh: _fetchMissions,
        child: ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _missions!.length,
          itemBuilder: (context, index) {
            final mission = _missions![index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading: Icon(Icons.assignment_turned_in, color: Colors.green),
                title: Text(mission.etabli, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat('dd/MM/yyyy').format(mission.date)),
                    Text(mission.moment, style: TextStyle(color: Colors.black54)),
                  ],
                ),
                trailing: Text(
                  mission.duree.substring(0, 5),
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        ),
      );
    }
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: isStart ? _startDate! : _endDate!,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
        locale: const Locale('fr', 'FR'));
    if (picked != null && picked != (isStart ? _startDate : _endDate)) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void showToast(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _fetchMissions() async {
    if (_startDate != null && _endDate != null) {
      String formattedStartDate = DateFormat('yyyy-MM-dd').format(_startDate!);
      String formattedEndDate = DateFormat('yyyy-MM-dd').format(_endDate!);
      MissionEffUserResult? result = await AuthApi.getMissionsEffectuees(formattedStartDate, formattedEndDate);
      if (result != null) {
        setState(() {
          _missions = result.missions ?? [];
          _totalHours = result.totalHours;
          _hasSearched = true; // Indiquer que la recherche a été effectuée
        });
      } else {
        setState(() {
          _missions = [];
          _totalHours = null;
          _hasSearched = true;
        });
      }
    } else {
      showToast("Choisissez une date de début et une date de fin.");
    }
  }
  String sanitizeText(String input) {
    Map<String, String> replacements = {
      'é': 'e',
      'è': 'e',
      'ê': 'e',
      'ë': 'e',
      'à': 'a',
      'â': 'a',
      'ä': 'a',
      'ç': 'c',
      'î': 'i',
      'ï': 'i',
      'ù': 'u',
      'û': 'u',
      'ü': 'u',
      'ô': 'o',
      'ö': 'o',

      // Ajoutez d'autres remplacements si nécessaire
    };

    String output = input;
    replacements.forEach((key, value) {
      output = output.replaceAll(key, value);
    });
    output = output.replaceAll(RegExp(r'[^\x00-\x7F]'), ' ');

    return output;


  }
  Future<String?> returnName() async {
    final user = await AuthApi.getLocalUserData();
    String? _nom= '';
    if (user != null) {
_nom=user.name;
return _nom;
    }
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();

    String? nom = await returnName();
    if (nom == null) {
      nom = "Nom non trouve";
    }

    final font = pw.Font.helvetica();
    final fontFallback = pw.Font.courier();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                sanitizeText(nom!),
                style: pw.TextStyle(
                  font: font,
                  fontFallback: [fontFallback],
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueAccent100,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Text(
                sanitizeText('Liste des Missions'),
                style: pw.TextStyle(
                  font: font,
                  fontFallback: [fontFallback],
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: [
                  'Date',
                  'Etablissement',
                  'Duree effective',
                  'Heure debut',
                  'Heure fin'
                ].map((header) => sanitizeText(header)).toList(),
                data: _missions!.map((mission) {
                  return [
                    sanitizeText(DateFormat('dd/MM/yyyy').format(mission.date)),
                    sanitizeText(mission.etabli ?? 'Inconnu'),
                    sanitizeText(mission.duree?.substring(0, 5) ?? 'Inconnu'),
                    sanitizeText(mission.heureDebut ?? 'Inconnu'),
                    sanitizeText(mission.heureFin ?? 'Inconnu'),
                  ];
                }).toList(),
                border: pw.TableBorder.all(),
                cellAlignment: pw.Alignment.centerLeft,
                headerStyle: pw.TextStyle(
                  font: font,
                  fontFallback: [fontFallback],
                  fontWeight: pw.FontWeight.bold,
                ),
                headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerLeft,
                  3: pw.Alignment.centerRight,
                },
                // Ajustements pour empêcher le débordement
                cellPadding: pw.EdgeInsets.all(4),
                columnWidths: {
                  0: pw.FixedColumnWidth(80), // Largeur fixe pour la colonne Date
                  1: pw.FixedColumnWidth(100), // Largeur fixe pour la colonne Etablissement
                  2: pw.FixedColumnWidth(60),  // Largeur fixe pour la colonne Duree
                  3: pw.FixedColumnWidth(70),  // Largeur fixe pour la colonne Heure début
                  4: pw.FixedColumnWidth(70),  // Largeur fixe pour la colonne Heure fin
                },
                cellStyle: pw.TextStyle(
                  font: font,
                  fontFallback: [fontFallback],
                  fontSize: 10, // Réduire la taille de la police si nécessaire
                ),
              ),
              pw.SizedBox(height: 16),
              if (_totalHours != null && _totalHours!.isNotEmpty)
                pw.Text(
                  sanitizeText('Heures Totales: ${formatTotalHours(_totalHours!)}'),
                  style: pw.TextStyle(
                    font: font,
                    fontFallback: [fontFallback],
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.teal,
                  ),
                ),
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/missions.pdf');
    await file.writeAsBytes(await pdf.save());

    if (Theme.of(context).platform == TargetPlatform.android ||
        Theme.of(context).platform == TargetPlatform.iOS) {
      Printing.layoutPdf(onLayout: (PdfPageFormat format) async => file.readAsBytesSync());
    } else {
      showToast('PDF généré et disponible dans les fichiers de l\'application.');
    }
  }

  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(_w / 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDateButton(context, true, 'Du: ', _startDate),
                SizedBox(width: _w / 30),
                _buildDateButton(context, false, 'Au: ', _endDate),
              ],
            ),
            SizedBox(height: _w / 30),
            _buildActionButton(context, _fetchMissions, 'Chercher les missions', Colors.green),
            if (_hasSearched && _missions!.isNotEmpty) ...[
              SizedBox(height: _w / 30),
              _buildActionButton(context, _generatePdf, 'Télécharger en PDF', Colors.blue),
            ],
            SizedBox(height: _w / 30),
            _buildTotalHoursDisplay(),
            _buildMissionsList(),
          ],
        ),
      ),
    );
  }
}
