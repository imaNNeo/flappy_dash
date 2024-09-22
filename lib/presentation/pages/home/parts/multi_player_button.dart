part of '../home_page.dart';

class MultiPlayerButton extends StatelessWidget {
  const MultiPlayerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BigButton(
      bgColor: AppColors.greenButtonBgColor,
      strokeColor: AppColors.greenButtonStrokeColor,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            "assets/images/multi_dash.svg",
            height: 58,
          ),
          const SizedBox(width: 8),
          const GradientText(
            'Multi Player',
            gradient: LinearGradient(
              colors: AppColors.multiColorGradient,
            ),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.4,
            ),
          ),
        ],
      ),
      onPressed: () {},
    );
  }
}
