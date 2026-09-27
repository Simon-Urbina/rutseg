import { Hono } from 'hono'
import { DonationController } from '../controllers/DonationController.js'

const router = new Hono()

// Públicos a propósito — cualquiera puede donar sin tener cuenta.
router.post('/checkout', DonationController.checkout)
router.get('/status/:id', DonationController.status)

export default router
