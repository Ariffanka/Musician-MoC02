class AuthService {
  Future<Map<String, String>?> signInWithGoogle() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      
      // Kembalikan data user (bisa juga return null untuk simulasi gagal)
      return {
        'email': 'user@example.com',
        'name': 'Musician User',
        'photo': '',
      };
    } catch (e) {
      return null;
    }
  }

  Future<void> signOutFromGoogle() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}