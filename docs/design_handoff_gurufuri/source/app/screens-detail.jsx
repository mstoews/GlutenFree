/* Gurufuri — Store Detail, Menu, Wishlist, Account screens.
   Exports: StoreDetailScreen, MenuScreen, WishlistScreen, AccountScreen */

const NOW = { day: 5, mins: 13 * 60 + 20 }; // demo "now" — Friday 13:20

function isOpenNow(store) {
  const h = store.hours.find((x) => x.d === NOW.day);
  if (!h || h.o === h.c) return false;
  const o = +h.o.slice(0, 2) * 60 + +h.o.slice(2);
  const c = +h.c.slice(0, 2) * 60 + +h.c.slice(2);
  return NOW.mins >= o && NOW.mins <= c;
}

function InfoRow({ icon, label, value, onClick, th, accentValue, last }) {
  return (
    <button onClick={onClick} disabled={!onClick} style={{ width: '100%', textAlign: 'left', display: 'flex',
      alignItems: 'center', gap: 12, padding: '13px 0', background: 'none', border: 'none',
      borderBottom: last ? 'none' : `0.5px solid ${th.sep}`, cursor: onClick ? 'pointer' : 'default' }}>
      <Icon name={icon} size={19} color={th.sub} stroke={1.8} />
      <div style={{ flex: 1, minWidth: 0 }}>
        {label && <div style={{ fontFamily: SF, fontSize: 11.5, fontWeight: 600, color: th.hint, marginBottom: 1 }}>{label}</div>}
        <div style={{ fontFamily: SF, fontSize: 14.5, color: accentValue ? th.primary : th.ink, fontWeight: accentValue ? 600 : 500, lineHeight: 1.4 }}>{value}</div>
      </div>
      {onClick && <Icon name="chevron" size={17} color={th.hint} stroke={2} />}
    </button>
  );
}

function Card({ th, children, style }) {
  return <div style={{ background: th.card, borderRadius: 16, padding: '4px 16px',
    boxShadow: th.dark ? 'none' : '0 1px 3px rgba(0,0,0,0.05)', outline: th.dark ? `0.5px solid ${th.sep}` : 'none', ...style }}>{children}</div>;
}

function SectionTitle({ children, th, right }) {
  return (
    <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', padding: '20px 18px 8px' }}>
      <span style={{ fontFamily: SF, fontSize: 13, fontWeight: 700, color: th.hint, letterSpacing: '0.04em', textTransform: 'uppercase' }}>{children}</span>
      {right}
    </div>
  );
}

function MenuItemRow({ item, lang, th, badge, last }) {
  return (
    <div style={{ display: 'flex', gap: 12, alignItems: 'center', padding: '12px 0', borderBottom: last ? 'none' : `0.5px solid ${th.sep}` }}>
      <Photo tint={item.tint} style={{ width: 60, height: 60, borderRadius: 12, flexShrink: 0 }} />
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontFamily: SF, fontSize: 14.5, fontWeight: 700, color: th.ink, letterSpacing: '-0.01em' }}>{t(item.name, lang)}</div>
        {item.note && <div style={{ fontFamily: SF, fontSize: 12, color: th.sub, marginTop: 2, lineHeight: 1.4, textWrap: 'pretty' }}>{t(item.note, lang)}</div>}
        <div style={{ marginTop: 6 }}><GFBadge status={item.gf} lang={lang} style={badge} size="sm" th={th} /></div>
      </div>
      <div style={{ fontFamily: SF, fontSize: 14.5, fontWeight: 700, color: th.ink, fontVariantNumeric: 'tabular-nums', flexShrink: 0 }}>{money(item.price, lang)}</div>
    </div>
  );
}

function StoreDetailScreen({ store, lang, th, badge, saved, onSave, onBack, onMenu, subscribed }) {
  const [sheet, setSheet] = React.useState(false);
  const locked = !subscribed;
  const g = GF[store.status];
  const open = isOpenNow(store);
  const today = store.hours.find((x) => x.d === NOW.day);
  return (
    <div style={{ height: '100%', position: 'relative', overflow: 'hidden', background: th.bg }}>
      <div style={{ position: 'absolute', inset: 0, overflowY: 'auto', WebkitOverflowScrolling: 'touch' }}>
      <div style={{ paddingBottom: 96 }}>
      {/* hero */}
      <div style={{ position: 'relative' }}>
        <Photo tint={store.tint} style={{ height: 256 }} />
        <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(180deg, rgba(0,0,0,0.28) 0%, rgba(0,0,0,0) 34%, rgba(0,0,0,0.04) 100%)' }} />
        <div style={{ position: 'absolute', top: 52, left: 14, right: 14, display: 'flex', justifyContent: 'space-between' }}>
          <button onClick={onBack} style={{ width: 36, height: 36, borderRadius: 999, border: 'none', cursor: 'pointer',
            background: 'rgba(0,0,0,0.32)', backdropFilter: 'blur(8px)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Icon name="back" size={22} color="#fff" stroke={2.2} />
          </button>
          <button onClick={onSave} style={{ width: 36, height: 36, borderRadius: 999, border: 'none', cursor: 'pointer',
            background: 'rgba(0,0,0,0.32)', backdropFilter: 'blur(8px)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Icon name="heart" size={20} color={saved ? '#ff3b30' : '#fff'} filled={saved} stroke={2} />
          </button>
        </div>
      </div>

      {/* title block */}
      <div style={{ background: th.card, borderRadius: '20px 20px 0 0', marginTop: -22, position: 'relative',
        padding: '18px 18px 16px', outline: th.dark ? `0.5px solid ${th.sep}` : 'none' }}>
        <div style={{ display: 'flex', gap: 8, marginBottom: 9 }}>
          {store.oriented && (
            <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4, fontFamily: SF, fontSize: 11,
              fontWeight: 700, color: th.primary, background: th.a.soft, padding: '4px 9px', borderRadius: 7 }}>
              <Icon name="leaf" size={12.5} color={th.primary} stroke={2} />{lang === 'ja' ? 'GF対応店' : 'GF-oriented'}
            </span>
          )}
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4, fontFamily: SF, fontSize: 11, fontWeight: 700,
            color: open ? '#047857' : '#dc2626', background: open ? 'rgba(16,185,129,0.12)' : 'rgba(220,38,38,0.1)', padding: '4px 9px', borderRadius: 7 }}>
            <span style={{ width: 7, height: 7, borderRadius: 9, background: open ? '#059669' : '#dc2626' }} />
            {open ? (lang === 'ja' ? '営業中' : 'Open now') : (lang === 'ja' ? '営業時間外' : 'Closed')}
          </span>
        </div>
        <div style={{ fontFamily: SF, fontSize: 24, fontWeight: 800, color: th.ink, letterSpacing: '-0.02em', lineHeight: 1.15 }}>{t(store.name, lang)}</div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 9, marginTop: 8, color: th.sub, flexWrap: 'wrap' }}>
          <Stars rating={store.rating} reviews={store.reviews} th={th} size={13.5} />
          <span style={{ color: th.hint }}>·</span>
          <span style={{ fontFamily: SF, fontSize: 13.5 }}>{t(store.cuisine, lang)}</span>
          <span style={{ color: th.hint }}>·</span>
          <PriceMark level={store.price} th={th} />
        </div>
        <div style={{ fontFamily: SF, fontSize: 14, color: th.sub, lineHeight: 1.5, marginTop: 11, textWrap: 'pretty' }}>{t(store.blurb, lang)}</div>
      </div>

      {/* GF assurance callout */}
      <div style={{ padding: '14px 16px 0' }}>
        <div style={{ display: 'flex', gap: 11, padding: 14, borderRadius: 14, background: g.bg, alignItems: 'flex-start' }}>
          <Icon name={g.icon} size={22} color={g.fg} stroke={2} />
          <div style={{ flex: 1 }}>
            <div style={{ fontFamily: SF, fontSize: 14, fontWeight: 700, color: g.fg }}>{t(g, lang)}</div>
            <div style={{ fontFamily: SF, fontSize: 12.5, color: g.fg, opacity: 0.82, marginTop: 2, lineHeight: 1.45, textWrap: 'pretty' }}>{t(g.blurb, lang)}</div>
          </div>
        </div>
      </div>

      {/* location & contact */}
      <SectionTitle th={th}>{lang === 'ja' ? '場所・アクセス' : 'Location'}</SectionTitle>
      <div style={{ padding: '0 16px' }}>
        <Card th={th}>
          <InfoRow icon="pin" label={lang === 'ja' ? '住所' : 'Address'} value={t(store.address, lang)} onClick={() => setSheet(true)} th={th} />
          <InfoRow icon="train" label={lang === 'ja' ? '最寄り駅' : 'Nearest station'} value={`${t(store.station, lang)} · ${lang === 'ja' ? store.dist : store.distEn}`} th={th} />
          <InfoRow icon="phone" label={lang === 'ja' ? '電話' : 'Phone'} value="03-1234-5678" onClick={() => {}} th={th} last />
        </Card>
      </div>

      {/* hours */}
      <SectionTitle th={th}>{lang === 'ja' ? '営業時間' : 'Opening hours'}</SectionTitle>
      <div style={{ padding: '0 16px' }}>
        <Card th={th} style={{ padding: '6px 16px' }}>
          {[1, 2, 3, 4, 5, 6, 0].map((d, i, arr) => {
            const h = store.hours.find((x) => x.d === d);
            const isToday = d === NOW.day;
            return (
              <div key={d} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '9px 0',
                borderBottom: i < arr.length - 1 ? `0.5px solid ${th.sep}` : 'none' }}>
                <span style={{ fontFamily: SF, fontSize: 14, fontWeight: isToday ? 700 : 500, color: isToday ? th.primary : th.ink }}>
                  {t(DAYS[d], lang)}{isToday ? (lang === 'ja' ? '（本日）' : ' · Today') : ''}
                </span>
                <span style={{ fontFamily: SF, fontSize: 14, fontWeight: isToday ? 700 : 500, fontVariantNumeric: 'tabular-nums',
                  color: !h || h.o === h.c ? th.hint : (isToday ? th.primary : th.sub) }}>{fmtHours(h, lang)}</span>
              </div>
            );
          })}
        </Card>
      </div>

      {/* menu preview */}
      <SectionTitle th={th} right={locked ? (
        <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4, fontFamily: SF, fontSize: 11.5,
          fontWeight: 700, color: th.primary, background: th.a.soft, padding: '4px 9px', borderRadius: 999 }}>
          <Icon name="lock" size={12} color={th.primary} stroke={2} />{lang === 'ja' ? 'メンバー限定' : 'Members'}
        </span>
      ) : (
        <button onClick={onMenu} style={{ background: 'none', border: 'none', cursor: 'pointer', color: th.primary,
          fontFamily: SF, fontSize: 13, fontWeight: 600, display: 'inline-flex', alignItems: 'center', gap: 1 }}>
          {lang === 'ja' ? `全${store.menu.length}品` : `All ${store.menu.length}`}<Icon name="chevron" size={15} color={th.primary} stroke={2} />
        </button>
      )}>{lang === 'ja' ? 'メニュー' : 'Menu'}</SectionTitle>
      <div style={{ padding: '0 16px' }}>
        {locked ? (
          <div role="button" tabIndex={0} onClick={onMenu} style={{ position: 'relative', cursor: 'pointer', borderRadius: 16, overflow: 'hidden' }}>
            <div style={{ filter: 'blur(5px)', pointerEvents: 'none', transform: 'scale(1.02)' }}>
              <Card th={th}>
                {store.menu.slice(0, 3).map((m, i, a) => <MenuItemRow key={m.id} item={m} lang={lang} th={th} badge={badge} last={i === a.length - 1} />)}
              </Card>
            </div>
            <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', alignItems: 'center',
              justifyContent: 'center', gap: 8, textAlign: 'center', padding: 20,
              background: th.dark ? 'rgba(20,20,22,0.34)' : 'rgba(242,242,247,0.34)' }}>
              <span style={{ width: 46, height: 46, borderRadius: 999, background: th.primary, display: 'flex',
                alignItems: 'center', justifyContent: 'center', boxShadow: '0 6px 18px rgba(0,0,0,0.18)' }}>
                <Icon name="lock" size={22} color="#fff" stroke={2} />
              </span>
              <div style={{ fontFamily: SF, fontSize: 14.5, fontWeight: 700, color: th.ink }}>
                {lang === 'ja' ? `全${store.menu.length}品をGurufuri+で解放` : `Unlock all ${store.menu.length} items with Gurufuri+`}
              </div>
              <span style={{ fontFamily: SF, fontSize: 12.5, fontWeight: 700, color: '#fff', background: th.primary,
                padding: '7px 16px', borderRadius: 999 }}>{lang === 'ja' ? '解放する' : 'Unlock'}</span>
            </div>
          </div>
        ) : (
          <Card th={th}>
            {store.menu.slice(0, 3).map((m, i, a) => <MenuItemRow key={m.id} item={m} lang={lang} th={th} badge={badge} last={i === a.length - 1} />)}
          </Card>
        )}
      </div>

      </div>
      </div>
      {/* sticky CTA */}
      <div style={{ position: 'absolute', left: 0, right: 0, bottom: 0, zIndex: 35, padding: '10px 16px 30px',
        background: th.dark ? 'rgba(20,20,22,0.86)' : 'rgba(242,242,247,0.86)', backdropFilter: 'blur(20px)', borderTop: `0.5px solid ${th.sep}` }}>
        <button onClick={onMenu} style={{ width: '100%', height: 50, borderRadius: 13, border: 'none', cursor: 'pointer',
          background: th.primary, color: '#fff', fontFamily: SF, fontSize: 16.5, fontWeight: 700, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8 }}>
          {locked && <Icon name="lock" size={18} color="#fff" stroke={2.1} />}
          {locked
            ? (lang === 'ja' ? 'メニューを解放（メンバー限定）' : 'Unlock full menu')
            : (lang === 'ja' ? 'メニューを見る' : 'View full menu')}
        </button>
      </div>

      <ActionSheet open={sheet} onClose={() => setSheet(false)} th={th}
        title={t(store.address, lang)}
        sub={lang === 'ja' ? 'アプリで開く' : 'Open in'}
        cancelLabel={lang === 'ja' ? 'キャンセル' : 'Cancel'}
        actions={[
          { label: lang === 'ja' ? 'マップで開く' : 'Apple Maps', icon: 'pin', bold: true },
          { label: lang === 'ja' ? 'Googleマップで開く' : 'Google Maps', icon: 'nav' },
          { label: lang === 'ja' ? '住所をコピー' : 'Copy address', icon: 'list' },
        ]} />
    </div>
  );
}

function MenuScreen({ store, lang, th, badge, onBack }) {
  // group certified first, then on_request, then hidden
  const order = { certified: 0, on_request: 1, contains_hidden_gluten: 2 };
  const items = [...store.menu].sort((a, b) => order[a.gf] - order[b.gf]);
  return (
    <div style={{ minHeight: '100%', background: th.bg, paddingBottom: 110 }}>
      <TopBar th={th} onBack={onBack} title={t(store.name, lang)} sub={lang === 'ja' ? `メニュー · 全${store.menu.length}品` : `Menu · ${store.menu.length} items`} />
      <div style={{ padding: '8px 16px 0' }}>
        <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap', marginBottom: 6 }}>
          {Object.keys(GF).map((k) => (
            <span key={k} style={{ display: 'inline-flex', alignItems: 'center', gap: 5, fontFamily: SF, fontSize: 11.5, color: th.sub }}>
              <span style={{ width: 8, height: 8, borderRadius: 9, background: GF[k].dot }} />{t(GF[k], lang)}
            </span>
          ))}
        </div>
      </div>
      <div style={{ padding: '6px 16px' }}>
        <Card th={th}>
          {items.map((m, i, a) => <MenuItemRow key={m.id} item={m} lang={lang} th={th} badge={badge} last={i === a.length - 1} />)}
        </Card>
        <div style={{ fontFamily: SF, fontSize: 11.5, color: th.hint, textAlign: 'center', padding: '16px 20px 0', lineHeight: 1.5, textWrap: 'pretty' }}>
          {lang === 'ja'
            ? 'GF情報は店舗からの申告に基づき、内部審査を経て掲載しています。最終的なアレルギー対応は各店舗にご確認ください。'
            : 'GF information is store-submitted and internally reviewed before publishing. Always confirm allergy handling with the store.'}
        </div>
      </div>
    </div>
  );
}

function WishlistScreen({ lang, th, badge, density, layout, stores, isSaved, onSave, onOpen }) {
  return (
    <div style={{ minHeight: '100%', background: th.bg }}>
      <TopBar large th={th} title={lang === 'ja' ? 'お気に入り' : 'Saved'} sub={lang === 'ja' ? `${stores.length}件の保存済み店舗` : `${stores.length} saved places`} />
      {stores.length === 0 ? (
        <div style={{ padding: '90px 40px', textAlign: 'center' }}>
          <div style={{ width: 76, height: 76, borderRadius: 999, background: th.fill, display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 18px' }}>
            <Icon name="heart" size={34} color={th.hint} stroke={1.7} />
          </div>
          <div style={{ fontFamily: SF, fontSize: 17, fontWeight: 700, color: th.ink }}>{lang === 'ja' ? 'まだ保存がありません' : 'Nothing saved yet'}</div>
          <div style={{ fontFamily: SF, fontSize: 13.5, color: th.sub, marginTop: 6, lineHeight: 1.5, textWrap: 'pretty' }}>
            {lang === 'ja' ? '店舗のハートをタップすると、ここに集まります。' : 'Tap the heart on any store and it will collect here.'}
          </div>
        </div>
      ) : (
        <div style={{ paddingTop: 6 }}>
          <StoreCollection stores={stores} layout={layout === 'grid' ? 'grid' : 'list'} lang={lang} th={th} badge={badge} density={density}
            isSaved={isSaved} onSave={onSave} onOpen={onOpen} />
        </div>
      )}
    </div>
  );
}

function AccountScreen({ lang, th, subscribed, onUpgrade }) {
  const rows = [
    { icon: 'leaf', label: lang === 'ja' ? '食事制限の設定' : 'Dietary preferences', value: lang === 'ja' ? 'グルテンフリー' : 'Gluten-free' },
    { icon: 'chat', label: lang === 'ja' ? 'お問い合わせ' : 'Contact support', value: '' },
    { icon: 'alert', label: lang === 'ja' ? '店舗の情報を報告' : 'Report a store', value: lang === 'ja' ? '近日' : 'Soon' },
    { icon: 'info', label: lang === 'ja' ? '利用規約とプライバシー' : 'Terms & privacy', value: '' },
  ];
  return (
    <div style={{ minHeight: '100%', background: th.bg, paddingBottom: 120 }}>
      <TopBar large th={th} title={lang === 'ja' ? 'アカウント' : 'Account'} />
      <div style={{ padding: '6px 16px 0' }}>
        {/* profile */}
        <Card th={th} style={{ padding: 16, display: 'flex', alignItems: 'center', gap: 14 }}>
          <div style={{ width: 54, height: 54, borderRadius: 999, background: `linear-gradient(150deg, ${th.a[600]}, ${th.a[800]})`,
            display: 'flex', alignItems: 'center', justifyContent: 'center', fontFamily: SF, fontSize: 22, fontWeight: 700, color: '#fff' }}>A</div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontFamily: SF, fontSize: 17, fontWeight: 700, color: th.ink }}>あおい / Aoi</div>
            <div style={{ fontFamily: SF, fontSize: 13, color: th.sub }}>hello@example.jp</div>
          </div>
          <Icon name="chevron" size={18} color={th.hint} stroke={2} />
        </Card>

        {/* subscription */}
        <div style={{ marginTop: 16, borderRadius: 16, overflow: 'hidden', position: 'relative',
          background: `linear-gradient(150deg, ${th.a[600]} 0%, ${th.a[800]} 100%)`, padding: 18 }}>
          <div style={{ position: 'absolute', width: 140, height: 140, borderRadius: 999, border: '26px solid rgba(255,255,255,0.07)', top: -60, right: -40 }} />
          <div style={{ position: 'relative' }}>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
              <span style={{ display: 'inline-flex', alignItems: 'center', gap: 6, fontFamily: SF, fontSize: 15, fontWeight: 800, color: '#fff', letterSpacing: '-0.01em' }}>
                <Icon name="sparkle" size={15} color="#fff" filled stroke={1.6} />Gurufuri+
              </span>
              <span style={{ fontFamily: SF, fontSize: 11, fontWeight: 700, color: '#fff', background: 'rgba(255,255,255,0.22)', padding: '3px 9px', borderRadius: 999 }}>
                {subscribed ? (lang === 'ja' ? '有効' : 'Active') : (lang === 'ja' ? '未加入' : 'Free')}
              </span>
            </div>
            <div style={{ fontFamily: SF, fontSize: 13, color: 'rgba(255,255,255,0.85)', marginTop: 6, lineHeight: 1.45 }}>
              {subscribed
                ? (lang === 'ja' ? '全店舗の詳細とメニューを閲覧できます。' : 'Full store details and menus unlocked.')
                : (lang === 'ja' ? 'メニューはメンバー限定です。アップグレードで全店舗を解放。' : 'Menus are members-only. Upgrade to unlock every store.')}
            </div>
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: 14 }}>
              <span style={{ fontFamily: SF, fontSize: 12, color: 'rgba(255,255,255,0.8)' }}>
                {subscribed
                  ? (lang === 'ja' ? '次回更新 2026年7月14日' : 'Renews Jul 14, 2026')
                  : (lang === 'ja' ? '月額 ¥480 から' : 'From ¥480/mo')}
              </span>
              <button onClick={subscribed ? undefined : onUpgrade} style={{ fontFamily: SF, fontSize: 12.5, fontWeight: 700, color: th.a[800], background: '#fff',
                border: 'none', borderRadius: 999, padding: '7px 14px', cursor: 'pointer' }}>
                {subscribed ? (lang === 'ja' ? '管理' : 'Manage') : (lang === 'ja' ? 'アップグレード' : 'Upgrade')}
              </button>
            </div>
          </div>
        </div>

        {/* settings list */}
        <div style={{ marginTop: 16 }}>
          <Card th={th}>
            {rows.map((r, i) => (
              <InfoRow key={i} icon={r.icon} value={r.label} onClick={() => {}} th={th} last={i === rows.length - 1}
                accentValue={false} />
            ))}
          </Card>
        </div>
        <div style={{ textAlign: 'center', fontFamily: SF, fontSize: 11, color: th.hint, marginTop: 18 }}>Noble Ledger · Gurufuri v0.0.4.66</div>
      </div>
    </div>
  );
}

Object.assign(window, { StoreDetailScreen, MenuScreen, WishlistScreen, AccountScreen, isOpenNow });
