import 'package:flutter/material.dart';
import 'main_screen.dart';
import '../widgets/common/premium_gradient_card.dart';
import 'buy_coffee_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true;
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    // Dummy Authentication - Proceed to MainScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo/Header area
              const SizedBox(height: 24),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.account_balance_wallet, size: 40, color: Theme.of(context).primaryColor),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                _isLogin ? 'Welcome Back!' : 'Create Account',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: -0.5),
              ),
              const SizedBox(height: 16),
              Text(
                _isLogin ? 'Sign in to access your dashboard' : 'Join us to track your expenses smarter',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 32),

              // Social Logins (Dummy)
              _buildSocialButton(context, icon: Icons.g_mobiledata, label: 'Continue with Google', color: Colors.red),
              const SizedBox(height: 12),
              _buildSocialButton(context, icon: Icons.apple, label: 'Continue with Apple', color: isDark ? Colors.white : Colors.black, isDark: isDark),
              
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('or sign in with email', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),

              // Form fields
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade50,
                ),
              ),
              if (_isLogin)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Forgot Password?', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )
              else
                const SizedBox(height: 24),

              const SizedBox(height: 16),
              PremiumGradientCard(
                builder: (context, textColor, subTextColor) {
                  return InkWell(
                    onTap: _submit,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 55,
                      alignment: Alignment.center,
                      child: Text(
                        _isLogin ? 'Sign In' : 'Sign Up',
                        style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Toggle Auth Mode
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_isLogin ? "Don't have an account? " : "Already have an account? ", style: const TextStyle(color: Colors.grey)),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isLogin = !_isLogin;
                        _emailController.clear();
                        _passwordController.clear();
                      });
                    },
                    child: Text(
                      _isLogin ? 'Sign Up' : 'Sign In',
                      style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Developer Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A1A) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                ),
                child: Column(
                  children: [
                    const Text('Developed by Hashim', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    const Text('GitHub: mohas7im', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const Text('mohammedhashim530@gmail.com', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (ctx) => const BuyCoffeeScreen()));
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('☕', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 8),
                          Text('Buy me a coffee', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(BuildContext context, {required IconData icon, required String label, required Color color, bool isDark = false}) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Dummy auth
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}
