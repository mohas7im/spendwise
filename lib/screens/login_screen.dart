import 'package:flutter/material.dart';
import 'main_screen.dart';
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
    // Force pure black theme as requested
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            _isLogin ? 'Welcome Back!' : 'Create Account',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                          ),
                          const SizedBox(height: 48),

                          // Form fields
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                              prefixIcon: Icon(Icons.email_outlined, color: Colors.white.withValues(alpha: 0.6)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                              prefixIcon: Icon(Icons.lock_outline, color: Colors.white.withValues(alpha: 0.6)),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white.withValues(alpha: 0.6)),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          if (_isLogin)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: const Text('Forgot Password?', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            )
                          else
                            const SizedBox(height: 24),
                        ],
                      ),
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          // Social Logins
                          _buildSocialButton(context, icon: Icons.g_mobiledata, label: 'Continue with Google', color: Colors.white),
                          const SizedBox(height: 12),
                          _buildSocialButton(context, icon: Icons.apple, label: 'Continue with Apple', color: Colors.white),
                          
                          const SizedBox(height: 24),
                          
                          // Sign In Button
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              ),
                              onPressed: _submit,
                              child: Text(
                                _isLogin ? 'Sign In' : 'Sign Up',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Toggle Auth Mode
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_isLogin ? "Don't have an account? " : "Already have an account? ", style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
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
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Developer Footer
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: Column(
                              children: [
                                const Text('Developed by Hashim', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                                const SizedBox(height: 4),
                                Text('GitHub: mohas7im', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                                Text('mohammedhashim530@gmail.com', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (ctx) => const BuyCoffeeScreen()));
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    minimumSize: const Size(0, 36),
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('☕', style: TextStyle(fontSize: 16)),
                                      SizedBox(width: 8),
                                      Text('Buy me a coffee', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSocialButton(BuildContext context, {required IconData icon, required String label, required Color color}) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(30),
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
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
