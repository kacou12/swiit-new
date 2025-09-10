import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:swiit/src/core/constants/base_url.dart';
import 'package:swiit/src/core/core.dart';
import 'package:swiit/src/core/reusable/functions/fetch_common_chat.dart';
import 'package:swiit/src/features/auth/data/models/user_model.dart';
import 'package:swiit/src/features/auth/presentation/bloc/bloc.dart';
import 'package:swiit/src/features/chat/data/models/message_model.dart';
import 'package:swiit/src/features/clubs/data/models/room_model.dart';
import 'package:swiit/src/features/clubs/presentation/cubit/club_cubit.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:web_socket_channel/web_socket_channel.dart';

class UserChatPage extends StatefulWidget {
  const UserChatPage({super.key, required this.room});
  final RoomModel room;

  @override
  State<UserChatPage> createState() => _UserChatPageState();
}

class _UserChatPageState extends State<UserChatPage> {
  late WebSocketChannel _channel;
  bool isFirstMessage = true;
  bool _showDeleteButton = false;

  List<MessageModel> messages = [];

  // final List<MessageModel> messages = [
  //   MessageModel(
  //     id: 1,
  //     chat_room_id: 96,
  //     sender_id: 174,
  //     content: "Salut tout le monde !",
  //     created_at: DateTime.now().subtract(const Duration(minutes: 18)),
  //     sender: UserModel(
  //       id: 174,
  //       createdAt: DateTime.now()
  //           .subtract(const Duration(days: 365))
  //           .toIso8601String(),
  //       updatedAt: null,
  //       deletedAt: null,
  //       userName: "user87",
  //       name: "Toi",
  //       city: "Paris",
  //       country: "France",
  //       image: null,
  //       phone: "+33123456789",
  //       deviceId: "device123",
  //       deviceType: "iOS",
  //       email: "toi@example.com",
  //       online: true,
  //       isPrivate: false,
  //       lastOnline: DateTime.now()
  //           .subtract(const Duration(minutes: 5))
  //           .toIso8601String(),
  //       sponsorshipCode: "SPONSOR87",
  //       sponsored: 5,
  //       type: "user",
  //       firebaseToken: null,
  //       stripeId: "stripe_87",
  //       stripeSellerId: "seller_87",
  //       token: null,
  //     ),
  //     chatRoom: const ChatRoom(id: 96, room_name: "Développement Flutter"),
  //   ),
  //   MessageModel(
  //     id: 2,
  //     chat_room_id: 96,
  //     sender_id: 23,
  //     content: "Salut ! Comment vas-tu ?",
  //     created_at: DateTime.now().subtract(const Duration(minutes: 16)),
  //     sender: UserModel(
  //       id: 23,
  //       createdAt: DateTime.now()
  //           .subtract(const Duration(days: 300))
  //           .toIso8601String(),
  //       updatedAt: null,
  //       deletedAt: null,
  //       userName: "user23",
  //       name: "Ali",
  //       city: "Casablanca",
  //       country: "Maroc",
  //       image: null,
  //       phone: "+212678901234",
  //       deviceId: "device23",
  //       deviceType: "Android",
  //       email: "ali@example.com",
  //       online: true,
  //       isPrivate: false,
  //       lastOnline: DateTime.now()
  //           .subtract(const Duration(minutes: 10))
  //           .toIso8601String(),
  //       sponsorshipCode: "SPONSOR23",
  //       sponsored: 3,
  //       type: "user",
  //       firebaseToken: null,
  //       stripeId: "stripe_23",
  //       stripeSellerId: "seller_23",
  //       token: null,
  //     ),
  //     chatRoom: const ChatRoom(id: 96, room_name: "Développement Flutter"),
  //   ),
  //   MessageModel(
  //     id: 3,
  //     chat_room_id: 96,
  //     sender_id: 174,
  //     content: "Je vais bien, merci. Et toi ?",
  //     created_at: DateTime.now().subtract(const Duration(minutes: 14)),
  //     sender: UserModel(
  //       id: 174,
  //       createdAt: DateTime.now()
  //           .subtract(const Duration(days: 365))
  //           .toIso8601String(),
  //       updatedAt: null,
  //       deletedAt: null,
  //       userName: "user87",
  //       name: "Toi",
  //       city: "Paris",
  //       country: "France",
  //       image: null,
  //       phone: "+33123456789",
  //       deviceId: "device123",
  //       deviceType: "iOS",
  //       email: "toi@example.com",
  //       online: true,
  //       isPrivate: false,
  //       lastOnline: DateTime.now()
  //           .subtract(const Duration(minutes: 5))
  //           .toIso8601String(),
  //       sponsorshipCode: "SPONSOR87",
  //       sponsored: 5,
  //       type: "user",
  //       firebaseToken: null,
  //       stripeId: "stripe_87",
  //       stripeSellerId: "seller_87",
  //       token: null,
  //     ),
  //     chatRoom: const ChatRoom(id: 96, room_name: "Développement Flutter"),
  //   ),
  //   MessageModel(
  //     id: 4,
  //     chat_room_id: 96,
  //     sender_id: 45,
  //     content: "Quelqu'un a déjà travaillé avec Firestore ici ?",
  //     created_at: DateTime.now().subtract(const Duration(minutes: 12)),
  //     sender: UserModel(
  //       id: 45,
  //       createdAt: DateTime.now()
  //           .subtract(const Duration(days: 150))
  //           .toIso8601String(),
  //       updatedAt: null,
  //       deletedAt: null,
  //       userName: "user45",
  //       name: "Lisa",
  //       city: "Berlin",
  //       country: "Allemagne",
  //       image: null,
  //       phone: "+491234567890",
  //       deviceId: "device45",
  //       deviceType: "Android",
  //       email: "lisa@example.com",
  //       online: true,
  //       isPrivate: false,
  //       lastOnline: DateTime.now()
  //           .subtract(const Duration(minutes: 7))
  //           .toIso8601String(),
  //       sponsorshipCode: "SPONSOR45",
  //       sponsored: 2,
  //       type: "user",
  //       firebaseToken: null,
  //       stripeId: "stripe_45",
  //       stripeSellerId: "seller_45",
  //       token: null,
  //     ),
  //     chatRoom: const ChatRoom(id: 96, room_name: "Développement Flutter"),
  //   ),
  //   MessageModel(
  //     id: 5,
  //     chat_room_id: 96,
  //     sender_id: 174,
  //     content: "Oui, je l'utilise pour un projet en ce moment.",
  //     created_at: DateTime.now().subtract(const Duration(minutes: 10)),
  //     sender: UserModel(
  //       id: 174,
  //       createdAt: DateTime.now()
  //           .subtract(const Duration(days: 365))
  //           .toIso8601String(),
  //       updatedAt: null,
  //       deletedAt: null,
  //       userName: "user87",
  //       name: "Toi",
  //       city: "Paris",
  //       country: "France",
  //       image: null,
  //       phone: "+33123456789",
  //       deviceId: "device123",
  //       deviceType: "iOS",
  //       email: "toi@example.com",
  //       online: true,
  //       isPrivate: false,
  //       lastOnline: DateTime.now()
  //           .subtract(const Duration(minutes: 5))
  //           .toIso8601String(),
  //       sponsorshipCode: "SPONSOR87",
  //       sponsored: 5,
  //       type: "user",
  //       firebaseToken: null,
  //       stripeId: "stripe_87",
  //       stripeSellerId: "seller_87",
  //       token: null,
  //     ),
  //     chatRoom: const ChatRoom(id: 96, room_name: "Développement Flutter"),
  //   ),
  //   MessageModel(
  //     id: 6,
  //     chat_room_id: 96,
  //     sender_id: 30,
  //     content: "C'est génial ! Tu fais quoi avec Firestore ?",
  //     created_at: DateTime.now().subtract(const Duration(minutes: 8)),
  //     sender: UserModel(
  //       id: 30,
  //       createdAt: DateTime.now()
  //           .subtract(const Duration(days: 200))
  //           .toIso8601String(),
  //       updatedAt: null,
  //       deletedAt: null,
  //       userName: "user30",
  //       name: "Pierre",
  //       city: "Bruxelles",
  //       country: "Belgique",
  //       image: null,
  //       phone: "+324567890123",
  //       deviceId: "device30",
  //       deviceType: "iOS",
  //       email: "pierre@example.com",
  //       online: true,
  //       isPrivate: false,
  //       lastOnline: DateTime.now()
  //           .subtract(const Duration(minutes: 6))
  //           .toIso8601String(),
  //       sponsorshipCode: "SPONSOR30",
  //       sponsored: 4,
  //       type: "user",
  //       firebaseToken: null,
  //       stripeId: "stripe_30",
  //       stripeSellerId: "seller_30",
  //       token: null,
  //     ),
  //     chatRoom: const ChatRoom(id: 96, room_name: "Développement Flutter"),
  //   ),
  //   MessageModel(
  //     id: 7,
  //     chat_room_id: 96,
  //     sender_id: 174,
  //     content: "Je travaille sur un module de chat en temps réel.",
  //     created_at: DateTime.now().subtract(const Duration(minutes: 6)),
  //     sender: UserModel(
  //       id: 174,
  //       createdAt: DateTime.now()
  //           .subtract(const Duration(days: 365))
  //           .toIso8601String(),
  //       updatedAt: null,
  //       deletedAt: null,
  //       userName: "user87",
  //       name: "Toi",
  //       city: "Paris",
  //       country: "France",
  //       image: null,
  //       phone: "+33123456789",
  //       deviceId: "device123",
  //       deviceType: "iOS",
  //       email: "toi@example.com",
  //       online: true,
  //       isPrivate: false,
  //       lastOnline: DateTime.now()
  //           .subtract(const Duration(minutes: 5))
  //           .toIso8601String(),
  //       sponsorshipCode: "SPONSOR87",
  //       sponsored: 5,
  //       type: "user",
  //       firebaseToken: null,
  //       stripeId: "stripe_87",
  //       stripeSellerId: "seller_87",
  //       token: null,
  //     ),
  //     chatRoom: const ChatRoom(id: 96, room_name: "Développement Flutter"),
  //   ),
  //   MessageModel(
  //     id: 8,
  //     chat_room_id: 96,
  //     sender_id: 12,
  //     content: "Oh cool, j'aimerais voir ça quand tu auras terminé !",
  //     created_at: DateTime.now().subtract(const Duration(minutes: 4)),
  //     sender: UserModel(
  //       id: 12,
  //       createdAt: DateTime.now()
  //           .subtract(const Duration(days: 250))
  //           .toIso8601String(),
  //       updatedAt: null,
  //       deletedAt: null,
  //       userName: "user12",
  //       name: "Nina",
  //       city: "Rome",
  //       country: "Italie",
  //       image: null,
  //       phone: "+390987654321",
  //       deviceId: "device12",
  //       deviceType: "Android",
  //       email: "nina@example.com",
  //       online: true,
  //       isPrivate: false,
  //       lastOnline: DateTime.now()
  //           .subtract(const Duration(minutes: 3))
  //           .toIso8601String(),
  //       sponsorshipCode: "SPONSOR12",
  //       sponsored: 1,
  //       type: "user",
  //       firebaseToken: null,
  //       stripeId: "stripe_12",
  //       stripeSellerId: "seller_12",
  //       token: null,
  //     ),
  //     chatRoom: const ChatRoom(id: 96, room_name: "Développement Flutter"),
  //   ),
  //   MessageModel(
  //     id: 9,
  //     chat_room_id: 96,
  //     sender_id: 174,
  //     content: "Pas de problème, je partagerai le code bientôt.",
  //     created_at: DateTime.now().subtract(const Duration(minutes: 2)),
  //     sender: UserModel(
  //       id: 174,
  //       createdAt: DateTime.now()
  //           .subtract(const Duration(days: 365))
  //           .toIso8601String(),
  //       updatedAt: null,
  //       deletedAt: null,
  //       userName: "user87",
  //       name: "Toi",
  //       city: "Paris",
  //       country: "France",
  //       image: null,
  //       phone: "+33123456789",
  //       deviceId: "device123",
  //       deviceType: "iOS",
  //       email: "toi@example.com",
  //       online: true,
  //       isPrivate: false,
  //       lastOnline: DateTime.now()
  //           .subtract(const Duration(minutes: 5))
  //           .toIso8601String(),
  //       sponsorshipCode: "SPONSOR87",
  //       sponsored: 5,
  //       type: "user",
  //       firebaseToken: null,
  //       stripeId: "stripe_87",
  //       stripeSellerId: "seller_87",
  //       token: null,
  //     ),
  //     chatRoom: const ChatRoom(id: 96, room_name: "Développement Flutter"),
  //   ),
  //   MessageModel(
  //     id: 10,
  //     chat_room_id: 96,
  //     sender_id: 56,
  //     content: "Je suis impatient de voir ça aussi !",
  //     created_at: DateTime.now(),
  //     sender: UserModel(
  //       id: 56,
  //       createdAt: DateTime.now()
  //           .subtract(const Duration(days: 100))
  //           .toIso8601String(),
  //       updatedAt: null,
  //       deletedAt: null,
  //       userName: "user56",
  //       name: "Paul",
  //       city: "Londres",
  //       country: "Royaume-Uni",
  //       image: null,
  //       phone: "+447911123456",
  //       deviceId: "device56",
  //       deviceType: "iOS",
  //       email: "paul@example.com",
  //       online: true,
  //       isPrivate: false,
  //       lastOnline: DateTime.now()
  //           .subtract(const Duration(minutes: 1))
  //           .toIso8601String(),
  //       sponsorshipCode: "SPONSOR56",
  //       sponsored: 7,
  //       type: "user",
  //       firebaseToken: null,
  //       stripeId: "stripe_56",
  //       stripeSellerId: "seller_56",
  //       token: null,
  //     ),
  //     chatRoom: const ChatRoom(id: 96, room_name: "Développement Flutter"),
  //   ),
  // ];

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _status = 'Déconnecté';
  bool isLoading = true;

  UserModel get getUserFromDirectChat {
    final authUser = context.read<AppBloc>().state.user!;
    return widget.room.users.firstWhere(
      (user) => user.id != authUser.id,
    );
  }

  @override
  void initState() {
    timeago.setLocaleMessages('fr', timeago.FrMessages());

    final user = context.read<AppBloc>().state.user;
    String socketUrl = '$baseUrlWss?token=${user!.token}';
    _channel = WebSocketChannel.connect(Uri.parse(socketUrl));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _channel.stream.listen(
        (message) {
          if (isFirstMessage) {
            setState(() {
              final msg = message;
              isFirstMessage = false;
            });
          } else {
            final data = jsonDecode(message);
            setState(() {
              // _status = 'Message reçu';

              final newMessage = MessageModel.fromJson(data);

              messages.add(newMessage);
            });
          }
        },
        onError: (error) {
          setState(() {
            // _status = 'Erreur: $error';
          });
        },
        onDone: () {
          setState(() {
            // _status = 'Connexion fermée';
          });
        },
      );

      fetchChatMessages(token: user.token!, roomId: widget.room.id)
          .then((data) => {
                setState(() {
                  messages = data.reversed.toList();
                  isLoading = false;
                })
              });
    });
    super.initState();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  bool get isAdminClub {
    if (context.read<AppBloc>().state.user != null) {
      final userId = context.read<AppBloc>().state.user!.id;
      return userId == widget.room.adminId;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.green,
        elevation: 1,
        actions: widget.room.isGroupChat
            ? [
                IconButton(
                  icon: const Icon(Icons.group),
                  onPressed: () {
                    context.pushNamed(PageRoutes.userManageRoomMembersRoute,
                        extra: widget.room);
                  },
                )
              ]
            : null,
        title: Container(
          // margin: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.room.roomName.isNotEmpty
                        ? widget.room.roomName
                        : getUserFromDirectChat.name,
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  // Text(
                  //   widget.room.,
                  //   style: const TextStyle(color: Colors.grey, fontSize: 12),
                  // )
                ],
              )
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          color: const Color(0XFFF5F0F7),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Builder(builder: (context) {
                  if (isFirstMessage || isLoading) {
                    return const Center(
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Color(0XFF893293),
                            strokeWidth: 1,
                          )),
                    );
                  }
                  if (messages.isEmpty) {
                    return const Center(
                        child: Text("Aucun message pour l'instant"));
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final showDate = index == 0 ||
                          !_isSameDay(message.created_at,
                              messages[index - 1].created_at);

                      return Column(
                        children: [
                          if (showDate)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                _formatDate(message.created_at),
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            ),
                          Builder(builder: (context) {
                            if (widget.room.isGroupChat) {
                              return _buildCustomMessageBubble(message);
                            }
                            return _buildMessageBubble(message);
                          }),
                        ],
                      );
                    },
                  );
                }),
              ),
              Container(
                // height: 100,
                color: const Color(0XFFE3E5F4),
                padding: const EdgeInsets.only(
                    bottom: 10, top: 10, right: 10, left: 10),
                child: Row(
                  // crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: TextField(
                          controller: _textController,
                          style: const TextStyle(fontSize: 15),
                          maxLines: 5,
                          minLines: 1,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10, 2, 10, 2),
                            border: InputBorder.none,
                            hintText: "Écrivez votre message",
                            hintStyle: TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0XFF9698AF),
                        shape: const CircleBorder(),
                      ),
                      onPressed: _sendMessage,
                      child: const Icon(Icons.send, color: Colors.white),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message) {
    final isMessageFromMe = isMe(message.sender_id);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      child: Row(
        mainAxisAlignment:
            isMessageFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // if (!isMessageFromMe) _buildAvatar(message.sender!),
          // const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isMessageFromMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  decoration: BoxDecoration(
                    color: isMessageFromMe
                        ? const Color(0XFF893293)
                        : Colors.grey[300],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMessageFromMe ? 20 : 0),
                      bottomRight: Radius.circular(isMessageFromMe ? 0 : 20),
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // if (!isMessageFromMe)
                      //   Padding(
                      //     padding: const EdgeInsets.only(bottom: 4),
                      //     child: Text(
                      //       message.sender!.name,
                      //       style: TextStyle(
                      //           fontWeight: FontWeight.bold,
                      //           color: _getColorForUser(message.sender_id)),
                      //     ),
                      //   ),
                      Text(
                        message.content,
                        style: TextStyle(
                            fontSize: 14,
                            color:
                                isMessageFromMe ? Colors.white : Colors.black),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatMessageTime(message.created_at),
                  style: TextStyle(color: Colors.grey[600], fontSize: 10),
                ),
              ],
            ),
          ),
          // if (isMessageFromMe) ...[
          //   const SizedBox(width: 8),
          //   _buildAvatar(message.sender_id),
          // ],
        ],
      ),
    );
  }

  Widget _buildCustomMessageBubble(MessageModel message) {
    final isMessageFromMe = isMe(message.sender_id);
    return GestureDetector(
      onLongPress: isAdminClub && widget.room.isGroupChat
          ? () {
              setState(() {
                _showDeleteButton = true;
              });
            }
          : null,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        child: Row(
          mainAxisAlignment:
              isMessageFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMessageFromMe) _buildAvatar(message.sender!),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: isMessageFromMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        decoration: BoxDecoration(
                          color: isMessageFromMe
                              ? const Color(0XFF893293)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(20),
                            topRight: const Radius.circular(20),
                            bottomLeft:
                                Radius.circular(isMessageFromMe ? 20 : 0),
                            bottomRight:
                                Radius.circular(isMessageFromMe ? 0 : 20),
                          ),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isMessageFromMe)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  message.sender!.name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          _getColorForUser(message.sender_id)),
                                ),
                              ),
                            Text(
                              message.content,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: isMessageFromMe
                                      ? Colors.white
                                      : Colors.black),
                            ),
                          ],
                        ),
                      ),
                      if (_showDeleteButton)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () async {
                              // widget.onDelete(message.id);
                              deleteUserMessage(message.id);
                              setState(() {
                                _showDeleteButton = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.delete,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatMessageTime(message.created_at),
                    style: TextStyle(color: Colors.grey[600], fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(UserModel sender) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: _getColorForUser(sender.id),
      child: Text(
        _getInitial(sender.name),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  deleteUserMessage(int messageId) async {
    //
    final user = context.read<AppBloc>().state.user!;
    await deleteMessage(token: user.token!, idMessage: messageId);
    setState(() {
      messages.removeWhere((message) => message.id == messageId);
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          content: Text("Message deleted successfully"),
        ),
      );
  }

  String _getInitial(String name) {
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Color _getColorForUser(int senderId) {
    // Cette fonction génère une couleur unique pour chaque utilisateur
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo
    ];
    return colors[senderId % colors.length];
  }

  void _sendMessage() {
    if (_textController.text.isNotEmpty) {
      _channel.sink.add(jsonEncode({
        "chat_room_id": widget.room.id,
        "content": _textController.text,
        "sender_id": context.read<AppBloc>().state.user!.id,
        "created_at": DateTime.now().toIso8601String(),
      }));
      setState(() {
        messages.add(MessageModel(
            chat_room_id: widget.room.id,
            content: _textController.text,
            sender_id: context.read<AppBloc>().state.user!.id,
            created_at: DateTime.now(),
            id: Random().nextInt(1000)));
        _textController.clear();
        // _scrollToBottom();
      });
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return "Aujourd'hui";
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return "Hier";
    } else {
      return DateFormat('d MMMM y').format(date);
    }
  }

  String _formatMessageTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return DateFormat('dd/MM/yy HH:mm').format(date);
    } else {
      return timeago.format(date, locale: 'fr', allowFromNow: true);
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool isMe(int senderId) {
    final userId = context.read<AppBloc>().state.user!.id;
    return userId == senderId;
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}
