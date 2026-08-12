import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:truefit_coaches/core/theme/app_theme.dart';
import 'package:truefit_coaches/core/intl/app_localizations.dart';
import 'package:truefit_coaches/features/chat/presentation/cubit/list/chat_list_cubit.dart';
import 'package:truefit_coaches/features/chat/presentation/pages/chat_room_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                l10n.translate('nav_chat').toUpperCase(),
                style: GoogleFonts.barlowCondensed(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<ChatListCubit, ChatListState>(
                  builder: (context, state) {
                    if (state is ChatListLoading) {
                      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
                    }
                    if (state is ChatListLoaded) {
                      if (state.conversations.isEmpty) {
                        return Center(
                          child: Text(l10n.translate('no_conversations'), style: const TextStyle(color: Colors.white24)),
                        );
                      }
                      return ListView.builder(
                        itemCount: state.conversations.length,
                        itemBuilder: (context, index) {
                          final chat = state.conversations[index];
                          return _buildChatTile(context, chat, l10n);
                        },
                      );
                    }
                    if (state is ChatListError) {
                      return Center(child: Text(state.message, style: const TextStyle(color: AppTheme.primaryRed)));
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, Map<String, dynamic> chat, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRoomScreen(conversation: chat),
            ),
          );
        },
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppTheme.primaryRed.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              (chat['display_name'] ?? 'M').substring(0, 1).toUpperCase(),
              style: GoogleFonts.barlowCondensed(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ),
        title: Text(
          chat['display_name'] ?? l10n.translate('member'),
          style: GoogleFonts.barlowCondensed(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          chat['last_message'] ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 13),
        ),
        trailing: chat['unread_count'] != null && chat['unread_count'] > 0
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: AppTheme.primaryRed, shape: BoxShape.circle),
                child: Text(
                  chat['unread_count'].toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              )
            : const Icon(LucideIcons.chevronRight, color: Colors.white12, size: 18),
      ),
    );
  }
}
