part of '../home_page.dart';

class SinglePlayerButton extends StatelessWidget {
  const SinglePlayerButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return BigButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            "assets/images/dash.svg",
            height: 58,
          ),
          const SizedBox(width: 8),
          const OutlineText(
            Text(
              'Single Player',
              style: TextStyle(
                color: AppColors.darkBlueColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            strokeColor: Colors.white,
            strokeWidth: 4,
          ),
        ],
      ),
    );
  }
}
