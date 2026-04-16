class Secrets {
  // Gemini API key used by AiService to generate workout and diet plans
  static const geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AIzaSyDMClV-4-PoukRMWZVziAbD0xVjuSYlJhA',
  );
}
