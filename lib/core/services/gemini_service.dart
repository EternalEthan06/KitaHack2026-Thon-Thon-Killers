import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static GeminiService? _instance;
  late final GenerativeModel _model;

  GeminiService._() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.3,
      ),
    );
  }

  static GeminiService get instance {
    _instance ??= GeminiService._();
    return _instance!;
  }

  /// Scores an SDG post from image bytes (web-compatible).
  /// Returns a map with: is_sdg_related, sdg_goals, score, reason
  Future<Map<String, dynamic>> scoreSdgPostFromBytes(
      Uint8List imageBytes) async {
    try {
      final imagePart = DataPart('image/jpeg', imageBytes);

      const prompt = '''
Analyse this image submitted for a sustainable social media platform.

Answer these questions:
1. Does this image relate to any UN Sustainable Development Goals (SDGs)?
2. If yes, which SDG numbers (1-17)?
3. Give an SDG Impact Score from 0 to 100:
   - 0-20: No SDG relevance
   - 21-50: Mild relevance (awareness, casual)
   - 51-80: Clear, meaningful SDG action shown
   - 81-100: Exceptional, direct and significant SDG impact
4. A short reason explaining the score (1-2 sentences, friendly tone).

Return ONLY this valid JSON:
{
  "is_sdg_related": true,
  "sdg_goals": [4, 12],
  "score": 75,
  "reason": "This image shows..."
}
''';

      final response = await _model.generateContent([
        Content.multi([imagePart, TextPart(prompt)]),
      ]);

      final text = response.text ?? '{}';
      return jsonDecode(text) as Map<String, dynamic>;
    } catch (e) {
      return {
        'is_sdg_related': false,
        'sdg_goals': [],
        'score': 0,
        'reason': 'Could not analyse this image. Please try again.',
      };
    }
  }

  /// Checks if an image is safe for the platform (moderation).
  Future<bool> isImageSafeFromBytes(Uint8List imageBytes) async {
    try {
      final imagePart = DataPart('image/jpeg', imageBytes);

      const prompt = '''
Is this image safe and appropriate for a family-friendly social media platform?
Return ONLY this JSON: {"is_safe": true, "reason": "..."}
''';

      final response = await _model.generateContent([
        Content.multi([imagePart, TextPart(prompt)]),
      ]);

      final result = jsonDecode(response.text ?? '{"is_safe": true}');
      return result['is_safe'] == true;
    } catch (_) {
      return true; // Fail open for hackathon
    }
  }

  /// Generates personalised SDG activity recommendations for a user's diary.
  Future<Map<String, dynamic>> generateDiaryRecommendations({
    required List<int> recentSdgGoals,
    required int totalScore,
    required int streak,
  }) async {
    try {
      final prompt = '''
A user of an SDG social platform has been active this week.
- Recent SDG goals they posted about: ${recentSdgGoals.map((g) => 'SDG $g').join(', ')}
- Total SDG score: $totalScore points
- Current streak: $streak days

Based on their activity, recommend 3 specific, practical real-world actions 
they can take tomorrow to increase their SDG impact. Be specific, encouraging, 
and relevant to their current interests.

Return ONLY this JSON:
{
  "recommendations": [
    "Action 1 description",
    "Action 2 description",
    "Action 3 description"
  ],
  "summary": "One encouraging sentence about their SDG journey so far."
}
''';

      final response = await _model.generateContent([
        Content.text(prompt),
      ]);

      return jsonDecode(response.text ?? '{}') as Map<String, dynamic>;
    } catch (_) {
      return {
        'recommendations': [
          'Reduce single-use plastic today by bringing a reusable bag',
          'Share an educational post about a local environmental issue',
          'Volunteer 1 hour at a community cleanup near you',
        ],
        'summary': 'Keep up the great SDG work! Every action counts.',
      };
    }
  }

  /// Generates an AI caption suggestion for an SDG post.
  Future<String> suggestCaptionFromBytes(Uint8List imageBytes) async {
    try {
      final imagePart = DataPart('image/jpeg', imageBytes);

      const prompt = '''
Suggest a short, inspiring caption (max 2 sentences) for this SDG-related social media post.
Make it engaging, hashtag-friendly, and highlight the SDG impact.
Return ONLY the caption text, no JSON.
''';

      final response = await _model.generateContent([
        Content.multi([imagePart, TextPart(prompt)]),
      ]);

      return response.text?.trim() ?? '';
    } catch (_) {
      return '';
    }
  }
}
