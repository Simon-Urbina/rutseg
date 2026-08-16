import { motion, AnimatePresence } from 'motion/react'
import { useTheme } from '../context/ThemeContext'

export interface ContinuousPaginationProps {
  currentPage: number
  totalPages: number
  onPageChange: (page: number) => void
}

function ChevronIcon({ direction }: { direction: 'left' | 'right' }) {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
      <polyline points={direction === 'left' ? '15 18 9 12 15 6' : '9 18 15 12 9 6'} />
    </svg>
  )
}

function NavButton({ children, onClick, disabled, isDark }: {
  children: React.ReactNode
  onClick: () => void
  disabled: boolean
  isDark: boolean
}) {
  return (
    <motion.button
      onClick={onClick}
      disabled={disabled}
      className="h-9 w-9 sm:h-11 sm:w-11 rounded-lg sm:rounded-xl flex items-center justify-center border disabled:opacity-30 disabled:cursor-not-allowed"
      style={{
        borderColor: isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.22)',
        background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff',
        color: isDark ? '#7B9FE8' : '#1A3F96',
      }}
      whileHover={disabled ? {} : { scale: 1.08, y: -3 }}
      whileTap={disabled ? {} : { scale: 0.92 }}
      transition={{ type: 'spring', stiffness: 400, damping: 20 }}
    >
      {children}
    </motion.button>
  )
}

export function ContinuousPagination({ currentPage, totalPages, onPageChange }: ContinuousPaginationProps) {
  const { theme } = useTheme()
  const isDark = theme === 'dark'

  const goTo = (page: number) => {
    if (page < 1 || page > totalPages || page === currentPage) return
    onPageChange(page)
  }

  return (
    <div className="flex items-center justify-center gap-1.5 sm:gap-2.5">
      <NavButton onClick={() => goTo(currentPage - 1)} disabled={currentPage <= 1} isDark={isDark}>
        <ChevronIcon direction="left" />
      </NavButton>

      <div className="relative flex gap-1.5 sm:gap-2.5">
        {Array.from({ length: totalPages }).map((_, i) => {
          const page = i + 1
          const isActive = page === currentPage

          return (
            <motion.button
              key={page}
              onClick={() => goTo(page)}
              className="relative z-10 h-9 w-9 sm:h-11 sm:w-11 rounded-lg sm:rounded-xl flex items-center justify-center border overflow-hidden"
              style={{
                borderColor: isActive
                  ? 'transparent'
                  : isDark ? 'rgba(26,63,150,0.30)' : 'rgba(26,63,150,0.22)',
                background: isActive ? undefined : isDark ? 'rgba(13,27,70,0.85)' : '#f8faff',
                color: isActive ? '#fff' : isDark ? '#7B9FE8' : '#1A3F96',
              }}
              whileHover={isActive ? {} : { y: -3 }}
              whileTap={{ scale: 0.92 }}
              transition={{ type: 'spring', stiffness: 320, damping: 20 }}
            >
              <AnimatePresence>
                {isActive && (
                  <motion.div
                    layoutId="pagination-active-bg"
                    className="absolute inset-0"
                    style={{
                      background: 'linear-gradient(110deg, #1A3F96 0%, #2451C8 45%, #1A3F96 55%, #0F2A6B 100%)',
                    }}
                    initial={{ opacity: 0 }}
                    animate={{ opacity: 1 }}
                    exit={{ opacity: 0 }}
                    transition={{ type: 'spring', stiffness: 260, damping: 24 }}
                  />
                )}
              </AnimatePresence>
              <span className="num-display relative z-10 text-sm sm:text-base">{page}</span>
            </motion.button>
          )
        })}
      </div>

      <NavButton onClick={() => goTo(currentPage + 1)} disabled={currentPage >= totalPages} isDark={isDark}>
        <ChevronIcon direction="right" />
      </NavButton>
    </div>
  )
}
