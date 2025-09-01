class LeaderboardModel {
  final String uid;
  final String name;
  final int score;
  final int time;

  LeaderboardModel({
    required this.uid,
    required this.name,
    required this.score,
    required this.time,
  });

  factory LeaderboardModel.fromMap(Map<String, dynamic> map) {
    return LeaderboardModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      score: map['score'] ?? 0,
      time: map['time'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'score': score,
      'time': time,
    };
  }
}
