export type Difficulty = 'principiante' | 'intermedio' | 'avanzado'
export type LabBucket = 'pocos' | 'medios' | 'muchos'
export type PointsBucket = 'bajo' | 'medio' | 'alto'

export interface CourseFilterState {
  difficulties: Set<Difficulty>
  labBuckets: Set<LabBucket>
  pointsBuckets: Set<PointsBucket>
}

export function emptyCourseFilters(): CourseFilterState {
  return { difficulties: new Set(), labBuckets: new Set(), pointsBuckets: new Set() }
}

export function hasActiveCourseFilters(f: CourseFilterState): boolean {
  return f.difficulties.size > 0 || f.labBuckets.size > 0 || f.pointsBuckets.size > 0
}

function labBucketOf(labCount: number): LabBucket {
  if (labCount <= 3) return 'pocos'
  if (labCount <= 6) return 'medios'
  return 'muchos'
}

function pointsBucketOf(totalPoints: number): PointsBucket {
  if (totalPoints <= 300) return 'bajo'
  if (totalPoints <= 700) return 'medio'
  return 'alto'
}

export function courseMatchesFilters(
  course: { difficulty: Difficulty; labCount: number; totalPoints: number },
  filters: CourseFilterState,
): boolean {
  if (filters.difficulties.size > 0 && !filters.difficulties.has(course.difficulty)) return false
  if (filters.labBuckets.size > 0 && !filters.labBuckets.has(labBucketOf(course.labCount))) return false
  if (filters.pointsBuckets.size > 0 && !filters.pointsBuckets.has(pointsBucketOf(course.totalPoints))) return false
  return true
}

export const DIFFICULTY_OPTIONS: { value: Difficulty; label: string }[] = [
  { value: 'principiante', label: 'Principiante' },
  { value: 'intermedio', label: 'Intermedio' },
  { value: 'avanzado', label: 'Avanzado' },
]

export const LAB_OPTIONS: { value: LabBucket; label: string }[] = [
  { value: 'pocos', label: '1–3 labs' },
  { value: 'medios', label: '4–6 labs' },
  { value: 'muchos', label: '7+ labs' },
]

export const POINTS_OPTIONS: { value: PointsBucket; label: string }[] = [
  { value: 'bajo', label: 'Hasta 300 pts' },
  { value: 'medio', label: '300–700 pts' },
  { value: 'alto', label: 'Más de 700 pts' },
]
