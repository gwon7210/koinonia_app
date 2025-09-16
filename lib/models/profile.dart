class Profile {
  final String id;
  final String name;
  final int age;
  final String occupation;
  final String introduction;
  final String imageUrl;
  final List<String> hobbies;
  final String detailedIntroduction;
  final String mbti;
  final String idealType;

  Profile({
    required this.id,
    required this.name,
    required this.age,
    required this.occupation,
    required this.introduction,
    required this.imageUrl,
    required this.hobbies,
    required this.detailedIntroduction,
    required this.mbti,
    required this.idealType,
  });
}

// 목 데이터
class MockProfiles {
  static List<Profile> getMockProfiles() {
    return [
      Profile(
        id: '1',
        name: '수지',
        age: 24,
        occupation: '간호사',
        introduction:
            '안녕하세요! 하나님의 사랑 안에서 함께 성장할 수 있는 분을 찾고 있어요. 음악과 독서를 좋아하며, 봉사활동에도 적극적으로 참여하고 있습니다.',
        imageUrl: 'https://via.placeholder.com/300x300/FFB6C1/FFFFFF?text=수지',
        hobbies: ['음악감상', '독서', '봉사활동', '요리'],
        detailedIntroduction:
            '저는 간호사로 일하면서 사람들을 돌보는 일에 보람을 느끼고 있어요. 어려서부터 교회에서 자라왔고, 주님의 사랑을 실천하며 살아가고 싶어합니다.\n\n매주 주일에는 교회에서 찬양팀으로 섬기고 있고, 평일에는 병원에서 환자분들을 돌보고 있어요. 쉬는 날에는 독서나 요리를 하면서 시간을 보내는 것을 좋아합니다.\n\n신앙 안에서 서로를 격려하고 함께 성장할 수 있는 분과 만나서 하나님이 기뻐하시는 가정을 이루고 싶어요.',
        mbti: 'ISFJ',
        idealType:
            '신앙이 깊고 진실한 분이면 좋겠어요. 서로의 꿈을 응원해주고 함께 기도할 수 있는 분, 그리고 유머 감각이 있어서 일상에서도 즐겁게 지낼 수 있는 분을 만나고 싶습니다.',
      ),
      Profile(
        id: '2',
        name: '민지',
        age: 26,
        occupation: '초등교사',
        introduction:
            '교육을 통해 아이들과 함께하는 일이 즐거워요. 주님 안에서 서로를 격려하며 함께 걸어갈 동반자를 만나고 싶습니다. 여행과 카페 탐방을 좋아해요!',
        imageUrl: 'https://via.placeholder.com/300x300/98FB98/FFFFFF?text=민지',
        hobbies: ['여행', '카페탐방', '사진촬영', '피아노'],
        detailedIntroduction:
            '초등학교에서 아이들을 가르치며 매일매일 새로운 에너지를 얻고 있어요. 아이들의 순수한 마음을 보면서 저도 더 순수한 마음으로 하나님을 바라보게 되는 것 같아요.\n\n주말에는 새로운 카페를 찾아다니며 사진을 찍는 것을 좋아하고, 피아노 연주도 취미로 하고 있어요. 교회에서는 주일학교 교사로 섬기고 있습니다.\n\n하나님의 계획 안에서 서로를 이해하고 존중하며, 함께 기도하고 꿈을 나눌 수 있는 분과 만나고 싶어요.',
        mbti: 'ENFP',
        idealType:
            '긍정적이고 밝은 에너지를 가진 분이었으면 좋겠어요. 새로운 것에 도전하는 것을 좋아하고, 신앙 안에서 서로 격려하며 함께 성장할 수 있는 분을 찾고 있습니다.',
      ),
    ];
  }
}
