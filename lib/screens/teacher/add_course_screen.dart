import 'package:flutter/material.dart';
import 'package:edubridge/theme/app_theme.dart';
import 'package:edubridge/widgets/custom_button.dart';
import 'package:edubridge/widgets/custom_text_field.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({Key? key}) : super(key: key);

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedSubject = 'Mathématiques';
  final List<String> _subjects = [
    'Mathématiques',
    'Physique',
    'Informatique',
    'Langues',
    'Autre',
  ];
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitCourse() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 2));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cours ajouté avec succès!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un cours')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informations du cours',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 24),

              // Course title
              CustomTextField(
                controller: _titleController,
                hintText: 'Titre du cours',
                prefixIcon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Subject dropdown
              DropdownButtonFormField<String>(
                value: _selectedSubject,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.subject),
                  filled: true,
                  fillColor:
                      Theme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : const Color(0xFF2A2A2A),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.grey.shade200
                              : Colors.grey.shade800,
                    ),
                  ),
                ),
                items:
                    _subjects.map((String subject) {
                      return DropdownMenuItem<String>(
                        value: subject,
                        child: Text(subject),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSubject = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Course description
              CustomTextField(
                controller: _descriptionController,
                hintText: 'Description du cours',
                prefixIcon: Icons.description,
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              Text(
                'Ressources du cours',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 16),

              // Upload buttons
              Row(
                children: [
                  Expanded(
                    child: _buildUploadButton(
                      icon: Icons.upload_file,
                      label: 'Documents',
                      onTap: () {
                        // Handle document upload
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildUploadButton(
                      icon: Icons.video_library,
                      label: 'Vidéos',
                      onTap: () {
                        // Handle video upload
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildUploadButton(
                      icon: Icons.quiz,
                      label: 'Quiz',
                      onTap: () {
                        // Handle quiz creation
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildUploadButton(
                      icon: Icons.assignment,
                      label: 'Exercices',
                      onTap: () {
                        // Handle exercise upload
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Submit button
              CustomButton(
                text: 'Créer le cours',
                isLoading: _isLoading,
                onPressed: _submitCourse,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: AppTheme.primaryColor),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              'Ajouter',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
