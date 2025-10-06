class Profile {
  final String id;
  final String name;
  final String age;
  final String occupation;
  final String? introduction;
  final String? imageUrl;
  final List<String> hobbies;
  final String? detailedIntroduction;
  final String? mbti;
  final String? idealType;
  final String? faithConfession;

  const Profile({
    required this.id,
    required this.name,
    required this.age,
    required this.occupation,
    this.introduction,
    this.imageUrl,
    this.hobbies = const [],
    this.detailedIntroduction,
    this.mbti,
    this.idealType,
    this.faithConfession,
  });
}
