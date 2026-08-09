import { BrowserRouter, Routes, Route, Navigate, useLocation } from 'react-router-dom'
import { useEffect } from 'react'
import { ToastProvider } from './context/ToastContext'
import { ThemeProvider, useTheme } from './context/ThemeContext'
import { AuthProvider, useAuth } from './context/AuthContext'
import Header from './components/Header'
import LandingPage from './pages/LandingPage'
import LoginPage from './pages/LoginPage'
import RegisterPage from './pages/RegisterPage'
import ForgotPasswordPage from './pages/ForgotPasswordPage'
import ResetPasswordPage from './pages/ResetPasswordPage'
import DashboardPage from './pages/DashboardPage'
import CoursePage from './pages/CoursePage'
import LabPage from './pages/LabPage'
import PublicProfilePage from './pages/PublicProfilePage'
import AboutPage from './pages/AboutPage'
import PrivacyPolicyPage from './pages/PrivacyPolicyPage'
import TermsOfUsePage from './pages/TermsOfUsePage'
import ForumPage from './pages/ForumPage'
import NotFoundPage from './pages/NotFoundPage'
import ChatWidget from './components/ChatWidget'
import CookieBanner from './components/CookieBanner'
import AdminDashboardPage from './pages/admin/AdminDashboardPage'
import AdminCoursesPage from './pages/admin/AdminCoursesPage'
import AdminCourseDetailPage from './pages/admin/AdminCourseDetailPage'
import AdminModuleDetailPage from './pages/admin/AdminModuleDetailPage'
import AdminLabEditorPage from './pages/admin/AdminLabEditorPage'
import AdminUsersPage from './pages/admin/AdminUsersPage'
import AdminUserDetailPage from './pages/admin/AdminUserDetailPage'

function ScrollToTop() {
  const { pathname } = useLocation()
  useEffect(() => { window.scrollTo(0, 0) }, [pathname])
  return null
}

function PrivateRoute({ children }: { children: React.ReactNode }) {
  const { token } = useAuth()
  return token ? <>{children}</> : <Navigate to="/login" replace />
}

function PublicRoute({ children }: { children: React.ReactNode }) {
  const { token } = useAuth()
  return !token ? <>{children}</> : <Navigate to="/dashboard" replace />
}

function AdminRoute({ children }: { children: React.ReactNode }) {
  const { token, user } = useAuth()
  if (!token) return <Navigate to="/login" replace />
  return user?.role === 'admin' ? <>{children}</> : <Navigate to="/dashboard" replace />
}

function AppShell() {
  const { theme } = useTheme()
  const isDark = theme === 'dark'

  return (
    <div className="min-h-screen" style={{ background: isDark ? '#060D1F' : '#EEF3FC' }}>
      <ScrollToTop />
      <Routes>
        {/* Public landing */}
        <Route path="/" element={<LandingPage />} />

        {/* Auth pages — own layout, no header */}
        <Route path="/login" element={<PublicRoute><LoginPage /></PublicRoute>} />
        <Route path="/register" element={<PublicRoute><RegisterPage /></PublicRoute>} />
        <Route path="/forgot-password" element={<ForgotPasswordPage />} />
        <Route path="/reset-password" element={<ResetPasswordPage />} />

        {/* App pages — header + content */}
        <Route path="/dashboard" element={
          <PrivateRoute>
            <>
              <Header />
              <DashboardPage />
            </>
          </PrivateRoute>
        } />

        {/* Course navigation */}
        <Route path="/courses/:slug" element={
          <PrivateRoute>
            <CoursePage />
          </PrivateRoute>
        } />

        {/* Lab page */}
        <Route path="/courses/:slug/:moduleSlug/:labSlug" element={
          <PrivateRoute>
            <LabPage />
          </PrivateRoute>
        } />

        {/* Admin panel */}
        <Route path="/admin" element={<AdminRoute><AdminDashboardPage /></AdminRoute>} />
        <Route path="/admin/courses" element={<AdminRoute><AdminCoursesPage /></AdminRoute>} />
        <Route path="/admin/courses/:courseSlug" element={<AdminRoute><AdminCourseDetailPage /></AdminRoute>} />
        <Route path="/admin/courses/:courseSlug/:moduleSlug" element={<AdminRoute><AdminModuleDetailPage /></AdminRoute>} />
        <Route path="/admin/courses/:courseSlug/:moduleSlug/:labSlug" element={<AdminRoute><AdminLabEditorPage /></AdminRoute>} />
        <Route path="/admin/users" element={<AdminRoute><AdminUsersPage /></AdminRoute>} />
        <Route path="/admin/users/:id" element={<AdminRoute><AdminUserDetailPage /></AdminRoute>} />

        {/* Public user profiles */}
        <Route path="/u/:username" element={<PublicProfilePage />} />

        {/* About page */}
        <Route path="/about" element={<AboutPage />} />

        {/* Forum */}
        <Route path="/forum" element={<ForumPage />} />

        {/* Privacy policy */}
        <Route path="/privacy-policy" element={<PrivacyPolicyPage />} />

        {/* Terms of use */}
        <Route path="/terms-of-use" element={<TermsOfUsePage />} />

        {/* 404 */}
        <Route path="*" element={<NotFoundPage />} />
      </Routes>
      <ChatWidget />
      <CookieBanner />
    </div>
  )
}

export default function App() {
  return (
    <BrowserRouter>
      <ThemeProvider>
        <AuthProvider>
          <ToastProvider>
            <AppShell />
          </ToastProvider>
        </AuthProvider>
      </ThemeProvider>
    </BrowserRouter>
  )
}
