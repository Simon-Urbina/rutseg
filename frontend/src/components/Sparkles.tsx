import { useState, useEffect, useRef } from 'react'
import type { CSSProperties, ReactNode } from 'react'

const COLORS = ['#F5C500', '#2596be', '#C8D5EE', '#ffffff']
const LIFETIME_MS = 700

interface Sparkle {
  id: string
  createdAt: number
  color: string
  size: number
  style: CSSProperties
}

function random(min: number, max: number): number {
  return Math.floor(Math.random() * (max - min)) + min
}

function generateSparkle(): Sparkle {
  return {
    id: Math.random().toString(36).slice(2),
    createdAt: Date.now(),
    color: COLORS[random(0, COLORS.length)],
    size: random(10, 20),
    style: {
      position: 'absolute',
      top: `${random(-20, 80)}%`,
      left: `${random(-10, 110)}%`,
      zIndex: 2,
      pointerEvents: 'none',
    },
  }
}

function useRandomInterval(
  callback: () => void,
  minDelay: number | null,
  maxDelay: number | null
) {
  const callbackRef = useRef(callback)
  callbackRef.current = callback

  useEffect(() => {
    if (minDelay === null || maxDelay === null) return

    let timeoutId: ReturnType<typeof setTimeout> | undefined

    const tick = () => {
      callbackRef.current()
      timeoutId = setTimeout(tick, random(minDelay, maxDelay))
    }

    timeoutId = setTimeout(tick, random(minDelay, maxDelay))
    return () => {
      if (timeoutId !== undefined) clearTimeout(timeoutId)
    }
  }, [minDelay, maxDelay])
}

function SparkleInstance({ color, size, style }: Pick<Sparkle, 'color' | 'size' | 'style'>) {
  return (
    <span style={style}>
      <svg
        width={size}
        height={size}
        viewBox="0 0 160 160"
        fill="none"
        className="sparkle-instance"
      >
        <path
          d="M80 0 C83 40 120 77 160 80 C120 83 83 120 80 160 C77 120 40 83 0 80 C40 77 77 40 80 0 Z"
          fill={color}
        />
      </svg>
    </span>
  )
}

interface SparklesProps {
  active?: boolean
  children: ReactNode
}

export function Sparkles({ active = true, children }: SparklesProps) {
  const [sparkles, setSparkles] = useState<Sparkle[]>([])

  useRandomInterval(
    () => {
      const now = Date.now()
      setSparkles(prev =>
        prev.filter(s => now - s.createdAt < LIFETIME_MS).concat(generateSparkle())
      )
    },
    active ? 50 : null,
    active ? 450 : null
  )

  return (
    <span style={{ position: 'relative', display: 'inline-block' }}>
      {sparkles.map(({ id, color, size, style }) => (
        <SparkleInstance key={id} color={color} size={size} style={style} />
      ))}
      <span style={{ position: 'relative', zIndex: 1 }}>
        {children}
      </span>
    </span>
  )
}
