import 'package:flappy_dash/domain/extensions/user_extension.dart';
import 'package:flappy_dash/presentation/bloc/account/account_cubit.dart';
import 'package:flappy_dash/presentation/app_style.dart';
import 'package:flappy_dash/presentation/widget/big_button.dart';
import 'package:flappy_dash/presentation/widget/game_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NicknameDialog extends StatefulWidget {
  static Future<String?> show(BuildContext context) {
    return showDialog<String?>(
      context: context,
      builder: (context) {
        return const NicknameDialog();
      },
    );
  }

  const NicknameDialog({super.key});

  @override
  State<NicknameDialog> createState() => _NicknameDialogState();
}

class _NicknameDialogState extends State<NicknameDialog> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    final name = context
        .read<AccountCubit>()
        .state
        .currentAccount
        ?.user
        .showingName;
    _textEditingController = TextEditingController(text: name);
    super.initState();
  }

  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return GameDialog(
      title: 'Your Nickname',
      maxWidth: 380,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textEditingController,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _onSaveClicked(),
              style: const TextStyle(
                color: AppColors.whiteTextColor,
                fontSize: 22,
              ),
              cursorColor: AppColors.mainColor,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black26,
                counterStyle: const TextStyle(color: Colors.white54),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.mainColor,
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                hintText: 'Nickname',
                hintStyle: const TextStyle(color: Colors.white38),
              ),
              maxLength: 12,
            ),
            const SizedBox(height: 12),
            Center(
              child: BigButton(
                height: 58,
                width: 240,
                strokeColor: Colors.white,
                bgColor: AppColors.blueButtonBgColor,
                showLoading: _saving,
                onPressed: _saving ? null : _onSaveClicked,
                child: const Text(
                  'SAVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSaveClicked() async {
    final newName = _textEditingController.text.trim();
    if (newName.isEmpty) {
      return;
    }
    setState(() => _saving = true);
    try {
      await context.read<AccountCubit>().updateUserDisplayName(newName);
    } catch (_) {
      // The name is saved again next time; don't keep the player stuck here.
    }
    if (mounted) {
      Navigator.of(context).pop(newName);
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
