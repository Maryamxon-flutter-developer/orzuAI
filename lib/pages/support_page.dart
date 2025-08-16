import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:orzulab/providers/auth_provider.dart';
import 'package:provider/provider.dart';

// Messaging API Service class (nomi o'zgartirildi)
class MessagingApiService {
  // TUZATISH: Asosiy manzil (baseUrl) to'g'irlandi. Ortiqcha '/products/' qismi
  // olib tashlandi. Endi xabar yuborish so'rovlari to'g'ri manzilga
  // (.../messaging/chats/) yuboriladi.
  static const String baseUrl = 'https://beautyaiapp.duckdns.org';

  // Chat list olish (Bu funksiya hozircha ishlatilmayapti, lekin kelajak uchun qoldirildi)
  static Future<List<dynamic>> getChatsList({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messaging/chats/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to load chats: ${response.statusCode}');
      }
    } catch (e) {
      throw e;
    }
  }

  // Yangi chat yaratish
  static Future<Map<String, dynamic>?> createChat({
    required String token,
    required String participantId,
    String? title,
  }) async {
    try {
      final requestBody = {
        'participant_id': participantId,
        'title': title ?? 'Support Chat',
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/messaging/chats/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to create chat: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error creating chat: $e');
      throw e;
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
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        // Agar javob results kalitiga ega bo'lsa
        if (data is Map && data.containsKey('results')) {
          return data['results'];
        }
        // Agar to'g'ridan-to'g'ri array bo'lsa
        else if (data is List) {
          return data;
        }
        // Aks holda bo'sh array qaytarish
        return [];
      } else {
        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      throw e;
    }
  }

  // Xabar yuborish
  static Future<Map<String, dynamic>?> sendMessage({
    required String token,
    required String chatId,
    required int senderId, // senderId parametri qo'shildi
    required String message,
    String? messageType = 'text',
  }) async {
    try {
      final requestBody = {
        'message': message,
        'chat': int.tryParse(chatId), // Xato xabariga asosan 'chat' maydoni qo'shildi
        'sender': senderId, // Xato xabariga asosan 'sender' maydoni qo'shildi
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/messaging/chats/$chatId/messages/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Failed to send message: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error sending message: $e');
      throw e;
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
  // **TUZATISH:** Endi bu metod joriy foydalanuvchi ID sini qabul qiladi
  factory Message.fromJson(Map<String, dynamic> json, int currentUserId) {
    final senderId = json['sender'];
    return Message(
      id: json['id'].toString(),
      text: json['message'] ?? '',
      // **TUZATISH:** `isUser` xabardagi `sender` ID bilan joriy foydalanuvchi ID si mos kelishiga qarab aniqlanadi
      isUser: senderId != null && senderId == currentUserId,
      timestamp: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      status: MessageStatus.delivered,
    );
  }
}

enum MessageStatus { sending, sent, delivered, read, failed }

class ChatSupportScreen extends StatefulWidget {
  final String? chatId;

  const ChatSupportScreen({super.key, this.chatId});

  @override
  State<ChatSupportScreen> createState() => _ChatSupportScreenState();
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
  String? currentToken;
  int? _currentUserId; // **YANGI:** Joriy foydalanuvchi ID sini saqlash uchun

  late AnimationController _typingAnimationController;
  late Animation<double> _typingAnimation;

  @override
  void initState() {
    super.initState();
    currentChatId = widget.chatId;
    _setupAnimations();
    _initializeChat();
  }

  void _setupAnimations() {
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _typingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_typingAnimationController);
  }

  // Chatni boshlash
  Future<void> _initializeChat() async {
    // TUZATISH: Tokenni markazlashgan AuthProvider'dan olamiz.
    // Bu ilovaning boshqa qismlari bilan bir xil ishlashini ta'minlaydi
    // va 401 (Unauthorized) xatosini oldini oladi.
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null || !mounted) {
      _showErrorSnackBar('Foydalanuvchi avtorizatsiyadan o\'tmagan. Iltimos, qayta login qiling.');
      return;
    }
    currentToken = token;

    // **TUZATISH:** Foydalanuvchi ID sini tokendan bir marta o'qib olamiz
    try {
      final payload = _parseJwt(token);
      if (mounted) {
        setState(() {
          _currentUserId = payload['user_id'];
        });
      }
    } catch (e) {
      _showErrorSnackBar('Tokenni o\'qishda xatolik: $e');
      return; // Agar token yaroqsiz bo'lsa, davom etmaymiz
    }

    if (currentChatId != null) {
      await _loadChatMessages();
    } else {
      await _createNewChat();
    }
  }

  // API dan xabarlarni yuklash
  Future<void> _loadChatMessages() async {
    if (currentChatId == null || currentToken == null) return;
    
    // **TUZATISH:** Xabarlarni yuklashdan oldin foydalanuvchi ID si mavjudligini tekshiramiz
    if (_currentUserId == null) {
      _showErrorSnackBar('Foydalanuvchi ID si topilmadi. Qayta urinib ko\'ring.');
      // ID ni olish uchun qayta ishga tushirishga harakat qilamiz
      await _initializeChat();
      return;
    }

    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final apiMessages = await MessagingApiService.getChatMessages(
        token: currentToken!,
        chatId: currentChatId!,
      );
      
      if (mounted) {
        setState(() {
          // **TUZATISH:** `fromJson` ga foydalanuvchi ID sini uzatamiz
          messages = apiMessages.map((json) => Message.fromJson(json, _currentUserId!)).toList();
          isLoading = false;
        });
      }
      
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      _showErrorSnackBar('Xabarlarni yuklashda xatolik: $e');
    }
  }

  // Yangi chat yaratish
  Future<void> _createNewChat() async {
    if (currentToken == null) {
      _showErrorSnackBar('Token topilmadi. Iltimos, qayta login qiling.');
      return;
    }

    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      // Bu yerda support agent ID sini o'zingizning API ga mos qilib o'zgartiring
      final newChat = await MessagingApiService.createChat(
        token: currentToken!,
        participantId: '1', // Bu qiymatni API dokumentatsiyasiga qarab o'zgartiring (masalan, admin IDsi)
        title: 'Support Chat',
      );

      if (newChat != null && mounted) {
        setState(() {
          currentChatId = newChat['id'].toString();
        });
        await _loadChatMessages();
      } else if (mounted) { 
        setState(() => isLoading = false);
        _showErrorSnackBar('Chat yaratishda xatolik');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      _showErrorSnackBar('Chat yaratishda xatolik: $e');
    }
  }

  // Serverdan javob kelguncha avtomatik javob va yozish animatsiyasini ko'rsatish
  Future<void> _simulateSupportResponse() async {
    // 1. "Yozmoqda..." animatsiyasini ko'rsatish
    if (mounted) {
      setState(() {
        isTyping = true;
      });
      _typingAnimationController.repeat();
      _scrollToBottom();
    }

    // 2. Bir necha soniya kutish
    await Future.delayed(const Duration(seconds: 2));

    // 3. Animatsiyani to'xtatish va avtomatik javobni qo'shish
    if (mounted) {
      setState(() {
        isTyping = false;
        _typingAnimationController.stop();
        messages.add(Message(
          id: 'support_reply_${DateTime.now().millisecondsSinceEpoch}',
          text: 'Rahmat, murojaatingiz qabul qilindi. Tez orada javob beramiz.',
          isUser: false, // Bu qo'llab-quvvatlash xizmatidan
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();
    }
  }
  // JWT tokenni qismlarga ajratib, ma'lumot qismini (payload) qaytaradi
  Map<String, dynamic> _parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('invalid token');
    }

    final payload = _decodeBase64(parts[1]);
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('invalid payload');
    }

    return payloadMap;
  }

  // Base64Url formatidagi matnni standart Base64 ga o'girib, decode qiladi
  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0: break;
      case 2: output += '=='; break;
      case 3: output += '='; break;
      default: throw Exception('Illegal base64url string!"');
    }
    return utf8.decode(base64Url.decode(output));
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
    if (_messageController.text.trim().isEmpty || 
        currentChatId == null || 
        currentToken == null) return;

    // **TUZATISH:** Xabar yuborishdan oldin foydalanuvchi ID si mavjudligini tekshiramiz
    if (_currentUserId == null) {
      _showErrorSnackBar('Xabar yuborish uchun foydalanuvchi ID si topilmadi.');
      return;
    }

    String messageText = _messageController.text.trim();
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    
    // UI da xabarni darhol ko'rsatish (Optimistic UI)
    Message tempMessage = Message(
      id: tempId,
      text: messageText,
      isUser: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    if (mounted) {
      setState(() {
        messages.add(tempMessage);
      });
    }

    _messageController.clear();
    _scrollToBottom();

    try {
      // API ga xabar yuborish
      final response = await MessagingApiService.sendMessage(
        token: currentToken!,
        chatId: currentChatId!,
        message: messageText,
        senderId: _currentUserId!, // Saqlangan ID dan foydalanamiz
      );

      if (response != null && mounted) {
        // Vaqtinchalik xabarni serverdan kelgan haqiqiy xabar bilan almashtirish
        setState(() {
          int index = messages.indexWhere((msg) => msg.id == tempId);
          if (index != -1) {
            // Xabarni serverdan kelgan ID bilan yangilab, statusini o'zgartiramiz
            messages[index] = Message(
              id: response['id'].toString(),
              text: tempMessage.text, // Yuborilgan matnni saqlab qolamiz
              isUser: true,
              timestamp: DateTime.tryParse(response['created_at'] ?? '') ?? tempMessage.timestamp,
              status: MessageStatus.delivered,
            );
          }
        });
        // Serverdan javob kelguncha avtomatik javobni ko'rsatish
        _simulateSupportResponse();
      } else {
        // Agar javob kutilgandek bo'lmasa, xatolik sifatida belgilaymiz
        throw Exception('Serverdan noto\'g\'ri javob keldi.');
      }
    } catch (e) {
      // Xatolik bo'lsa, vaqtinchalik xabarni "failed" statusiga o'tkazamiz
      if (mounted) {
        setState(() {
          int index = messages.indexWhere((msg) => msg.id == tempId);
          if (index != -1) {
            messages[index] = Message(id: tempId, text: messageText, isUser: true, timestamp: tempMessage.timestamp, status: MessageStatus.failed);
          }
        });
      }
      _showErrorSnackBar('Xabar yuborishda xatolik: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color.fromARGB(255, 60, 60, 60),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessage(Message message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Column(
          crossAxisAlignment: message.isUser 
              ? CrossAxisAlignment.end 
              : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: message.isUser ? Colors.blue[500] : Colors.grey[700],
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomRight: message.isUser 
                      ? const Radius.circular(4) 
                      : const Radius.circular(18),
                  bottomLeft: message.isUser 
                      ? const Radius.circular(18) 
                      : const Radius.circular(4),
                ),
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            if (message.isUser)
              Padding(
                padding: const EdgeInsets.only(top: 2, right: 8),
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
                    const SizedBox(width: 4),
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
      case MessageStatus.failed:
        return Icon(Icons.error_outline, size: 12, color: Colors.red);
    }
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey[700],
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomLeft: const Radius.circular(4),
          ),
        ),
        child: AnimatedBuilder(
          animation: _typingAnimation,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
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
      appBar: PreferredSize( // AppBar'ni o'zgartirish
        preferredSize: Size.fromHeight(70),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.grey[800]),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Support Chat',
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
                  const SizedBox(width: 6),
                  Text(
                    isOnline ? 'Onlayn' : 'Oflayn',
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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Yuklanmoqda...'),
                ],
              ),
            )
          : Column(
              children: [
                // Chat ID ko'rsatuvchi qism olib tashlandi
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
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
                              hintText: 'Xabar yozing...',
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
                            color: currentChatId != null ? const Color.fromARGB(255, 73, 74, 75) : Colors.grey,
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
              title: Text('Refresh messages'),
              onTap: () {
                Navigator.pop(context);
                _loadChatMessages();
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Chat information'),
              onTap: () {
                Navigator.pop(context);
                _showChatInfo();
              },
            ),
            ListTile(
              leading: Icon(Icons.clear_all),
              title: Text('Create new chat'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  messages.clear();
                  currentChatId = null;
                });
                _createNewChat();
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Clear token'),
              onTap: () {
                Navigator.pop(context);
                _clearToken();
              },
            ),
          ],
        ),
      );
    },
  );
}


  // Tokenni tozalash funksiyasi (debug uchun)
  Future<void> _clearToken() async {
    try {
      // TUZATISH: Tokenni tozalash uchun markazlashtirilgan AuthProvider'dan
      // foydalanamiz. Bu `AuthService` mavjud emasligi xatosini tuzatadi.
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      setState(() {
        currentToken = null;
        currentChatId = null;
        messages.clear();
      });
      _showErrorSnackBar('Token tozalandi. Iltimos, qayta login qiling.');
    } catch (e) {
      print('Error clearing token: $e');
    }
  }

  void _showChatInfo() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Chat Ma\'lumotlari'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chat ID: ${currentChatId ?? "Yaratilmagan"}'),
              SizedBox(height: 8),
              Text('Holat: ${isOnline ? "Onlayn" : "Oflayn"}'),
              SizedBox(height: 8),
              Text('Xabarlar soni: ${messages.length}'),
              SizedBox(height: 8),
              if (messages.isNotEmpty)
                Text('Boshlangan: ${_formatTime(messages.first.timestamp)}'),
              SizedBox(height: 8),
              Text('Token mavjud: ${currentToken != null ? "Ha" : "Yo\'q"}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Yopish'),
            ),
          ],
        );
      },
    );
  }
}