import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/match_model.dart';
import 'models/user_team_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  await Supabase.initialize(
    url: dotenv.env['BASE_URL'] ??
        'URL not found', //dotenv.get('BASE_URL', fallback: 'URL not found'),
    anonKey: dotenv.env['BASE_API_KEY'] ??
        'Anon key not found', //dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Score App',
        theme: ThemeData(
          useMaterial3: true,
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              foregroundColor: Colors.white, // Color del texto del botón
            ),
          ),
          //2c8455
          colorScheme: ColorScheme.fromSeed(
              seedColor: Color.fromARGB(255, 18, 104, 58), brightness: Brightness.dark),
        ),
        home: const MyHomePage(),
        debugShowCheckedModeBanner: false, //Removing Debug Banner
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  PostgrestTransformBuilder<List<Map<String, dynamic>>>? matches;

  UserTeam currentUserTeam = const UserTeam(
    id: 3,
    userId: 1,
    teamId: 3,
    teamName: 'Villarreal',
    teamDescription: '',
    teamCountry: 'España',
    startDate: '',
    finishDate: '',
    isCurrent: true,
    dtLastName: 'Dominguez',
    dtName: 'Eduardo',
    createdAt: '',
  );

  // List<Map<String, dynamic>>? tournaments;

  void updateMatches() {
    matches = Supabase.instance.client
        .from('matches')
        .select(
            'id, local_team, visit_team, local_score,visit_score, tournament, difficulty, has_penalty, local_penalty, visit_penalty, result, note')
        .eq('user_team_id', currentUserTeam.id)
        .limit(10)
        .order('created_at', ascending: false);

    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getTournaments() {
    return Supabase.instance.client
        .from('tournaments')
        .select('id, name, description')
        .eq('active', true)
        .order('order', ascending: true);
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    Widget? floatingActionButton;
    MyAppState appState = context.watch<MyAppState>();
    UserTeam currenUserTeam = appState.currentUserTeam;

    // const formKey = Key('form_key_abm_match');

    // void redirectTo(int indexPage) {
    //   setState(() {
    //     selectedIndex = indexPage;
    //   });
    // }

    switch (selectedIndex) {
      case 0:
        page = const MatchesPage();
        floatingActionButton = FloatingActionButton(
            onPressed: () {
              // setState(() {
              //   selectedIndex = 1;
              // });
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ABMMatchPage(userTeam: currenUserTeam)),
              );
            },
            tooltip: 'Add Match',
            child: const Icon(Icons.add));
        break;
      case 1:
        page = const Placeholder();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        appBar: const AppBarMain(),
        body: page,
        floatingActionButton: floatingActionButton,
      );
    });
  }
}

class AppBarMain extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  const AppBarMain({
    this.preferredSize = const Size.fromHeight(50.0),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'SCORE APP',
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 4
        ),
      ),
      toolbarHeight: 50,
      elevation: 10,
      centerTitle: false,
    );
  }
}

class MatchesPage extends StatelessWidget {
  const MatchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    appState.updateMatches();

    var future = appState.matches;

    var currenUserTeam = appState.currentUserTeam;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final matches = snapshot.data ?? [];

        if (matches.isEmpty) {
          return const Center(child: Text('No matches found'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
                "${currenUserTeam.teamName} - ${currenUserTeam.dtName}, ${currenUserTeam.dtLastName}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 3
                )
            ),
            const SizedBox(height: 10),
            Expanded(
                child: ListView.builder(
                    itemCount: matches.length,
                    itemBuilder: ((context, index) {
                      final match = matches[index];

                      return CardMatch(match: match);
                    }))),
            const SizedBox(height: 65),
          ],
        );
      },
    );
  }
}

class CardMatch extends StatelessWidget {
  const CardMatch({
    super.key,
    required this.match,
  });

  final Map<String, dynamic> match;

  @override
  Widget build(BuildContext context) {
    String score = '';
    MyAppState appState = context.watch<MyAppState>();
    UserTeam currenUserTeam = appState.currentUserTeam;

    if (match['local_score'] != null && match['visit_score'] != null) {
      score = '${match['local_score']} - ${match['visit_score']}';
    }

    return ListTile(
      title: Text('${match['local_team']} vs ${match['visit_team']}',
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 3)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${match['difficulty']} - ${match['tournament']}'),
          // Icon(Icons.check_circle, size: 12, color: Colors.green),
          CircleAvatar(
            backgroundColor: Colors.grey.shade800,
            radius: 9,
            child: const Text('G', style: TextStyle(fontSize: 10)),
          ),
          // Chip(
          //   avatar: CircleAvatar(
          //     backgroundColor: Colors.grey.shade800,
          //     child: const Text('A'),
          //   ),
          //   label: const Text('Aaron Burr'),
          // )
        ],
      ),
      trailing: Text(score),
      onTap: () {
        Match pMath = Match.fromJson(match);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ABMMatchPage(match: pMath, userTeam: currenUserTeam)),
        );
      },
    );
  }
}

class ABMMatchPage extends StatelessWidget {
  //final Key formKey;
  final formKey = GlobalKey<FormState>();
  final Match? match;
  final UserTeam? userTeam;

  // final void Function(int) redirectTo;
  final TextEditingController _localTeamController = TextEditingController();
  final TextEditingController _visitTeamController = TextEditingController();
  final TextEditingController _localScoreController = TextEditingController();
  final TextEditingController _visitScoreController = TextEditingController();
  final TextEditingController _difficultyController = TextEditingController();
  final TextEditingController _tournamentController = TextEditingController();

  ABMMatchPage({
    //required this.formKey,
    //required this.redirectTo,
    this.match,
    this.userTeam,
    super.key,
  });

  String getResult() {
   bool wasPlayed = _localScoreController.text != '' || _visitScoreController.text != '';
   
   if (!wasPlayed) {
     return '-'; 
   } 

   bool isTie = _localScoreController.text == _visitScoreController.text;
   
   if (isTie) {
     return 'E';
   }

   bool isMyTeamLocal = _localTeamController.text == userTeam!.teamName;
   bool isLocalWin = _localScoreController.text != '' && int.parse(_localScoreController.text) > int.parse(_visitScoreController.text);

   if (isMyTeamLocal) {
     return isLocalWin ? 'G' : 'P';
   } 
   else { //My Team is visit
     return isLocalWin ? 'P' : 'G';
   }
  }

  Future<List<Map<String, dynamic>>> saveMatch(String result) async {
    final List<Map<String, dynamic>> data;
   
    if (match != null && match!.id > 0) {
      data = await Supabase.instance.client
          .from('matches')
          .update({
            'local_team': _localTeamController.text,
            'visit_team': _visitTeamController.text,
            'local_score': _localScoreController.text != ''
                ? _localScoreController.text
                : null,
            'visit_score': _visitScoreController.text != ''
                ? _visitScoreController.text
                : null,
            'difficulty': _difficultyController.text,
            'tournament': _tournamentController.text,
            'result': result
            })
          .eq('id', match!.id)
          .select();
    } else {
      // ToDo: Add validation
      data = await Supabase.instance.client.from('matches').insert({
        'local_team': _localTeamController.text,
        'visit_team': _visitTeamController.text,
        'local_score': _localScoreController.text != ''
            ? _localScoreController.text
            : null,
        'visit_score': _visitScoreController.text != ''
            ? _visitScoreController.text
            : null,
        'difficulty': _difficultyController.text,
        'tournament': _tournamentController.text,
        'user_team_id': userTeam!.id,
        'result': result
        }).select();
    }

    return data;
  }

  List<DropdownMenuEntry<String>> get difficulties {
    List<DropdownMenuEntry<String>> items = [
      const DropdownMenuEntry(value: "Clase Mundial", label: "Clase Mundial"),
      const DropdownMenuEntry(value: "Profesional", label: "Profesional")
    ];
    return items;
  }

  // List<DropdownMenuEntry<String>> get tournaments {
  //   List<DropdownMenuEntry<String>> items = [
  //     const DropdownMenuEntry(value: "Premier League", label: "Premier League"),
  //     const DropdownMenuEntry(value: "Emi. FA Cup", label: "Emi. FA Cup"),
  //     const DropdownMenuEntry(value: "Carabao Cup", label: "Carabao Cup"),
  //     const DropdownMenuEntry(value: "EFL Champ.", label: "EFL Champ."),
  //   ];
  //   return items;
  // }

  @override
  Widget build(BuildContext context) {
    final filledButtonCancelTheme = FilledButton.styleFrom(
      backgroundColor: Colors.red, // Color de fondo del botón
    );
    // ToDo: Mejorar el tema
     final filledButtonSaveTheme = FilledButton.styleFrom(
      backgroundColor: Color.fromARGB(255, 25, 59, 27), // Color de fondo del botón
    );

    if (match != null && match!.id > 0) {
      _localTeamController.text = match!.localTeam;
      _visitTeamController.text = match!.visitTeam;
      _localScoreController.text = match!.localScore.toString();
      _visitScoreController.text = match!.visitScore.toString();
      _difficultyController.text = match!.difficulty;
      _tournamentController.text = match!.tournament;
    }

    MyAppState appState = context.watch<MyAppState>();

    var futureTournaments = appState.getTournaments();
      
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
          appBar: const AppBarMain(),
          body: FutureBuilder<List<Map<String, dynamic>>>(
            future: futureTournaments,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final lstTournaments = snapshot.data ?? [];

              if (lstTournaments.isEmpty) {
                return const Center(child: Text('No data found'));
              }

              final tournaments = lstTournaments
                  .map((item) => DropdownMenuEntry(
                      value: item['name'], label: item['name']))
                  .toList();

              return Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Text("New Match - ${userTeam?.teamName}"),
                      const SizedBox(height: 10),
                      DropdownMenu(
                        controller: _difficultyController,
                        initialSelection: match?.difficulty ?? "Clase Mundial",
                        dropdownMenuEntries: difficulties,
                        label: const Text("Difficulty"),
                      ),
                      const SizedBox(height: 10),
                      DropdownMenu(
                        controller: _tournamentController,
                        initialSelection:
                            match?.tournament ?? tournaments.first.value,
                        dropdownMenuEntries: tournaments,
                        label: const Text("Competition"),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 200,
                            child: TextField(
                              controller: _localTeamController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Local Team",
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 70,
                            child: TextField(
                              controller: _localScoreController,
                              textAlign: TextAlign.right,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Score',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Text("vs"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 200,
                            child: TextField(
                              controller: _visitTeamController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Visit Team",
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 70,
                            child: TextField(
                              controller: _visitScoreController,
                              textAlign: TextAlign.right,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Score',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FilledButton(
                            style: filledButtonSaveTheme,
                            onPressed: () {
                              String result =  getResult();
                              print(result);
                              saveMatch(result);
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const MyHomePage()),
                                (Route<dynamic> route) => false,
                              );
                            },
                            child: const Text("Save"),
                          ),
                          const SizedBox(width: 10),
                          FilledButton(
                            style: filledButtonCancelTheme,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ));
    });
  }
}
