import {
  type CourseFilterState,
  hasActiveCourseFilters,
  emptyCourseFilters,
  DIFFICULTY_OPTIONS,
  LAB_OPTIONS,
  POINTS_OPTIONS,
} from '../lib/courseFilters'

function FilterCheckbox({
  checked, label, onToggle, isDark,
}: { checked: boolean; label: string; onToggle: () => void; isDark: boolean }) {
  return (
    <button
      type="button"
      role="checkbox"
      aria-checked={checked}
      onClick={onToggle}
      className="flex items-center gap-2 transition-colors"
    >
      <span
        className="w-4 h-4 shrink-0 rounded flex items-center justify-center transition-all"
        style={{
          background: checked ? '#1A3F96' : 'transparent',
          border: `1.5px solid ${checked ? '#1A3F96' : isDark ? 'rgba(26,63,150,0.45)' : 'rgba(26,63,150,0.40)'}`,
        }}
      >
        {checked && (
          <svg width="9" height="9" viewBox="0 0 12 12" fill="none">
            <path d="M2 6L5 9L10 3" stroke="white" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        )}
      </span>
      <span className="font-mono text-[12px]" style={{ color: isDark ? '#C8D5EE' : '#0A1545' }}>
        {label}
      </span>
    </button>
  )
}

function FilterGroup({
  label, children,
}: { label: string; children: React.ReactNode }) {
  return (
    <div className="flex items-center gap-4 flex-wrap">
      <span className="font-mono text-[10px] tracking-[0.16em] uppercase shrink-0 w-24" style={{ color: '#4A70CC' }}>
        {label}
      </span>
      <div className="flex items-center gap-5 flex-wrap">{children}</div>
    </div>
  )
}

export function CourseFilterPanel({
  filters, onChange, isDark,
}: { filters: CourseFilterState; onChange: (f: CourseFilterState) => void; isDark: boolean }) {
  function toggle<T>(set: Set<T>, value: T): Set<T> {
    const next = new Set(set)
    if (next.has(value)) next.delete(value)
    else next.add(value)
    return next
  }

  return (
    <div
      className="hud-panel p-4 space-y-3"
      style={{ background: isDark ? 'rgba(13,27,70,0.85)' : '#FFFFFF' }}
    >
      <FilterGroup label="Dificultad">
        {DIFFICULTY_OPTIONS.map(opt => (
          <FilterCheckbox
            key={opt.value}
            label={opt.label}
            isDark={isDark}
            checked={filters.difficulties.has(opt.value)}
            onToggle={() => onChange({ ...filters, difficulties: toggle(filters.difficulties, opt.value) })}
          />
        ))}
      </FilterGroup>

      <FilterGroup label="Laboratorios">
        {LAB_OPTIONS.map(opt => (
          <FilterCheckbox
            key={opt.value}
            label={opt.label}
            isDark={isDark}
            checked={filters.labBuckets.has(opt.value)}
            onToggle={() => onChange({ ...filters, labBuckets: toggle(filters.labBuckets, opt.value) })}
          />
        ))}
      </FilterGroup>

      <FilterGroup label="Puntos">
        {POINTS_OPTIONS.map(opt => (
          <FilterCheckbox
            key={opt.value}
            label={opt.label}
            isDark={isDark}
            checked={filters.pointsBuckets.has(opt.value)}
            onToggle={() => onChange({ ...filters, pointsBuckets: toggle(filters.pointsBuckets, opt.value) })}
          />
        ))}
      </FilterGroup>

      {hasActiveCourseFilters(filters) && (
        <button
          onClick={() => onChange(emptyCourseFilters())}
          className="font-mono text-[11px] uppercase tracking-[0.14em] transition-colors"
          style={{ color: isDark ? '#7B9FE8' : '#1A3F96' }}
        >
          Limpiar filtros
        </button>
      )}
    </div>
  )
}
