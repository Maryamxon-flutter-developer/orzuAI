import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(ChatSupportApp());
}

class ChatSupportApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Support',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ChatSupportScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// API Service class
class ApiService {
  static const String baseUrl = 'http://13.60.62.242:8080';
  // static const String token = '...'; // <-- BU QATORNI O'CHIRAMIZ. TOKEN ENDI DINAMIK BO'LADI.

  // Chat list olish
  static Future<List<dynamic>> getChatsList({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messaging/chats/'),
        headers: {
          'Authorization': 'Bearer $token', // Parametrdan kelgan token ishlatiladi
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load chats');
      }
    } catch (e) {
      print('Error getting chats: $e');
      return [];
    }
  }

  // Yangi chat yaratish
  static Future<Map<String, dynamic>?> createChat({
    required String token,
    required String participantId,
    String? title,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messaging/chats/'),
        headers: {
          'Authorization': 'Bearer $token', // Parametrdan kelgan token ishlatiladi
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'participant_id': participantId,
          'title': title ?? 'Support Chat',
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create chat');
      }
    } catch (e) {
      print('Error creating chat: $e');
      return null;
    }
  }

  // Chat xabarlarini olish
  static Future<List<dynamic>> getChatMessages({
    required String token,
    required String chatId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messaging/chats/$chatId/messages/'),
        headers: {
          'Authorization': 'Bearer $token', // Parametrdan kelgan token ishlatiladi
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      print('Error getting messages: $e');
      return [];
    }
  }

  // Xabar yuborish
  static Future<Map<String, dynamic>?> sendMessage({
    required String token,
    required String chatId,
    required String message,
    String? messageType = 'text',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messaging/chats/$chatId/messages/'),
        headers: {
          'Authorization': 'Bearer $token', // Parametrdan kelgan token ishlatiladi
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'message': message,
          'message_type': messageType,
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      print('Error sending message: $e');
      return null;
    }
  }
}

class Message {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final MessageStatus status;

  Message({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });

  // API dan kelgan ma'lumotlarni Message obyektiga o'girish
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'].toString(),
      text: json['message'] ?? '',
      isUser: json['is_from_user'] ?? false,
      timestamp: DateTime.parse(json['created_at']),
      status: MessageStatus.delivered,
    );
  }
}

enum MessageStatus { sending, sent, delivered, read }

class ChatSupportScreen extends StatefulWidget {
  final String? chatId;
  
  ChatSupportScreen({this.chatId});

  @override
  _ChatSupportScreenState createState() => _ChatSupportScreenState();
}

class _ChatSupportScreenState extends State<ChatSupportScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  List<Message> messages = [];
  bool isTyping = false;
  bool isOnline = true;
  bool isLoading = false;
  String? currentChatId;

  late AnimationController _typingAnimationController;
  late Animation<double> _typingAnimation;

  @override
  void initState() {
    super.initState();
    currentChatId = widget.chatId;
    _setupAnimations();
    if (currentChatId != null) {
      _loadChatMessages();
    } else {
      _createNewChat();
    }
  }

  void _setupAnimations() {
    _typingAnimationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _typingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_typingAnimationController);
  }

  // BU FUNKSIYA FAQAT NAMUNA UCHUN.
  // Haqiqiy ilovada bu funksiya login qilingan foydalanuvchining
  // tokenini `shared_preferences` kabi xavfsiz joydan o'qib oladi.
  Future<String?> _getUserToken() async {
    // Hozircha, test uchun tokenni shu yerda qat'iy belgilab turamiz.
    // Login sahifasi qo'shilgandan so'ng bu joyni o'zgartirish kerak.
    return 'YOUR_ACCESS_TOKEN';
  }

  // API dan xabarlarni yuklash
  Future<void> _loadChatMessages() async {
    if (currentChatId == null) return;
    final token = await _getUserToken();
    if (token == null) return _showErrorSnackBar('Foydalanuvchi avtorizatsiyadan o\'tmagan');
    setState(() {
      isLoading = true;
    });
    try {
      final apiMessages = await ApiService.getChatMessages(token: token, chatId: currentChatId!);
      setState(() {
        messages = apiMessages.map((json) => Message.fromJson(json)).toList();
        isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Xabarlarni yuklashda xatolik: $e');
    }
  }

  // Yangi chat yaratish
  Future<void> _createNewChat() async {
    final token = await _getUserToken();
    if (token == null) return _showErrorSnackBar('Foydalanuvchi avtorizatsiyadan o\'tmagan');

    setState(() {
      isLoading = true;
    });

    try {
      final newChat = await ApiService.createChat(
        token: token,
        participantId: 'support_agent_id', // Support agent ID sini kiriting
        title: 'Support Chat',
      );

      if (newChat != null) {
        setState(() {
          currentChatId = newChat['id'].toString();
          isLoading = false;
        });
        _addWelcomeMessage();
      } else {
        setState(() {
          isLoading = false;
        });
        _showErrorSnackBar('Chat yaratishda xatolik');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Chat yaratishda xatolik: $e');
    }
  }

  void _addWelcomeMessage() {
    setState(() {
      messages.add(Message(
        id: 'welcome_msg',
        text: "Hello! I am your assistant. How can I help you today?",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  // Xabar yuborish (API bilan)
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || currentChatId == null) return;

    final token = await _getUserToken();
    if (token == null) return _showErrorSnackBar('Foydalanuvchi avtorizatsiyadan o\'tmagan');

    String messageText = _messageController.text.trim();
    
    // UI da xabarni darhol ko'rsatish
    Message tempMessage = Message(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      text: messageText,
      isUser: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    setState(() {
      messages.add(tempMessage);
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // API ga xabar yuborish
      final response = await ApiService.sendMessage(
        token: token,
        chatId: currentChatId!,
        message: messageText,
      );

      if (response != null) {
        // Temporary xabarni real xabar bilan almashtirish
        setState(() {
          int index = messages.indexWhere((msg) => msg.id == tempMessage.id);
          if (index != -1) {
            messages[index] = Message(
              id: response['id'].toString(),
              text: messageText,
              isUser: true,
              timestamp: DateTime.parse(response['created_at']),
              status: MessageStatus.delivered,
            );
          }
        });

        // Yangi xabarlarni yuklash (javob uchun)
        await _loadChatMessages();
      } else {
        // Xatolik bo'lsa temporary xabarni o'chirish
        setState(() {
          messages.removeWhere((msg) => msg.id == tempMessage.id);
        });
        _showErrorSnackBar('Xabar yuborishda xatolik');
      }
    } catch (e) {
      setState(() {
        messages.removeWhere((msg) => msg.id == tempMessage.id);
      });
      _showErrorSnackBar('Xabar yuborishda xatolik: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessage(Message message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Column(
          crossAxisAlignment: message.isUser 
              ? CrossAxisAlignment.end 
              : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.blue[500] : Colors.grey[700],
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomRight: message.isUser 
                      ? Radius.circular(4) 
                      : Radius.circular(18),
                  bottomLeft: message.isUser 
                      ? Radius.circular(18) 
                      : Radius.circular(4),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            if (message.isUser)
              Padding(
                padding: EdgeInsets.only(top: 2, right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 4),
                    _buildMessageStatusIcon(message.status),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
          ),
        );
      case MessageStatus.sent:
        return Icon(Icons.check, size: 12, color: Colors.grey[600]);
      case MessageStatus.delivered:
        return Icon(Icons.done_all, size: 12, color: Colors.grey[600]);
      case MessageStatus.read:
        return Icon(Icons.done_all, size: 12, color: Colors.blue);
    }
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[700],
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: AnimatedBuilder(
          animation: _typingAnimation,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                SizedBox(width: 4),
                _buildTypingDot(1),
                SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    double delay = index * 0.2;
    return AnimatedBuilder(
      animation: _typingAnimation,
      builder: (context, child) {
        double animationValue = (_typingAnimation.value - delay).clamp(0.0, 1.0);
        double scale = 0.8 + (0.4 * (1 - (animationValue - 0.5).abs() * 2).clamp(0.0, 1.0));
        
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Help and Support',
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isOnline ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    isOnline ? 'Active now' : 'Offline',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.grey[800]),
              onPressed: _loadChatMessages,
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: Colors.grey[800]),
              onPressed: () {
                _showOptionsMenu();
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (currentChatId != null)
                  Container(
                    padding: EdgeInsets.all(8),
                    color: Colors.blue[50],
                    child: Text(
                      'Chat ID: $currentChatId',
                      style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    itemCount: messages.length + (isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length && isTyping) {
                        return _buildTypingIndicator();
                      }
                      return _buildMessage(messages[index]);
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextField(
                            controller: _messageController,
                            focusNode: _focusNode,
                            decoration: InputDecoration(
                              hintText: 'Type message here',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                            textInputAction: TextInputAction.send,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: currentChatId != null ? Colors.blue : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.refresh),
                title: Text('Reload Messages'),
                onTap: () {
                  Navigator.pop(context);
                  _loadChatMessages();
                },
              ),
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('Chat Info'),
                onTap: () {
                  Navigator.pop(context);
                  _showChatInfo();
                },
              ),
              ListTile(
                leading: Icon(Icons.clear_all),
                title: Text('Create New Chat'),
                onTap: () {
                  Navigator.pop(context);
                  _createNewChat();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showChatInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Chat Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chat ID: ${currentChatId ?? "Not created"}'),
              SizedBox(height: 8),
              Text('Status: ${isOnline ? "Online" : "Offline"}'),
              SizedBox(height: 8),
              Text('Messages: ${messages.length}'),
              SizedBox(height: 8),
              if (messages.isNotEmpty)
                Text('Started: ${_formatTime(messages.first.timestamp)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}