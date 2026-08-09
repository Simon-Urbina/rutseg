import sql from '../db/index.js'
import type { User } from '../types.js'

export class UserDAO {
  static async findById(id: string): Promise<User | null> {
    const [row] = await sql<User[]>`
      SELECT * FROM users WHERE id = ${id} AND deleted_at IS NULL
    `
    return row ?? null
  }

  static async findByEmail(email: string): Promise<User | null> {
    const [row] = await sql<User[]>`
      SELECT * FROM users WHERE email = ${email} AND deleted_at IS NULL
    `
    return row ?? null
  }

  static async findByUsername(username: string): Promise<User | null> {
    const [row] = await sql<User[]>`
      SELECT * FROM users WHERE username = ${username} AND deleted_at IS NULL
    `
    return row ?? null
  }

  static async create(data: {
    username: string
    email: string
    passwordHash: string
    privacyAcceptedAt?: Date | null
    privacyPolicyVersion?: string | null
  }): Promise<User> {
    const [row] = await sql<User[]>`
      INSERT INTO users (username, email, password_hash, privacy_accepted_at, privacy_policy_version)
      VALUES (
        ${data.username},
        ${data.email},
        ${data.passwordHash},
        ${data.privacyAcceptedAt ?? null},
        ${data.privacyPolicyVersion ?? null}
      )
      RETURNING *
    `
    return row
  }

  static async update(
    id: string,
    data: { username?: string; email?: string; bio?: string | null; role?: 'user' | 'admin' },
  ): Promise<User | null> {
    const updates: Record<string, string | null> = {}
    if (data.username !== undefined) updates.username = data.username
    if (data.email !== undefined) updates.email = data.email
    if (data.bio !== undefined) updates.bio = data.bio
    if (data.role !== undefined) updates.role = data.role

    if (Object.keys(updates).length === 0) return UserDAO.findById(id)

    const [row] = await sql<User[]>`
      UPDATE users SET ${sql(updates)}
      WHERE id = ${id} AND deleted_at IS NULL
      RETURNING *
    `
    return row ?? null
  }

  static async updatePassword(id: string, passwordHash: string): Promise<void> {
    await sql`
      UPDATE users SET password_hash = ${passwordHash}
      WHERE id = ${id} AND deleted_at IS NULL
    `
  }

  static async updateAvatar(id: string, image: Buffer): Promise<User | null> {
    const [row] = await sql<User[]>`
      UPDATE users SET profile_image = ${image}
      WHERE id = ${id} AND deleted_at IS NULL
      RETURNING *
    `
    return row ?? null
  }

  static async softDelete(id: string): Promise<void> {
    await sql`UPDATE users SET deleted_at = now() WHERE id = ${id}`
  }

  static async findRanking(limit = 20, offset = 0): Promise<User[]> {
    return sql<User[]>`
      SELECT * FROM users
      WHERE deleted_at IS NULL
      ORDER BY points DESC, username ASC
      LIMIT ${limit} OFFSET ${offset}
    `
  }

  static async countRanking(): Promise<number> {
    const [{ count }] = await sql<[{ count: string }]>`
      SELECT COUNT(*) AS count FROM users WHERE deleted_at IS NULL
    `
    return Number(count)
  }

  static async findAllAdmin({ limit = 20, offset = 0, search }: { limit?: number; offset?: number; search?: string } = {}): Promise<User[]> {
    const pattern = search ? `%${search}%` : null
    return sql<User[]>`
      SELECT * FROM users
      WHERE deleted_at IS NULL
      ${pattern ? sql`AND (username ILIKE ${pattern} OR email ILIKE ${pattern})` : sql``}
      ORDER BY created_at DESC
      LIMIT ${limit} OFFSET ${offset}
    `
  }

  static async countAllAdmin({ search }: { search?: string } = {}): Promise<number> {
    const pattern = search ? `%${search}%` : null
    const [{ count }] = await sql<[{ count: string }]>`
      SELECT COUNT(*) AS count FROM users
      WHERE deleted_at IS NULL
      ${pattern ? sql`AND (username ILIKE ${pattern} OR email ILIKE ${pattern})` : sql``}
    `
    return Number(count)
  }

  static async getRank(userId: string): Promise<number | null> {
    const [row] = await sql<[{ rank: string }]>`
      SELECT rank FROM (
        SELECT id, ROW_NUMBER() OVER (ORDER BY points DESC, username ASC) AS rank
        FROM users WHERE deleted_at IS NULL
      ) ranked
      WHERE id = ${userId}
    `
    return row ? Number(row.rank) : null
  }

  static async countCompletedLabs(userId: string): Promise<number> {
    const [{ count }] = await sql<[{ count: string }]>`
      SELECT COUNT(*) AS count FROM user_laboratory_progress
      WHERE user_id = ${userId} AND status = 'completed'
    `
    return Number(count)
  }
}
