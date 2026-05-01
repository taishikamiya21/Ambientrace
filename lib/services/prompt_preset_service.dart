import 'package:shared_preferences/shared_preferences.dart';

enum PromptPreset { minimal, poetic, documentary, exhibition }

class PromptPresetService {
  static const _key = 'selected_prompt_preset';
  PromptPreset _current = PromptPreset.poetic;
  PromptPreset get current => _current;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final idx = prefs.getInt(_key);
    if (idx != null && idx >= 0 && idx < PromptPreset.values.length) {
      _current = PromptPreset.values[idx];
    }
  }

  Future<void> set(PromptPreset preset) async {
    _current = preset;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, preset.index);
  }

  String analysisPrompt(PromptPreset preset, String languageCode) {
    final ja = languageCode.startsWith('ja');
    switch (preset) {
      case PromptPreset.minimal:
        return ja
            ? '''この画像から、3〜5個の短い名詞句を生成してください。物体名のみ、形容詞は最小限。カンマ区切り。'''
            : '''Generate 3-5 short noun phrases from this image. Object names only, minimal adjectives. Comma-separated.''';
      case PromptPreset.poetic:
        return ja
            ? '''この画像を分析し、雰囲気、光、質感、文脈を捉えた短い日本語のフレーズを5〜7個生成してください。
単なる物体のリストではなく、シーンの「空気感」に焦点を当ててください。
例:「やわらかな午後の陽射し」「静かな朝の空気」「コーヒーの豊かな香り」「古びた木の温もり」「穏やかな時間の流れ」
各フレーズは必ず体言止めまたは完結した名詞句にしてください。
カンマ区切りのフレーズのみを返してください。'''
            : '''Analyze this image and generate 5-7 short, complete phrases that capture the atmosphere, lighting, textures, and context.
Do not just list objects. Focus on the 'feeling' of the scene.
Examples: 'Warm afternoon light', 'Quiet morning', 'Coffee aroma', 'Aged wood warmth', 'Peaceful moment'
Each phrase must be 1-4 words. Never end with articles. Return ONLY comma-separated phrases.''';
      case PromptPreset.documentary:
        return ja
            ? '''この画像を客観的に観察し、視覚的に確認できる要素を5〜7個、簡潔な名詞句で記述してください。主観的・詩的表現は避け、事実のみ。カンマ区切り。'''
            : '''Observe this image objectively. Describe 5-7 visually verifiable elements as concise noun phrases. Avoid subjective or poetic language. Facts only. Comma-separated.''';
      case PromptPreset.exhibition:
        return ja
            ? '''この画像を展示作品のキャプションとして捉え、5〜7個の短い静謐なフレーズを生成してください。鑑賞者の想像を促す抑制された表現で。カンマ区切り。'''
            : '''Treat this image as an exhibition piece. Generate 5-7 short, restrained phrases as if writing wall labels. Evocative but understated. Comma-separated.''';
    }
  }

  String storyPrompt({
    required PromptPreset preset,
    required String time,
    required List<String> ambientTraces,
    required List<String> colorDescriptions,
    String? weather,
    String? temperature,
    String? placeName,
    required String languageCode,
  }) {
    final ja = languageCode.startsWith('ja');
    final tracesText = ambientTraces.isNotEmpty
        ? ambientTraces.join(', ')
        : (ja ? '不明な雰囲気' : 'unknown atmosphere');
    final colorsText = colorDescriptions.isNotEmpty
        ? colorDescriptions.join(', ')
        : (ja ? '落ち着いた色調' : 'muted tones');
    final weatherText = weather != null
        ? '$weather${temperature != null ? ', $temperature' : ''}'
        : (ja ? '不明な天気' : 'unknown weather');
    final placeText = placeName ?? (ja ? 'どこか' : 'somewhere');
    final dataLine = ja
        ? '時刻: $time / 雰囲気: $tracesText / 色彩: $colorsText / 天気: $weatherText / 場所: $placeText'
        : 'Time: $time / Atmosphere: $tracesText / Colors: $colorsText / Weather: $weatherText / Place: $placeText';

    // Output is rendered into a card slot that wraps automatically. The model
    // must NOT insert manual line breaks — pass it as a single flowing
    // sentence/paragraph. Char-count guides ensure it fits 4 visual lines
    // after wrapping.
    const jaNoBreak = '改行や箇条書きを使わず、1段落の流れる文章として返答してください。';
    const enNoBreak =
        'Return a single flowing paragraph. Do NOT insert line breaks or bullet points.';
    switch (preset) {
      case PromptPreset.minimal:
        return ja
            ? '''次のデータから、1文・25文字以内の簡潔な記録文を生成してください。必ず句点で終えること。$jaNoBreak\n$dataLine'''
            : '''Generate a single sentence under 10 words from this data. Must end with a period. $enNoBreak\n$dataLine''';
      case PromptPreset.poetic:
        return ja
            ? '''以下のデータから、その瞬間の空気感を描写する短い詩的な文章を生成してください。
$dataLine
ルール:
- 1〜2文・合計70文字以内
- 感覚的・詩的、過去形または現在進行形
- 必ず句点(。)、感嘆符(！)、疑問符(？)のいずれかで文を終える
- $jaNoBreak'''
            : '''Write a short, poetic narrative from this ambient data. Imagine the scene.
$dataLine
Rules:
- 1-2 sentences, under 28 words total
- Sensory and poetic, past tense or present continuous
- Every sentence MUST end with a period, exclamation mark, or question mark
- $enNoBreak''';
      case PromptPreset.documentary:
        return ja
            ? '''以下のデータから、観察記録として1〜2文・70文字以内の事実描写を生成してください。詩的表現を避け、客観的に。必ず句点で終え、$jaNoBreak\n$dataLine'''
            : '''Write 1-2 sentences of factual observation, under 28 words. Avoid poetic language. End with a period. $enNoBreak\n$dataLine''';
      case PromptPreset.exhibition:
        return ja
            ? '''以下のデータから、美術館の壁ラベル風に2文・80文字以内の余韻のある叙述を生成してください。抑制された静謐な調子で。最後は句点で終え、$jaNoBreak\n$dataLine'''
            : '''Write a 2-sentence gallery wall caption, under 32 words. Restrained, evocative tone. End with a period. $enNoBreak\n$dataLine''';
    }
  }
}
