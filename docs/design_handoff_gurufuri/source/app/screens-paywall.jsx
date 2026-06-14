/* Gurufuri — StoreKit-style paywall.
   Surfaces on the first menu tap for free-tier users (the GET /stores/:id/menu
   → 402 gate). Slides up as a presented modal over the device.
   Exports: Paywall */

const PLANS = [
  { id: 'annual', price: '¥3,800', per: { ja: '/年', en: '/yr' },
    sub: { ja: '¥317/月 相当 · 2か月分お得', en: '¥317/mo · 2 months free' },
    badge: { ja: 'おすすめ', en: 'Best value' } },
  { id: 'monthly', price: '¥480', per: { ja: '/月', en: '/mo' },
    sub: { ja: 'いつでもキャンセル可能', en: 'Cancel anytime' }, badge: null },
];

function PlanCard({ plan, selected, onPick, lang, th }) {
  return (
    <div role="button" tabIndex={0} onClick={() => onPick(plan.id)} style={{
      position: 'relative', display: 'flex', alignItems: 'center', gap: 12, cursor: 'pointer',
      padding: '14px 15px', borderRadius: 14, transition: 'all .15s',
      background: selected ? th.a.soft : th.card,
      border: `1.5px solid ${selected ? th.primary : th.sep}`,
      boxShadow: th.dark ? 'none' : (selected ? 'none' : '0 1px 2px rgba(0,0,0,0.04)') }}>
      <div style={{ width: 22, height: 22, borderRadius: 999, flexShrink: 0,
        border: `2px solid ${selected ? th.primary : th.hint}`, background: selected ? th.primary : 'transparent',
        display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        {selected && <Icon name="check" size={13} color="#fff" stroke={2.6} />}
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: 'flex', alignItems: 'baseline', gap: 4 }}>
          <span style={{ fontFamily: SF, fontSize: 18, fontWeight: 800, color: th.ink, letterSpacing: '-0.02em' }}>{plan.price}</span>
          <span style={{ fontFamily: SF, fontSize: 13, fontWeight: 600, color: th.sub }}>{t(plan.per, lang)}</span>
        </div>
        <div style={{ fontFamily: SF, fontSize: 12, color: th.sub, marginTop: 1 }}>{t(plan.sub, lang)}</div>
      </div>
      {plan.badge && (
        <span style={{ fontFamily: SF, fontSize: 10.5, fontWeight: 700, color: '#fff', background: th.primary,
          padding: '4px 9px', borderRadius: 999, flexShrink: 0 }}>{t(plan.badge, lang)}</span>
      )}
    </div>
  );
}

function Paywall({ open, store, lang, th, onSubscribe, onClose }) {
  const [plan, setPlan] = React.useState('annual');
  if (!open) return null;
  const sel = PLANS.find((p) => p.id === plan);
  const benefits = [
    { ja: '全店舗の詳細とメニューを閲覧', en: 'View every store’s full menu' },
    { ja: '品目ごとのGFステータスと注意点', en: 'Per-item GF status & cross-contact notes' },
    { ja: '区・エリアで絞り込み（路線は近日）', en: 'Filter by ward — train lines soon' },
    { ja: 'お気に入りを無制限に保存', en: 'Unlimited saved places' },
  ];
  const ctaPrice = `${sel.price}${t(sel.per, lang)}`;

  return (
    <div onClick={onClose} style={{ position: 'absolute', inset: 0, zIndex: 90, display: 'flex',
      alignItems: 'flex-end', background: 'rgba(0,0,0,0.45)', animation: 'gfFade .2s ease' }}>
      <div onClick={(e) => e.stopPropagation()} style={{ width: '100%', height: '94%', background: th.bg,
        borderRadius: '22px 22px 0 0', overflow: 'hidden', position: 'relative',
        animation: 'gfSlideUp .32s cubic-bezier(.2,.8,.2,1)', display: 'flex', flexDirection: 'column' }}>
        {/* grabber + close */}
        <div style={{ position: 'absolute', top: 8, left: 0, right: 0, display: 'flex', justifyContent: 'center', zIndex: 3 }}>
          <div style={{ width: 38, height: 5, borderRadius: 100, background: th.dark ? 'rgba(255,255,255,0.3)' : 'rgba(0,0,0,0.18)' }} />
        </div>
        <button onClick={onClose} style={{ position: 'absolute', top: 16, right: 14, zIndex: 3, width: 30, height: 30,
          borderRadius: 999, border: 'none', cursor: 'pointer', background: th.dark ? 'rgba(255,255,255,0.14)' : 'rgba(120,120,128,0.16)',
          display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Icon name="x" size={17} color={th.sub} stroke={2.2} />
        </button>

        <div style={{ flex: 1, overflowY: 'auto' }}>
          {/* hero */}
          <div style={{ position: 'relative', overflow: 'hidden', padding: '40px 24px 26px',
            background: `linear-gradient(155deg, ${th.a[600]} 0%, ${th.a[800]} 100%)` }}>
            <div style={{ position: 'absolute', width: 200, height: 200, borderRadius: 999, border: '36px solid rgba(255,255,255,0.06)', top: -80, right: -56 }} />
            <div style={{ position: 'relative' }}>
              <div style={{ display: 'inline-flex', alignItems: 'center', gap: 7, background: 'rgba(255,255,255,0.16)',
                border: '1px solid rgba(255,255,255,0.34)', padding: '5px 11px', borderRadius: 999 }}>
                <Icon name="sparkle" size={14} color="#fff" filled stroke={1.6} />
                <span style={{ fontFamily: SF, fontSize: 13, fontWeight: 800, color: '#fff', letterSpacing: '0.01em' }}>Gurufuri+</span>
              </div>
              <div style={{ fontFamily: SF, fontSize: 25, fontWeight: 800, color: '#fff', letterSpacing: '-0.02em', lineHeight: 1.18, marginTop: 16 }}>
                {lang === 'ja' ? '全メニューを、解放しよう。' : 'Unlock every menu.'}
              </div>
              <div style={{ fontFamily: SF, fontSize: 14, color: 'rgba(255,255,255,0.88)', marginTop: 8, lineHeight: 1.5, textWrap: 'pretty' }}>
                {store
                  ? (lang === 'ja'
                      ? `「${t(store.name, lang)}」を含む全店舗の詳細とメニューが見放題に。`
                      : `See full details and menus for every store, including ${t(store.name, lang)}.`)
                  : (lang === 'ja'
                      ? '審査済みのGF対応店、全店舗の詳細とメニューが見放題に。'
                      : 'Full details and menus for every vetted GF store.')}
              </div>
            </div>
          </div>

          {/* benefits */}
          <div style={{ padding: '20px 22px 6px', display: 'flex', flexDirection: 'column', gap: 13 }}>
            {benefits.map((b, i) => (
              <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                <span style={{ width: 26, height: 26, borderRadius: 999, background: th.a.soft, flexShrink: 0,
                  display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                  <Icon name="check" size={15} color={th.primary} stroke={2.4} />
                </span>
                <span style={{ fontFamily: SF, fontSize: 14.5, fontWeight: 500, color: th.ink, lineHeight: 1.35 }}>{t(b, lang)}</span>
              </div>
            ))}
          </div>

          {/* plans */}
          <div style={{ padding: '18px 16px 4px', display: 'flex', flexDirection: 'column', gap: 10 }}>
            {PLANS.map((p) => <PlanCard key={p.id} plan={p} selected={plan === p.id} onPick={setPlan} lang={lang} th={th} />)}
          </div>

          <div style={{ fontFamily: SF, fontSize: 11, color: th.hint, textAlign: 'center', padding: '14px 28px 18px', lineHeight: 1.5, textWrap: 'pretty' }}>
            {lang === 'ja'
              ? `${ctaPrice}で自動更新。確認後にApple IDへ課金されます。設定からいつでもキャンセルできます。`
              : `Auto-renews at ${ctaPrice}. Billed to your Apple ID at confirmation. Cancel anytime in Settings.`}
          </div>
        </div>

        {/* pinned CTA */}
        <div style={{ padding: '12px 16px 26px', borderTop: `0.5px solid ${th.sep}`,
          background: th.dark ? 'rgba(20,20,22,0.92)' : 'rgba(242,242,247,0.92)', backdropFilter: 'blur(20px)' }}>
          <button onClick={() => onSubscribe(plan)} style={{ width: '100%', height: 52, borderRadius: 14, border: 'none',
            cursor: 'pointer', background: th.primary, color: '#fff', fontFamily: SF, fontSize: 17, fontWeight: 700,
            display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8 }}>
            <Icon name="apple" size={18} color="#fff" />
            {lang === 'ja' ? `${ctaPrice}で続ける` : `Continue — ${ctaPrice}`}
          </button>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 18, marginTop: 12 }}>
            {[lang === 'ja' ? '購入を復元' : 'Restore', lang === 'ja' ? '利用規約' : 'Terms', lang === 'ja' ? 'プライバシー' : 'Privacy'].map((l, i) => (
              <button key={i} onClick={i === 0 ? () => onSubscribe(plan) : undefined} style={{ background: 'none', border: 'none',
                cursor: 'pointer', fontFamily: SF, fontSize: 12, fontWeight: 500, color: th.sub, padding: 0 }}>{l}</button>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { Paywall });
