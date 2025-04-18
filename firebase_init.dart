import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseInitializer {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fonction pour initialiser les collections et documents de base
  Future<void> initializeDatabase() async {
    try {
      // Vérifier si l'utilisateur admin existe déjà
      bool adminExists = false;
      final adminQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();
      
      adminExists = adminQuery.docs.isNotEmpty;

      // Créer un utilisateur admin si nécessaire
      if (!adminExists) {
        // Créer un compte admin dans Authentication
        final adminCredential = await _auth.createUserWithEmailAndPassword(
          email: 'admin@edubridge.com',
          password: 'Admin123!', // Changez ce mot de passe en production!
        );
        
        // Ajouter les informations admin dans Firestore
        await _firestore.collection('users').doc(adminCredential.user!.uid).set({
          'name': 'Administrateur',
          'email': 'admin@edubridge.com',
          'role': 'admin',
          'photoURL': '',
          'bio': 'Administrateur de la plateforme EduBridge',
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        debugPrint('✅ Utilisateur admin créé avec succès');
      }

      // Créer des exemples de cours
      await _createSampleCourses();
      
      debugPrint('✅ Base de données Firebase initialisée avec succès');
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'initialisation de la base de données: $e');
    }
  }

  // Fonction pour créer des exemples de cours
  Future<void> _createSampleCourses() async {
    // Vérifier si des cours existent déjà
    final coursesQuery = await _firestore.collection('courses').limit(1).get();
    if (coursesQuery.docs.isNotEmpty) {
      debugPrint('Des cours existent déjà, pas besoin d\'en créer');
      return;
    }

    // Créer un compte enseignant
    UserCredential teacherCredential;
    try {
      teacherCredential = await _auth.createUserWithEmailAndPassword(
        email: 'prof@edubridge.com',
        password: 'Prof123!', // Changez ce mot de passe en production!
      );
    } catch (e) {
      // Si l'utilisateur existe déjà, se connecter
      teacherCredential = await _auth.signInWithEmailAndPassword(
        email: 'prof@edubridge.com',
        password: 'Prof123!',
      );
    }

    // Ajouter les informations de l'enseignant dans Firestore
    await _firestore.collection('users').doc(teacherCredential.user!.uid).set({
      'name': 'Professeur Dupont',
      'email': 'prof@edubridge.com',
      'role': 'teacher',
      'photoURL': '',
      'bio': 'Professeur de mathématiques et sciences',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Créer un cours de mathématiques
    final mathCourseRef = await _firestore.collection('courses').add({
      'title': 'Mathématiques Avancées',
      'description': 'Cours de mathématiques pour les étudiants de niveau avancé',
      'imageUrl': '',
      'tags': ['mathématiques', 'algèbre', 'calcul'],
      'teacherId': teacherCredential.user!.uid,
      'teacherName': 'Professeur Dupont',
      'studentsCount': 0,
      'lessonsCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Créer des leçons pour le cours de mathématiques
    final lessons = [
      {
        'title': 'Introduction à l\'algèbre linéaire',
        'content': 'Dans cette leçon, nous allons explorer les bases de l\'algèbre linéaire...',
        'courseId': mathCourseRef.id,
        'order': 1,
        'resources': [],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Matrices et déterminants',
        'content': 'Les matrices sont des tableaux de nombres qui permettent de résoudre...',
        'courseId': mathCourseRef.id,
        'order': 2,
        'resources': [],
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'title': 'Systèmes d\'équations linéaires',
        'content': 'Un système d\'équations linéaires est un ensemble d\'équations...',
        'courseId': mathCourseRef.id,
        'order': 3,
        'resources': [],
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    // Ajouter les leçons à Firestore
    for (final lesson in lessons) {
      await _firestore.collection('lessons').add(lesson);
    }

    // Mettre à jour le nombre de leçons dans le cours
    await mathCourseRef.update({
      'lessonsCount': lessons.length,
    });

    // Créer un compte étudiant
    UserCredential studentCredential;
    try {
      studentCredential = await _auth.createUserWithEmailAndPassword(
        email: 'etudiant@edubridge.com',
        password: 'Etudiant123!', // Changez ce mot de passe en production!
      );
    } catch (e) {
      // Si l'utilisateur existe déjà, se connecter
      studentCredential = await _auth.signInWithEmailAndPassword(
        email: 'etudiant@edubridge.com',
        password: 'Etudiant123!',
      );
    }

    // Ajouter les informations de l'étudiant dans Firestore
    await _firestore.collection('users').doc(studentCredential.user!.uid).set({
      'name': 'Jean Dupont',
      'email': 'etudiant@edubridge.com',
      'role': 'student',
      'photoURL': '',
      'bio': 'Étudiant en sciences',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Inscrire l'étudiant au cours de mathématiques
    await _firestore.collection('enrollments').doc('${studentCredential.user!.uid}_${mathCourseRef.id}').set({
      'studentId': studentCredential.user!.uid,
      'courseId': mathCourseRef.id,
      'enrolledAt': FieldValue.serverTimestamp(),
      'progress': 0,
      'lastAccessedAt': FieldValue.serverTimestamp(),
    });

    // Mettre à jour le nombre d'étudiants dans le cours
    await mathCourseRef.update({
      'studentsCount': 1,
    });

    // Créer une question dans le forum
    final questionRef = await _firestore.collection('questions').add({
      'title': 'Question sur les matrices',
      'content': 'Comment calculer le déterminant d\'une matrice 3x3 ?',
      'courseId': mathCourseRef.id,
      'userId': studentCredential.user!.uid,
      'userName': 'Jean Dupont',
      'createdAt': FieldValue.serverTimestamp(),
      'answersCount': 0,
    });

    // Créer une réponse à la question
    await _firestore.collection('answers').add({
      'content': 'Pour calculer le déterminant d\'une matrice 3x3, vous pouvez utiliser la règle de Sarrus...',
      'questionId': questionRef.id,
      'userId': teacherCredential.user!.uid,
      'userName': 'Professeur Dupont',
      'createdAt': FieldValue.serverTimestamp(),
      'isAccepted': false,
    });

    // Mettre à jour le nombre de réponses à la question
    await questionRef.update({
      'answersCount': 1,
    });

    // Créer une notification pour l'étudiant
    await _firestore.collection('notifications').add({
      'title': 'Nouvelle réponse',
      'message': 'Votre question a reçu une nouvelle réponse',
      'userId': studentCredential.user!.uid,
      'type': 'answer',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
      'relatedId': questionRef.id,
    });

    // Créer un examen
    final examRef = await _firestore.collection('exams').add({
      'title': 'Examen d\'algèbre linéaire',
      'description': 'Examen final sur l\'algèbre linéaire',
      'courseId': mathCourseRef.id,
      'questions': [
        {
          'question': 'Qu\'est-ce qu\'une matrice identité ?',
          'options': [
            'Une matrice avec des 1 sur la diagonale principale et des 0 ailleurs',
            'Une matrice avec des 0 sur la diagonale principale et des 1 ailleurs',
            'Une matrice avec uniquement des 1',
            'Une matrice avec uniquement des 0',
          ],
          'correctAnswer': 0,
        },
        {
          'question': 'Comment calculer le déterminant d\'une matrice 2x2 ?',
          'options': [
            'a*d - b*c',
            'a*c - b*d',
            'a*b - c*d',
            'a*d + b*c',
          ],
          'correctAnswer': 0,
        },
      ],
      'duration': 60, // 60 minutes
      'startDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 7))),
      'endDate': Timestamp.fromDate(DateTime.now().add(Duration(days: 7, hours: 1))),
      'createdAt': FieldValue.serverTimestamp(),
    });

    debugPrint('✅ Exemples de données créés avec succès');
  }

  // Fonction pour configurer les règles de sécurité Firestore
  Future<void> setupSecurityRules() async {
    // Cette fonction est juste pour information
    // Les règles de sécurité doivent être configurées manuellement dans la console Firebase
    debugPrint('''
    ⚠️ N'oubliez pas de configurer les règles de sécurité Firestore dans la console Firebase.
    Voici un exemple de règles:
    
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
          return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'student';
        }
        
        function isTeacher() {
          return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'teacher';
        }
        
        function isAdmin() {
          return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
        }
        
        // Règles pour les utilisateurs
        match /users/{userId} {
          allow read: if isSignedIn();
          allow create: if isSignedIn() && isOwner(userId);
          allow update: if isSignedIn() && (isOwner(userId) || isAdmin());
          allow delete: if isSignedIn() && isAdmin();
        }
        
        // Règles pour les cours
        match /courses/{courseId} {
          allow read: if true;
          allow create: if isSignedIn() && (isTeacher() || isAdmin());
          allow update, delete: if isSignedIn() && (
            resource.data.teacherId == request.auth.uid || isAdmin()
          );
        }
        
        // Autres règles...
      }
    }
    ''');
  }
}