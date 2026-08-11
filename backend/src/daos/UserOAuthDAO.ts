import sql from '../db/index.js'
import type { OAuthProviderName, User } from '../types.js'

export class UserOAuthDAO {
  /** Busca el usuario ya vinculado a esta identidad externa (provider + providerUserId). */
  static async findUserByProvider(provider: OAuthProviderName, providerUserId: string): Promise<User | null> {
    const [row] = await sql<User[]>`
      SELECT u.* FROM users u
      JOIN user_oauth_accounts oa ON oa.user_id = u.id
      WHERE oa.provider = ${provider}
        AND oa.provider_user_id = ${providerUserId}
        AND u.deleted_at IS NULL
    `
    return row ?? null
  }

  /** Vincula una identidad externa a un usuario existente. Idempotente si ya estaba vinculada. */
  static async link(userId: string, provider: OAuthProviderName, providerUserId: string): Promise<void> {
    await sql`
      INSERT INTO user_oauth_accounts (user_id, provider, provider_user_id)
      VALUES (${userId}, ${provider}, ${providerUserId})
      ON CONFLICT (user_id, provider) DO NOTHING
    `
  }
}
