const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const QuestionSchema = new Schema({
  studentName: {
    type: String,
    required: true
  },
  studentId: {
    type: Schema.Types.ObjectId,
    ref: 'users',
    required: true
  },
  studentAvatar: {
    type: String,
    default: 'assets/images/default_avatar.jpg'
  },
  courseTitle: {
    type: String,
    required: true
  },
  courseId: {
    type: Schema.Types.ObjectId,
    ref: 'courses'
  },
  text: {
    type: String,
    required: true
  },
  timestamp: {
    type: Date,
    default: Date.now
  },
  answered: {
    type: Boolean,
    default: false
  },
  answer: {
    type: String,
    default: null
  },
  teacherId: {
    type: Schema.Types.ObjectId,
    ref: 'users'
  }
});

module.exports = Question = mongoose.model('question', QuestionSchema);
