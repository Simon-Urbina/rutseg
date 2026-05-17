export function LogoIcon({ className = 'w-8 h-8' }: { className?: string }) {
  return (
    <svg viewBox="0 0 44 44" fill="none" xmlns="http://www.w3.org/2000/svg" className={className}>
      <path
        d="M22 2L4 9.5V21C4 31.8 12.2 41.8 22 44C31.8 41.8 40 31.8 40 21V9.5L22 2Z"
        fill="#0A1545"
        stroke="#1A3F96"
        strokeWidth="1.5"
        strokeLinejoin="round"
      />
      <path
        d="M22 6.5L8 13V21C8 29.8 14.4 38 22 40.5C29.6 38 36 29.8 36 21V13L22 6.5Z"
        fill="#060D1F"
      />
      <path d="M16 18L12 23L16 28" stroke="#2596be" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
      <path d="M28 18L32 23L28 28" stroke="#1A3F96" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
      <path d="M20 29.5L24 16.5" stroke="#F5C500" strokeWidth="1.75" strokeLinecap="round"/>
    </svg>
  )
}

import { Boop } from './Boop'

export function LogoWordmark({ isDark = true }: { isDark?: boolean }) {
  return (
    <div className="flex items-center gap-2.5">
      <Boop rotation={12} scale={1.12}>
        <LogoIcon />
      </Boop>
      <div className="flex flex-col leading-none gap-1.5">
        <span
          className="font-display text-[17px] tracking-tight leading-none"
          style={{ color: isDark ? '#EEF3FC' : '#0A1545' }}
        >
          RutSeg
        </span>
        <span
          className="font-mono text-[9px] tracking-[0.2em] uppercase leading-none"
          style={{ color: isDark ? '#3A5AB8' : '#1535A0' }}
        >
          ruta · segura
        </span>
      </div>
    </div>
  )
}
