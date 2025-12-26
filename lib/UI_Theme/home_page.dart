import 'package:ai_chat_app/UI_Theme/chats.dart';
import 'package:ai_chat_app/UI_Theme/disclaimer_page.dart';
import 'package:ai_chat_app/UI_Theme/help_page.dart';
import 'package:ai_chat_app/UI_Theme/privacy_page.dart';
import 'package:ai_chat_app/provider/chat_provider.dart';
import 'package:ai_chat_app/provider/internet_provider.dart';
import 'package:ai_chat_app/provider/login_register_provider.dart';
import 'package:ai_chat_app/provider/selection_provider.dart';
import 'package:ai_chat_app/provider/theme_provider.dart';
import 'package:ai_chat_app/UI_Theme/sign_in.dart';
import 'package:ai_chat_app/UI_Theme/sign_up.dart';
import 'package:ai_chat_app/UI_Theme/ui_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/sessions_provider.dart';

final TextEditingController mess_cont = TextEditingController();
final FocusNode field1Focus = FocusNode();
final ScrollController scrollController = ScrollController();

// One-time flag for showing login popup on first send
bool _hasShownLoginPromptOnSend = false;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final bool isDesktop = w > 600;
    bool isConnected = context.watch<InternetProvider>().isConnected;
    final chat = context.watch<ChatProvider>();
    int? id = chat.session_id;
    int tempIdCounter = 0; // in ChatProvider or global
    final authProvider = context.watch<Login_Register_Provider>();
    final bool isloggedin = authProvider.is_loggedin;

    return GestureDetector(
      onTap: () => field1Focus.unfocus(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: const Color(0xFF90CAF9),
          elevation: 0,
          title: Row(
            children: [
              const SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.white24,
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.smart_toy_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "SmileAI",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    isConnected ? "Online" : "Offline",
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ),
        drawer: Drawer(
          width: isDesktop
              ? (w * 0.18).clamp(240.0, 320.0)
              : (w * 0.70).clamp(240.0, 320.0),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB39DDB), Color(0xFF90CAF9)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isloggedin
                            ? Icons.account_circle_rounded
                            : Icons.smart_toy_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          isloggedin
                              ? context.watch<Login_Register_Provider>().name
                              : "SmileAI",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _drawerItem(Icons.login, "Login", () {
                  context.read<ChatProvider>().ResetChat();
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignIn()),
                  );
                }),
                _drawerItem(Icons.app_registration, "Register", () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUp()),
                  );
                }),
                _drawerItem(Icons.chat, "New Chat", () {
                  context.read<ChatProvider>().ResetChat();
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                }),
                _drawerItem(Icons.list, "Chats", () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatScreen()),
                  );
                }),
                Consumer<Login_Register_Provider>(
                  builder: (context, provider, child) {
                    return _drawerItem(
                      Icons.logout_outlined,
                      "Logout",
                          () async {
                        if (!provider.is_loggedin) {
                          UiHelper.customColoredBox(context, "You are not logged in");
                          return;
                        }
                        final result = await provider.LogoutUser();
                        if (result["code"] == "200") {
                          Provider.of<SessionsProvider>(context, listen: false).ResetSessions();
                          Provider.of<SelectionProvider>(context, listen: false).clearSessionSelection();
                          provider.is_loggedin = false; // update state
                          UiHelper.customColoredBox(
                            context,
                            result["message"] ?? "Logout Success",
                          );
                        } else {
                          UiHelper.customColoredBox(
                            context,
                            result["message"] ?? "Logout Failed",
                          );
                        }
                      },
                    );
                  },
                ),
                isDesktop
                    ? Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return SwitchListTile.adaptive(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                      ),
                      secondary: const Icon(
                        Icons.nights_stay_outlined,
                        color: Colors.white,
                      ),
                      title: const Text(
                        "Dark Mode",
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text(
                        "Change mode here",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      value: themeProvider.isdark,
                      onChanged: (value) {
                        themeProvider.updatetheme(value);
                      },
                    );
                  },
                )
                    : Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                      ),
                      leading: const Icon(
                        Icons.nights_stay_outlined,
                        color: Colors.white,
                      ),
                      title: const Text(
                        "Dark Mode",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: Switch.adaptive(
                        value: themeProvider.isdark,
                        onChanged: (value) {
                          themeProvider.updatetheme(value);
                        },
                      ),
                    );
                  },
                ),
                _drawerItem(Icons.help_outline, "Help & Support", () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HelpScreen()),
                  );
                }),
                _drawerItem(Icons.warning_amber_rounded, "Disclaimer", () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DisclaimerScreen()),
                  );
                }),
                _drawerItem(Icons.privacy_tip_outlined, "Privacy Policy", () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrivacyPolicyScreen(),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        body: Container(
          height: h,
          width: w,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFB39DDB), Color(0xFF90CAF9)],
            ),
          ),
          child: Consumer<ChatProvider>(
            builder: (ct, provider, child) {
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: chat.messages.length,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      reverse: true,
                      itemBuilder: (context, index) {
                        final msg = chat.messages[chat.messages.length - 1 - index];

                        final bool isMe = msg["role"] == "user";

                        final messageIdentifier = msg["id"]??index ;

                        return Consumer<SelectionProvider>(
                          builder: (ctx, selection, _) {
                            final isSelected = selection.selected_msg_id == messageIdentifier;

                            return GestureDetector(
                              onLongPress: () {
                                debugPrint("Long press on: $messageIdentifier");
                                selection.selectMessage(messageIdentifier);
                              },
                              child: Align(
                                alignment: isMe
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 5,
                                    horizontal: 10,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMe ? null : Colors.grey[200],
                                    gradient: isMe
                                        ? const LinearGradient(
                                      colors: [
                                        Color(0xFF6D7CF4),
                                        Color(0xFF8E5EC7),
                                      ],
                                    )
                                        : null,
                                    borderRadius: BorderRadius.circular(20),
                                    border: isSelected
                                        ? Border.all(
                                        color:  Colors.blue, width: 3)
                                        : null,
                                  ),
                                  child: Text(
                                    msg["message"] ?? "No message",
                                    style: TextStyle(
                                      color:
                                      isMe ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 5,
                    ),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(" 😊", style: TextStyle(fontSize: 30)),
                        ),
                        Expanded(
                          child: TextField(
                            controller: mess_cont,
                            focusNode: field1Focus,
                            decoration: InputDecoration(
                              hintText: "Type a message...",
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                              fillColor: Colors.white.withOpacity(0.7),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            final message = mess_cont.text.trim();
                            if (message.isEmpty) return;

                            final authProvider =
                            context.read<Login_Register_Provider>();
                            final bool isloggedin = authProvider.is_loggedin;

                            // Show login popup once on first send if user is not logged in
                            if (!isloggedin && !_hasShownLoginPromptOnSend) {
                              _hasShownLoginPromptOnSend = true;
                              showDialog(
                                context: context,
                                builder: (ctx) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFFB39DDB),
                                            Color(0xFF90CAF9),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.info_outline,
                                            color: Colors.white,
                                            size: 50,
                                          ),
                                          const SizedBox(height: 10),
                                          const Text(
                                            "Login Recommended",
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          const Text(
                                            "Please login for the best experience.",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  foregroundColor:
                                                  const Color(0xFF6D7CF4),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(ctx).pop();
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => const SignIn(),
                                                    ),
                                                  );
                                                },
                                                child: const Text("Login"),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white24,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(ctx).pop();
                                                },
                                                child: const Text("Later"),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }

                            mess_cont.clear();
                            field1Focus.unfocus();

                            try {
                              await context
                                  .read<ChatProvider>()
                                  .GetResponse(message);
                            } catch (e) {
                              debugPrint("Error sending message: $e");
                            }

                            if (scrollController.hasClients) {
                              scrollController.animateTo(
                                scrollController.position.minScrollExtent,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            }
                          },

                          icon: const Icon(
                            Icons.send,
                            color: Color(0xFF6D7CF4),
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              );
            },
          ),
        ),
        bottomNavigationBar: Consumer<SelectionProvider>(
          builder: (context, sel, _) {
            // Only show if a session is selected
            if (sel.selected_msg_id == null) return const SizedBox();
            return Container(
              padding: EdgeInsets.only(bottom: 50, top: 10),
              height: 80,
              decoration: BoxDecoration(color: Colors.white),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, size: 30),
                    onPressed: sel.clearMessageSelection,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 30),
                    onPressed: () {
                      sel.deleteMsg(
                        sel.selected_msg_id!,
                        context.read<ChatProvider>().messages,
                            () => context.read<ChatProvider>().notifyListeners(),
                      );
                      sel.clearAllSelections();
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      hoverColor: Colors.white24,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      onTap: onTap,
    );
  }
}
