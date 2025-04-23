// Database initialization script
const { MongoClient } = require('mongodb');
const bcrypt = require('bcrypt');

// Connection URL
const url = 'mongodb://localhost:27017';
const client = new MongoClient(url);

// Database Name
const dbName = 'edubridge';

async function main() {
  try {
    // Connect to MongoDB
    await client.connect();
    console.log('Connected to MongoDB server');
    
    // Get/create the edubridge database
    const db = client.db(dbName);
    
    // Create collections if they don't exist
    await db.createCollection('users');
    await db.createCollection('courses');
    await db.createCollection('assignments');
    
    console.log('Collections created');
    
    // Create admin user (check if exists first)
    const usersCollection = db.collection('users');
    const adminExists = await usersCollection.findOne({ email: 'admin@edubridge.com' });
    
    if (!adminExists) {
      const hashedPassword = await bcrypt.hash('password123', 10);
      await usersCollection.insertOne({
        name: 'Admin User',
        email: 'admin@edubridge.com',
        password: hashedPassword,
        role: 'admin',
        createdAt: new Date()
      });
      console.log('Admin user created');
    } else {
      console.log('Admin user already exists');
    }
    
    // Create teacher user
    const teacherExists = await usersCollection.findOne({ email: 'teacher@edubridge.com' });
    
    if (!teacherExists) {
      const hashedPassword = await bcrypt.hash('password123', 10);
      await usersCollection.insertOne({
        name: 'Teacher User',
        email: 'teacher@edubridge.com',
        password: hashedPassword,
        role: 'teacher',
        createdAt: new Date()
      });
      console.log('Teacher user created');
    } else {
      console.log('Teacher user already exists');
    }
    
    // Create student user
    const studentExists = await usersCollection.findOne({ email: 'student@edubridge.com' });
    
    if (!studentExists) {
      const hashedPassword = await bcrypt.hash('password123', 10);
      await usersCollection.insertOne({
        name: 'Student User',
        email: 'student@edubridge.com',
        password: hashedPassword,
        role: 'student',
        createdAt: new Date()
      });
      console.log('Student user created');
    } else {
      console.log('Student user already exists');
    }
    
    // Create indexes
    await usersCollection.createIndex({ email: 1 }, { unique: true });
    await db.collection('courses').createIndex({ instructor: 1 });
    await db.collection('courses').createIndex({ category: 1 });
    await db.collection('assignments').createIndex({ course: 1 });
    
    console.log('Indexes created');
    console.log('EduBridge database initialized successfully!');
    
  } catch (err) {
    console.error('Error initializing database:', err);
  } finally {
    await client.close();
    console.log('Database connection closed');
  }
}

main().catch(console.error);
