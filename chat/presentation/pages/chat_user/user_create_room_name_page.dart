import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swiit/src/core/reusable/form_input/constant.dart';
import 'package:swiit/src/core/reusable/functions/fetch_common_chat.dart';
import 'package:swiit/src/features/auth/presentation/bloc/app_bloc/app_bloc.dart';
import 'package:swiit/src/features/auth/presentation/widgets/submit_button.dart';
import 'package:swiit/src/features/clubs/data/models/room_payload.dart';
import 'package:swiit/src/features/clubs/presentation/cubit/club_cubit.dart';
import 'package:swiit/src/features/clubs/presentation/widgets/form_text_field.dart';
import 'package:swiit/src/features/coaching/presentation/widgets/coaching_app_bar.dart';
import 'package:swiit/src/features/coaching/presentation/widgets/library/coaching%20select_category_dropdown.dart';
import 'package:swiit/src/features/events/data/models/event_model.dart';

class UserCreateRoomNamePage extends StatefulWidget {
  const UserCreateRoomNamePage({super.key});

  @override
  _UserCreateRoomNamePageState createState() => _UserCreateRoomNamePageState();
}

class _UserCreateRoomNamePageState extends State<UserCreateRoomNamePage> {
  final TextEditingController _roomNameController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    if (mounted) {
      final user = context.read<AppBloc>().state.user;
      final currentClub = context.read<ClubCubit>().state.currentClub;
    }
    super.initState();
  }

  bool areAllFieldsFilled() {
    return _roomNameController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CoachingAppBar(
        title: "Créer une nouvelle room",
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormTextField(
              title: "Nom de la room",
              controller: _roomNameController,
            ),
            const SizedBox(height: 20),
            // _SelectEventDropdown(),
            const SizedBox(height: 20),
            SubmitButton(
              title: isLoading ? "Creating.." : "Continuer",
              onTap: () async {
                if (areAllFieldsFilled() && !isLoading) {
                  final user = context.read<AppBloc>().state.user!;
                  final currentClub =
                      context.read<ClubCubit>().state.currentClub;
                  try {
                    setState(() {
                      isLoading = true;
                    });
                    final result = await createUserRoom(
                        payload: RoomPayload(
                            admin_id: context.read<AppBloc>().state.user!.id,
                            room_name: _roomNameController.text),
                        token: user.token!);

                    if (result != null) {
                      await context.read<ClubCubit>().fetchInitalUserRooms();
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.green,
                            content: Text("Room created with success"),
                          ),
                        );

                      Navigator.of(context).pop();
                    }
                  } finally {
                    setState(() {
                      isLoading = false;
                    });
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Veuillez entrer un nom pour la room')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    super.dispose();
  }
}
