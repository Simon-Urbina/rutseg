export type UserRole = 'user' | 'admin'
export type Difficulty = 'principiante' | 'intermedio' | 'avanzado'
export type LaboratoryStatus = 'not_started' | 'in_progress' | 'completed'
export type ActivityStatus = 'not_started' | 'in_progress' | 'completed'
export type QuestionType = 'multiple_choice' | 'activity_response'

export interface User {
  id: string
  username: string
  email: string
  passwordHash: string | null
  role: UserRole
  bio: string | null
  profileImage: Buffer | null
  points: number
  createdAt: Date
  updatedAt: Date
  deletedAt: Date | null
}

export type OAuthProviderName = 'google' | 'microsoft'

export interface UserOAuthAccount {
  id: string
  userId: string
  provider: OAuthProviderName
  providerUserId: string
  createdAt: Date
}

export interface Course {
  id: string
  slug: string
  title: string
  description: string | null
  difficulty: Difficulty
  isPublished: boolean
  createdBy: string | null
  createdAt: Date
  updatedAt: Date
}

export interface CourseModule {
  id: string
  courseId: string
  slug: string
  title: string
  description: string | null
  position: number
  createdAt: Date
  updatedAt: Date
}

export interface CourseEnrollment {
  id: string
  userId: string
  courseId: string
  enrolledAt: Date
}

export interface Laboratory {
  id: string
  moduleId: string
  slug: string
  title: string
  contentMarkdown: string
  position: number
  estimatedMinutes: number
  quizQuestionsRequired: number
  points: number
  isPublished: boolean
  createdAt: Date
  updatedAt: Date
}

export interface LaboratoryQuestion {
  id: string
  laboratoryId: string
  questionOrder: number
  questionType: QuestionType
  questionText: string
  explanation: string | null
  createdAt: Date
  updatedAt: Date
}

export interface LaboratoryQuestionOption {
  id: string
  questionId: string
  optionOrder: number
  optionText: string
  isCorrect: boolean
}

export interface QuestionActivity {
  id: string
  questionId: string
  title: string
  instructionsMarkdown: string
  expectedActionKey: string
  successFeedback: string
  isPublished: boolean
  createdAt: Date
  updatedAt: Date
}

export interface Submission {
  id: string
  userId: string
  laboratoryId: string
  attemptNumber: number
  answers: SubmissionAnswer[]
  answeredQuestionsCount: number
  correctAnswersCount: number
  scorePercent: number
  submittedAt: Date
}

export interface SubmissionAnswer {
  questionId: string
  selectedOptionId?: string
  responseText?: string
}

export interface UserLaboratoryProgress {
  id: string
  userId: string
  laboratoryId: string
  status: LaboratoryStatus
  attemptsCount: number
  bestScorePercent: number
  lastScorePercent: number | null
  completedAt: Date | null
  lastSubmissionAt: Date | null
  lastSubmissionId: string | null
  createdAt: Date
  updatedAt: Date
}

export interface UserActivityProgress {
  id: string
  userId: string
  activityId: string
  status: ActivityStatus
  attemptsCount: number
  generatedResponse: string | null
  generatedResponseIssuedAt: Date | null
  completedAt: Date | null
  lastActionPayload: Record<string, unknown>
  createdAt: Date
  updatedAt: Date
}

export interface ActivityActionLog {
  id: string
  userId: string
  activityId: string
  actionPayload: Record<string, unknown>
  isCorrect: boolean
  feedback: string | null
  generatedResponse: string | null
  createdAt: Date
}

export interface TokenPayload {
  id: string
  username: string
  email: string
  role: UserRole
}

export interface ForumComment {
  id: string
  userId: string | null
  content: string
  parentId: string | null
  createdAt: Date
  updatedAt: Date
  deletedAt: Date | null
}
