/* Gurufuri — theme + shared UI components.
   Built natively on NobleLedger tokens (emerald/indigo/slate, Inter).
   Exports: useTheme, GFBadge, Photo, Stars, PriceMark, WardChips,
            TabBar, TopBar, ActionSheet, Segmented */

const ACCENTS = {
  emerald: { 700: '#047857', 800: '#065f46', 600: '#059669', soft: 'rgba(5,150,105,0.12)', 50: '#ecfdf5' },
  indigo:  { 700: '#4338ca', 800: '#3730a3', 600: '#4f46e5', soft: 'rgba(79,70,229,0.12)', 50: '#eef2ff' },
};

function useTheme(dark, accentKey) {
  const a = ACCENTS[accentKey] || ACCENTS.emerald;
  if (dark) {
    return {
      a, dark: true,
      bg: '#000000', group: '#0b0b0d', card: '#1c1c1e', card2: '#2c2c2e',
      ink: '#f5f5f7', sub: 'rgba(235,235,245,0.62)', hint: 'rgba(235,235,245,0.38)',
      sep: 'rgba(255,255,255,0.10)', fill: 'rgba(118,118,128,0.24)',
      primary: a[600], primaryInk: a[600], onPrimary: '#ffffff', chipBg: 'rgba(255,255,255,0.08)',
    };
  }
  return {
    a, dark: false,
    bg: '#f2f2f7', group: '#f2f2f7', card: '#ffffff', card2: '#f7f7fa',
    ink: '#11141a', sub: '#6b7280', hint: '#9aa1ac',
    sep: 'rgba(60,60,67,0.12)', fill: 'rgba(118,118,128,0.10)',
    primary: a[700], primaryInk: a[700], onPrimary: '#ffffff', chipBg: '#ffffff',
  };
}

const SF = '-apple-system, "SF Pro Text", system-ui, sans-serif';

/* ---- GF status badge — three visual styles via tweak ---- */
function GFBadge({ status, lang, style = 'pill', size = 'md', th }) {
  const g = GF[status];
  if (!g) return null;
  const small = size === 'sm';
  const label = small ? t(g.short, lang) : t(g, lang);
  if (style === 'dot') {
    return (
      <span style={{ display: 'inline-flex', alignItems: 'center', gap: 6, fontFamily: SF,
        fontSize: small ? 11 : 12.5, fontWeight: 600, color: th ? th.ink : g.fg, whiteSpace: 'nowrap' }}>
        <span style={{ width: 8, height: 8, borderRadius: 9, background: g.dot, flexShrink: 0 }} />
        {label}
      </span>
    );
  }
  if (style === 'tag') {
    return (
      <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5, fontFamily: SF,
        fontSize: small ? 10.5 : 11.5, fontWeight: 700, letterSpacing: '0.02em',
        color: '#fff', background: g.dot, padding: small ? '3px 8px' : '4px 10px',
        borderRadius: 6, whiteSpace: 'nowrap' }}>
        <Icon name={g.icon} size={small ? 12 : 13} color="#fff" stroke={2} />
        {label}
      </span>
    );
  }
  // default: soft pill
  return (
    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5, fontFamily: SF,
      fontSize: small ? 11 : 12, fontWeight: 600, color: g.fg, background: g.bg,
      padding: small ? '3px 8px' : '5px 10px', borderRadius: 999, whiteSpace: 'nowrap' }}>
      <Icon name={g.icon} size={small ? 12 : 13.5} color={g.fg} stroke={2} />
      {label}
    </span>
  );
}

/* ---- Photo placeholder (warm gradient + faint dish glyph) ---- */
function Photo({ tint = ['#efe6d8', '#cdb592'], radius = 0, label, style }) {
  return (
    <div style={{ position: 'relative', borderRadius: radius, overflow: 'hidden',
      background: `linear-gradient(135deg, ${tint[0]} 0%, ${tint[1]} 100%)`, ...style }}>
      <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', opacity: 0.5 }}>
        <Icon name="leaf" size={28} color="rgba(255,255,255,0.85)" stroke={1.6} />
      </div>
      <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(160deg, rgba(255,255,255,0.18), rgba(0,0,0,0.06))' }} />
      {label && <span style={{ position: 'absolute', bottom: 6, right: 8, fontFamily: SF, fontSize: 9,
        fontWeight: 600, letterSpacing: '0.08em', color: 'rgba(255,255,255,0.85)', textTransform: 'uppercase' }}>{label}</span>}
    </div>
  );
}

function Stars({ rating, reviews, th, size = 12.5 }) {
  return (
    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4, fontFamily: SF, fontSize: size, fontWeight: 600, color: th.ink }}>
      <Icon name="star" size={size + 1} color="#f5a623" filled stroke={1.4} />
      {rating.toFixed(1)}
      {reviews != null && <span style={{ color: th.hint, fontWeight: 500 }}>({reviews})</span>}
    </span>
  );
}

function PriceMark({ level, th }) {
  return (
    <span style={{ fontFamily: SF, fontSize: 12.5, fontWeight: 600, color: th.sub, letterSpacing: '0.5px' }}>
      {'¥'.repeat(level)}<span style={{ color: th.hint }}>{'¥'.repeat(3 - level)}</span>
    </span>
  );
}

/* ---- ward filter chips ---- */
function WardChips({ wards, active, onPick, lang, th }) {
  return (
    <div style={{ display: 'flex', gap: 8, overflowX: 'auto', padding: '2px 16px 2px', WebkitOverflowScrolling: 'touch', scrollbarWidth: 'none' }}>
      {wards.map((w) => {
        const on = w.id === active;
        return (
          <button key={w.id} onClick={() => onPick(w.id)} style={{
            flexShrink: 0, fontFamily: SF, fontSize: 13.5, fontWeight: 600,
            padding: '7px 14px', borderRadius: 999, cursor: 'pointer',
            border: `1px solid ${on ? th.primary : th.sep}`,
            background: on ? th.primary : th.chipBg, color: on ? th.onPrimary : th.sub,
            transition: 'all .15s', whiteSpace: 'nowrap',
          }}>{t(w, lang)}</button>
        );
      })}
    </div>
  );
}

/* ---- bottom tab bar (Stores · Wishlist · Account) ---- */
function TabBar({ active, onTab, lang, th, wishCount }) {
  const tabs = [
    { id: 'stores', icon: 'search', ja: '探す', en: 'Explore' },
    { id: 'wishlist', icon: 'heart', ja: 'お気に入り', en: 'Saved', badge: wishCount },
    { id: 'account', icon: 'user', ja: 'アカウント', en: 'Account' },
  ];
  return (
    <div style={{ position: 'absolute', left: 0, right: 0, bottom: 0, zIndex: 40,
      paddingBottom: 22, background: th.dark ? 'rgba(20,20,22,0.82)' : 'rgba(255,255,255,0.82)',
      backdropFilter: 'saturate(180%) blur(20px)', WebkitBackdropFilter: 'saturate(180%) blur(20px)',
      borderTop: `0.5px solid ${th.sep}` }}>
      <div style={{ display: 'flex', alignItems: 'center', height: 50, padding: '0 12px' }}>
        {tabs.map((tb) => {
          const on = active === tb.id;
          const c = on ? th.primary : (th.dark ? 'rgba(235,235,245,0.5)' : 'rgba(60,60,67,0.45)');
          return (
            <button key={tb.id} onClick={() => onTab(tb.id)} style={{
              flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 3,
              background: 'none', border: 'none', cursor: 'pointer', position: 'relative' }}>
              <div style={{ position: 'relative' }}>
                <Icon name={tb.icon} size={25} color={c} filled={on && tb.icon === 'heart'} stroke={on ? 2 : 1.7} />
                {tb.badge ? <span style={{ position: 'absolute', top: -4, right: -8, minWidth: 15, height: 15,
                  padding: '0 4px', borderRadius: 9, background: '#ff3b30', color: '#fff', fontFamily: SF,
                  fontSize: 9.5, fontWeight: 700, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>{tb.badge}</span> : null}
              </div>
              <span style={{ fontFamily: SF, fontSize: 10, fontWeight: 600, color: c }}>{lang === 'ja' ? tb.ja : tb.en}</span>
            </button>
          );
        })}
      </div>
    </div>
  );
}

/* ---- translucent top bar with optional back + right slot ---- */
function TopBar({ title, sub, onBack, right, th, large }) {
  return (
    <div style={{ position: 'sticky', top: 0, zIndex: 30,
      background: th.dark ? 'rgba(20,20,22,0.8)' : 'rgba(242,242,247,0.8)',
      backdropFilter: 'saturate(180%) blur(20px)', WebkitBackdropFilter: 'saturate(180%) blur(20px)',
      borderBottom: `0.5px solid ${th.sep}` }}>
      <div style={{ height: 44 }} />
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '4px 12px 10px', minHeight: 40 }}>
        {onBack ? (
          <button onClick={onBack} style={{ display: 'flex', alignItems: 'center', gap: 1, background: 'none',
            border: 'none', cursor: 'pointer', color: th.primary, fontFamily: SF, fontSize: 16, fontWeight: 500, padding: '4px 4px 4px 0' }}>
            <Icon name="back" size={24} color={th.primary} stroke={2} />
          </button>
        ) : null}
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontFamily: SF, fontSize: large ? 22 : 17, fontWeight: large ? 800 : 700, color: th.ink,
            letterSpacing: '-0.01em', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{title}</div>
          {sub ? <div style={{ fontFamily: SF, fontSize: 12, color: th.sub, marginTop: 1 }}>{sub}</div> : null}
        </div>
        {right}
      </div>
    </div>
  );
}

/* ---- iOS-style bottom action sheet ---- */
function ActionSheet({ open, onClose, title, sub, actions, cancelLabel, th }) {
  if (!open) return null;
  return (
    <div onClick={onClose} style={{ position: 'absolute', inset: 0, zIndex: 80, display: 'flex',
      alignItems: 'flex-end', background: 'rgba(0,0,0,0.4)', animation: 'gfFade .2s ease' }}>
      <div onClick={(e) => e.stopPropagation()} style={{ width: '100%', padding: '0 8px 8px', animation: 'gfSlideUp .28s cubic-bezier(.2,.8,.2,1)' }}>
        <div style={{ background: th.dark ? 'rgba(44,44,46,0.96)' : 'rgba(255,255,255,0.96)', backdropFilter: 'blur(20px)',
          borderRadius: 14, overflow: 'hidden', marginBottom: 8 }}>
          {(title || sub) && (
            <div style={{ padding: '14px 16px 12px', textAlign: 'center', borderBottom: `0.5px solid ${th.sep}` }}>
              {title && <div style={{ fontFamily: SF, fontSize: 13, fontWeight: 600, color: th.sub }}>{title}</div>}
              {sub && <div style={{ fontFamily: SF, fontSize: 12, color: th.hint, marginTop: 2 }}>{sub}</div>}
            </div>
          )}
          {actions.map((act, i) => (
            <button key={i} onClick={() => { act.onClick?.(); onClose(); }} style={{
              width: '100%', padding: '16px', background: 'none', border: 'none', cursor: 'pointer',
              borderTop: i ? `0.5px solid ${th.sep}` : 'none', fontFamily: SF, fontSize: 18,
              fontWeight: act.bold ? 600 : 400, color: act.danger ? '#ff3b30' : th.primary,
              display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8 }}>
              {act.icon && <Icon name={act.icon} size={20} color={act.danger ? '#ff3b30' : th.primary} />}
              {act.label}
            </button>
          ))}
        </div>
        <button onClick={onClose} style={{ width: '100%', padding: '16px', background: th.dark ? 'rgba(44,44,46,0.96)' : '#fff',
          border: 'none', borderRadius: 14, cursor: 'pointer', fontFamily: SF, fontSize: 18, fontWeight: 600, color: th.primary }}>
          {cancelLabel}
        </button>
      </div>
    </div>
  );
}

/* ---- segmented control (used in layout switcher etc.) ---- */
function Segmented({ value, options, onChange, th }) {
  return (
    <div style={{ display: 'inline-flex', background: th.fill, borderRadius: 9, padding: 2, gap: 2 }}>
      {options.map((o) => {
        const on = o.id === value;
        return (
          <button key={o.id} onClick={() => onChange(o.id)} style={{
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 4,
            padding: '5px 9px', borderRadius: 7, border: 'none', cursor: 'pointer',
            background: on ? (th.dark ? '#636366' : '#fff') : 'transparent',
            color: on ? th.ink : th.sub, fontFamily: SF, fontSize: 12, fontWeight: 600,
            boxShadow: on ? '0 1px 3px rgba(0,0,0,0.12)' : 'none', transition: 'all .15s' }}>
            {o.icon && <Icon name={o.icon} size={15} color={on ? th.ink : th.sub} stroke={2} />}
            {o.label}
          </button>
        );
      })}
    </div>
  );
}

Object.assign(window, { useTheme, SF, GFBadge, Photo, Stars, PriceMark, WardChips, TabBar, TopBar, ActionSheet, Segmented });
