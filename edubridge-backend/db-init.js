// Initialize EduBridge database
db = db.getSiblingDB('edubridge');

// Create collections
db.createCollection('users');
db.createCollection('courses');
db.createCollection('assignments');

// Create admin user
db.users.insertOne({
  name: 'Admin User',
  email: 'admin@edubridge.com',
  password: '$2b$10$X/A.e1rHYWFahI.EUkB0EuvVNOzqN0IWMxs83fLtqkgTrQSm81Kx.', // hashed 'password123'
  role: 'admin',
  createdAt: new Date()
});

// Create teacher user
db.users.insertOne({
  name: 'Teacher User',
  email: 'teacher@edubridge.com',
  password: '$2b$10$X/A.e1rHYWFahI.EUkB0EuvVNOzqN0IWMxs83fLtqkgTrQSm81Kx.', // hashed 'password123'
  role: 'teacher',
  createdAt: new Date()
});

// Create student user
db.users.insertOne({
  name: 'Student User',
  email: 'student@edubridge.com',
  password: '$2b$10$X/A.e1rHYWFahI.EUkB0EuvVNOzqN0IWMxs83fLtqkgTrQSm81Kx.', // hashed 'password123'
  role: 'student',
  createdAt: new Date()
});

// Create an index on email field for users collection
db.users.createIndex({ email: 1 }, { unique: true });

// Create indexes for other collections
db.courses.createIndex({ instructor: 1 });
db.courses.createIndex({ category: 1 });
db.assignments.createIndex({ course: 1 });

print('EduBridge database initialized successfully!');
