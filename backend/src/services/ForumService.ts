import { ForumCommentDAO } from '../daos/ForumCommentDAO.js'
import { ForumComment } from '../models/ForumComment.js'
import { NotFoundError, ForbiddenError, BadRequestError, ValidationError } from '../utils/errors.js'
import sql from '../db/index.js'
import type { UserRole } from '../types.js'

const PAGE_SIZE = 20

async function getAuthor(userId: string | null) {
  if (!userId) return null
  const [row] = await sql<{ username: string; profile_image: Buffer | null }[]>`
    SELECT username, profile_image FROM users WHERE id = ${userId} AND deleted_at IS NULL
  `
  if (!row) return null
  return {
    username: row.username,
    profileImage: row.profile_image ? row.profile_image.toString('base64') : null,
  }
}

export class ForumService {
  static async listRoots(page: number) {
    const p = Math.max(1, Math.floor(page))
    const { rows, total } = await ForumCommentDAO.findRoots(p)
    const comments = await Promise.all(
      rows.map(async (row) => {
        const model = new ForumComment(
          row.id, row.userId, row.content, row.parentId,
          row.createdAt, row.updatedAt, row.deletedAt,
        )
        const author = await getAuthor(row.userId)
        const replyCount = await ForumCommentDAO.countReplies(row.id)
        return model.toPublic(author, replyCount)
      }),
    )
    return {
      comments,
      total,
      page: p,
      totalPages: Math.ceil(total / PAGE_SIZE),
    }
  }

  static async listReplies(parentId: string) {
    const parent = await ForumCommentDAO.findById(parentId)
    if (!parent) throw new NotFoundError('Comentario no encontrado.')
    if (parent.parentId !== null) throw new BadRequestError('Las respuestas no pueden tener respuestas.')
    const rows = await ForumCommentDAO.findReplies(parentId)
    return Promise.all(
      rows.map(async (row) => {
        const model = new ForumComment(
          row.id, row.userId, row.content, row.parentId,
          row.createdAt, row.updatedAt, row.deletedAt,
        )
        const author = await getAuthor(row.userId)
        return model.toPublic(author)
      }),
    )
  }

  static async createComment(userId: string, content: string) {
    const errors = ForumComment.validate({ content })
    if (errors.length) throw new ValidationError(errors)
    const row = await ForumCommentDAO.create({ userId, content: content.trim(), parentId: null })
    const model = new ForumComment(
      row.id, row.userId, row.content, row.parentId,
      row.createdAt, row.updatedAt, row.deletedAt,
    )
    const author = await getAuthor(userId)
    return model.toPublic(author, 0)
  }

  static async createReply(userId: string, parentId: string, content: string) {
    const errors = ForumComment.validate({ content })
    if (errors.length) throw new ValidationError(errors)
    const parent = await ForumCommentDAO.findById(parentId)
    if (!parent) throw new NotFoundError('Comentario no encontrado.')
    if (parent.parentId !== null) throw new BadRequestError('No se puede responder a una respuesta.')
    const row = await ForumCommentDAO.create({ userId, content: content.trim(), parentId })
    const model = new ForumComment(
      row.id, row.userId, row.content, row.parentId,
      row.createdAt, row.updatedAt, row.deletedAt,
    )
    const author = await getAuthor(userId)
    return model.toPublic(author)
  }

  static async deleteComment(commentId: string, requesterId: string, requesterRole: UserRole) {
    const row = await ForumCommentDAO.findById(commentId)
    if (!row) throw new NotFoundError('Comentario no encontrado.')
    if (row.deletedAt) throw new NotFoundError('Comentario no encontrado.')
    if (requesterRole !== 'admin' && row.userId !== requesterId)
      throw new ForbiddenError('No tienes permiso para eliminar este comentario.')
    await ForumCommentDAO.softDelete(commentId)
  }
}
