class AppConfig {
  static const String apiBaseUrl = 'http://127.0.0.1:8000';
}

class UiConstants {
  static const String appName = 'Bharat Transliteration';
  static const String loginLabel = 'Login';
  static const String transliterateLabel = 'Transliterate';
  static const String notesLabel = 'Notes';
  static const String mapLabel = 'Map';
  
  // Login screen constants
  static const String loginFailedMessage = 'Login failed. Please check your credentials.';
  static const String loginTitle = 'Login to Your Account';
  static const String logoutButtonLabel = 'Logout';
  static const String loginButtonLabel = 'Login';
  
  // Transliteration screen constants
  static const List<String> supportedScripts = ['English', 'Hindi', 'Tamil', 'Telugu', 'Bengali', 'Gujarati', 'Marathi', 'Punjabi', 'Kannada', 'Malayalam', 'Odia', 'Assamese'];
  static const String enterTextMessage = 'Please enter some text to transliterate';
  static const String transliterationErrorMessage = 'Error during transliteration of';
  static const String textCopiedMessage = 'Text copied to clipboard!';
  static const String loginRequiredMessage = 'Please log in to save notes';
  static const String noteSavedMessage = 'Note saved successfully!';
  static const String noteSavedToMapMessage = 'Note saved to map successfully!';
  static const String transliterationTitle = 'Text Transliteration';
  static const String clearTextLabel = 'Clear Text';
  static const String transliterateTextLabel = 'Transliterate Text';
  static const String pickImageLabel = 'Pick Image';
  static const String captureImageLabel = 'Capture Image';
  static const String copyResultLabel = 'Copy Result';
  static const String saveToNotesLabel = 'Save to Notes';
  static const String saveToMapLabel = 'Save to Map';
  
  // Notes screen constants
  static const String noteAddFailedMessage = 'Failed to add note. Please try again.';
  static const String notesTitle = 'Your Notes';
  static const String saveNoteLabel = 'Save Note';
}
