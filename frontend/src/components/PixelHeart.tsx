// Corazón en pixel art (11×10). Cada carácter es un píxel:
// '.' vacío · 'r' rojo/rosado · 'h' brillo · 's' sombra
const PIXELS = [
  '..rr...rr..',
  '.rhhr.rrrr.',
  'rhhrrrrrrrr',
  'rhrrrrrrrrr',
  'rrrrrrrrrrs',
  '.rrrrrrrrs.',
  '..rrrrrrs..',
  '...rrrrs...',
  '....rrs....',
  '.....s.....',
]

const COLORS: Record<string, string> = {
  r: '#FF3D6E',
  h: '#FFB3C8',
  s: '#C21E4E',
}

export default function PixelHeart({ size = 96, beat = false }: { size?: number; beat?: boolean }) {
  const cols = PIXELS[0].length
  const rows = PIXELS.length
  return (
    <svg
      width={size}
      height={(size * rows) / cols}
      viewBox={`0 0 ${cols} ${rows}`}
      shapeRendering="crispEdges"
      aria-hidden="true"
      className={beat ? 'pixel-heart-beat' : undefined}
      style={{ filter: 'drop-shadow(0 0 12px rgba(255,61,110,0.35))' }}
    >
      {PIXELS.flatMap((row, y) =>
        [...row].map((ch, x) =>
          ch === '.' ? null : <rect key={`${x}-${y}`} x={x} y={y} width={1} height={1} fill={COLORS[ch]} />,
        ),
      )}
    </svg>
  )
}
