/* Gurufuri — Login + Store List screens.
   Exports: LoginScreen, StoreListScreen, Field, Wordmark */

function Wordmark({ size = 40, color = '#fff', sub }) {
  return (
    <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
        <span style={{ display: 'inline-flex', alignItems: 'center', justifyContent: 'center',
          width: size * 0.92, height: size * 0.92, borderRadius: size * 0.28,
          background: 'rgba(255,255,255,0.16)', border: '1.5px solid rgba(255,255,255,0.5)' }}>
          <Icon name="leaf" size={size * 0.56} color={color} stroke={1.9} />
        </span>
        <span style={{ fontFamily: SF, fontWeight: 800, fontSize: size, color, letterSpacing: '-0.03em' }}>グルフリ</span>
      </div>
      {sub && <span style={{ fontFamily: SF, fontSize: 12.5, fontWeight: 600, letterSpacing: '0.32em', color, opacity: 0.82, textTransform: 'uppercase', paddingLeft: '0.32em' }}>{sub}</span>}
    </div>
  );
}

function Field({ icon, type = 'text', placeholder, value, onChange, th, right }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '0 14px', height: 50,
      background: th.dark ? 'rgba(118,118,128,0.24)' : '#fff', borderRadius: 12,
      border: `1px solid ${th.dark ? 'transparent' : 'rgba(60,60,67,0.12)'}` }}>
      {icon && <Icon name={icon} size={19} color={th.hint} stroke={1.8} />}
      <input type={type} placeholder={placeholder} value={value}
        onChange={(e) => onChange?.(e.target.value)}
        style={{ flex: 1, border: 'none', outline: 'none', background: 'transparent', fontFamily: SF,
          fontSize: 16, color: th.ink, minWidth: 0 }} />
      {right}
    </div>
  );
}

function LoginScreen({ lang, th, accentKey, onLogin }) {
  const [email, setEmail] = React.useState('hello@example.jp');
  const [pw, setPw] = React.useState('passw0rd');
  const [show, setShow] = React.useState(false);
  const grad = th.a;
  return (
    <div style={{ minHeight: '100%', background: th.bg, display: 'flex', flexDirection: 'column' }}>
      {/* hero */}
      <div style={{ position: 'relative', padding: '96px 28px 40px', overflow: 'hidden',
        background: `linear-gradient(155deg, ${grad[600]} 0%, ${grad[800]} 100%)` }}>
        <div style={{ position: 'absolute', width: 240, height: 240, borderRadius: 999, border: '40px solid rgba(255,255,255,0.06)', top: -90, right: -70 }} />
        <div style={{ position: 'absolute', width: 150, height: 150, borderRadius: 999, border: '28px solid rgba(255,255,255,0.05)', bottom: -50, left: -40 }} />
        <div style={{ position: 'relative' }}>
          <Wordmark size={38} sub="Gurufuri" />
          <div style={{ textAlign: 'center', marginTop: 22 }}>
            <div style={{ fontFamily: SF, fontSize: 21, fontWeight: 800, color: '#fff', letterSpacing: '-0.02em' }}>
              {lang === 'ja' ? '安心して、外食を。' : 'Dine out, worry-free.'}
            </div>
            <div style={{ fontFamily: SF, fontSize: 13.5, color: 'rgba(255,255,255,0.86)', marginTop: 7, lineHeight: 1.5, textWrap: 'pretty' }}>
              {lang === 'ja'
                ? '東京のグルテンフリー対応店と全メニューを、審査済みデータベースで。'
                : 'Tokyo’s gluten-free restaurants and full menus — every store vetted before it goes live.'}
            </div>
          </div>
        </div>
      </div>

      {/* form */}
      <div style={{ flex: 1, padding: '24px 24px 28px', display: 'flex', flexDirection: 'column', gap: 12 }}>
        <Field icon="mail" type="email" placeholder={lang === 'ja' ? 'メールアドレス' : 'Email address'} value={email} onChange={setEmail} th={th} />
        <Field icon="shield" type={show ? 'text' : 'password'} placeholder={lang === 'ja' ? 'パスワード' : 'Password'} value={pw} onChange={setPw} th={th}
          right={<button onClick={() => setShow(!show)} style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 0 }}><Icon name="eye" size={19} color={th.hint} stroke={1.7} /></button>} />

        <button onClick={onLogin} style={{ marginTop: 4, height: 50, borderRadius: 12, border: 'none', cursor: 'pointer',
          background: th.primary, color: '#fff', fontFamily: SF, fontSize: 16.5, fontWeight: 700, letterSpacing: '0.01em' }}>
          {lang === 'ja' ? 'ログイン' : 'Log In'}
        </button>

        <div style={{ display: 'flex', alignItems: 'center', gap: 12, margin: '8px 0 2px' }}>
          <div style={{ flex: 1, height: 1, background: th.sep }} />
          <span style={{ fontFamily: SF, fontSize: 12, color: th.hint }}>{lang === 'ja' ? 'または' : 'or'}</span>
          <div style={{ flex: 1, height: 1, background: th.sep }} />
        </div>

        <button onClick={onLogin} style={{ height: 50, borderRadius: 12, border: 'none', cursor: 'pointer',
          background: th.dark ? '#fff' : '#000', color: th.dark ? '#000' : '#fff', fontFamily: SF, fontSize: 16, fontWeight: 600,
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8 }}>
          <Icon name="apple" size={19} color={th.dark ? '#000' : '#fff'} />
          {lang === 'ja' ? 'Appleでサインイン' : 'Sign in with Apple'}
        </button>

        <div style={{ flex: 1 }} />
        <div style={{ textAlign: 'center', fontFamily: SF, fontSize: 13.5, color: th.sub }}>
          {lang === 'ja' ? 'アカウントをお持ちでない方は ' : 'New here? '}
          <button onClick={onLogin} style={{ background: 'none', border: 'none', cursor: 'pointer', color: th.primary, fontFamily: SF, fontSize: 13.5, fontWeight: 700, padding: 0 }}>
            {lang === 'ja' ? '新規登録' : 'Create account'}
          </button>
        </div>
        <div style={{ textAlign: 'center', fontFamily: SF, fontSize: 11, color: th.hint, marginTop: 2 }}>Noble Ledger · Gurufuri v0.0.4.66</div>
      </div>
    </div>
  );
}

function SearchBar({ lang, th }) {
  return (
    <div style={{ padding: '4px 16px 8px' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '0 12px', height: 38,
        background: th.fill, borderRadius: 11 }}>
        <Icon name="search" size={17} color={th.hint} stroke={1.9} />
        <span style={{ fontFamily: SF, fontSize: 15, color: th.hint }}>{lang === 'ja' ? '店名・エリアで検索' : 'Search stores or areas'}</span>
      </div>
    </div>
  );
}

function StoreListScreen({ lang, th, badge, density, layout, setLayout, ward, setWard, stores, isSaved, onSave, onOpen }) {
  const filtered = ward === 0 ? stores : stores.filter((s) => s.ward === ward);
  const layoutOpts = [
    { id: 'rich', icon: 'leaf' }, { id: 'list', icon: 'list' }, { id: 'grid', icon: 'grid' },
  ];
  return (
    <div style={{ minHeight: '100%', background: th.bg }}>
      <TopBar large th={th}
        title={lang === 'ja' ? '探す' : 'Explore'}
        sub={lang === 'ja' ? '東京 · グルテンフリー対応' : 'Tokyo · gluten-free'}
        right={<Segmented value={layout} onChange={setLayout} th={th}
          options={layoutOpts.map((o) => ({ id: o.id, icon: o.icon }))} />} />
      <div style={{ paddingTop: 6 }}>
        <SearchBar lang={lang} th={th} />
        <WardChips wards={WARDS} active={ward} onPick={setWard} lang={lang} th={th} />
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '12px 18px 4px' }}>
          <span style={{ fontFamily: SF, fontSize: 12.5, fontWeight: 600, color: th.sub }}>
            {filtered.length}{lang === 'ja' ? '件' : ' places'}
          </span>
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4, fontFamily: SF, fontSize: 12.5, color: th.sub }}>
            <Icon name="nav" size={13} color={th.primary} stroke={1.9} />
            {lang === 'ja' ? '近い順' : 'Nearest'}
            <Icon name="chevronDown" size={13} color={th.hint} stroke={2} />
          </span>
        </div>
        <StoreCollection stores={filtered} layout={layout} lang={lang} th={th} badge={badge} density={density}
          isSaved={isSaved} onSave={onSave} onOpen={onOpen} />
      </div>
    </div>
  );
}

Object.assign(window, { LoginScreen, StoreListScreen, Field, Wordmark, SearchBar });
