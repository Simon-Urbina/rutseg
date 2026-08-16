import { forwardRef } from 'react'

interface Props {
  isDark: boolean
}

// Fondo decorativo del hero: grilla técnica + un brillo radial cuyo centro
// se mueve con el cursor. El centro se controla vía las custom properties
// --x/--y, actualizadas directamente sobre el DOM (ver LandingPage) para no
// disparar un re-render de React en cada pointermove.
const HeroSpotlight = forwardRef<HTMLDivElement, Props>(function HeroSpotlight({ isDark }, ref) {
  return (
    <div className="absolute inset-0 overflow-hidden" style={{ pointerEvents: 'none' }} aria-hidden="true">
      <div
        className="absolute inset-0"
        style={{
          backgroundImage:
            'linear-gradient(to right, rgba(26,63,150,0.12) 1px, transparent 1px), linear-gradient(to bottom, rgba(26,63,150,0.12) 1px, transparent 1px)',
          backgroundSize: '32px 32px',
        }}
      />
      <div
        ref={ref}
        className="absolute inset-0"
        style={{
          background: isDark
            ? 'radial-gradient(500px circle at var(--x, 50%) var(--y, 50%), rgba(245,197,0,0.16), rgba(37,150,190,0.07) 40%, transparent 70%)'
            : 'radial-gradient(500px circle at var(--x, 50%) var(--y, 50%), rgba(26,63,150,0.30), rgba(26,63,150,0.10) 45%, transparent 70%)',
        }}
      />
    </div>
  )
})

export default HeroSpotlight
