/* Gurufuri — icon set (heroicons-style stroke, single component).
   <Icon name="…" size={20} color="…" stroke={1.8} filled /> */

function Icon({ name, size = 22, color = 'currentColor', stroke = 1.8, filled = false }) {
  const p = { fill: 'none', stroke: color, strokeWidth: stroke, strokeLinecap: 'round', strokeLinejoin: 'round' };
  const paths = {
    back: <path d="M15 5l-7 7 7 7" {...p} />,
    chevron: <path d="M9 6l6 6-6 6" {...p} />,
    chevronDown: <path d="M6 9l6 6 6-6" {...p} />,
    search: <g {...p}><circle cx="11" cy="11" r="7" /><path d="M20 20l-3.2-3.2" /></g>,
    pin: <g {...p}><path d="M12 21s7-6.3 7-11a7 7 0 10-14 0c0 4.7 7 11 7 11z" /><circle cx="12" cy="10" r="2.5" /></g>,
    clock: <g {...p}><circle cx="12" cy="12" r="8.2" /><path d="M12 7.5V12l3 1.8" /></g>,
    star: <path d="M12 4.5l2.3 4.7 5.2.76-3.75 3.66.9 5.18L12 16.9l-4.65 2.45.9-5.18L4.5 9.96l5.2-.76L12 4.5z"
            fill={filled ? color : 'none'} stroke={color} strokeWidth={stroke} strokeLinejoin="round" />,
    heart: <path d="M12 20s-7-4.6-7-9.5A4.2 4.2 0 0112 7a4.2 4.2 0 017 3.5c0 4.9-7 9.5-7 9.5z"
            fill={filled ? color : 'none'} stroke={color} strokeWidth={stroke} strokeLinejoin="round" />,
    shield: <g {...p}><path d="M12 3.5l6.5 2.4V11c0 4.4-2.9 7.6-6.5 9-3.6-1.4-6.5-4.6-6.5-9V5.9L12 3.5z" /><path d="M9.2 12l2 2 3.6-3.8" /></g>,
    chat: <g {...p}><path d="M5 6.5h14a1.5 1.5 0 011.5 1.5v6a1.5 1.5 0 01-1.5 1.5h-7l-4 3v-3H5A1.5 1.5 0 013.5 14V8A1.5 1.5 0 015 6.5z" /></g>,
    alert: <g {...p}><path d="M12 4.5l8.5 14.5h-17L12 4.5z" /><path d="M12 10v4" /><circle cx="12" cy="16.6" r="0.4" fill={color} stroke={color} /></g>,
    info: <g {...p}><circle cx="12" cy="12" r="8.2" /><path d="M12 11v5" /><circle cx="12" cy="8.2" r="0.4" fill={color} stroke={color} /></g>,
    x: <path d="M6 6l12 12M18 6L6 18" {...p} />,
    sliders: <g {...p}><path d="M4 7h10M18 7h2M4 17h2M10 17h10" /><circle cx="16" cy="7" r="2" /><circle cx="8" cy="17" r="2" /></g>,
    nav: <path d="M3 11l18-7-7 18-2.5-8.5L3 11z" {...p} />,
    phone: <path d="M5 4h3.5l1.5 4-2 1.4a11 11 0 005.6 5.6L18 17l4 1.5V22a1 1 0 01-1 1A17 17 0 014 6a1 1 0 011-1z" {...p} />,
    list: <g {...p}><path d="M4 7h16M4 12h16M4 17h16" /></g>,
    grid: <g {...p}><rect x="4" y="4" width="7" height="7" rx="1.4" /><rect x="13" y="4" width="7" height="7" rx="1.4" /><rect x="4" y="13" width="7" height="7" rx="1.4" /><rect x="13" y="13" width="7" height="7" rx="1.4" /></g>,
    user: <g {...p}><circle cx="12" cy="8.5" r="3.6" /><path d="M5.5 19.5a6.5 6.5 0 0113 0" /></g>,
    apple: <path d="M16 13.2c0-2.2 1.8-3.2 1.9-3.3-1-1.5-2.6-1.7-3.2-1.7-1.4-.1-2.6.8-3.3.8-.7 0-1.7-.8-2.8-.8-1.5 0-2.8.8-3.6 2.2-1.5 2.6-.4 6.5 1.1 8.6.7 1 1.6 2.2 2.7 2.1 1.1 0 1.5-.7 2.8-.7 1.3 0 1.6.7 2.8.7 1.1 0 1.9-1 2.6-2 .8-1.2 1.1-2.3 1.1-2.4-.1 0-2.1-.8-2.1-3.2zM14 6.5c.6-.7 1-1.7.9-2.7-.9 0-1.9.6-2.5 1.3-.5.6-1 1.6-.9 2.6 1 0 2-.5 2.5-1.2z" fill={color} stroke="none" />,
    mail: <g {...p}><rect x="3.5" y="5.5" width="17" height="13" rx="2" /><path d="M4 7l8 5.5L20 7" /></g>,
    eye: <g {...p}><path d="M2.5 12S6 5.5 12 5.5 21.5 12 21.5 12 18 18.5 12 18.5 2.5 12 2.5 12z" /><circle cx="12" cy="12" r="2.8" /></g>,
    check: <path d="M5 12.5l4.5 4.5L19 6.5" {...p} />,
    plus: <path d="M12 5v14M5 12h14" {...p} />,
    yen: <g {...p}><path d="M7 5l5 7 5-7M12 12v7M8.5 14h7M8.5 17h7" /></g>,
    train: <g {...p}><rect x="6" y="4" width="12" height="13" rx="3" /><path d="M6 11h12M9 20l-1.5 2M15 20l1.5 2" /><circle cx="9.2" cy="14" r="0.5" fill={color} stroke={color} /><circle cx="14.8" cy="14" r="0.5" fill={color} stroke={color} /></g>,
    leaf: <g {...p}><path d="M5 19c0-7 5-12 14-13 0 9-5 14-12 14-1 0-2-.4-2-1z" /><path d="M9 15c2-3 4.5-5 8-6" /></g>,
    lock: <g {...p}><rect x="5" y="10.5" width="14" height="9.5" rx="2.4" /><path d="M8 10.5V8a4 4 0 018 0v2.5" /></g>,
    sparkle: <path d="M12 3.5l1.7 4.8L18.5 10l-4.8 1.7L12 16.5l-1.7-4.8L5.5 10l4.8-1.7L12 3.5z"
            fill={filled ? color : 'none'} stroke={color} strokeWidth={stroke} strokeLinejoin="round" />,
  };
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" style={{ display: 'block', flexShrink: 0 }}>
      {paths[name] || null}
    </svg>
  );
}

// Bilingual helper: t(label, lang) where label = { ja, en }
function t(label, lang) {
  if (label == null) return '';
  if (typeof label === 'string') return label;
  return label[lang] ?? label.en ?? label.ja ?? '';
}

// "1130" → "11:30"; renders a day's open/close or 定休日 (closed)
function fmtHours(h, lang) {
  if (!h || h.o === h.c) return lang === 'ja' ? '定休日' : 'Closed';
  const hm = (s) => `${s.slice(0, 2)}:${s.slice(2)}`;
  return `${hm(h.o)} – ${hm(h.c)}`;
}

function money(yen, lang) {
  if (yen === 0) return lang === 'ja' ? '—' : '—';
  return '¥' + yen.toLocaleString('en-US');
}

Object.assign(window, { Icon, t, fmtHours, money });
