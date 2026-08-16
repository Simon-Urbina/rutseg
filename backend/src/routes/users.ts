import { Hono } from 'hono'
import { UserController } from '../controllers/UserController.js'
import { requireAuth } from '../middleware/auth.js'

const router = new Hono()

router.get('/me', requireAuth, UserController.getMyProfile)
router.put('/me', requireAuth, UserController.updateProfile)
router.post('/me/password', requireAuth, UserController.changePassword)
router.post('/me/link-google', requireAuth, UserController.linkGoogle)
router.post('/me/avatar', requireAuth, UserController.updateAvatar)
router.get('/:username', UserController.getPublicProfile)

export default router
