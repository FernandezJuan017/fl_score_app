class Match {
  final int id;
  final String localTeam;
  final String visitTeam;
  final int localScore;
  final int visitScore;
  final String difficulty;
  final String tournament;

  const Match({
    required this.id,
    required this.localTeam,
    required this.visitTeam,
    required this.localScore,
    required this.visitScore,
    required this.difficulty,
    required this.tournament,
  }); 

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'],
      localTeam: json['local_team'],
      visitTeam: json['visit_team'],
      localScore: json['local_score'] ?? 0,
      visitScore: json['visit_score'] ?? 0,
      difficulty: json['difficulty'],
      tournament: json['tournament'],
    );
  }
}