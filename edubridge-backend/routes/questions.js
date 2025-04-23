const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Question = require('../models/Question');
const User = require('../models/User');
const { check, validationResult } = require('express-validator');

// @route   GET /api/questions
// @desc    Get all questions
// @access  Private
router.get('/', auth, async (req, res) => {
  try {
    const questions = await Question.find().sort({ timestamp: -1 });
    res.json(questions);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// @route   GET /api/questions/unanswered
// @desc    Get all unanswered questions (for teachers)
// @access  Private (teacher/admin only)
router.get('/unanswered', auth, async (req, res) => {
  // Check if the user is a teacher or admin
  if (req.user.role !== 'teacher' && req.user.role !== 'admin') {
    return res.status(403).json({ msg: 'Not authorized to view unanswered questions' });
  }

  try {
    const questions = await Question.find({ answered: false }).sort({ timestamp: -1 });
    res.json(questions);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// @route   GET /api/questions/student
// @desc    Get questions asked by the current user
// @access  Private
router.get('/student', auth, async (req, res) => {
  try {
    const questions = await Question.find({ studentId: req.user.id }).sort({ timestamp: -1 });
    res.json(questions);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// @route   GET /api/questions/:id
// @desc    Get question by ID
// @access  Private
router.get('/:id', auth, async (req, res) => {
  try {
    const question = await Question.findById(req.params.id);
    
    if (!question) {
      return res.status(404).json({ msg: 'Question not found' });
    }

    res.json(question);
  } catch (err) {
    console.error(err.message);
    if (err.kind === 'ObjectId') {
      return res.status(404).json({ msg: 'Question not found' });
    }
    res.status(500).send('Server Error');
  }
});

// @route   POST /api/questions
// @desc    Create a new question
// @access  Private
router.post('/', [
  auth,
  [
    check('text', 'Question text is required').not().isEmpty(),
    check('courseTitle', 'Course title is required').not().isEmpty()
  ]
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  try {
    const user = await User.findById(req.user.id).select('-password');
    
    const newQuestion = new Question({
      text: req.body.text,
      courseTitle: req.body.courseTitle,
      courseId: req.body.courseId,
      studentName: user.name,
      studentId: req.user.id,
      studentAvatar: req.body.studentAvatar || 'assets/images/default_avatar.jpg'
    });

    const question = await newQuestion.save();
    res.status(201).json(question);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// @route   PUT /api/questions/:id/answer
// @desc    Answer a question or mark as answered
// @access  Private (teacher/admin only)
router.put('/:id/answer', [
  auth,
  [
    check('answered', 'Answered status is required').isBoolean()
  ]
], async (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }

  // Check if the user is a teacher or admin
  if (req.user.role !== 'teacher' && req.user.role !== 'admin') {
    return res.status(403).json({ msg: 'Not authorized to answer questions' });
  }

  try {
    const question = await Question.findById(req.params.id);
    
    if (!question) {
      return res.status(404).json({ msg: 'Question not found' });
    }

    // Update the question
    question.answered = req.body.answered;
    question.answer = req.body.answer || 'Marked as answered by teacher';
    question.teacherId = req.user.id;
    
    await question.save();
    res.json(question);
  } catch (err) {
    console.error(err.message);
    if (err.kind === 'ObjectId') {
      return res.status(404).json({ msg: 'Question not found' });
    }
    res.status(500).send('Server Error');
  }
});

// @route   DELETE /api/questions/:id
// @desc    Delete a question
// @access  Private
router.delete('/:id', auth, async (req, res) => {
  try {
    const question = await Question.findById(req.params.id);
    
    if (!question) {
      return res.status(404).json({ msg: 'Question not found' });
    }

    // Check user is the student who asked or is teacher/admin
    if (question.studentId.toString() !== req.user.id && 
        req.user.role !== 'teacher' && 
        req.user.role !== 'admin') {
      return res.status(401).json({ msg: 'User not authorized to delete this question' });
    }

    await question.remove();
    res.json({ msg: 'Question removed' });
  } catch (err) {
    console.error(err.message);
    if (err.kind === 'ObjectId') {
      return res.status(404).json({ msg: 'Question not found' });
    }
    res.status(500).send('Server Error');
  }
});

module.exports = router;
