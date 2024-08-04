class UserTeam {
  final int id;
  final int userId;
  final int teamId;
  final String teamName;
  final String teamDescription;
  final String teamCountry;
  final String startDate;
  final String finishDate;
  final bool isCurrent;
  final String dtName;
  final String dtLastName;
  final String createdAt;

  const UserTeam({
    required this.id,
    required this.userId,
    required this.teamId,
    required this.teamName,
    required this.teamDescription,
    required this.teamCountry,
    required this.startDate,
    required this.finishDate,
    required this.isCurrent,
    required this.dtName,
    required this.dtLastName,
    required this.createdAt,
  });

  factory UserTeam.fromJson(Map<String, dynamic> json) {
    return UserTeam(
      id: json['id'],
      userId: json['user_id'],
      teamId: json['team_id'],
      teamName: json['team_name'],
      teamDescription: json['team_description'],
      teamCountry: json['team_country'],
      startDate: json['start_date'],
      finishDate: json['finish_date'],
      isCurrent: json['is_current'],
      dtName: json['dt_name'],
      dtLastName: json['dt_last_name'],
      createdAt: json['created_at'],
    );
  }
}