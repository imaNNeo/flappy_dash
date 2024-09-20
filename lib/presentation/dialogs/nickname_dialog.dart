import 'package:flappy_dash/domain/extensions/user_extension.dart';
import 'package:flappy_dash/presentation/bloc/game/game_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NicknameDialog extends StatefulWidget {
  const NicknameDialog({super.key});

  @override
  State<NicknameDialog> createState() => _NicknameDialogState();
}

class _NicknameDialogState extends State<NicknameDialog> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    final name =
        context.read<GameCubit>().state.currentUserAccount?.user.showingName;
    _textEditingController = TextEditingController(text: name);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      content: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Your name',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _textEditingController,
                decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.0),
                  ),
                  hintText: 'Nickname',
                ),
                maxLength: 12,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 240,
                child: FilledButton.tonal(
                  onPressed: _onSaveClicked,
                  child: const Text('SAVE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSaveClicked() {
    final gameCubit = context.read<GameCubit>();
    final newName = _textEditingController.text;
    gameCubit.updateUserDisplayName(newName);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
