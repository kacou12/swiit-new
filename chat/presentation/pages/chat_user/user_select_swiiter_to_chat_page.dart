import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:swiit/src/core/core.dart';
import 'package:swiit/src/core/reusable/functions/fetch_common_chat.dart';
import 'package:swiit/src/features/auth/data/models/user_model.dart';
import 'package:swiit/src/features/auth/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:swiit/src/features/clubs/presentation/cubit/club_state.dart';
import 'package:swiit/src/features/coaching/presentation/cubit/coaching_cubit.dart';
import 'package:swiit/src/features/coaching/presentation/widgets/coaching_app_bar.dart';

import '../../../../../core/constants/app_colors.dart';

class UserSelectSwiiterToChatPage extends StatelessWidget {
  const UserSelectSwiiterToChatPage({super.key});
  // final RoomModel room;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CoachingAppBar(
          title: "Chattez avec des swiiters",
        ),
        body: Container(
            padding: EdgeInsets.symmetric(horizontal: 5.r, vertical: 10.r),
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            decoration: BoxDecoration(gradient: AppColors.colorGradient),
            child: const _ListClubMembers()));
  }
}

class _ListClubMembers extends StatefulWidget {
  const _ListClubMembers({super.key});

  @override
  State<_ListClubMembers> createState() => __ListClubMembersState();
}

class __ListClubMembersState extends State<_ListClubMembers> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool isLoading = false;
  int _currentPage = 1;
  List<UserModel> membersWithoutDirectChat = [];

  Future<void> _onScroll() async {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    const scrollThreshold = 200.0;

    final state = context.read<CoachingCubit>().state;

    if (state.swiitersStatus == Status.success &&
        maxScroll - currentScroll <= scrollThreshold &&
        !_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
      });

      try {
        // Incrémente la page et charge les nouveaux événements
        final user = context.read<AppBloc>().state.user!;

        _currentPage++;
        final results = await fetchUserWithoutDirectChat(
            token: user.token!, page: _currentPage);
        setState(() {
          membersWithoutDirectChat = [...membersWithoutDirectChat, ...results];
        });
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
    setState(() {
      isLoading = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.addListener(_onScroll);
      final user = context.read<AppBloc>().state.user!;

      // _currentPage++;

      fetchUserWithoutDirectChat(token: user.token!, page: _currentPage)
          .then((results) {
        setState(() {
          membersWithoutDirectChat = results;
        });
      }).whenComplete(() {
        setState(() {
          isLoading = false;
        });
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollController.removeListener(_onScroll);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      if (!isLoading) {
        if (membersWithoutDirectChat.isEmpty) {
          return const Center(
              child: Text("No Member found",
                  style: TextStyle(color: Colors.white)));
        }
        return ListView.builder(
            controller: _scrollController,
            itemCount:
                membersWithoutDirectChat.length + (_isLoadingMore ? 1 : 0),
            // shrinkWrap: true,
            // physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              if (index >= membersWithoutDirectChat.length) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0.w),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                );
              }
              final member = membersWithoutDirectChat[index];
              return _AddMemberCard(
                onTap: () async {
                  context.pushNamed(
                      PageRoutes.userChatBySendFirstMessagePageRoute,
                      extra: member);
                  // final addUserToRoomPayload = AddUserToRoomPayload(
                  //   chat_room_id: widget.room.id,
                  //   user_id: member.id,
                  // );
                  // final user = context.read<AppBloc>().state.user!;
                  // await addUserToRoom(
                  //     payload: addUserToRoomPayload, token: user.token!);

                  // Navigator.of(context).pop(member);
                },
                user: member,
              );
            });
      }
      return const Center(
          child: CircularProgressIndicator(
        color: Colors.white,
      ));
    });
  }
}

class _AddMemberCard extends StatelessWidget {
  const _AddMemberCard({required this.user, required this.onTap});

  final UserModel user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(bottom: 10.r),
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
          border: Border.all(width: 3, color: Colors.white),
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r)),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.r),
            height: 60.w,
            width: 50.w,
            decoration: BoxDecoration(boxShadow: const [
              BoxShadow(
                  offset: Offset(0, 0),
                  color: Colors.grey,
                  blurRadius: 1,
                  spreadRadius: 1)
            ], color: Colors.white, borderRadius: BorderRadius.circular(10.r)),
            child: Container(
              // padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: Colors.blueGrey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: user.image != null
                  ? CachedNetworkImage(
                      imageUrl: user.image!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) {
                        return const Center(
                            child: CircularProgressIndicator.adaptive());
                      },
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error,
                        color: AppColors.primary,
                      ),
                    )
                  : Opacity(
                      opacity: 0.2,
                      child: Image.asset(
                        "assets/icons/logo.png",
                        fit: BoxFit.scaleDown,
                      )),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //User name and expired mention if coaching expired
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(user.name,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      ),
                      //show this text if coaching expired

                      const SizedBox.shrink(),
                    ],
                  ),

                  SizedBox(
                    height: 2.r,
                  ),

                  Row(
                    children: [
                      Flexible(
                        child: Text("${user.city}, ${user.country}",
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                                color: Colors.black, fontSize: 9.sp)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          InkWell(
              onTap: onTap,
              child: Container(
                  width: 105.w,
                  padding: EdgeInsets.symmetric(vertical: 5.r, horizontal: 5.r),
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5.r)),
                  child: const Center(
                    child: Text(
                      "Envoyer le message",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  )))
        ],
      ),
    );
  }
}
