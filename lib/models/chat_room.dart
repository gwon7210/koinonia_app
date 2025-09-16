class ChatRoom {
  final String id;
  final String name;
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCount;
  final String profileImageUrl;
  final bool isOnline;

  ChatRoom({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.profileImageUrl,
    required this.isOnline,
  });
}

// 목 데이터
class MockChatRooms {
  static List<ChatRoom> getMockChatRooms() {
    return [
      ChatRoom(
        id: '1',
        name: '수지',
        lastMessage: '안녕하세요! 오늘 교회에서 만나서 반가웠어요 😊',
        lastMessageTime: '2분 전',
        unreadCount: 2,
        profileImageUrl:
            'https://via.placeholder.com/50x50/FFB6C1/FFFFFF?text=수',
        isOnline: true,
      ),
      ChatRoom(
        id: '2',
        name: '민지',
        lastMessage: '주일학교 수업 준비는 어떻게 하고 계세요?',
        lastMessageTime: '1시간 전',
        unreadCount: 0,
        profileImageUrl:
            'https://via.placeholder.com/50x50/98FB98/FFFFFF?text=민',
        isOnline: false,
      ),
      ChatRoom(
        id: '3',
        name: '개척교회 청년들',
        lastMessage: '다음 주 토요일에 봉사활동이 있습니다!',
        lastMessageTime: '3시간 전',
        unreadCount: 5,
        profileImageUrl:
            'https://via.placeholder.com/50x50/87CEEB/FFFFFF?text=교',
        isOnline: false,
      ),
      ChatRoom(
        id: '4',
        name: '찬양팀',
        lastMessage: '이번 주 찬양곡 연습 일정 공유드려요',
        lastMessageTime: '5시간 전',
        unreadCount: 1,
        profileImageUrl:
            'https://via.placeholder.com/50x50/DDA0DD/FFFFFF?text=찬',
        isOnline: false,
      ),
      ChatRoom(
        id: '5',
        name: '지영',
        lastMessage: '감사합니다! 도움이 많이 되었어요 🙏',
        lastMessageTime: '1일 전',
        unreadCount: 0,
        profileImageUrl:
            'https://via.placeholder.com/50x50/F0E68C/FFFFFF?text=지',
        isOnline: true,
      ),
    ];
  }
}
