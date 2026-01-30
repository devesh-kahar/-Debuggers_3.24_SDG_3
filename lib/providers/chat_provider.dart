import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';

class ChatProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final _uuid = const Uuid();

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  // Add user message
  void addUserMessage(String content) {
    _messages.add(ChatMessage(
      id: _uuid.v4(),
      oderId: 'demo-user-001',
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  // Add AI response from backend
  Future<void> generateAIResponse(String userMessage, {
    required String mode,
    int? pregnancyWeek,
    int? cycleDay,
    int? fertilityScore,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.dio.post('/ai/chat', data: {
        'message': userMessage,
        'context': {
          'mode': mode,
          'pregnancyWeek': pregnancyWeek,
          'cycleDay': cycleDay,
          'fertilityScore': fertilityScore,
        }
      });

      if (response.statusCode == 200) {
        final data = response.data;
        // Backend returns { userMessage: {...}, aiMessage: {...} }
        if (data.containsKey('aiMessage')) {
           final aiData = data['aiMessage'];
           // Backend uses 'isAI', frontend uses 'isUser'. Map them.
           // If isAI is true, isUser should be false.
           if (aiData['isAI'] == true) {
             aiData['isUser'] = false;
           }
           
           final aiMessage = ChatMessage.fromJson(aiData);
           _messages.add(aiMessage);
        }
      }
    } catch (e) {
      debugPrint('Error generating AI response: $e');
      
      // Fallback to local logic if server fails
      final localResponse = _generateContextualResponse(
        userMessage: userMessage,
        mode: mode,
        pregnancyWeek: pregnancyWeek,
        cycleDay: cycleDay,
        fertilityScore: fertilityScore,
      );

      _messages.add(ChatMessage(
        id: _uuid.v4(),
        oderId: 'user',
        content: localResponse,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    }

    _isLoading = false;
    notifyListeners();
  }

  // Generate contextual response based on mode and question
  String _generateContextualResponse({
    required String userMessage,
    required String mode,
    int? pregnancyWeek,
    int? cycleDay,
    int? fertilityScore,
  }) {
    final lowerMessage = userMessage.toLowerCase();

    // Fertility mode responses
    if (mode == 'fertility') {
      if (lowerMessage.contains('fertile') || lowerMessage.contains('ovulation')) {
        return '''Based on your cycle data, your fertile window is approaching! 🌸

**Your Fertility Status:**
• Current Cycle Day: ${cycleDay ?? 14}
• Fertility Score Today: ${fertilityScore ?? 85}%
• Ovulation Expected: In approximately ${14 - (cycleDay ?? 14)} days

**Tips to maximize conception:**
1. Have intercourse every 1-2 days during your fertile window
2. Track your cervical mucus - look for "egg white" consistency
3. Monitor your BBT for the temperature rise
4. Stay relaxed and reduce stress

*Remember: I'm an AI assistant. For personalized medical advice, please consult your healthcare provider.*''';
      }

      if (lowerMessage.contains('pregnant') || lowerMessage.contains('test')) {
        return '''Great question about pregnancy testing! 🤰

**When to take a pregnancy test:**
• Best time: 14 days after ovulation (day 28+ if 28-day cycle)
• Early testing: Some sensitive tests work 10 days post-ovulation
• For most accurate results: Test with first morning urine

**Signs to watch for:**
• Missed period
• Breast tenderness
• Fatigue
• Mild cramping (implantation)

Based on your cycle day (${cycleDay ?? 14}), ${(cycleDay ?? 14) >= 28 ? "it's a good time to test!" : "you may want to wait a few more days for accurate results."}

*Remember: I'm an AI assistant. Confirm results with a healthcare provider.*''';
      }

      if (lowerMessage.contains('food') || lowerMessage.contains('diet') || lowerMessage.contains('nutrition')) {
        return '''Here are fertility-boosting nutrition tips! 🥗

**Foods that support fertility:**
• Leafy greens (folate)
• Fatty fish (omega-3s)
• Berries (antioxidants)
• Whole grains (fiber & B vitamins)
• Eggs (protein & choline)
• Avocados (healthy fats)

**Foods to limit:**
• Processed foods
• Excessive caffeine (limit to 200mg/day)
• Alcohol
• Trans fats

**Supplements to consider:**
• Folic acid (400-800mcg daily)
• Vitamin D
• Coenzyme Q10 (CoQ10)

*Remember: Consult your doctor before starting any supplements.*''';
      }
    }

    // Pregnancy mode responses
    if (mode == 'pregnancy') {
      if (lowerMessage.contains('cramp') || lowerMessage.contains('pain')) {
        return '''I understand cramping can be concerning during pregnancy. Let me help! 💝

**Normal cramping in Week ${pregnancyWeek ?? 24}:**
• Mild stretching as uterus grows
• Round ligament pain (sharp, brief pains)
• Braxton Hicks contractions (after week 20)

**When to seek immediate care:**
⚠️ Severe or persistent pain
⚠️ Cramping with bleeding
⚠️ Regular contractions before 37 weeks
⚠️ Pain with fever

**For relief:**
• Rest and change positions
• Warm (not hot) bath
• Gentle stretching
• Stay hydrated

*If you're experiencing severe symptoms, please contact your healthcare provider immediately.*''';
      }

      if (lowerMessage.contains('preeclampsia') || lowerMessage.contains('blood pressure')) {
        return '''Preeclampsia awareness is important - good question! 🩺

**What is Preeclampsia?**
A pregnancy complication involving high blood pressure and organ damage, usually after week 20.

**Warning Signs:**
⚠️ BP readings above 140/90
⚠️ Severe headaches
⚠️ Vision changes (blurred, seeing spots)
⚠️ Upper abdominal pain (right side)
⚠️ Sudden swelling (face, hands)
⚠️ Sudden weight gain

**Risk Factors:**
• First pregnancy
• Age over 35 or under 20
• Pre-existing hypertension
• Multiple pregnancy (twins)
• Obesity

**Prevention:**
• Regular prenatal visits
• Monitor BP at home
• Low-dose aspirin (if prescribed)
• Stay active and eat well

*Preeclampsia requires immediate medical attention. Please contact your provider if you notice any warning signs.*''';
      }

      if (lowerMessage.contains('move') || lowerMessage.contains('kick') || lowerMessage.contains('baby')) {
        return '''Fetal movement is exciting to track! 👶

**At Week ${pregnancyWeek ?? 24}:**
${(pregnancyWeek ?? 24) < 20 
    ? "You may start feeling first movements (quickening) soon!" 
    : "You should be feeling regular movements by now."}

**Normal movement patterns:**
• Most active: After meals, in the evening
• Quiet times are normal too
• You should feel at least 10 kicks in 2 hours

**When to call your doctor:**
⚠️ Significant decrease in movement
⚠️ No movement for 6+ hours (after week 28)
⚠️ Sudden change in pattern

**Tips:**
• Use our Kick Counter feature!
• Lie on your side while counting
• Have a cold drink or snack if baby is quiet

*Track regularly and trust your instincts - you know your baby best!*''';
      }

      if (lowerMessage.contains('eat') || lowerMessage.contains('food') || lowerMessage.contains('safe')) {
        return '''Pregnancy nutrition is so important! 🍽️

**Safe to eat:**
✅ Well-cooked meat and fish
✅ Pasteurized dairy products
✅ Washed fruits and vegetables
✅ Cooked eggs (firm yolk)

**Foods to avoid:**
❌ Raw fish (sushi), raw shellfish
❌ Unpasteurized cheese (soft cheeses)
❌ Deli meats (unless heated)
❌ Raw or undercooked eggs
❌ High-mercury fish (shark, swordfish, king mackerel)
❌ Alcohol

**Limit these:**
• Caffeine: max 200mg/day (about 1 coffee)
• Processed foods

*When in doubt, ask your healthcare provider!*''';
      }
    }

    // Default response
    return '''Thank you for your question! 💕

I'm MomAI, your reproductive health assistant. I can help you with:

**Fertility Mode:**
• Understanding your cycle
• Ovulation prediction
• Conception tips
• Fertility nutrition

**Pregnancy Mode:**
• Week-by-week guidance
• Symptom information
• Nutrition advice
• Warning signs awareness

Could you tell me more about what you'd like to know? I'm here to help! 

*Remember: For medical emergencies or personalized advice, please consult your healthcare provider.*''';
  }

  // Clear messages
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  // Get quick questions based on mode
  List<String> getQuickQuestions(String mode) {
    if (mode == 'fertility') {
      return [
        'When is my fertile window?',
        'When should I take a pregnancy test?',
        'What foods boost fertility?',
        'How can I track ovulation?',
      ];
    } else {
      return [
        'Is cramping normal right now?',
        'What are signs of preeclampsia?',
        'When will I feel baby move?',
        'What foods should I avoid?',
      ];
    }
  }
}
