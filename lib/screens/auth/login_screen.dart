import 'package:flutter/material.dart';
import 'package:edubridge/screens/auth/register_screen.dart';
import 'package:edubridge/screens/student/student_dashboard.dart';
import 'package:edubridge/screens/teacher/teacher_dashboard.dart';
import 'package:edubridge/screens/admin/admin_dashboard.dart';
import 'package:edubridge/widgets/custom_button.dart';
import 'package:edubridge/widgets/custom_text_field.dart';
import 'package:edubridge/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Simuler un délai de connexion
      await Future.delayed(const Duration(seconds: 1));

      // Logique de connexion simplifiée pour la démo
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (email == 'admin@edubridge.com' && password == 'Admin123!') {
        // Rediriger vers le tableau de bord admin
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AdminDashboard()),
          );
        }
      } else if (email == 'prof@edubridge.com' && password == 'Prof123!') {
        // Rediriger vers le tableau de bord enseignant
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const TeacherDashboard()),
          );
        }
      } else if (email == 'etudiant@edubridge.com' && password == 'Etudiant123!') {
        // Rediriger vers le tableau de bord étudiant
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const StudentDashboard()),
          );
        }
      } else {
        // Afficher une erreur
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Email ou mot de passe incorrect';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/logo.png',
                    width: 120,
                    height: 120,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'EB',
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  // Titre
                  const Text(
                    'Connexion',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  // Sous-titre
                  const Text(
                    'Bienvenue sur EduBridge',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Message d'erreur
                  if (_errorMessage.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (_errorMessage.isNotEmpty) const SizedBox(height: 16),
                  
                  // Champ email
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    hintText: 'Entrez votre email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Veuillez entrer un email valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Champ mot de passe
                  CustomTextField(
                    controller: _passwordController,
                    labelText: 'Mot de passe',
                    hintText: 'Entrez votre mot de passe',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre mot de passe';
                      }
                      if (value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  
                  // Lien mot de passe oublié
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Navigation vers l'écran de récupération de mot de passe
                      },
                      child: const Text('Mot de passe oublié?'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Bouton de connexion
                  CustomButton(
                    text: 'Se connecter',
                    isLoading: _isLoading,
                    onPressed: _login,
                  ),
                  const SizedBox(height: 24),
                  
                  // Lien d'inscription
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Vous n\'avez pas de compte?',
                        style: TextStyle(color: AppTheme.textSecondaryColor),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: const Text('S\'inscrire'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

