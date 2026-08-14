import { Hono } from 'hono'
import { CourseController } from '../controllers/CourseController.js'
import { requireAuth, optionalAuth } from '../middleware/auth.js'

const router = new Hono()

router.get('/', optionalAuth, CourseController.listCourses)
router.get('/:slug', optionalAuth, CourseController.getCourse)
router.get('/:slug/nav', CourseController.getCourseNav)
router.post('/:slug/enroll', requireAuth, CourseController.enroll)
router.get('/:slug/certificate', requireAuth, CourseController.getCertificate)
router.get('/:slug/modules', CourseController.getModules)
router.get('/:slug/modules/:moduleSlug/labs', optionalAuth, CourseController.getLaboratories)
router.get('/:slug/modules/:moduleSlug/labs/:labSlug', requireAuth, CourseController.getLaboratory)

export default router
