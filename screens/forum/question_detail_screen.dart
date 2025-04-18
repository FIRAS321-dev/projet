import 'package:flutter/material.dart';
import 'package:edubridge/models/question.dart';
import 'package:edubridge/theme/app_theme.dart';
import 'package:timeago/timeago.dart' as timeago;

class QuestionDetailScreen extends StatefulWidget {
  final Question question;
  final bool isTeacher;

  const QuestionDetailScreen({
    Key? key,
    required this.question,
    this.isTeacher = false,
  }) : super(key: key);

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  final TextEditingController _replyController = TextEditingController();
  bool _isSubmitting = false;
  
  // Sample data for replies
  final List<Map<String, dynamic>> _replies = [
    {
      'id': '1',
      'author': 'Dr. Martin',
      'isTeacher': true,
      'content': 'Pour résoudre un système d\'équations linéaires avec la méthode de Gauss, vous devez suivre ces étapes: 1) Écrire le système sous forme matricielle, 2) Appliquer des opérations élémentaires pour transformer la matrice en forme échelonnée, 3) Résoudre le système par substitution arrière.',
      'timestamp': DateTime.now().subtract(const Duration(hours: 1)),
      'likes': 5,
      'isLiked': false,
    },
    {
      'id': '2',
      'author': 'Emma Garcia',
      'isTeacher': false,
      'content': 'Merci pour cette explication! J\'ai une question supplémentaire: comment déterminer si un système a une solution unique, plusieurs solutions ou aucune solution?',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 30)),
      'likes': 2,
      'isLiked': true,
    },
  ];

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _submitReply() async {
    if (_replyController.text.isEmpty) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Add reply to the list
      setState(() {
        _replies.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'author': widget.isTeacher ? 'Dr. Martin' : 'Vous',
          'isTeacher': widget.isTeacher,
          'content': _replyController.text,
          'timestamp': DateTime.now(),
          'likes': 0,
          'isLiked': false,
        });
        
        _replyController.clear();
        _isSubmitting = false;
      });
      
      // Mark question as answered if teacher
      if (widget.isTeacher) {
        // In a real app, update the question status in the database
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _toggleLike(int index) {
    setState(() {
      final isLiked = _replies[index]['isLiked'] as bool;
      _replies[index]['isLiked'] = !isLiked;
      _replies[index]['likes'] = isLiked
          ? (_replies[index]['likes'] as int) - 1
          : (_replies[index]['likes'] as int) + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share question
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Lien de la question copié!'),
                  backgroundColor: AppTheme.primaryColor,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Question card
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildQuestionCard(),
                const SizedBox(height: 24),
                
                // Replies section
                Text(
                  'Réponses (${_replies.length})',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 16),
                
                ..._replies.asMap().entries.map((entry) {
                  final index = entry.key;
                  final reply = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildReplyCard(reply, index),
                  );
                }).toList(),
              ],
            ),
          ),
          
          // Reply input
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _replyController,
                    decoration: InputDecoration(
                      hintText: 'Écrivez votre réponse...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.light
                          ? Colors.grey.shade100
                          : Colors.grey.shade800,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: _submitReply,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Student avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    widget.question.studentName.substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Student info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.question.studentName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Cours: ${widget.question.courseTitle}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Question status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.question.answered
                        ? AppTheme.successColor.withOpacity(0.1)
                        : AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.question.answered ? 'Répondu' : 'En attente',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: widget.question.answered
                          ? AppTheme.successColor
                          : AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Question text
            Text(
              widget.question.question,
              style: const TextStyle(
                fontSize: 18,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            
            // Question timestamp
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppTheme.textSecondaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Posée ${timeago.format(widget.question.timestamp, locale: 'fr')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyCard(Map<String, dynamic> reply, int index) {
    final bool isTeacher = reply['isTeacher'] as bool;
    
    return Card(
      elevation: isTeacher ? 2 : 0,
      color: isTeacher
          ? AppTheme.primaryColor.withOpacity(0.05)
          : Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isTeacher
              ? AppTheme.primaryColor.withOpacity(0.2)
              : Colors.grey.shade300,
          width: isTeacher ? 1 : 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Author avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: isTeacher
                      ? AppTheme.primaryColor
                      : Colors.grey.shade400,
                  child: Text(
                    reply['author'].toString().substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Author info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            reply['author'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (isTeacher)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Enseignant',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        timeago.format(reply['timestamp'] as DateTime, locale: 'fr'),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Reply content
            Text(
              reply['content'] as String,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            
            // Actions
            Row(
              children: [
                InkWell(
                  onTap: () => _toggleLike(index),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(
                          (reply['isLiked'] as bool)
                              ? Icons.thumb_up
                              : Icons.thumb_up_outlined,
                          size: 16,
                          color: (reply['isLiked'] as bool)
                              ? AppTheme.primaryColor
                              : AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          (reply['likes'] as int).toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: (reply['isLiked'] as bool)
                                ? AppTheme.primaryColor
                                : AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                InkWell(
                  onTap: () {
                    // Reply to this comment
                    _replyController.text = '@${reply['author']} ';
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.reply,
                          size: 16,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Répondre',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

