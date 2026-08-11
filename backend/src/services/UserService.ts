import { UserDAO } from '../daos/UserDAO.js'
import { CourseEnrollmentDAO } from '../daos/CourseEnrollmentDAO.js'
import { NotFoundError, ConflictError, UnauthorizedError, BadRequestError, ValidationError } from '../utils/errors.js'

const MAX_IMAGE_BYTES = 5 * 1024 * 1024
const ALLOWED_MIMETYPES = ['image/jpeg', 'image/jpg']
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

export class UserService {
  static async getPublicProfile(username: string) {
    const user = await UserDAO.findByUsername(username)
    if (!user) throw new NotFoundError('Usuario no encontrado.')
    const [completedLabs, rank, enrolledCourses] = await Promise.all([
      UserDAO.countCompletedLabs(user.id),
      UserDAO.getRank(user.id),
      CourseEnrollmentDAO.findCourseSummariesByUserId(user.id),
    ])
    return {
      id: user.id,
      username: user.username,
      bio: user.bio,
      profileImage: user.profileImage ? Buffer.from(user.profileImage).toString('base64') : null,
      points: user.points,
      createdAt: user.createdAt,
      completedLabs,
      rank,
      enrolledCourses,
    }
  }

  static async getMyProfile(userId: string) {
    const user = await UserDAO.findById(userId)
    if (!user) throw new NotFoundError('Usuario no encontrado.')
    const [completedLabs, rank] = await Promise.all([
      UserDAO.countCompletedLabs(userId),
      UserDAO.getRank(userId),
    ])
    return {
      id: user.id,
      username: user.username,
      email: user.email,
      bio: user.bio,
      profileImage: user.profileImage ? Buffer.from(user.profileImage).toString('base64') : null,
      points: user.points,
      role: user.role,
      createdAt: user.createdAt,
      completedLabs,
      rank,
    }
  }

  static async updateProfile(
    userId: string,
    data: { username?: string; email?: string; bio?: string | null },
  ) {
    const errors: string[] = []
    const patch: { username?: string; email?: string; bio?: string | null } = {}

    if (data.username !== undefined) {
      const u = data.username.trim()
      if (u.length < 3 || u.length > 50)
        errors.push('El username debe tener entre 3 y 50 caracteres.')
      else patch.username = u
    }

    if (data.email !== undefined) {
      const e = data.email.trim().toLowerCase()
      if (!EMAIL_REGEX.test(e))
        errors.push('El email no tiene un formato válido.')
      else patch.email = e
    }

    if (data.bio !== undefined) {
      const b = data.bio === null ? null : String(data.bio).trim()
      if (b !== null && b.length > 500)
        errors.push('La biografía no puede superar los 500 caracteres.')
      else patch.bio = b === '' ? null : b
    }

    if (errors.length) throw new ValidationError(errors)

    if (patch.username) {
      const taken = await UserDAO.findByUsername(patch.username)
      if (taken && taken.id !== userId)
        throw new ConflictError('El username ya está en uso.')
    }
    if (patch.email) {
      const taken = await UserDAO.findByEmail(patch.email)
      if (taken && taken.id !== userId)
        throw new ConflictError('El email ya está registrado.')
    }

    const user = await UserDAO.update(userId, patch)
    if (!user) throw new NotFoundError('Usuario no encontrado.')
    return UserService.getMyProfile(userId)
  }

  static async changePassword(
    userId: string,
    data: { currentPassword: string; newPassword: string },
  ): Promise<void> {
    if (!data.newPassword || data.newPassword.length < 8)
      throw new ValidationError(['La nueva contraseña debe tener al menos 8 caracteres.'])

    const user = await UserDAO.findById(userId)
    if (!user) throw new NotFoundError('Usuario no encontrado.')

    if (!user.passwordHash)
      throw new UnauthorizedError('Tu cuenta inicia sesión con Google o Microsoft y no tiene contraseña propia.')

    const ok = await Bun.password.verify(data.currentPassword, user.passwordHash)
    if (!ok) throw new UnauthorizedError('La contraseña actual es incorrecta.')

    const newHash = await Bun.password.hash(data.newPassword)
    await UserDAO.updatePassword(userId, newHash)
  }

  static async updateAvatar(
    userId: string,
    file: { buffer: Buffer; mimetype: string; size: number },
  ): Promise<void> {
    if (!ALLOWED_MIMETYPES.includes(file.mimetype))
      throw new BadRequestError('La foto de perfil solo acepta formato JPG/JPEG.')
    if (file.size > MAX_IMAGE_BYTES)
      throw new BadRequestError('La foto de perfil no puede superar los 5 MB.')
    await UserDAO.updateAvatar(userId, file.buffer)
  }

  static async getRanking(page = 1, limit = 20) {
    const safeLimit = Math.min(limit, 100)
    const offset = (page - 1) * safeLimit
    const [users, total] = await Promise.all([
      UserDAO.findRanking(safeLimit, offset),
      UserDAO.countRanking(),
    ])
    return {
      data: users.map((u, i) => ({
        rank: offset + i + 1,
        id: u.id,
        username: u.username,
        bio: u.bio,
        points: u.points,
      })),
      total,
      page,
      limit: safeLimit,
      totalPages: Math.ceil(total / safeLimit),
    }
  }
}
