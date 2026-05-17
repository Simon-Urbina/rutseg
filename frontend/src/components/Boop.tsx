import { useState, useEffect } from 'react'
import type { CSSProperties, ReactNode } from 'react'

interface BoopConfig {
  rotation?: number
  scale?: number
  timing?: number
}

function useBoop({ rotation = 12, scale = 1.12, timing = 150 }: BoopConfig = {}) {
  const [isBooping, setIsBooping] = useState(false)

  useEffect(() => {
    if (!isBooping) return
    const timer = setTimeout(() => setIsBooping(false), timing)
    return () => clearTimeout(timer)
  }, [isBooping, timing])

  const style: CSSProperties = {
    display: 'inline-block',
    transform: isBooping
      ? `rotate(${rotation}deg) scale(${scale})`
      : 'rotate(0deg) scale(1)',
    transition: isBooping
      ? `transform ${timing}ms`
      : 'transform 300ms cubic-bezier(0.34, 1.56, 0.64, 1)',
  }

  return { style, trigger: () => setIsBooping(true) }
}

export function Boop({ children, ...config }: BoopConfig & { children: ReactNode }) {
  const { style, trigger } = useBoop(config)
  return (
    <span style={style} onMouseEnter={trigger}>
      {children}
    </span>
  )
}
