import { useState, type ReactNode } from 'react'
import { motion, AnimatePresence } from 'motion/react'
import { useTheme } from '../context/ThemeContext'

export interface FeatureCarouselCard {
  id: string
  title: string
  kicker: string
  body: string
  icon: ReactNode
  accent: string
}

function CardChrome({ isDark, accent, children }: { isDark: boolean; accent: string; children: ReactNode }) {
  return (
    <div
      className="hud-panel h-full"
      style={{
        background: isDark ? 'rgba(13,27,70,0.85)' : '#f8faff',
        '--hud-border': `${accent}40`,
        '--hud-border-hover': accent,
        '--hud-focus': accent,
      } as React.CSSProperties}
    >
      {children}
    </div>
  )
}

function IconBadge({ isDark, accent, icon, compact = false }: { isDark: boolean; accent: string; icon: ReactNode; compact?: boolean }) {
  return (
    <div
      className="rounded-xl flex items-center justify-center shrink-0"
      style={{
        width: compact ? 36 : 48,
        height: compact ? 36 : 48,
        background: isDark ? `${accent}26` : `${accent}14`,
        border: `1px solid ${accent}40`,
        color: accent,
      }}
    >
      {icon}
    </div>
  )
}

export function FeatureCarousel({ cards }: { cards: FeatureCarouselCard[] }) {
  const { theme } = useTheme()
  const isDark = theme === 'dark'
  const [activeId, setActiveId] = useState<string | null>(null)

  const activeCard = cards.find(c => c.id === activeId)
  const restCards = cards.filter(c => c.id !== activeId)

  const handleBackgroundClick = (e: React.MouseEvent) => {
    if (e.target === e.currentTarget) setActiveId(null)
  }

  return (
    <div onClick={handleBackgroundClick}>
      <motion.div layout className="flex flex-col gap-4">
        <AnimatePresence mode="popLayout">
          {activeCard && (
            <motion.div
              key={activeCard.id}
              layoutId={activeCard.id}
              onClick={() => setActiveId(null)}
              className="cursor-pointer"
              transition={{ type: 'spring', bounce: 0.2, duration: 0.5 }}
            >
              <CardChrome isDark={isDark} accent={activeCard.accent}>
                <div className="p-7 sm:p-8 flex flex-col justify-between h-full min-h-[220px]">
                  <div className="flex items-center justify-between mb-6">
                    <IconBadge isDark={isDark} accent={activeCard.accent} icon={activeCard.icon} />
                    <span
                      className="font-mono text-[10px] tracking-[0.18em] uppercase px-3 py-1 rounded border font-semibold"
                      style={{ color: activeCard.accent, background: `${activeCard.accent}10`, borderColor: `${activeCard.accent}30` }}
                    >
                      {activeCard.kicker}
                    </span>
                  </div>
                  <div>
                    <h3 className="font-display text-2xl font-bold mb-3" style={{ color: isDark ? '#EEF3FC' : '#0A1545' }}>
                      {activeCard.title}
                    </h3>
                    <p className="text-sm font-light leading-relaxed" style={{ color: isDark ? '#7B9FE8' : '#2451C8' }}>
                      {activeCard.body}
                    </p>
                  </div>
                </div>
              </CardChrome>
            </motion.div>
          )}
        </AnimatePresence>

        <motion.div layout className="grid grid-cols-2 sm:grid-cols-4 gap-3 sm:gap-4">
          {(activeId ? restCards : cards).map(card => (
            <motion.div
              key={card.id}
              layoutId={card.id}
              onClick={e => { e.stopPropagation(); setActiveId(card.id) }}
              transition={{ type: 'spring', bounce: 0.2, duration: 0.5 }}
              className="cursor-pointer"
              whileHover={{ y: -4 }}
            >
              <CardChrome isDark={isDark} accent={card.accent}>
                <div className="p-4 sm:p-5 flex flex-col gap-3 h-full min-h-[104px] sm:min-h-[120px]">
                  <IconBadge isDark={isDark} accent={card.accent} icon={card.icon} compact />
                  <h4 className="font-display text-sm sm:text-base font-bold leading-tight" style={{ color: isDark ? '#EEF3FC' : '#0A1545' }}>
                    {card.title}
                  </h4>
                </div>
              </CardChrome>
            </motion.div>
          ))}
        </motion.div>
      </motion.div>
    </div>
  )
}
