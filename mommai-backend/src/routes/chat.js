const express = require('express');
const { GoogleGenerativeAI } = require('@google/generative-ai');
const Message = require('../models/Message');
const Vital = require('../models/Vital');
const Pregnancy = require('../models/Pregnancy');
const { auth } = require('../middleware/auth');

const router = express.Router();

// Initialize Gemini AI
let genAI = null;
if (process.env.GEMINI_API_KEY && process.env.GEMINI_API_KEY !== 'your-gemini-api-key-here') {
    genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
}

// Send message and get AI response
router.post('/', auth, async (req, res) => {
    try {
        const { message } = req.body;

        if (!message) {
            return res.status(400).json({ error: 'Message required' });
        }

        // Save user message
        const userMessage = new Message({
            senderId: req.user._id,
            receiverId: req.user._id, // Self for AI chat
            content: message,
            isAI: false
        });
        await userMessage.save();

        // Gather context
        const context = await gatherPatientContext(req.user);

        // Generate AI response
        let aiResponse;
        if (genAI) {
            aiResponse = await generateGeminiResponse(message, context);
        } else {
            aiResponse = generateMockResponse(message, context);
        }

        // Save AI message
        const aiMessage = new Message({
            senderId: req.user._id,
            receiverId: req.user._id,
            content: aiResponse,
            isAI: true
        });
        await aiMessage.save();

        res.json({
            userMessage: { id: userMessage._id, content: message },
            aiMessage: { id: aiMessage._id, content: aiResponse }
        });
    } catch (error) {
        console.error('Chat error:', error);
        res.status(500).json({ error: 'Failed to get response' });
    }
});

// Get chat history
router.get('/history', auth, async (req, res) => {
    try {
        const messages = await Message.find({
            $or: [
                { senderId: req.user._id, receiverId: req.user._id },
            ]
        }).sort({ createdAt: -1 }).limit(50);

        res.json({ messages: messages.reverse() });
    } catch (error) {
        res.status(500).json({ error: 'Failed to get history' });
    }
});

// Gather patient context for AI
async function gatherPatientContext(user) {
    const context = {
        name: user.name,
        mode: user.currentMode,
        age: user.age
    };

    // Get latest vitals
    const latestBP = await Vital.findOne({ userId: user._id, type: 'bp' }).sort({ date: -1 });
    const latestWeight = await Vital.findOne({ userId: user._id, type: 'weight' }).sort({ date: -1 });

    if (latestBP) {
        context.latestBP = `${latestBP.value}/${latestBP.secondaryValue}`;
        context.bpDate = latestBP.date;
    }
    if (latestWeight) {
        context.weight = latestWeight.value;
    }

    // Pregnancy-specific context
    if (user.currentMode === 'pregnancy') {
        const pregnancy = await Pregnancy.findOne({ userId: user._id, isActive: true });
        if (pregnancy) {
            context.pregnancyWeek = pregnancy.currentWeek;
            context.trimester = pregnancy.trimester;
            context.dueDate = pregnancy.dueDate;
            context.riskScore = pregnancy.riskScore;
            context.riskLevel = pregnancy.riskLevel;
            context.riskFactors = pregnancy.riskFactors.map(r => r.factor);
            context.babySizeComparison = pregnancy.babySizeComparison;
        }
    } else {
        // Fertility context
        if (user.lastMenstrualPeriod) {
            const daysSinceLMP = Math.floor((new Date() - new Date(user.lastMenstrualPeriod)) / (1000 * 60 * 60 * 24));
            context.cycleDay = daysSinceLMP % (user.averageCycleLength || 28);
            context.cycleLength = user.averageCycleLength || 28;

            // Calculate ovulation day
            const ovulationDay = context.cycleLength - 14;
            context.daysToOvulation = ovulationDay - context.cycleDay;
            context.inFertileWindow = context.daysToOvulation >= -3 && context.daysToOvulation <= 3;
        }
    }

    return context;
}

// Generate response using Gemini
async function generateGeminiResponse(message, context) {
    try {
        const model = genAI.getGenerativeModel({ model: 'gemini-pro' });

        const systemPrompt = `You are MomAI, a caring and knowledgeable maternal health assistant. 
You provide empathetic, accurate health guidance for women during fertility tracking and pregnancy.
Always recommend consulting a healthcare provider for medical decisions.

Patient Context:
- Name: ${context.name}
- Mode: ${context.mode === 'pregnancy' ? 'Pregnancy' : 'Fertility Tracking'}
${context.mode === 'pregnancy' ? `
- Pregnancy Week: ${context.pregnancyWeek || 'Unknown'}
- Trimester: ${context.trimester || 'Unknown'}
- Due Date: ${context.dueDate ? new Date(context.dueDate).toLocaleDateString() : 'Unknown'}
- Risk Score: ${context.riskScore || 0}/100 (${context.riskLevel || 'low'})
- Risk Factors: ${context.riskFactors?.join(', ') || 'None'}
- Baby Size: ${context.babySizeComparison || 'Unknown'}
` : `
- Cycle Day: ${context.cycleDay || 'Unknown'}
- Cycle Length: ${context.cycleLength || 28} days
- Days to Ovulation: ${context.daysToOvulation || 'Unknown'}
- In Fertile Window: ${context.inFertileWindow ? 'Yes' : 'No'}
`}
- Latest BP: ${context.latestBP || 'Not recorded'}
- Weight: ${context.weight ? context.weight + ' kg' : 'Not recorded'}

Respond to the following message with care and accuracy. Keep responses concise but helpful.`;

        const result = await model.generateContent([
            { text: systemPrompt },
            { text: `User: ${message}` }
        ]);

        return result.response.text();
    } catch (error) {
        console.error('Gemini error:', error);
        return generateMockResponse(message, context);
    }
}

// Mock response when Gemini is not available
function generateMockResponse(message, context) {
    const lowerMessage = message.toLowerCase();

    if (context.mode === 'pregnancy') {
        if (lowerMessage.includes('bp') || lowerMessage.includes('blood pressure')) {
            if (context.latestBP) {
                const [sys, dia] = context.latestBP.split('/').map(Number);
                if (sys >= 140 || dia >= 90) {
                    return `Your recent BP of ${context.latestBP} mmHg is elevated. This is important to monitor at week ${context.pregnancyWeek}. I recommend:\n\n• Rest and lie on your left side\n• Avoid salty foods\n• Stay hydrated\n• Recheck in 4 hours\n• Contact your doctor if it stays high or you have headaches/vision changes\n\nYour current risk score is ${context.riskScore}/100. Please monitor closely. 💗`;
                }
                return `Your recent BP of ${context.latestBP} mmHg looks good! Keep monitoring regularly at week ${context.pregnancyWeek}. 💗`;
            }
            return `I don't see a recent BP reading. Would you like to log one now? Regular monitoring is important during pregnancy. 💗`;
        }

        if (lowerMessage.includes('kick') || lowerMessage.includes('movement')) {
            return `At week ${context.pregnancyWeek}, you should feel regular movements. A healthy pattern is 10+ kicks in 2 hours. If you notice decreased movement, lie on your left side, drink cold water, and count kicks. Contact your provider if you get fewer than 10 in 2 hours. 💗`;
        }

        if (lowerMessage.includes('week') || lowerMessage.includes('baby') || lowerMessage.includes('size')) {
            return `You're at week ${context.pregnancyWeek}! Your baby is about the size of a ${context.babySizeComparison}. ${context.daysRemaining ? `Only ${context.daysRemaining} days until your due date!` : ''} 🍼💗`;
        }

        return `I'm here to help with your pregnancy at week ${context.pregnancyWeek}! Your current risk level is ${context.riskLevel}. Feel free to ask about:\n\n• Blood pressure concerns\n• Baby movements\n• Symptoms you're experiencing\n• What to expect this week\n\nHow can I assist you today? 💗`;
    } else {
        // Fertility mode
        if (lowerMessage.includes('ovulat') || lowerMessage.includes('fertile')) {
            if (context.daysToOvulation !== undefined) {
                if (context.inFertileWindow) {
                    return `You're in your fertile window! This is a great time if you're trying to conceive. Ovulation is expected ${context.daysToOvulation === 0 ? 'today' : `in ${Math.abs(context.daysToOvulation)} days`}. 🌸`;
                }
                return `Your estimated ovulation is in ${context.daysToOvulation} days (around cycle day ${(context.cycleLength || 28) - 14}). Your fertile window will start about 3 days before that. 🌸`;
            }
            return `To predict ovulation, I need your last period date. Would you like to update that? 🌸`;
        }

        if (lowerMessage.includes('period') || lowerMessage.includes('cycle')) {
            return `You're on cycle day ${context.cycleDay} of your ${context.cycleLength}-day cycle. ${context.inFertileWindow ? "You're currently in your fertile window!" : `Your fertile window ${context.daysToOvulation > 0 ? 'starts soon' : 'has passed for this cycle'}.`} 🌸`;
        }

        return `I'm here to help with your fertility journey! You're on cycle day ${context.cycleDay || '?'}. Ask me about:\n\n• Ovulation prediction\n• Fertile window timing\n• Cycle symptoms\n• Tips for conception\n\nHow can I help today? 🌸`;
    }
}

module.exports = router;
