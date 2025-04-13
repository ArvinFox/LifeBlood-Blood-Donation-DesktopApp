import 'package:flutter/material.dart';

class CustomAuthButton extends StatelessWidget {
  final bool? isLoading;
  final String label;
  final VoidCallback? onPressed;  

  const CustomAuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE97777),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      onPressed: onPressed,
      child: isLoading!
        ? CircularProgressIndicator()
        : Text(
            label,
            style: TextStyle(color: Colors.white),
          ),
    );
  }
}