import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swiit/src/core/core.dart';
import 'package:swiit/src/core/reusable/functions/fetch_common_chat.dart';
import 'package:swiit/src/core/router/page_route.dart';
import 'package:swiit/src/features/auth/data/models/user_model.dart';
import 'package:swiit/src/features/auth/presentation/widgets/color_gradient.dart';
import 'package:swiit/src/features/clubs/presentation/widgets/search_text_field.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../auth/presentation/bloc/app_bloc/app_bloc.dart'; // Import AppBloc to access the authenticated user

class UserSearchSwiiterToChatPage extends StatefulWidget {
  const UserSearchSwiiterToChatPage({super.key});

  @override
  State<UserSearchSwiiterToChatPage> createState() =>
      _UserSearchSwiiterToChatPageState();
}

class _UserSearchSwiiterToChatPageState
    extends State<UserSearchSwiiterToChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = false;
  List<UserModel> membersWithoutDirectChat = [];
  int _currentPage = 1;
  bool _isLoadingMore = false;
  // fetchUserWithoutDirectChat

  Future<void> _onScroll() async {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    const scrollThreshold = 200.0;

    if (membersWithoutDirectChat.isNotEmpty &&
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
            token: user.token!,
            page: _currentPage,
            searchText: _searchController.text);
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
    super.initState();
    setState(() {
      isLoading = true;
    });
    // Add listener to watch for text changes in the search field
    _searchController.addListener(_onSearchTextChanged);
    _scrollController.addListener(_onScroll);

    // Perform an initial search
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AppBloc>().state.user!;
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
  }

  initFetchUserWithoutDirectChat() {
    final user = context.read<AppBloc>().state.user!;
    setState(() {
      isLoading = true;
      _currentPage = 1;
    });
    fetchUserWithoutDirectChat(
            token: user.token!,
            page: _currentPage,
            searchText: _searchController.text)
        .then((results) {
      setState(() {
        membersWithoutDirectChat = results;
      });
    }).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _scrollController.removeListener(_onScroll);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    // Function executed whenever the search field value changes
    final query = _searchController.text;
    final user = context.read<AppBloc>().state.user!;
    setState(() {
      isLoading = true;
      _currentPage = 1;
    });
    fetchUserWithoutDirectChat(
            token: user.token!, page: _currentPage, searchText: query)
        .then((results) {
      setState(() {
        membersWithoutDirectChat = results;
      });
    }).whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: true,
          leading: IconButton(
            onPressed: () {
              // context.pop();
              context.pushReplacementNamed(PageRoutes.userRoomListRoute);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.black),
          ),
          title: MySearchTextFiel(
            searchController: _searchController,
          ),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            if (membersWithoutDirectChat.isNotEmpty) {
              return ListView.separated(
                // shrinkWrap: true,
                // physics: const NeverScrollableScrollPhysics(),
                controller: _scrollController,
                itemCount:
                    membersWithoutDirectChat.length + (_isLoadingMore ? 1 : 0),
                separatorBuilder: (context, index) => Container(
                    // margin: const EdgeInsets.symmetric(vertical: 10),

                    ),
                itemBuilder: (context, index) {
                  if (index >= membersWithoutDirectChat.length) {
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
                  final member = membersWithoutDirectChat[index];
                  return _AddMemberCard(
                    onTap: () async {
                      final userToRemove = await context.pushNamed(
                          PageRoutes.userChatBySendFirstMessagePageRoute,
                          extra: member);
                      if (userToRemove != null) {
                        initFetchUserWithoutDirectChat();
                      }
                    },
                    user: member,
                  );
                },
              );
            }
            return const Center(
                child: Text(
              "Aucun swiiter",
              style: TextStyle(color: Colors.white),
            ));
          }),
        ));
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
