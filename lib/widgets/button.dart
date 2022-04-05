import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ngo/apptheme.dart';

class Button extends StatelessWidget {
  final String name;
  final Function userMethod;

  Button(this.name, this.userMethod);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => userMethod(),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        alignment: Alignment.center,
        height: 45.0,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(0, 1),
            ),
          ],
          color: AppTheme.button,
        ),
        child: Text(
          name,
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
