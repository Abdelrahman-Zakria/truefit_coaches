import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:truefit_coaches/core/theme/app_theme.dart';
import 'package:truefit_coaches/core/intl/app_localizations.dart';
import 'package:truefit_coaches/features/auth/presentation/cubit/auth_cubit.dart';
import '../cubit/room/chat_room_cubit.dart';

class ChatRoomScreen extends StatefulWidget {
  final Map<String, dynamic> conversation;

  const ChatRoomScreen({super.key, required this.conversation});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    context.read<ChatRoomCubit>().watchMessages(widget.conversation['id']);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordSeconds = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordSeconds++;
      });
    });
  }

  void _stopRecording() {
    _timer?.cancel();
    setState(() {
      _isRecording = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: _buildAppBar(l10n),
      body: Column(
        children: [
          Expanded(child: _buildMessagesList(l10n)),
          _buildQuickReplies(l10n),
          _buildInputArea(l10n),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    final name = widget.conversation['display_name'] ?? l10n.translate('member');
    final role = widget.conversation['coach_role'] ?? l10n.translate('coach');
    final isOnline = widget.conversation['is_online'] ?? false;

    return AppBar(
      backgroundColor: const Color(0xFF1A1A1A),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(LucideIcons.chevronLeft, color: Colors.grey),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.substring(0, 1).toUpperCase(),
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF1A1A1A), width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.barlowCondensed(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                isOnline ? l10n.translate('active_now') : role,
                style: GoogleFonts.inter(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.moreVertical, color: Colors.white, size: 20),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMessagesList(AppLocalizations l10n) {
    return BlocBuilder<ChatRoomCubit, ChatRoomState>(
      buildWhen: (previous, current) => current is ChatRoomMessagesLoaded || current is ChatRoomLoading,
      builder: (context, state) {
        if (state is ChatRoomLoading) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRed));
        }

        if (state is ChatRoomMessagesLoaded) {
          final messages = state.messages;
          if (messages.isEmpty) {
            return Center(
              child: Text(
                l10n.translate('start_conversation'),
                style: GoogleFonts.inter(color: Colors.white24, fontSize: 14),
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              final authState = context.read<AuthCubit>().state;
              final String currentUid = authState is AuthAuthenticated ? authState.coach['uid'] : '';
              final bool isMe = msg['sender_id'] == currentUid;

              return _buildMessageBubble(msg, isMe);
            },
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe) {
    final timestamp = msg['created_at'] as dynamic;
    String timeStr = "";
    if (timestamp != null) {
      final date = timestamp is DateTime ? timestamp : timestamp.toDate();
      timeStr = DateFormat('HH:mm').format(date);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.user, color: AppTheme.primaryRed, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe ? AppTheme.primaryRed : const Color(0xFF1A1A1A),
                    border: isMe ? null : Border.all(color: const Color(0xFF2A2A2A)),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMe ? 20 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 20),
                    ),
                  ),
                  child: Text(
                    msg['text'] ?? '',
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeStr,
                  style: GoogleFonts.jetBrainsMono(color: const Color(0xFF6B7280), fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReplies(AppLocalizations l10n) {
    final replies = [
      l10n.translate('reply_great_work'),
      l10n.translate('reply_diet_plan'),
      l10n.translate('reply_check_in'),
      l10n.translate('reply_push_harder'),
    ];
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: replies.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) => ActionChip(
          label: Text(
            replies[index],
            style: GoogleFonts.inter(color: const Color(0xFFD1D5DB), fontSize: 12),
          ),
          backgroundColor: const Color(0xFF1A1A1A),
          side: const BorderSide(color: Color(0xFF2A2A2A)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          onPressed: () => _controller.text = replies[index],
        ),
      ),
    );
  }

  Widget _buildInputArea(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      child: _isRecording ? _buildRecordingInput(l10n) : _buildTextInput(l10n),
    );
  }

  Widget _buildTextInput(AppLocalizations l10n) {
    return Row(
      children: [
        IconButton(icon: const Icon(LucideIcons.paperclip, color: Colors.grey, size: 20), onPressed: () {}),
        IconButton(
          icon: const Icon(LucideIcons.mic, color: Colors.grey, size: 20),
          onPressed: _startRecording,
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: l10n.translate('type_message'),
                      hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const Icon(LucideIcons.smile, color: Colors.grey, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            final text = _controller.text.trim();
            if (text.isNotEmpty) {
              final authState = context.read<AuthCubit>().state;
              if (authState is AuthAuthenticated) {
                final coach = authState.coach;
                context.read<ChatRoomCubit>().sendMessage(
                      coach['uid'],
                      widget.conversation['id'],
                      text,
                      coach['name'] ?? l10n.translate('coach'),
                    );
                _controller.clear();
              }
            }
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(color: AppTheme.primaryRed, shape: BoxShape.circle),
            child: const Icon(LucideIcons.send, color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingInput(AppLocalizations l10n) {
    final minutes = _recordSeconds ~/ 60;
    final seconds = _recordSeconds % 60;
    final fmtTime = "$minutes:${seconds.toString().padLeft(2, '0')}";

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.primaryRed.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppTheme.primaryRed, shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
                Text(
                  "${l10n.translate('recording')} $fmtTime",
                  style: GoogleFonts.inter(
                    color: AppTheme.primaryRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _stopRecording,
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(color: AppTheme.primaryRed, shape: BoxShape.circle),
            child: const Icon(LucideIcons.square, color: Colors.white, size: 16),
          ),
        ),
      ],
    );
  }
}
