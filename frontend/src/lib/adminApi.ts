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

export function slugify(text: string): string {
  return text
    .toLowerCase()
    .normalize('NFD').replace(/[̀-ͯ]/g, '')
    .replace(/[^a-z0-9\s-]/g, '')
    .trim()
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
}

export const adminApi = {
  // Listado — reutiliza los GET públicos, ya devuelven contenido no publicado a un admin
  listCourses: () => api.get<AdminCourse[]>('/api/courses'),
  getCourse: (slug: string) => api.get<AdminCourse>(`/api/courses/${slug}`),
  listModules: (courseSlug: string) => api.get<AdminModule[]>(`/api/courses/${courseSlug}/modules`),
  listLabs: (courseSlug: string, moduleSlug: string) =>
    api.get<AdminLabSummary[]>(`/api/courses/${courseSlug}/modules/${moduleSlug}/labs`),

  // Curso
  createCourse: (data: { slug: string; title: string; description?: string; difficulty: string }) =>
    api.post<AdminCourse>('/api/admin/courses', data),
  updateCourse: (id: string, data: Partial<{ slug: string; title: string; description: string; difficulty: string; isPublished: boolean }>) =>
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
  createQuestion: (labId: string, data: { questionOrder: number; questionType: string; questionText: string; explanation?: string }) =>
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
}
