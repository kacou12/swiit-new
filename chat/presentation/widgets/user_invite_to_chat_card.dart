import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swiit/src/core/constants/app_colors.dart';
import 'package:swiit/src/features/auth/data/models/chat_user_model.dart';

class UserInviteToChatCard extends StatelessWidget {
  const UserInviteToChatCard(
      {super.key, this.onTap, required this.user, required this.textButton});

  final String textButton;
  final UserChatModel user;
  final VoidCallback? onTap;

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
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: Colors.blueGrey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: user.image != null
                  ? CachedNetworkImage(
                      imageUrl: user.image,
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
                            maxLines: 1,
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

                  // TEXT INFO
                ],
              ),
            ),
          ),
          Builder(builder: (context) {
            return InkWell(
                onTap: onTap,
                child: Container(
                    width: 85.w,
                    padding: EdgeInsets.symmetric(vertical: 2.r),
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
                    )));
          })
        ],
      ),
    );
  }
}
