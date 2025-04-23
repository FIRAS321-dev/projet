// filepath: edubridge-backend/routes/assignments.js
const express = require('express');
const router = express.Router();
const Assignment = require('../models/Assignment');
const Course = require('../models/Course');
const auth = require('../middleware/auth');

// Get all assignments
router.get('/', auth, async (req, res) => {
  try {
    const assignments = await Assignment.find()
      .populate('course', 'title')
      .sort({ createdAt: -1 });
    res.json(assignments);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get assignments by course
router.get('/course/:courseId', auth, async (req, res) => {
  try {
    const assignments = await Assignment.find({ course: req.params.courseId })
      .populate('course', 'title')
      .sort({ dueDate: 1 });
    res.json(assignments);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Get single assignment by ID
router.get('/:id', auth, async (req, res) => {
  try {
    const assignment = await Assignment.findById(req.params.id)
      .populate('course', 'title instructor')
      .populate('submissions.student', 'name email');
    
    if (!assignment) {
      return res.status(404).json({ message: 'Assignment not found' });
    }
    
    res.json(assignment);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Create new assignment (teacher or admin only)
router.post('/', auth, async (req, res) => {
  try {
    const { title, description, course, dueDate, points, attachments } = req.body;
    
    // Check if user is an instructor or admin
    if (req.user.role !== 'teacher' && req.user.role !== 'admin') {
      return res.status(403).json({ message: 'Not authorized to create assignments' });
    }
    
    // Check if course exists
    const courseExists = await Course.findById(course);
    if (!courseExists) {
      return res.status(404).json({ message: 'Course not found' });
    }
    
    // Check if user is instructor of this course or an admin
    if (
      req.user.role !== 'admin' && 
      courseExists.instructor.toString() !== req.user.id
    ) {
      return res.status(403).json({ message: 'Not authorized to add assignments to this course' });
    }
    
    const assignment = new Assignment({
      title,
      description,
      course,
      dueDate,
      points,
      attachments: attachments || []
    });
    
    await assignment.save();
    res.status(201).json(assignment);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Update assignment (teacher of the course or admin only)
router.put('/:id', auth, async (req, res) => {
  try {
    const { title, description, dueDate, points, attachments } = req.body;
    
    const assignment = await Assignment.findById(req.params.id);
    
    if (!assignment) {
      return res.status(404).json({ message: 'Assignment not found' });
    }
    
    // Get course info to check permissions
    const course = await Course.findById(assignment.course);
    
    // Check if user is the instructor of the course or an admin
    if (
      req.user.role !== 'admin' && 
      course.instructor.toString() !== req.user.id
    ) {
      return res.status(403).json({ message: 'Not authorized to update this assignment' });
    }
    
    // Update fields
    if (title) assignment.title = title;
    if (description) assignment.description = description;
    if (dueDate) assignment.dueDate = dueDate;
    if (points) assignment.points = points;
    if (attachments) assignment.attachments = attachments;
    
    await assignment.save();
    res.json(assignment);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Delete assignment (teacher of the course or admin only)
router.delete('/:id', auth, async (req, res) => {
  try {
    const assignment = await Assignment.findById(req.params.id);
    
    if (!assignment) {
      return res.status(404).json({ message: 'Assignment not found' });
    }
    
    // Get course info to check permissions
    const course = await Course.findById(assignment.course);
    
    // Check if user is the instructor of the course or an admin
    if (
      req.user.role !== 'admin' && 
      course.instructor.toString() !== req.user.id
    ) {
      return res.status(403).json({ message: 'Not authorized to delete this assignment' });
    }
    
    await Assignment.findByIdAndDelete(req.params.id);
    res.json({ message: 'Assignment removed' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Submit assignment (students only)
router.post('/:id/submit', auth, async (req, res) => {
  try {
    const { submissionUrl, submissionText } = req.body;
    
    // Check if user is a student
    if (req.user.role !== 'student') {
      return res.status(403).json({ message: 'Only students can submit assignments' });
    }
    
    const assignment = await Assignment.findById(req.params.id);
    
    if (!assignment) {
      return res.status(404).json({ message: 'Assignment not found' });
    }
    
    // Check if assignment is past due date
    if (new Date(assignment.dueDate) < new Date()) {
      return res.status(400).json({ message: 'Assignment past due date' });
    }
    
    // Check if student is enrolled in the course
    const course = await Course.findById(assignment.course);
    if (!course.enrolledStudents.includes(req.user.id)) {
      return res.status(403).json({ message: 'You must be enrolled in this course to submit assignments' });
    }
    
    // Check if student has already submitted
    const existingSubmissionIndex = assignment.submissions.findIndex(
      submission => submission.student.toString() === req.user.id
    );
    
    if (existingSubmissionIndex !== -1) {
      // Update existing submission
      assignment.submissions[existingSubmissionIndex].submissionUrl = submissionUrl;
      assignment.submissions[existingSubmissionIndex].submissionText = submissionText || '';
      assignment.submissions[existingSubmissionIndex].submittedAt = Date.now();
    } else {
      // Add new submission
      assignment.submissions.push({
        student: req.user.id,
        submissionUrl,
        submissionText: submissionText || ''
      });
    }
    
    await assignment.save();
    res.json({ message: 'Assignment submitted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Grade assignment submission (teacher of the course or admin only)
router.post('/:id/grade/:submissionId', auth, async (req, res) => {
  try {
    const { grade, feedback } = req.body;
    
    if (grade < 0 || grade > 100) {
      return res.status(400).json({ message: 'Grade must be between 0 and 100' });
    }
    
    const assignment = await Assignment.findById(req.params.id);
    
    if (!assignment) {
      return res.status(404).json({ message: 'Assignment not found' });
    }
    
    // Get course info to check permissions
    const course = await Course.findById(assignment.course);
    
    // Check if user is the instructor of the course or an admin
    if (
      req.user.role !== 'admin' && 
      course.instructor.toString() !== req.user.id
    ) {
      return res.status(403).json({ message: 'Not authorized to grade this assignment' });
    }
    
    // Find the submission
    const submission = assignment.submissions.id(req.params.submissionId);
    
    if (!submission) {
      return res.status(404).json({ message: 'Submission not found' });
    }
    
    // Update grade and feedback
    submission.grade = grade;
    submission.feedback = feedback || '';
    
    await assignment.save();
    res.json({ message: 'Assignment graded successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
