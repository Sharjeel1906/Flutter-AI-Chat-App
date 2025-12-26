import 'package:ai_chat_app/UI_Theme/home_page.dart';
import 'package:ai_chat_app/provider/focus_provider.dart';
import 'package:ai_chat_app/provider/login_register_provider.dart';
import 'package:ai_chat_app/UI_Theme/sign_up.dart';
import 'package:ai_chat_app/UI_Theme/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final TextEditingController email_cont = TextEditingController();
final TextEditingController pass_cont = TextEditingController();
final FocusNode field1Focus = FocusNode();
final FocusNode field2Focus = FocusNode();
class SignIn extends StatelessWidget {
  const SignIn({super.key});

  @override
  Widget build(BuildContext context) {

    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    final double cardWidth = w < 600 ? w * 0.9 : 450;
    final bool isDesktop = w > 600;

    return GestureDetector(
      onTap: () {
        field1Focus.unfocus();
        field2Focus.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF7B6CF6)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          width: w,
          height: h,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xffB39DDB), Color(0xff90CAF9)],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: cardWidth,
                  padding: EdgeInsets.all(isDesktop ? 40 : 0),
                  decoration: BoxDecoration(
                    color: isDesktop
                        ? Colors.white.withOpacity(0.9)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: isDesktop
                        ? const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo Icon
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7B6CF6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.smart_toy_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Welcome back 😊",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: Color(0xff3E4A61),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Your stress-free companion",
                        style: TextStyle(
                          color: Color(0xff7A869C),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Email TextField
                      TextField(
                        focusNode: field1Focus,
                        keyboardType: TextInputType.emailAddress,
                        controller: email_cont,
                        decoration: InputDecoration(
                          hintText: "Email Address",
                          prefixIcon: const Icon(Icons.email_outlined, size: 20),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          fillColor: isDesktop
                              ? Colors.white
                              : Colors.white.withOpacity(0.9),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Password TextField
                      TextField(
                        focusNode: field2Focus,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: true,
                        controller: pass_cont,
                        decoration: InputDecoration(
                          hintText: "Password",
                          prefixIcon: const Icon(Icons.lock_outline, size: 20),
                          filled: true,
                          fillColor: isDesktop
                              ? Colors.white
                              : Colors.white.withOpacity(0.9),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Sign In Button with Provider Loading
                      Consumer<Login_Register_Provider>(
                        builder: (context, provider, child) {
                          return SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: provider.is_loading
                                  ? null
                                  : () async {
                                      final result = await provider.Login_user(
                                        email_cont.text,
                                        pass_cont.text,
                                      );
                                      if (result["code"] == "200") {
                                        UiHelper.customColoredBox(context, result["message"]!);
                                        provider.is_loggedin= true;
                                        email_cont.clear();
                                        pass_cont.clear();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => HomePage(),
                                          ),
                                        );
                                      } else {
                                        UiHelper.customColoredBox(context, result["message"]!);
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: EdgeInsets.zero,
                                elevation: 0,
                              ),
                              child: provider.is_loading
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    )
                                  : Ink(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF6D7CF4),
                                            Color(0xFF8E5EC7),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          "Sign In",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(fontSize: 14),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SignUp()),
                              );
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7B6CF6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
