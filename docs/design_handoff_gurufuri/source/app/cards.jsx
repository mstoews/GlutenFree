/* Gurufuri — store card in 3 layout directions for the key screen:
   'rich'  — full-bleed photo hero cards (discovery-forward)
   'list'  — compact rows with thumbnail (scan-many)
   'grid'  — 2-up photo tiles (visual browse)
   Exports: StoreCard, StoreCollection */

const DENS = {
  compact: { gap: 8,  pad: 11, rich: 132, thumb: 58, grid: 104 },
  regular: { gap: 12, pad: 13, rich: 158, thumb: 70, grid: 124 },
  comfy:   { gap: 18, pad: 16, rich: 188, thumb: 84, grid: 146 },
};

function HeartBtn({ on, onClick, th, light }) {
  const c = on ? '#ff3b30' : (light ? '#fff' : th.hint);
  return (
    <div role="button" tabIndex={0} onClick={(e) => { e.stopPropagation(); onClick(); }} style={{
      width: 34, height: 34, borderRadius: 999, cursor: 'pointer', flexShrink: 0,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      background: light ? 'rgba(0,0,0,0.28)' : 'transparent', backdropFilter: light ? 'blur(8px)' : 'none' }}>
      <Icon name="heart" size={20} color={c} filled={on} stroke={2} />
    </div>
  );
}

function OrientedTag({ lang, th }) {
  return (
    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4, fontFamily: SF, fontSize: 10.5,
      fontWeight: 700, letterSpacing: '0.02em', color: th.primary, background: th.a.soft,
      padding: '3px 8px', borderRadius: 6, whiteSpace: 'nowrap' }}>
      <Icon name="leaf" size={12} color={th.primary} stroke={2} />
      {lang === 'ja' ? 'GF対応店' : 'GF-oriented'}
    </span>
  );
}

function StoreCard({ store, layout, lang, th, badge, density, saved, onSave, onOpen }) {
  const d = DENS[density] || DENS.regular;

  if (layout === 'grid') {
    return (
      <button onClick={onOpen} style={{ textAlign: 'left', background: th.card, border: 'none',
        borderRadius: 16, overflow: 'hidden', cursor: 'pointer', boxShadow: th.dark ? 'none' : '0 1px 3px rgba(0,0,0,0.06)',
        outline: th.dark ? `0.5px solid ${th.sep}` : 'none', display: 'flex', flexDirection: 'column' }}>
        <div style={{ position: 'relative' }}>
          <Photo tint={store.tint} style={{ height: d.grid }} />
          <div style={{ position: 'absolute', top: 7, right: 7 }}><HeartBtn on={saved} onClick={onSave} th={th} light /></div>
          <div style={{ position: 'absolute', left: 7, bottom: 7 }}><GFBadge status={store.status} lang={lang} style={badge} size="sm" /></div>
        </div>
        <div style={{ padding: '9px 11px 12px' }}>
          <div style={{ fontFamily: SF, fontSize: 13.5, fontWeight: 700, color: th.ink, letterSpacing: '-0.01em',
            lineHeight: 1.25, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{t(store.name, lang)}</div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 5 }}>
            <Stars rating={store.rating} th={th} size={11.5} />
            <span style={{ color: th.hint, fontSize: 11 }}>·</span>
            <span style={{ fontFamily: SF, fontSize: 11.5, color: th.sub, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{t(store.cuisine, lang)}</span>
          </div>
        </div>
      </button>
    );
  }

  if (layout === 'list') {
    return (
      <button onClick={onOpen} style={{ width: '100%', textAlign: 'left', display: 'flex', gap: 12, alignItems: 'center',
        padding: d.pad, background: th.card, border: 'none', borderRadius: 14, cursor: 'pointer',
        boxShadow: th.dark ? 'none' : '0 1px 2px rgba(0,0,0,0.05)', outline: th.dark ? `0.5px solid ${th.sep}` : 'none' }}>
        <Photo tint={store.tint} style={{ width: d.thumb, height: d.thumb, borderRadius: 12, flexShrink: 0 }} />
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <span style={{ fontFamily: SF, fontSize: 15, fontWeight: 700, color: th.ink, letterSpacing: '-0.01em',
              overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', flex: 1, minWidth: 0 }}>{t(store.name, lang)}</span>
            <Stars rating={store.rating} th={th} size={12} />
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 3, color: th.sub }}>
            <span style={{ fontFamily: SF, fontSize: 12.5 }}>{t(store.cuisine, lang)}</span>
            <span style={{ color: th.hint }}>·</span>
            <PriceMark level={store.price} th={th} />
            <span style={{ color: th.hint }}>·</span>
            <span style={{ display: 'inline-flex', alignItems: 'center', gap: 2, fontFamily: SF, fontSize: 12.5 }}>
              <Icon name="pin" size={12} color={th.hint} stroke={1.8} />{lang === 'ja' ? store.dist : store.distEn}
            </span>
          </div>
          <div style={{ marginTop: 7 }}><GFBadge status={store.status} lang={lang} style={badge} size="sm" th={th} /></div>
        </div>
        <HeartBtn on={saved} onClick={onSave} th={th} />
      </button>
    );
  }

  // rich (default) — photo hero
  return (
    <button onClick={onOpen} style={{ width: '100%', textAlign: 'left', background: th.card, border: 'none',
      borderRadius: 18, overflow: 'hidden', cursor: 'pointer', boxShadow: th.dark ? 'none' : '0 2px 10px rgba(0,0,0,0.07)',
      outline: th.dark ? `0.5px solid ${th.sep}` : 'none', display: 'flex', flexDirection: 'column' }}>
      <div style={{ position: 'relative' }}>
        <Photo tint={store.tint} style={{ height: d.rich }} />
        <div style={{ position: 'absolute', top: 10, left: 10, display: 'flex', gap: 6 }}>
          {store.oriented && <OrientedTag lang={lang} th={th} />}
        </div>
        <div style={{ position: 'absolute', top: 8, right: 8 }}><HeartBtn on={saved} onClick={onSave} th={th} light /></div>
        <div style={{ position: 'absolute', left: 10, bottom: 10 }}><GFBadge status={store.status} lang={lang} style={badge === 'dot' ? 'tag' : badge} /></div>
      </div>
      <div style={{ padding: `${d.pad}px ${d.pad + 2}px ${d.pad + 2}px` }}>
        <div style={{ display: 'flex', alignItems: 'flex-start', gap: 8 }}>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontFamily: SF, fontSize: 16.5, fontWeight: 800, color: th.ink, letterSpacing: '-0.015em', lineHeight: 1.2 }}>{t(store.name, lang)}</div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 7, marginTop: 4, color: th.sub, flexWrap: 'wrap' }}>
              <span style={{ fontFamily: SF, fontSize: 12.5 }}>{t(store.cuisine, lang)}</span>
              <span style={{ color: th.hint }}>·</span>
              <PriceMark level={store.price} th={th} />
              <span style={{ color: th.hint }}>·</span>
              <span style={{ display: 'inline-flex', alignItems: 'center', gap: 2, fontFamily: SF, fontSize: 12.5 }}>
                <Icon name="pin" size={12.5} color={th.hint} stroke={1.8} />{t(store.station, lang)}
              </span>
            </div>
          </div>
          <Stars rating={store.rating} reviews={store.reviews} th={th} />
        </div>
        <div style={{ fontFamily: SF, fontSize: 13, color: th.sub, lineHeight: 1.45, marginTop: 8, textWrap: 'pretty' }}>{t(store.blurb, lang)}</div>
      </div>
    </button>
  );
}

function StoreCollection({ stores, layout, lang, th, badge, density, isSaved, onSave, onOpen, empty }) {
  const d = DENS[density] || DENS.regular;
  if (stores.length === 0 && empty) return empty;
  if (layout === 'grid') {
    return (
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: d.gap, padding: `4px 16px ${130}px` }}>
        {stores.map((s) => <StoreCard key={s.id} store={s} layout="grid" lang={lang} th={th} badge={badge}
          density={density} saved={isSaved(s.id)} onSave={() => onSave(s.id)} onOpen={() => onOpen(s.id)} />)}
      </div>
    );
  }
  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: d.gap, padding: `4px 16px 130px` }}>
      {stores.map((s) => <StoreCard key={s.id} store={s} layout={layout} lang={lang} th={th} badge={badge}
        density={density} saved={isSaved(s.id)} onSave={() => onSave(s.id)} onOpen={() => onOpen(s.id)} />)}
    </div>
  );
}

Object.assign(window, { StoreCard, StoreCollection, DENS });
