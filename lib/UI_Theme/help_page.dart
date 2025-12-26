import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final bool isDesktop = w > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF90CAF9),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Help & Support",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB39DDB), Color(0xFF90CAF9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SizedBox(
            width: isDesktop ? 700 : double.infinity,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: const [
                _HelpCard(
                  icon: Icons.smart_toy_rounded,
                  title: "About SmileAI",
                  content:
                  "SmileAI is an AI-powered chat application designed to reduce stress, provide emotional comfort, and offer engaging conversations in a calm and friendly environment.",
                ),
                _HelpCard(
                  icon: Icons.login_rounded,
                  title: "Login & Registration",
                  content:
                  "• Create an account using the Register option.\n"
                      "• Login using your email and password.\n"
                      "• Your sessions will be saved securely for future access.",
                ),
                _HelpCard(
                  icon: Icons.chat_bubble_outline,
                  title: "Using Chat",
                  content:
                  "• Start a new chat from the drawer menu.\n"
                      "• Talk freely with SmileAI about stress, emotions, or general topics.\n"
                      "• SmileAI responds in a supportive and friendly manner.",
                ),
                _HelpCard(
                  icon: Icons.history_rounded,
                  title: "Chat Sessions",
                  content:
                  "• Each conversation is saved as a session.\n"
                      "• Sessions appear with meaningful titles.\n"
                      "• You can revisit previous chats anytime.",
                ),
                _HelpCard(
                  icon: Icons.security_rounded,
                  title: "Privacy & Safety",
                  content:
                  "• Your chats are private and secure.\n"
                      "• No sensitive personal data is shared.\n"
                      "• SmileAI is not a replacement for professional medical advice.",
                ),
                _HelpCard(
                  icon: Icons.support_agent_rounded,
                  title: "Need More Help?",
                  content:
                  "If you face any issues or have suggestions, feel free to contact us.\n\n"
                      "Email: support@smileai.app\n"
                      "We’re always happy to help 😊",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const _HelpCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28, color: Color(0xFF7E57C2)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
