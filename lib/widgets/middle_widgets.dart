import 'package:flutter/material.dart';

class MiddleWidgets extends StatelessWidget {
  const MiddleWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Dashed Add Button (Using solid border with opacity for simplicity, matching the vibe)
          Container(
            width: 60,
            height: 160,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24, width: 2, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(child: Icon(Icons.add, color: Colors.white54)),
          ),
          const SizedBox(width: 16),
          // AI Assistant Card
          Container(
            width: 160,
            height: 160,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.black,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('AI Assistant', style: TextStyle(color: Colors.white54, fontSize: 14)),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
                      child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 14),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Get free personal\nfinance assistant from\nAI powered chatbot.', style: TextStyle(color: Colors.white38, fontSize: 10, height: 1.5)),
                const Spacer(),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Start new\nchat with AI', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Goals Card
          Container(
            width: 160,
            height: 160,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.black,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Goals', style: TextStyle(color: Colors.white54, fontSize: 14)),
                    Icon(Icons.more_horiz, color: Colors.white54, size: 16),
                  ],
                ),
                SizedBox(height: 12),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 50, height: 50,
                        child: CircularProgressIndicator(
                          value: 0.2,
                          strokeWidth: 4,
                          backgroundColor: Colors.white12,
                          color: Colors.white,
                        ),
                      ),
                      Text('20%', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Spacer(),
                Center(child: Text('New Bicycle', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                Center(child: Text('1 Dec 2023', style: TextStyle(color: Colors.white38, fontSize: 10))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
