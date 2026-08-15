import { api } from './api'

export interface AdminCourse {
  id: string
  slug: string
  title: string
  description: string | null
  difficulty: 'principiante' | 'intermedio' | 'avanzado'
  isPublished: boolean
  createdBy: string | null
  createdAt: string
  updatedAt: string
  moduleCount: number
  labCount: number
  totalPoints: number
}

export interface AdminModule {
  id: string
  courseId: string
  slug: string
  title: string
  description: string | null
  position: number
}

export interface AdminLabSummary {
  id: string
  moduleId: string
  slug: string
  title: string
  position: number
  estimatedMinutes: number
  points: number
  isPublished: boolean
}

export interface AdminOption {
  id: string
  questionId: string
  optionOrder: number
  optionText: string
  isCorrect: boolean
}

export interface AdminActivity {
  id: string
  questionId: string
  title: string
  instructionsMarkdown: string
  expectedActionKey: string
  successFeedback: string
  isPublished: boolean
}

export interface AdminQuestion {
  id: string
  laboratoryId: string
  questionOrder: number
  questionType: 'multiple_choice' | 'activity_response'
  questionText: string
  explanation: string | null
  options: AdminOption[]
  activity: AdminActivity | null
}

export interface AdminLabMeta {
  id: string
  moduleId: string
  slug: string
  title: string
  contentMarkdown: string
  position: number
  estimatedMinutes: number
  points: number
  isPublished: boolean
}

export interface AdminLabDetail extends AdminLabMeta {
  questions: AdminQuestion[]
}

export interface AdminUser {
  id: string
  username: string
  email: string
  bio: string | null
  role: 'user' | 'admin'
  points: number
  createdAt: string
  updatedAt: string
}

export interface AdminUserListResponse {
  data: AdminUser[]
  total: number
  page: number
  limit: number
  totalPages: number
}

export function slugify(text: string): string {
  return text
    .toLowerCase()
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9\s-]/g, '')
    .trim()
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-+|-+$/g, '')
}

export type AnalyticsRange = '7d' | '1m' | '1y' | '5y'

export interface AnalyticsKpis {
  totalUsers: number
  newUsersInRange: number
  totalPointsAwarded: number
  labsCompletedInRange: number
}

export interface AnalyticsTimeBucket {
  bucket: string
  count: number
}

export interface AnalyticsPointsBucket {
  bucket: string
  points: number
}

export interface AnalyticsCategoryCount {
  range: string
  count: number
}

export interface AnalyticsDifficultyCount {
  difficulty: 'principiante' | 'intermedio' | 'avanzado'
  count: number
}

export interface AnalyticsAuthMethodCount {
  method: string
  count: number
}

export interface AnalyticsCourseEnrollment {
  courseId: string
  title: string
  enrollments: number
}

export interface AnalyticsQuizScore {
  scorePercent: number
  count: number
}

export interface AnalyticsCourseCompletion {
  courseId: string
  title: string
  enrolledCount: number
  ratePercent: number
}

export interface AdminAnalytics {
  kpis: AnalyticsKpis
  timeSeries: {
    newUsers: AnalyticsTimeBucket[]
    labsCompleted: AnalyticsTimeBucket[]
    pointsAwarded: AnalyticsPointsBucket[]
    forumComments: AnalyticsTimeBucket[]
  }
  pointsDistribution: AnalyticsCategoryCount[]
  coursesByDifficulty: AnalyticsDifficultyCount[]
  enrollmentsByDifficulty: AnalyticsDifficultyCount[]
  usersByAuthMethod: AnalyticsAuthMethodCount[]
  enrollmentsByCourse: AnalyticsCourseEnrollment[]
  quizScoreDistribution: AnalyticsQuizScore[]
  completionRateByCourse: AnalyticsCourseCompletion[]
}

export const adminApi = {
  // Listado — reutiliza los GET públicos, ya devuelven contenido no publicado a un admin
  listCourses: () => api.get<AdminCourse[]>('/api/courses'),
  getCourse: (slug: string) => api.get<AdminCourse>(`/api/courses/${slug}`),
  listModules: (courseSlug: string) => api.get<AdminModule[]>(`/api/courses/${courseSlug}/modules`),
  listLabs: (courseSlug: string, moduleSlug: string) =>
    api.get<AdminLabSummary[]>(`/api/courses/${courseSlug}/modules/${moduleSlug}/labs`),

  // Curso
  // POST /courses devuelve la fila cruda (sin moduleCount/labCount/totalPoints, que solo
  // calcula el listado vía findAllWithStats) — el caller debe rellenarlos con 0 al crear.
  createCourse: (data: { slug: string; title: string; description?: string; difficulty: AdminCourse['difficulty'] }) =>
    api.post<Omit<AdminCourse, 'moduleCount' | 'labCount' | 'totalPoints'>>('/api/admin/courses', data),
  updateCourse: (id: string, data: Partial<{ slug: string; title: string; description: string; difficulty: AdminCourse['difficulty']; isPublished: boolean }>) =>
    api.put<AdminCourse>(`/api/admin/courses/${id}`, data),
  deleteCourse: (id: string) => api.delete<{ success: boolean }>(`/api/admin/courses/${id}`),

  // Módulo
  createModule: (courseId: string, data: { slug: string; title: string; description?: string; position: number }) =>
    api.post<AdminModule>(`/api/admin/courses/${courseId}/modules`, data),
  updateModule: (id: string, data: Partial<{ slug: string; title: string; description: string; position: number }>) =>
    api.put<AdminModule>(`/api/admin/modules/${id}`, data),
  deleteModule: (id: string) => api.delete<{ success: boolean }>(`/api/admin/modules/${id}`),

  // Laboratorio
  getLabDetail: (id: string) => api.get<AdminLabDetail>(`/api/admin/labs/${id}`),
  createLab: (moduleId: string, data: { slug: string; title: string; contentMarkdown: string; position: number; estimatedMinutes: number; points: number }) =>
    api.post<AdminLabMeta>(`/api/admin/modules/${moduleId}/labs`, data),
  updateLab: (id: string, data: Partial<{ slug: string; title: string; contentMarkdown: string; position: number; estimatedMinutes: number; points: number; isPublished: boolean }>) =>
    api.put<AdminLabMeta>(`/api/admin/labs/${id}`, data),
  deleteLab: (id: string) => api.delete<{ success: boolean }>(`/api/admin/labs/${id}`),

  // Pregunta
  createQuestion: (labId: string, data: { questionOrder: number; questionType: AdminQuestion['questionType']; questionText: string; explanation?: string }) =>
    api.post<Omit<AdminQuestion, 'options' | 'activity'>>(`/api/admin/labs/${labId}/questions`, data),
  updateQuestion: (id: string, data: Partial<{ questionText: string; explanation: string }>) =>
    api.put<Omit<AdminQuestion, 'options' | 'activity'>>(`/api/admin/questions/${id}`, data),
  deleteQuestion: (id: string) => api.delete<{ success: boolean }>(`/api/admin/questions/${id}`),

  // Opción
  createOption: (questionId: string, data: { optionOrder: number; optionText: string; isCorrect: boolean }) =>
    api.post<AdminOption>(`/api/admin/questions/${questionId}/options`, data),
  updateOption: (questionId: string, id: string, data: Partial<{ optionOrder: number; optionText: string; isCorrect: boolean }>) =>
    api.put<AdminOption>(`/api/admin/questions/${questionId}/options/${id}`, data),
  deleteOption: (questionId: string, id: string) =>
    api.delete<{ success: boolean }>(`/api/admin/questions/${questionId}/options/${id}`),

  // Actividad
  createActivity: (questionId: string, data: { title: string; instructionsMarkdown: string; expectedActionKey: string; successFeedback?: string }) =>
    api.post<AdminActivity>(`/api/admin/questions/${questionId}/activity`, data),
  updateActivity: (id: string, data: Partial<{ title: string; instructionsMarkdown: string; expectedActionKey: string; successFeedback: string; isPublished: boolean }>) =>
    api.put<AdminActivity>(`/api/admin/activities/${id}`, data),

  // Usuario
  listUsers: (params: { page?: number; limit?: number; search?: string } = {}) => {
    const query = new URLSearchParams()
    if (params.page) query.set('page', String(params.page))
    if (params.limit) query.set('limit', String(params.limit))
    if (params.search) query.set('search', params.search)
    const qs = query.toString()
    return api.get<AdminUserListResponse>(`/api/admin/users${qs ? `?${qs}` : ''}`)
  },
  getUser: (id: string) => api.get<AdminUser>(`/api/admin/users/${id}`),
  updateUser: (id: string, data: Partial<{ username: string; email: string; bio: string | null; role: AdminUser['role'] }>) =>
    api.put<AdminUser>(`/api/admin/users/${id}`, data),
  setUserPassword: (id: string, newPassword: string) =>
    api.post<{ message: string }>(`/api/admin/users/${id}/password`, { newPassword }),
  deleteUser: (id: string) => api.delete<{ success: boolean }>(`/api/admin/users/${id}`),

  // Analíticas
  getAnalytics: (range: AnalyticsRange) => api.get<AdminAnalytics>(`/api/admin/analytics?range=${range}`),
}
