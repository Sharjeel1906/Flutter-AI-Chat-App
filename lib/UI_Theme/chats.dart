import 'package:ai_chat_app/provider/login_register_provider.dart';
import 'package:ai_chat_app/provider/selection_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_chat_app/provider/sessions_provider.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionProvider = context.watch<SessionsProvider>();
    final selectionProvider = context.watch<SelectionProvider>();
    final loginProvider = context.watch<Login_Register_Provider>();

    // Ensure sessions match login state
    Future.microtask(() {
      if (loginProvider.is_loggedin) {
        sessionProvider.getSessions();
      } else {
        sessionProvider.ResetSessions();
      }
    });

    final sessionList = sessionProvider.sessions;
    final w = MediaQuery.of(context).size.width;
    final bool isDesktop = w > 600;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            sessionProvider.ResetSessions();
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Chats",
          style: TextStyle(
            fontSize: 28,
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
            child: _buildBody(sessionProvider, sessionList, selectionProvider),
          ),
        ),
      ),
      bottomNavigationBar: Consumer<SelectionProvider>(
        builder: (context, sel, _) {
          // Only show if a session is selected
          if (sel.selected_session_id == null) return const SizedBox();

          return Container(
            padding: EdgeInsets.only(bottom: 50, top: 10),
            height: 80,
            decoration: BoxDecoration(color: Colors.white),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, size: 30),
                  onPressed: sel.clearSessionSelection,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 30),
                  onPressed: () {
                    sel.deleteSession(sel.selected_session_id!, sessionList);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    SessionsProvider sessionProvider,
    List<Map<String, dynamic>> list,
    SelectionProvider selectionprovider,
  ) {
    if (sessionProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (list.isEmpty) {
      return const Center(
        child: Text(
          "No sessions yet",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        selectionprovider.clearSessionSelection();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(
          top: 100,
          left: 16,
          right: 16,
          bottom: 20,
        ),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          return Consumer<SelectionProvider>(
            builder: (ctx, selection, _) {
              final isSelected = selection.selected_session_id == item["id"];
              final id = item['id'];
              return GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   // MaterialPageRoute(
                  //   //   builder: (context) => PreviousChatScreen(
                  //   //     session_id: id,
                  //   //   ),
                  //   // ),
                  // );
                },
                onLongPress: () {
                  selection.selectSession(item['id']);
                },
                child: _ChatCard(
                  icon: Icons.chat_rounded,
                  title: item["title"]?.toString() ?? "Untitled",
                  time: item["last_message_time"] != null
                      ? formatTime(item["last_message_time"])
                      : "Unknown",
                  selected: isSelected,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ChatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  final bool selected; // NEW

  const _ChatCard({
    required this.icon,
    required this.title,
    required this.time,
    this.selected = false, // default false
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: selected
            ? BorderSide(color: Colors.blue, width: 2) // highlight border
            : BorderSide.none,
      ),
      color: selected
          ? Colors.blue.shade50
          : Colors.white, // highlight background
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 5),
                  child: Icon(
                    icon,
                    size: 22,
                    color: selected
                        ? Colors.blue.shade700
                        : const Color(0xFF7E57C2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      color: selected
                          ? Colors.blue.shade700
                          : const Color(0xFF7E57C2),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "  Last Updated • $time",
              style: TextStyle(
                fontSize: 14,
                color: selected ? Colors.blueGrey : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String formatTime(String isoTime) {
  final dt = DateTime.parse(isoTime).toUtc().toLocal();
  final day = dt.day.toString().padLeft(2, '0');
  final month = dt.month.toString().padLeft(2, '0');
  final year = dt.year.toString();

  final hour12 = dt.hour == 0
      ? 12
      : dt.hour > 12
      ? dt.hour - 12
      : dt.hour;
  final minute = dt.minute.toString().padLeft(2, '0');
  final ampm = dt.hour >= 12 ? 'PM' : 'AM';

  return '$day/$month/$year • $hour12:$minute $ampm';
}
