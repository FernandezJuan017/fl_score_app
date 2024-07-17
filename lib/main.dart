import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xff2c8455), brightness: Brightness.dark),
        ),
        home: const MyHomePage(),
        debugShowCheckedModeBanner: false, //Removing Debug Banner
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  PostgrestTransformBuilder<List<Map<String, dynamic>>>? matches;

  void updateMatches() {
    matches = Supabase.instance.client
        .from('matches')
        .select(
            'id, local_team, visit_team, local_score,visit_score, tournament, difficulty, has_penalty, local_penalty, visit_penalty, note')
        .limit(10)
        .order('created_at', ascending: false);

    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    Widget? floatingActionButton;
    const formKey = Key('form_key_abm_match');

    void redirectTo(int indexPage) {
      setState(() {
        selectedIndex = indexPage;
      });
    }

    switch (selectedIndex) {
      case 0:
        page = const MatchesPage();
        floatingActionButton = FloatingActionButton(
            onPressed: () {
              setState(() {
                selectedIndex = 1;
              });
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => const Placeholder()),
              // );
            },
            tooltip: 'Add Match',
            child: const Icon(Icons.add));
        break;
      case 1:
        page = ABMMatchPage(
          formKey: formKey,
          redirectTo: redirectTo,
        );
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'SCORE APP',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: 4),
          ),
          toolbarHeight: 50,
          elevation: 10,
          centerTitle: false,
        ),
        body: page,
        floatingActionButton: floatingActionButton,
      );
    });
  }
}

class MatchesPage extends StatelessWidget {
  const MatchesPage({super.key});
  // ToDo:
  // 1- Add function to add matches
  // 2- Add boton to cancel matches
  // 3- Add input to score the matches

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    appState.updateMatches();

    var future = appState.matches;

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

        return ListView.builder(
          itemCount: matches.length,
          itemBuilder: ((context, index) {
            final match = matches[index];

            return CardMatch(match: match);
          }),
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
    return ListTile(
        title: Text('${match['local_team']} vs ${match['visit_team']}',
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 3)),
        subtitle: Text('${match['difficulty']} - ${match['tournament']}'),
        trailing: Text('${match['local_score']} - ${match['visit_score']}'));
  }
}

class ABMMatchPage extends StatelessWidget {
  final Key formKey;
  final void Function(int) redirectTo;

  final TextEditingController _localTeamController = TextEditingController();
  final TextEditingController _visitTeamController = TextEditingController();
  final TextEditingController _localScoreController = TextEditingController();
  final TextEditingController _visitScoreController = TextEditingController();
  final TextEditingController _difficultyController = TextEditingController();
  final TextEditingController _tournamentController = TextEditingController();

  ABMMatchPage({
    required this.formKey,
    required this.redirectTo,
    super.key,
  });

  Future<List<Map<String, dynamic>>> saveMatch() async {
    final data = await Supabase.instance.client.from('matches').insert({
      'local_team': _localTeamController.text,
      'visit_team': _visitTeamController.text,
      'local_score': _localScoreController.text,
      'visit_score': _visitScoreController.text,
      'difficulty': _difficultyController.text,
      'tournament': _tournamentController.text,
    }).select();
    return data;
  }

  List<DropdownMenuEntry<String>> get difficulties {
    List<DropdownMenuEntry<String>> items = [
      const DropdownMenuEntry(value: "Clase Mundial", label: "Clase Mundial"),
      const DropdownMenuEntry(value: "Profesional", label: "Profesional")
    ];
    return items;
  }

  List<DropdownMenuEntry<String>> get tournaments {
    List<DropdownMenuEntry<String>> items = [
      const DropdownMenuEntry(value: "EFL Champ.", label: "EFL Champ."),
      const DropdownMenuEntry(value: "Emi. FA Cup", label: "Emi. FA Cup"),
      const DropdownMenuEntry(value: "Premier League", label: "Premier League"),
    ];
    return items;
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Text("New Match"),
            const SizedBox(height: 10),
            DropdownMenu(
              controller: _difficultyController,
              initialSelection: "Clase Mundial",
              dropdownMenuEntries: difficulties,
              label: const Text("Difficulty"),
            ),
            const SizedBox(height: 10),
            DropdownMenu(
              controller: _tournamentController,
              initialSelection: "EFL Champ.",
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
                      FilteringTextInputFormatter
                          .digitsOnly // Permitir solo dígitos numérico
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
                      FilteringTextInputFormatter
                          .digitsOnly // Permitir solo dígitos numéricos
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
                  onPressed: () {
                    saveMatch();
                    redirectTo(0);
                    appState.updateMatches();
                  },
                  child: const Text("Save"),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.red)),
                  onPressed: () {
                    redirectTo(0);
                  },
                  child: const Text("Cancel"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
