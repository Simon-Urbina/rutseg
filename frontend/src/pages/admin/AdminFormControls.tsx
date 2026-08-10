import type { ChangeEvent } from 'react'

interface FieldProps {
  label: string
  isDark: boolean
  hint?: string
}

export function AdminInput({
  label, value, onChange, isDark, placeholder, hint, type = 'text',
}: FieldProps & { value: string; onChange: (v: string) => void; placeholder?: string; type?: string }) {
  return (
    <div className="space-y-1.5">
      <label className="block font-mono text-[10px] tracking-[0.18em] uppercase" style={{ color: isDark ? '#7B9FE8' : '#1A3F96' }}>
        {label}
      </label>
      <input
        type={type}
        value={value}
        onChange={(e: ChangeEvent<HTMLInputElement>) => onChange(e.target.value)}
        placeholder={placeholder}
        className="tech-input w-full px-4 py-2.5 text-[14px]"
        style={{
          background: isDark ? 'rgba(6,13,31,0.5)' : '#ffffff',
          color: isDark ? '#C8D5EE' : '#0A1545',
        }}
      />
      {hint && <p className="text-[12px]" style={{ color: '#4A70CC' }}>{hint}</p>}
    </div>
  )
}

export function AdminTextarea({
  label, value, onChange, isDark, placeholder, hint, rows = 6, mono = false,
}: FieldProps & { value: string; onChange: (v: string) => void; placeholder?: string; rows?: number; mono?: boolean }) {
  return (
    <div className="space-y-1.5">
      <label className="block font-mono text-[10px] tracking-[0.18em] uppercase" style={{ color: isDark ? '#7B9FE8' : '#1A3F96' }}>
        {label}
      </label>
      {hint && <p className="text-[12px] mb-1" style={{ color: '#4A70CC' }}>{hint}</p>}
      <textarea
        value={value}
        onChange={e => onChange(e.target.value)}
        placeholder={placeholder}
        rows={rows}
        className={`tech-input w-full px-4 py-3 text-[14px] resize-y ${mono ? 'font-mono' : ''}`}
        style={{
          background: isDark ? 'rgba(6,13,31,0.5)' : '#ffffff',
          color: isDark ? '#C8D5EE' : '#0A1545',
        }}
      />
    </div>
  )
}

export function AdminSelect({
  label, value, onChange, isDark, options,
}: FieldProps & { value: string; onChange: (v: string) => void; options: { value: string; label: string }[] }) {
  return (
    <div className="space-y-1.5">
      <label className="block font-mono text-[10px] tracking-[0.18em] uppercase" style={{ color: isDark ? '#7B9FE8' : '#1A3F96' }}>
        {label}
      </label>
      <select
        value={value}
        onChange={e => onChange(e.target.value)}
        className="tech-input w-full px-4 py-2.5 text-[14px]"
        style={{
          background: isDark ? 'rgba(6,13,31,0.5)' : '#ffffff',
          color: isDark ? '#C8D5EE' : '#0A1545',
        }}
      >
        {options.map(o => <option key={o.value} value={o.value}>{o.label}</option>)}
      </select>
    </div>
  )
}

export function ErrorBanner({ message, isDark }: { message: string; isDark: boolean }) {
  return (
    <div
      className="flex items-start gap-3 px-4 py-3 rounded-xl"
      style={{
        background: isDark ? 'rgba(6,13,31,0.6)' : '#eef0f8',
        border: '1px solid rgba(26,63,150,0.25)',
        borderLeft: '3px solid #1A3F96',
      }}
    >
      <span className="font-mono text-xs mt-0.5" style={{ color: '#1A3F96' }}>ERR</span>
      <p className="text-[14px]" style={{ color: isDark ? '#93B0F0' : '#0A1545' }}>{message}</p>
    </div>
  )
}
