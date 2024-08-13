class Match {
  final int id;
  final String localTeam;
  final String visitTeam;
  final int localScore;
  final int visitScore;
  final String difficulty;
  final String tournament;
  final String? result;

  const Match({
    required this.id,
    required this.localTeam,
    required this.visitTeam,
    required this.localScore,
    required this.visitScore,
    required this.difficulty,
    required this.tournament,
    this.result,
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
      result: json['result'] ?? '-',
    );
  }

  // String getResult(String team) {
  //   var res= "-";
  //   bool wasPlayed = localScore > 0 || visitScore > 0;

  //   if (!wasPlayed) {
  //     return res;
  //   }
  //   var isLocal = team == localTeam;

  //   if (isLocal) {
  //     if (localScore > visitScore) {
  //       res = "G";
  //     }
  //      else if (localScore < visitScore) {
  //       res = "P";
  //     } 
  //     else {
  //       res = "E";
  //     }
  //   } 
  //   else {
  //     if (visitScore > localScore) {
  //       res = "G";
  //     } else if (visitScore < localScore) {
  //       res = "P";
  //     } else {
  //       res = "E";
  //     }
  //   }

  //   return res;
  // }
}