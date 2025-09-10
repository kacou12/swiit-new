import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:swiit/src/core/core.dart';
import 'package:swiit/src/core/reusable/functions/fetch_common_chat.dart';
import 'package:swiit/src/core/reusable/functions/utils.dart';
import 'package:swiit/src/features/auth/data/models/user_model.dart';
import 'package:swiit/src/features/auth/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:swiit/src/features/auth/presentation/widgets/color_gradient.dart';
import 'package:swiit/src/features/clubs/data/models/room_model.dart';
import 'package:swiit/src/features/clubs/presentation/cubit/club_cubit.dart';
import 'package:swiit/src/features/clubs/presentation/cubit/club_state.dart';
import 'package:swiit/src/features/coaching/presentation/widgets/coaching_app_bar.dart';

class UserRoomListPage extends StatefulWidget {
  const UserRoomListPage({super.key});

  @override
  _UserRoomListPageState createState() => _UserRoomListPageState();
}

class _UserRoomListPageState extends State<UserRoomListPage> {
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  int _currentPage = 1;

  Future<void> _onScroll() async {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    const scrollThreshold = 100.0;

    if (maxScroll - currentScroll <= scrollThreshold && !_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
      });

      try {
        // Incrémente la page et charge les nouveaux événements
        _currentPage++;
        _loadRooms();
      } catch (e) {
        // En cas d'erreur, décrémente la page pour réessayer lors de la prochaine tentative
        _currentPage--;
      } finally {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.addListener(_onScroll);

      _loadInitialRooms();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollController.removeListener(_onScroll);

    super.dispose();
  }

  Future<void> _loadInitialRooms() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
      final userState = context.read<AppBloc>().state;
      final user = context.read<AppBloc>().state.user!;
      context
          .read<ClubCubit>()
          .fetchInitalUserRooms(pageKey: _currentPage)
          .whenComplete(() {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  Future<void> _loadRooms() async {
    final user = context.read<AppBloc>().state.user!;
    context.read<ClubCubit>().fetchUserRooms(
          pageKey: _currentPage,
        );
  }

  UserModel getUserFromDirectChat(RoomModel room) {
    final authUser = context.read<AppBloc>().state.user!;
    return room.users.firstWhere(
      (user) => user.id != authUser.id,
    );
  }

  void _navigateToRoom(RoomModel room) {
    print('Navigating to room: ${room.roomName}');
    context.pushNamed(PageRoutes.chatUserRoute, extra: room);
    // context.pushNamed(PageRoutes.chatClubRoute);
  }

  void _createNewRoom() {
    context.pushNamed(PageRoutes.userCreateRoomNameRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CoachingAppBar(
        title: "Mes Rooms",
        showIcon: true,
        onAdd: _createNewRoom,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: colorGradient),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const SearchInputWithNavigation(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                      color: Colors.white,
                    ))
                  : BlocBuilder<ClubCubit, ClubState>(
                      builder: (context, state) {
                        if (_isLoading) {
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
                        if (state.rooms.isNotEmpty) {
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            controller: _scrollController,
                            itemCount:
                                state.rooms.length + (_isLoadingMore ? 1 : 0),
                            separatorBuilder: (context, index) => Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                            ),
                            itemBuilder: (context, index) {
                              final room = state.rooms[index];
                              if (index >= state.rooms.length) {
                                return Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0.w),
                                    child: const SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return GestureDetector(
                                onLongPress: () {
                                  final user =
                                      context.read<AppBloc>().state.user!;
                                  showDeleteConfirmationBottomSheet(
                                      context: context,
                                      onDeleteConfirmed: () async {
                                        await deleteRoomById(
                                            token: user.token!,
                                            roomId: state.rooms[index].id);

                                        setState(() {
                                          state.rooms.removeWhere((room) =>
                                              room.id == state.rooms[index].id);
                                        });

                                        ScaffoldMessenger.of(context)
                                          ..hideCurrentSnackBar()
                                          ..showSnackBar(
                                            const SnackBar(
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              backgroundColor: Colors.green,
                                              content: Text(
                                                  "Room deleted successFully"),
                                            ),
                                          );
                                      });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      child: Text(room.roomName.isNotEmpty
                                          ? room.roomName[0]
                                          : getUserFromDirectChat(room)
                                              .name[0]),
                                    ),
                                    title: Text(room.roomName.isNotEmpty
                                        ? room.roomName
                                        : getUserFromDirectChat(room).name),
                                    // subtitle: const Text("room.lastMessage!"),
                                    subtitle: room.messages.isNotEmpty
                                        ? Text(room.messages[0].content)
                                        : null,
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap: () => _navigateToRoom(room),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                        return const Center(child: Text("Aucune rooms"));
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchInputWithNavigation extends StatelessWidget {
  final Function(String)? onSearch;

  const SearchInputWithNavigation({super.key, this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey),
      ),
      child: InkWell(
        onTap: () {
          context.pushNamed(PageRoutes.userSearchSwiiterToChatPageRoute);
          // context.pushNamed(PageRoutes.userSelectSwiiterToChatPageRoute);
        },
        child: IgnorePointer(
          child: TextField(
            // controller: controller,
            decoration: InputDecoration(
              hintText: "Seach user",
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {},
              ),
            ),
          ),
        ),
      ),
    );
  }
}
