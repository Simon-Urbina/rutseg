import { Hono } from 'hono'
import { CertificateController } from '../controllers/CertificateController.js'

const router = new Hono()

// Endpoint público a propósito — cualquiera debe poder verificar un certificado sin sesión.
router.get('/verify', CertificateController.verify)

export default router
