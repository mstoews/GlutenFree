/* Gurufuri — app shell: navigation, theme wiring, Tweaks panel.
   Renders inside the bundle's <IOSDevice> frame. */

const { useState, useEffect } = React;
const { IOSDevice } = window; // from NobleLedger DS bundle

const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "lang": "ja",
  "dark": false,
  "accent": "emerald",
  "badge": "pill",
  "density": "regular",
  "layout": "rich"
}/*EDITMODE-END*/;

function loadSet(key) {
  try { return new Set(JSON.parse(localStorage.getItem(key) || '[]')); } catch { return new Set(); }
}

function GurufuriApp() {
  const [tw, setTweak] = useTweaks(TWEAK_DEFAULTS);
  const lang = tw.lang;
  const th = useTheme(tw.dark, tw.accent);

  // navigation
  const [loggedIn, setLoggedIn] = useState(() => localStorage.getItem('gf_auth') === '1');
  const [tab, setTab] = useState('stores');           // stores | wishlist | account
  const [detailId, setDetailId] = useState(null);
  const [menuId, setMenuId] = useState(null);
  const [ward, setWard] = useState(0);
  const [saved, setSaved] = useState(() => loadSet('gf_saved'));
  const [subscribed, setSubscribed] = useState(() => localStorage.getItem('gf_sub') === '1');
  const [paywall, setPaywall] = useState(null); // null = closed, else { store: id|null }

  useEffect(() => { localStorage.setItem('gf_saved', JSON.stringify([...saved])); }, [saved]);
  useEffect(() => { localStorage.setItem('gf_auth', loggedIn ? '1' : '0'); }, [loggedIn]);
  useEffect(() => { localStorage.setItem('gf_sub', subscribed ? '1' : '0'); }, [subscribed]);

  const isSaved = (id) => saved.has(id);
  const toggleSave = (id) => setSaved((prev) => {
    const n = new Set(prev); n.has(id) ? n.delete(id) : n.add(id); return n;
  });

  const byId = (id) => STORES.find((s) => s.id === id);
  const savedStores = STORES.filter((s) => saved.has(s.id));

  // first menu tap on free tier → paywall (the GET /menu 402 gate)
  const openMenu = (id) => subscribed ? setMenuId(id) : setPaywall({ store: id });
  const onSubscribe = () => {
    setSubscribed(true);
    const target = paywall?.store;
    setPaywall(null);
    if (target) setMenuId(target);
  };

  // which screen + device chrome
  const screenKey = !loggedIn ? 'login'
    : menuId ? `menu-${menuId}`
    : detailId ? `detail-${detailId}`
    : tab;
  const isLogin = !loggedIn;
  const isOverlay = !!(detailId || menuId); // detail/menu hide the tab bar
  const deviceDark = isLogin ? true : tw.dark;

  let content;
  if (isLogin) {
    content = (
      <ScrollHost reset={screenKey}>
        <LoginScreen lang={lang} th={th} accentKey={tw.accent} onLogin={() => setLoggedIn(true)} />
      </ScrollHost>
    );
  } else if (menuId) {
    content = (
      <ScrollHost reset={screenKey}>
        <MenuScreen store={byId(menuId)} lang={lang} th={th} badge={tw.badge} onBack={() => setMenuId(null)} />
      </ScrollHost>
    );
  } else if (detailId) {
    // StoreDetailScreen manages its own scroll + pinned CTA/sheet
    content = (
      <StoreDetailScreen store={byId(detailId)} lang={lang} th={th} badge={tw.badge} subscribed={subscribed}
        saved={isSaved(detailId)} onSave={() => toggleSave(detailId)}
        onBack={() => setDetailId(null)} onMenu={() => openMenu(detailId)} />
    );
  } else if (tab === 'wishlist') {
    content = (
      <ScrollHost reset={screenKey}>
        <WishlistScreen lang={lang} th={th} badge={tw.badge} density={tw.density} layout={tw.layout}
          stores={savedStores} isSaved={isSaved} onSave={toggleSave} onOpen={setDetailId} />
      </ScrollHost>
    );
  } else if (tab === 'account') {
    content = <ScrollHost reset={screenKey}><AccountScreen lang={lang} th={th} subscribed={subscribed} onUpgrade={() => setPaywall({ store: null })} /></ScrollHost>;
  } else {
    content = (
      <ScrollHost reset={screenKey}>
        <StoreListScreen lang={lang} th={th} badge={tw.badge} density={tw.density}
          layout={tw.layout} setLayout={(v) => setTweak('layout', v)}
          ward={ward} setWard={setWard} stores={STORES}
          isSaved={isSaved} onSave={toggleSave} onOpen={setDetailId} />
      </ScrollHost>
    );
  }

  return (
    <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center',
      background: tw.dark ? '#0a0a0c' : '#e9eaee', padding: 24, boxSizing: 'border-box' }}>
      <IOSDevice dark={deviceDark}>
        <div style={{ height: '100%', position: 'relative', overflow: 'hidden', background: th.bg }}>
          {content}
          {loggedIn && !isOverlay && (
            <TabBar active={tab} onTab={setTab} lang={lang} th={th} wishCount={saved.size} />
          )}
          <Paywall open={!!paywall} store={paywall?.store ? byId(paywall.store) : null}
            lang={lang} th={th} onSubscribe={onSubscribe} onClose={() => setPaywall(null)} />
        </div>
      </IOSDevice>

      <TweaksPanel title="Tweaks">
        <TweakSection label={lang === 'ja' ? '表示' : 'Display'} />
        <TweakRadio label={lang === 'ja' ? '言語' : 'Language'} value={tw.lang}
          options={[{ value: 'ja', label: '日本語' }, { value: 'en', label: 'English' }]}
          onChange={(v) => setTweak('lang', v)} />
        <TweakToggle label={lang === 'ja' ? 'ダークモード' : 'Dark mode'} value={tw.dark} onChange={(v) => setTweak('dark', v)} />
        <TweakRadio label={lang === 'ja' ? 'アクセント' : 'Accent'} value={tw.accent}
          options={[{ value: 'emerald', label: 'Emerald' }, { value: 'indigo', label: 'Indigo' }]}
          onChange={(v) => setTweak('accent', v)} />

        <TweakSection label={lang === 'ja' ? '店舗リスト（メイン画面）' : 'Store list (key screen)'} />
        <TweakRadio label={lang === 'ja' ? 'レイアウト' : 'Layout'} value={tw.layout}
          options={[{ value: 'rich', label: lang === 'ja' ? 'リッチ' : 'Rich' },
                    { value: 'list', label: lang === 'ja' ? 'リスト' : 'List' },
                    { value: 'grid', label: lang === 'ja' ? 'グリッド' : 'Grid' }]}
          onChange={(v) => setTweak('layout', v)} />
        <TweakRadio label={lang === 'ja' ? '密度' : 'Density'} value={tw.density}
          options={[{ value: 'compact', label: lang === 'ja' ? '密' : 'Compact' },
                    { value: 'regular', label: lang === 'ja' ? '標準' : 'Regular' },
                    { value: 'comfy', label: lang === 'ja' ? '広' : 'Comfy' }]}
          onChange={(v) => setTweak('density', v)} />

        <TweakSection label={lang === 'ja' ? 'グルテンフリー表示' : 'GF status badge'} />
        <TweakRadio label={lang === 'ja' ? 'バッジ' : 'Style'} value={tw.badge}
          options={[{ value: 'pill', label: lang === 'ja' ? 'ピル' : 'Pill' },
                    { value: 'dot', label: lang === 'ja' ? 'ドット' : 'Dot' },
                    { value: 'tag', label: lang === 'ja' ? 'タグ' : 'Tag' }]}
          onChange={(v) => setTweak('badge', v)} />
      </TweaksPanel>
    </div>
  );
}

// Non-scrolling host whose single child scrolls — keeps pinned siblings (tab bar)
// anchored to the device, and resets scroll position when `reset` changes.
function ScrollHost({ reset, children }) {
  const ref = React.useRef(null);
  useEffect(() => { if (ref.current) ref.current.scrollTop = 0; }, [reset]);
  return (
    <div ref={ref} style={{ position: 'absolute', inset: 0, overflowY: 'auto', WebkitOverflowScrolling: 'touch' }}>
      {children}
    </div>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<GurufuriApp />);
