class ChatUtils {
  /// Generates a deterministic chat ID to ensure both apps (Coach and User)
  /// connect to the exact same Firestore document without redundant lookups.
  static String getDeterministicChatId(String uid1, String uid2) {
    final List<String> ids = [uid1, uid2];
    ids.sort(); // Sorting ensures the ID is always the same regardless of who starts the chat
    return ids.join('_');
  }
}
