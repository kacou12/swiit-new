import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swiit/src/core/core.dart';
import 'package:swiit/src/core/reusable/functions/fetch_common_chat.dart';
import 'package:swiit/src/features/auth/data/models/chat_user_model.dart';
import 'package:swiit/src/features/auth/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:swiit/src/features/auth/presentation/widgets/color_gradient.dart';
import 'package:swiit/src/features/clubs/data/models/add_user_to_room_payload.dart';
import 'package:swiit/src/features/clubs/data/models/room_model.dart';
import 'package:go_router/go_router.dart';
import 'package:swiit/src/features/clubs/presentation/cubit/club_cubit.dart';
import 'package:swiit/src/features/clubs/presentation/pages/finalize_subscription_club.dart';

class UserManageRoomMembersPage extends StatefulWidget {
  final RoomModel room;

  const UserManageRoomMembersPage({super.key, required this.room});

  @override
  _UserManageRoomMembersPageState createState() =>
      _UserManageRoomMembersPageState();
}

class _UserManageRoomMembersPageState extends State<UserManageRoomMembersPage> {
  List<UserChatModel> _members = [];

  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    Future.wait([_loadMembers()]).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> _loadMembers() async {
    // Charger la liste des membres depuis votre base de données
    final user = context.read<AppBloc>().state.user!;
    final usersData =
        await getRoomUsers(token: user.token!, roomId: widget.room.id, page: 1);
    setState(() {
      _members = usersData;
      // _members =
      //     usersData.where((user) => user.id != widget.room.adminId).toList();
    });
  }

  Future<void> _removeMember(UserChatModel member) async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text(
              'Êtes-vous sûr de vouloir supprimer ${member.name} de cette room ?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Supprimer'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm) {
      try {
        final user = context.read<AppBloc>().state.user!;
        await deleteUserFromRoom(
            userId: member.id, token: user.token!, roomId: widget.room.id);

        setState(() {
          _members.remove(member);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${member.name} a été retiré de la room')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur lors de la suppression du membre: $e')),
        );
      }
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Membres de ${widget.room.roomName}',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        actions: isAdminClub && widget.room.isGroupChat
            ? [
                IconButton(
                  icon: const Icon(Icons.person_add),
                  // onPressed: _addMember,
                  onPressed: () async {
                    final UserChatModel? newMember = await context.pushNamed(
                        PageRoutes.userAddMemberToRoomPageRoute,
                        extra: widget.room);
                    if (newMember != null) {
                      setState(() {
                        _members.add(newMember);
                      });
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.green,
                            content: Text(
                                "L'utilisateur a bien été ajouté a la room"),
                          ),
                        );
                    }
                  },
                ),
              ]
            : null,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: colorGradient),
        child: Builder(builder: (context) {
          if (isLoading) {
            return const Center(
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            );
          }
          if (_members.isNotEmpty) {
            return ListView.builder(
              itemCount: _members.length,
              itemBuilder: (context, index) {
                final member = _members[index];
                return Card(
                  color: Colors.white,
                  child: ListTile(
                    title: Text(member.name),
                    trailing: isAdminClub &&
                            widget.room.isGroupChat &&
                            member.id != widget.room.adminId
                        ? IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => _removeMember(member),
                          )
                        : null,
                  ),
                );
              },
            );
          }
          return const Center(
            child: Text("Aucun membre", style: TextStyle(color: Colors.white)),
          );
        }),
      ),
    );
  }
}
