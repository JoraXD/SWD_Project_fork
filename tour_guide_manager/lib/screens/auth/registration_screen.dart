import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tour_guide_manager/colors.dart';
import 'package:tour_guide_manager/main.dart';
import 'login_screen.dart';
import 'package:tour_guide_manager/widgets/top_snack_bar.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final telegramController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    telegramController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() {
      isLoading = true;
    });
    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final tg = telegramController.text.trim();
      final name = nameController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        setState(() {
          isLoading = false;
        });
        showTopSnackBar(context, 'Введите email и пароль');
        return;
      }

      if (name.isEmpty) {
        setState(() {
          isLoading = false;
        });
        showTopSnackBar(context, 'Введите имя');
        return;
      }

      if (tg.isEmpty) {
        setState(() {
          isLoading = false;
        });
        showTopSnackBar(context, 'Введите telegram');
        return;
      }

      if (!tg.contains('@')) {
        setState(() {
          isLoading = false;
        });
        showTopSnackBar(context, 'Telegram не формата @username');
        return;
      }

      final userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseFirestore.instance
          .collection('guides')
          .doc(userCred.user!.uid)
          .set({
        'telegramAlias': tg,
        'excursionsDone': 0,
        'name': name,
        'avatar': '',
        'bio': '',
        'createdAt': Timestamp.now(),
        'email': email,
        'level': '',
        'phone': '',
      });

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/auth',
          (route) => false,
        );
      }

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code == 'email-already-in-use') {
        showTopSnackBar(context, 'Этот email уже используется');
      } else if (e.code == 'weak-password') {
        showTopSnackBar(context, 'Пароль слишком простой');
      } else if (e.code == 'invalid-email') {
        showTopSnackBar(context, 'Неверный формат email');
      } else {
        showTopSnackBar(context, 'Ошибка регистрации: ${e.message}');
      }
    } on FirebaseException catch (e) {
      if (!mounted) return;
      showTopSnackBar(context, 'Произошла ошибка: ${e.message}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: isLoading ?
      const Center(
        child: CircularProgressIndicator(color: AppColors.darkBlue),
      ) :
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Text(
              'Создайте аккаунт',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 22,
                color: AppColors.darkGrey,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: TextField(
                controller: emailController,
                cursorColor: AppColors.darkBlue,
                style: const TextStyle(fontSize: 17),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  hintText: 'Email',
                  hintStyle: const TextStyle(color: AppColors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: TextField(
                controller: passwordController,
                cursorColor: AppColors.darkBlue,
                obscureText: true,
                style: const TextStyle(fontSize: 17),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  hintText: 'Пароль',
                  hintStyle: const TextStyle(color: AppColors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: TextField(
                controller: nameController,
                cursorColor: AppColors.darkBlue,
                style: const TextStyle(fontSize: 17),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  hintText: 'Имя и фамилия',
                  hintStyle: const TextStyle(color: AppColors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 48,
              child: TextField(
                controller: telegramController,
                cursorColor: AppColors.darkBlue,
                style: const TextStyle(fontSize: 17),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  hintText: 'Telegram',
                  hintStyle: const TextStyle(color: AppColors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              width: double.infinity,
              child: FilledButton(
                onPressed: _signUp,
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                    )
                ),
                child: const Text(
                  'Регистрация',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Уже есть аккаунт?'),
                  const SizedBox(width: 6),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/login'
                      );
                    },
                    child: const Text(
                      'Вход',
                      style: TextStyle(
                        color: AppColors.darkBlue,
                      ),
                    )
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
