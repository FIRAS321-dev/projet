// filepath: edubridge-backend/routes/courses.js
const express = require('express');
const router = express.Router();
const Course = require('../models/Course');
const User = require('../models/User');
const auth = require('../middleware/auth');

// Get all courses
router.get('/', async (req, res) => {
  try {
    const courses = await Course.find().populate('instructor', 'name email');
    res.json(courses);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get course by ID
router.get('/:id', async (req, res) => {
  try {
    const course = await Course.findById(req.params.id)
      .populate('instructor', 'name email')
      .populate('enrolledStudents', 'name email');
    
    if (!course) {
      return res.status(404).json({ message: 'Course not found' });
    }
    
    res.json(course);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Create a new course (instructor or admin only)
router.post('/', auth, async (req, res) => {
  try {
    // Check if user is instructor or admin
    if (req.user.role !== 'teacher' && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Not authorized to create courses' });
    }
    
    const {
      title,
      description,
      imageUrl,
      category,
      level,
      price,
      duration,
      lessons
    } = req.body;
    
    const course = new Course({
      title,
      description,
      instructor: req.user.id,
      imageUrl,
      category,
      level,
      price,
      duration,
      lessons: lessons || []
    });
    
    await course.save();
    res.status(201).json(course);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update a course (instructor of the course or admin only)
router.put('/:id', auth, async (req, res) => {
  try {
    const course = await Course.findById(req.params.id);
    
    if (!course) {
      return res.status(404).json({ message: 'Course not found' });
    }
    
    // Check if user is the instructor of this course or an admin
    if (
      course.instructor.toString() !== req.user.id &&
      req.user.role !== 'admin'
    ) {
      return res.status(403).json({ message: 'Not authorized to update this course' });
    }
    
    const {
      title,
      description,
      imageUrl,
      category,
      level,
      price,
      duration,
      lessons
    } = req.body;
    
    // Update course fields
    if (title) course.title = title;
    if (description) course.description = description;
    if (imageUrl) course.imageUrl = imageUrl;
    if (category) course.category = category;
    if (level) course.level = level;
    if (price !== undefined) course.price = price;
    if (duration) course.duration = duration;
    if (lessons) course.lessons = lessons;
    
    course.updatedAt = Date.now();
    
    await course.save();
    res.json(course);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete a course (instructor of the course or admin only)
router.delete('/:id', auth, async (req, res) => {
  try {
    const course = await Course.findById(req.params.id);
    
    if (!course) {
      return res.status(404).json({ message: 'Course not found' });
    }
    
    // Check if user is the instructor of this course or an admin
    if (
      course.instructor.toString() !== req.user.id &&
      req.user.role !== 'admin'
    ) {
      return res.status(403).json({ message: 'Not authorized to delete this course' });
    }
    
    await course.remove();
    res.json({ message: 'Course deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Enroll in a course
router.post('/:id/enroll', auth, async (req, res) => {
  try {
    const course = await Course.findById(req.params.id);
    
    if (!course) {
      return res.status(404).json({ message: 'Course not found' });
    }
    
    // Check if user is already enrolled
    if (course.enrolledStudents.includes(req.user.id)) {
      return res.status(400).json({ message: 'Already enrolled in this course' });
    }
    
    // Add user to enrolled students
    course.enrolledStudents.push(req.user.id);
    await course.save();
    
    res.json({ message: 'Successfully enrolled in course' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Rate a course
router.post('/:id/rate', auth, async (req, res) => {
  try {
    const { rating, review } = req.body;
    
    if (!rating || rating < 1 || rating > 5) {
      return res.status(400).json({ message: 'Rating must be between 1 and 5' });
    }
    
    const course = await Course.findById(req.params.id);
    
    if (!course) {
      return res.status(404).json({ message: 'Course not found' });
    }
    
    // Check if user is enrolled in the course
    if (!course.enrolledStudents.includes(req.user.id)) {
      return res.status(403).json({ message: 'You must be enrolled to rate this course' });
    }
    
    // Check if user has already rated this course
    const existingRatingIndex = course.ratings.findIndex(
      r => r.user.toString() === req.user.id
    );
    
    if (existingRatingIndex !== -1) {
      // Update existing rating
      course.ratings[existingRatingIndex].rating = rating;
      course.ratings[existingRatingIndex].review = review || '';
      course.ratings[existingRatingIndex].date = Date.now();
    } else {
      // Add new rating
      course.ratings.push({
        user: req.user.id,
        rating,
        review: review || '',
        date: Date.now()
      });
    }
    
    await course.save();
    res.json({ message: 'Course rated successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get courses by instructor
router.get('/instructor/:instructorId', async (req, res) => {
  try {
    const courses = await Course.find({ instructor: req.params.instructorId })
      .populate('instructor', 'name email');
    
    res.json(courses);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get enrolled courses for current user
router.get('/enrolled/me', auth, async (req, res) => {
  try {
    const courses = await Course.find({ enrolledStudents: req.user.id })
      .populate('instructor', 'name email');
    
    res.json(courses);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;