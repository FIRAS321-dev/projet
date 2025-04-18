import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseInitializer {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initializeDatabase() async {
    try {
      // Créer les utilisateurs de test
      await _createTestUsers();
      
      // Créer les cours de test
      await _createTestCourses();
      
      // Créer les leçons de test
      await _createTestLessons();
      
      // Créer les inscriptions de test
      await _createTestEnrollments();
      
      // Créer les questions de test
      await _createTestQuestions();
      
      // Créer les examens de test
      await _createTestExams();
      
      print('Base de données Firebase initialisée avec succès!');
    } catch (e) {
      print('Erreur lors de l\'initialisation de la base de données: $e');
    }
  }

  Future<void> _createTestUsers() async {
    // Vérifier si les utilisateurs existent déjà
    final adminSnapshot = await _firestore.collection('users').where('email', isEqualTo: 'admin@edubridge.com').get();
    if (adminSnapshot.docs.isEmpty) {
      try {
        // Créer l'utilisateur admin dans Firebase Auth
        final adminCredential = await _auth.createUserWithEmailAndPassword(
          email: 'admin@edubridge.com',
          password: 'Admin123!',
        );
        
        // Ajouter les données admin dans Firestore
        await _firestore.collection('users').doc(adminCredential.user!.uid).set({
          'name': 'Admin',
          'email': 'admin@edubridge.com',
          'role': 'admin',
          'photoURL': '',
          'bio': 'Administrateur de la plateforme EduBridge',
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        // Créer l'utilisateur enseignant dans Firebase Auth
        final teacherCredential = await _auth.createUserWithEmailAndPassword(
          email: 'prof@edubridge.com',
          password: 'Prof123!',
        );
        
        // Ajouter les données enseignant dans Firestore
        await _firestore.collection('users').doc(teacherCredential.user!.uid).set({
          'name': 'Professeur Test',
          'email': 'prof@edubridge.com',
          'role': 'teacher',
          'photoURL': '',
          'bio': 'Enseignant spécialisé en informatique',
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        // Créer l'utilisateur étudiant dans Firebase Auth
        final studentCredential = await _auth.createUserWithEmailAndPassword(
          email: 'etudiant@edubridge.com',
          password: 'Etudiant123!',
        );
        
        // Ajouter les données étudiant dans Firestore
        await _firestore.collection('users').doc(studentCredential.user!.uid).set({
          'name': 'Étudiant Test',
          'email': 'etudiant@edubridge.com',
          'role': 'student',
          'photoURL': '',
          'bio': 'Étudiant en informatique',
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        print('Utilisateurs de test créés avec succès');
      } catch (e) {
        print('Erreur lors de la création des utilisateurs: $e');
      }
    } else {
      print('Les utilisateurs de test existent déjà');
    }
  }

  Future<void> _createTestCourses() async {
    // Vérifier si les cours existent déjà
    final coursesSnapshot = await _firestore.collection('courses').limit(1).get();
    if (coursesSnapshot.docs.isEmpty) {
      try {
        // Obtenir l'ID de l'enseignant
        final teacherSnapshot = await _firestore.collection('users').where('email', isEqualTo: 'prof@edubridge.com').get();
        if (teacherSnapshot.docs.isNotEmpty) {
          final teacherId = teacherSnapshot.docs.first.id;
          
          // Créer des cours de test
          await _firestore.collection('courses').add({
            'title': 'Introduction à la programmation',
            'description': 'Apprenez les bases de la programmation avec Python',
            'imageUrl': '',
            'tags': ['programmation', 'python', 'débutant'],
            'teacherId': teacherId,
            'teacherName': 'Professeur Test',
            'studentsCount': 0,
            'lessonsCount': 0,
            'createdAt': FieldValue.serverTimestamp(),
            // Ajout des champs manquants pour la compatibilité
            'subject': 'Informatique',
            'totalLessons': 5,
            'completedLessons': 0,
            'progress': 0.0,
            'startDate': Timestamp.fromDate(DateTime.now()),
            'endDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 90))),
          });
          
          await _firestore.collection('courses').add({
            'title': 'Développement Web Avancé',
            'description': 'Maîtrisez les frameworks modernes comme React et Node.js',
            'imageUrl': '',
            'tags': ['web', 'javascript', 'react', 'node'],
            'teacherId': teacherId,
            'teacherName': 'Professeur Test',
            'studentsCount': 0,
            'lessonsCount': 0,
            'createdAt': FieldValue.serverTimestamp(),
            // Ajout des champs manquants pour la compatibilité
            'subject': 'Développement Web',
            'totalLessons': 5,
            'completedLessons': 0,
            'progress': 0.0,
            'startDate': Timestamp.fromDate(DateTime.now()),
            'endDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 90))),
          });
          
          await _firestore.collection('courses').add({
            'title': 'Intelligence Artificielle',
            'description': 'Découvrez les concepts fondamentaux de l\'IA et du machine learning',
            'imageUrl': '',
            'tags': ['ia', 'machine learning', 'python'],
            'teacherId': teacherId,
            'teacherName': 'Professeur Test',
            'studentsCount': 0,
            'lessonsCount': 0,
            'createdAt': FieldValue.serverTimestamp(),
            // Ajout des champs manquants pour la compatibilité
            'subject': 'Intelligence Artificielle',
            'totalLessons': 5,
            'completedLessons': 0,
            'progress': 0.0,
            'startDate': Timestamp.fromDate(DateTime.now()),
            'endDate': Timestamp.fromDate(DateTime.now().add(const Duration(days: 90))),
          });
          
          print('Cours de test créés avec succès');
        }
      } catch (e) {
        print('Erreur lors de la création des cours: $e');
      }
    } else {
      print('Les cours de test existent déjà');
    }
  }

  Future<void> _createTestLessons() async {
    // Vérifier si les leçons existent déjà
    final lessonsSnapshot = await _firestore.collection('lessons').limit(1).get();
    if (lessonsSnapshot.docs.isEmpty) {
      try {
        // Obtenir les cours
        final coursesSnapshot = await _firestore.collection('courses').get();
        
        for (var courseDoc in coursesSnapshot.docs) {
          final courseId = courseDoc.id;
          final courseData = courseDoc.data();
          
          // Créer des leçons pour chaque cours
          for (var i = 1; i <= 5; i++) {
            await _firestore.collection('lessons').add({
              'title': 'Leçon $i: ${i == 1 ? 'Introduction' : 'Chapitre ${i-1}'}',
              'content': 'Contenu de la leçon $i pour le cours ${courseData['title']}',
              'courseId': courseId,
              'order': i,
              'resources': [],
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
          
          // Mettre à jour le nombre de leçons dans le cours
          await _firestore.collection('courses').doc(courseId).update({
            'lessonsCount': 5,
          });
        }
        
        print('Leçons de test créées avec succès');
      } catch (e) {
        print('Erreur lors de la création des leçons: $e');
      }
    } else {
      print('Les leçons de test existent déjà');
    }
  }

  Future<void> _createTestEnrollments() async {
    // Vérifier si les inscriptions existent déjà
    final enrollmentsSnapshot = await _firestore.collection('enrollments').limit(1).get();
    if (enrollmentsSnapshot.docs.isEmpty) {
      try {
        // Obtenir l'ID de l'étudiant
        final studentSnapshot = await _firestore.collection('users').where('email', isEqualTo: 'etudiant@edubridge.com').get();
        if (studentSnapshot.docs.isNotEmpty) {
          final studentId = studentSnapshot.docs.first.id;
          
          // Obtenir les cours
          final coursesSnapshot = await _firestore.collection('courses').get();
          
          for (var courseDoc in coursesSnapshot.docs) {
            final courseId = courseDoc.id;
            
            // Créer une inscription pour chaque cours
            await _firestore.collection('enrollments').doc('${studentId}_${courseId}').set({
              'studentId': studentId,
              'courseId': courseId,
              'enrolledAt': FieldValue.serverTimestamp(),
              'progress': 0,
              'lastAccessedAt': FieldValue.serverTimestamp(),
            });
            
            // Mettre à jour le nombre d'étudiants dans le cours
            await _firestore.collection('courses').doc(courseId).update({
              'studentsCount': FieldValue.increment(1),
            });
          }
          
          print('Inscriptions de test créées avec succès');
        }
      } catch (e) {
        print('Erreur lors de la création des inscriptions: $e');
      }
    } else {
      print('Les inscriptions de test existent déjà');
    }
  }

  Future<void> _createTestQuestions() async {
    // Vérifier si les questions existent déjà
    final questionsSnapshot = await _firestore.collection('questions').limit(1).get();
    if (questionsSnapshot.docs.isEmpty) {
      try {
        // Obtenir l'ID de l'étudiant
        final studentSnapshot = await _firestore.collection('users').where('email', isEqualTo: 'etudiant@edubridge.com').get();
        if (studentSnapshot.docs.isNotEmpty) {
          final studentId = studentSnapshot.docs.first.id;
          final studentName = studentSnapshot.docs.first.data()['name'];
          
          // Obtenir les cours
          final coursesSnapshot = await _firestore.collection('courses').get();
          
          for (var courseDoc in coursesSnapshot.docs) {
            final courseId = courseDoc.id;
            final courseTitle = courseDoc.data()['title'];
            
            // Créer des questions pour chaque cours
            final questionRef = await _firestore.collection('questions').add({
              'title': 'Question sur ${courseTitle}',
              'content': 'Comment puis-je approfondir mes connaissances sur ce sujet?',
              'courseId': courseId,
              'userId': studentId,
              'userName': studentName,
              'createdAt': FieldValue.serverTimestamp(),
              'answersCount': 0,
            });
            
            // Créer une réponse à la question
            final teacherSnapshot = await _firestore.collection('users').where('email', isEqualTo: 'prof@edubridge.com').get();
            if (teacherSnapshot.docs.isNotEmpty) {
              final teacherId = teacherSnapshot.docs.first.id;
              final teacherName = teacherSnapshot.docs.first.data()['name'];
              
              await _firestore.collection('answers').add({
                'content': 'Je vous recommande de consulter les ressources supplémentaires dans la section des leçons.',
                'questionId': questionRef.id,
                'userId': teacherId,
                'userName': teacherName,
                'createdAt': FieldValue.serverTimestamp(),
                'isAccepted': true,
              });
              
              // Mettre à jour le nombre de réponses
              await _firestore.collection('questions').doc(questionRef.id).update({
                'answersCount': 1,
              });
            }
          }
          
          print('Questions et réponses de test créées avec succès');
        }
      } catch (e) {
        print('Erreur lors de la création des questions: $e');
      }
    } else {
      print('Les questions de test existent déjà');
    }
  }

  Future<void> _createTestExams() async {
    // Vérifier si les examens existent déjà
    final examsSnapshot = await _firestore.collection('exams').limit(1).get();
    if (examsSnapshot.docs.isEmpty) {
      try {
        // Obtenir les cours
        final coursesSnapshot = await _firestore.collection('courses').get();
        
        for (var courseDoc in coursesSnapshot.docs) {
          final courseId = courseDoc.id;
          final courseTitle = courseDoc.data()['title'];
          
          // Créer un examen pour chaque cours
          final now = DateTime.now();
          final startDate = now.add(const Duration(days: 7));
          final endDate = startDate.add(const Duration(days: 1));
          
          await _firestore.collection('exams').add({
            'title': 'Examen final: $courseTitle',
            'description': 'Évaluation des connaissances acquises durant le cours',
            'courseId': courseId,
            'questions': [
              {
                'question': 'Question 1: Expliquez le concept principal du cours.',
                'points': 10,
                'type': 'essay',
              },
              {
                'question': 'Question 2: Choisissez la bonne réponse.',
                'points': 5,
                'type': 'multiple_choice',
                'options': ['Option A', 'Option B', 'Option C', 'Option D'],
                'correctAnswer': 1,
              },
              {
                'question': 'Question 3: Vrai ou Faux?',
                'points': 5,
                'type': 'true_false',
                'correctAnswer': true,
              },
            ],
            'duration': 120, // minutes
            'startDate': Timestamp.fromDate(startDate),
            'endDate': Timestamp.fromDate(endDate),
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        
        print('Examens de test créés avec succès');
      } catch (e) {
        print('Erreur lors de la création des examens: $e');
      }
    } else {
      print('Les examens de test existent déjà');
    }
  }

  // Fonction pour configurer les règles de sécurité (à exécuter manuellement dans la console Firebase)
  void setupSecurityRules() {
    print('''
    Règles de sécurité Firestore à copier dans la console Firebase:
    
    rules_version = '2';
    service cloud.firestore {
      match /databases/{database}/documents {
        // Fonctions utilitaires
        function isSignedIn() {
          return request.auth != null;
        }
        
        function isOwner(userId) {
          return request.auth.uid == userId;
        }
        
        function isStudent() {
          return get(/databases/\$(database)/documents/users/\$(request.auth.uid)).data.role == 'student';
        }
        
        function isTeacher() {
          return get(/databases/\$(database)/documents/users/\$(request.auth.uid)).data.role == 'teacher';
        }
        
        function isAdmin() {
          return get(/databases/\$(database)/documents/users/\$(request.auth.uid)).data.role == 'admin';
        }
        
        function isCourseTeacher(courseId) {
          return get(/databases/\$(database)/documents/courses/\$(courseId)).data.teacherId == request.auth.uid;
        }
        
        function isEnrolledInCourse(courseId) {
          return exists(/databases/\$(database)/documents/enrollments/\$(request.auth.uid + '_' + courseId));
        }
        
        // Règles pour les utilisateurs
        match /users/{userId} {
          allow read: if isSignedIn();
          allow create: if isSignedIn() && isOwner(userId);
          allow update: if isSignedIn() && (isOwner(userId) || isAdmin());
          allow delete: if isSignedIn() && isAdmin();
        }
        
        // Autres règles...
      }
    }
    ''');
  }
}

