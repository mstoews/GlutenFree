/* Gurufuri — sample content (Tokyo, GF-oriented stores).
   Bilingual: every label carries { ja, en }. Prices in yen.
   GF status enum mirrors the data model:
     certified | on_request | contains_hidden_gluten          */

const WARDS = [
  { id: 0, ja: 'すべて',  en: 'All wards' },
  { id: 1, ja: '渋谷区',  en: 'Shibuya' },
  { id: 2, ja: '新宿区',  en: 'Shinjuku' },
  { id: 3, ja: '港区',    en: 'Minato' },
  { id: 4, ja: '目黒区',  en: 'Meguro' },
  { id: 5, ja: '世田谷区', en: 'Setagaya' },
  { id: 6, ja: '台東区',  en: 'Taito' },
];

// GF status → semantic meta (colors are FIXED — they encode trust, not brand)
const GF = {
  certified: {
    ja: '認証済み', en: 'Certified', short: { ja: '認証', en: 'Cert.' },
    fg: '#047857', bg: 'rgba(16,185,129,0.12)', dot: '#059669', icon: 'shield',
    blurb: { ja: '専用調理・検査済み。コンタミ対策あり。', en: 'Dedicated prep, tested. Cross-contact controls in place.' },
  },
  on_request: {
    ja: '要相談', en: 'On request', short: { ja: '相談', en: 'Ask' },
    fg: '#b45309', bg: 'rgba(245,158,11,0.14)', dot: '#d97706', icon: 'chat',
    blurb: { ja: 'スタッフに確認の上で対応可能。', en: 'Available — confirm with staff before ordering.' },
  },
  contains_hidden_gluten: {
    ja: '隠れ小麦あり', en: 'Hidden gluten', short: { ja: '注意', en: 'Caution' },
    fg: '#dc2626', bg: 'rgba(220,38,38,0.12)', dot: '#dc2626', icon: 'alert',
    blurb: { ja: '醤油・だし等に小麦を含む可能性。', en: 'Wheat may be present in soy sauce / dashi.' },
  },
};

const STORES = [
  {
    id: 's1', ward: 1, oriented: true, status: 'certified',
    name: { ja: '米粉キッチン こめこ', en: 'Komeko Rice-Flour Kitchen' },
    cuisine: { ja: '定食・カフェ', en: 'Teishoku · Café' },
    blurb: { ja: '全メニュー米粉。専用フライヤーで揚げ物も安心。', en: 'Fully rice-flour kitchen. Dedicated fryer for safe tempura.' },
    price: 2, rating: 4.8, reviews: 312, dist: '徒歩4分', distEn: '4 min walk',
    address: { ja: '東京都渋谷区神南1-12-3', en: '1-12-3 Jinnan, Shibuya-ku, Tokyo' },
    station: { ja: '渋谷駅 ハチ公口', en: 'Shibuya Stn · Hachikō exit' },
    tint: ['#fdeede', '#f6d8b8'],
    hours: [
      { d: 0, o: '1100', c: '2000' }, { d: 1, o: '1100', c: '2200' },
      { d: 2, o: '1100', c: '2200' }, { d: 3, o: '1100', c: '2200' },
      { d: 4, o: '1100', c: '2200' }, { d: 5, o: '1100', c: '2300' },
      { d: 6, o: '1000', c: '2300' },
    ],
    menu: [
      { id: 'm1', name: { ja: '米粉からあげ定食', en: 'Rice-flour karaage set' }, price: 1280, gf: 'certified', tint: ['#f7e3c4', '#eab676'],
        note: { ja: '専用フライヤー・米粉衣。', en: 'Dedicated fryer, rice-flour coating.' } },
      { id: 'm2', name: { ja: '生姜焼き定食', en: 'Ginger pork set' }, price: 1180, gf: 'certified', tint: ['#f3d9c0', '#dba06a'],
        note: { ja: 'GF醤油使用。', en: 'Made with GF tamari.' } },
      { id: 'm3', name: { ja: '米粉パンケーキ', en: 'Rice-flour pancakes' }, price: 980, gf: 'certified', tint: ['#fbe9cf', '#f0c285'],
        note: { ja: 'メープル添え。', en: 'Served with maple.' } },
      { id: 'm4', name: { ja: '味噌だしうどん（米粉麺）', en: 'Miso udon · rice noodle' }, price: 1080, gf: 'on_request', tint: ['#efdcc2', '#cf9f5f'],
        note: { ja: 'だしは要確認（鰹）。', en: 'Confirm dashi (bonito) on request.' } },
    ],
  },
  {
    id: 's2', ward: 2, oriented: true, status: 'certified',
    name: { ja: '玄 -GEN- グルテンフリー製麺', en: 'Gen — GF Noodle Bar' },
    cuisine: { ja: 'ラーメン', en: 'Ramen' },
    blurb: { ja: '米粉100%の自家製麺ラーメン。小麦不使用の厨房。', en: '100% rice-flour house noodles. Wheat-free kitchen.' },
    price: 2, rating: 4.7, reviews: 528, dist: '徒歩6分', distEn: '6 min walk',
    address: { ja: '東京都新宿区新宿3-21-7', en: '3-21-7 Shinjuku, Shinjuku-ku, Tokyo' },
    station: { ja: '新宿三丁目駅 C2', en: 'Shinjuku-sanchōme · C2' },
    tint: ['#e7ede6', '#bcae9a'],
    hours: [
      { d: 0, o: '1100', c: '2100' }, { d: 1, o: '1130', c: '2300' },
      { d: 2, o: '1130', c: '2300' }, { d: 3, o: '1130', c: '2300' },
      { d: 4, o: '1130', c: '2300' }, { d: 5, o: '1130', c: '2330' },
      { d: 6, o: '1100', c: '2330' },
    ],
    menu: [
      { id: 'm1', name: { ja: '醤油ラーメン（米粉麺）', en: 'Shoyu ramen · rice noodle' }, price: 1200, gf: 'certified', tint: ['#e9dcc4', '#c79a5d'],
        note: { ja: 'GF醤油・専用寸胴。', en: 'GF shoyu, dedicated stockpot.' } },
      { id: 'm2', name: { ja: '味噌ラーメン', en: 'Miso ramen' }, price: 1300, gf: 'certified', tint: ['#ecd9bd', '#cf9b54'],
        note: { ja: '味噌はGF認証品。', en: 'GF-certified miso.' } },
      { id: 'm3', name: { ja: '餃子（米粉皮）', en: 'Gyoza · rice-flour skin' }, price: 580, gf: 'certified', tint: ['#e6e0cf', '#b9a878'],
        note: { ja: '別鍋で調理。', en: 'Cooked in a separate pan.' } },
      { id: 'm4', name: { ja: 'チャーシュー丼', en: 'Chashu rice bowl' }, price: 780, gf: 'on_request', tint: ['#ecdcc4', '#c89b60'],
        note: { ja: 'タレの小麦は要相談。', en: 'Confirm wheat in tare.' } },
    ],
  },
  {
    id: 's3', ward: 4, oriented: true, status: 'certified',
    name: { ja: 'こめ粉ベーカリー Sora', en: 'Sora Rice-Flour Bakery' },
    cuisine: { ja: 'ベーカリー', en: 'Bakery' },
    blurb: { ja: '米粉と玄米のパン専門。卵・乳の選択も可。', en: 'Rice & brown-rice bread specialist. Egg/dairy options.' },
    price: 1, rating: 4.9, reviews: 196, dist: '徒歩3分', distEn: '3 min walk',
    address: { ja: '東京都目黒区自由が丘2-9-1', en: '2-9-1 Jiyūgaoka, Meguro-ku, Tokyo' },
    station: { ja: '自由が丘駅 正面口', en: 'Jiyūgaoka Stn · Front exit' },
    tint: ['#f6ead7', '#e2bf86'],
    hours: [
      { d: 0, o: '0900', c: '1800' }, { d: 1, o: '0800', c: '1900' },
      { d: 2, o: '0800', c: '1900' }, { d: 3, o: '0000', c: '0000' },
      { d: 4, o: '0800', c: '1900' }, { d: 5, o: '0800', c: '1900' },
      { d: 6, o: '0800', c: '1900' },
    ],
    menu: [
      { id: 'm1', name: { ja: '米粉カンパーニュ', en: 'Rice-flour campagne' }, price: 620, gf: 'certified', tint: ['#f0dcbb', '#d6ab6b'],
        note: { ja: '専用工房で焼成。', en: 'Baked in a dedicated workshop.' } },
      { id: 'm2', name: { ja: '玄米食パン', en: 'Brown-rice shokupan' }, price: 540, gf: 'certified', tint: ['#f2e0c2', '#dab06f'],
        note: { ja: '卵・乳不使用。', en: 'Egg- and dairy-free.' } },
      { id: 'm3', name: { ja: 'シナモンロール', en: 'Cinnamon roll' }, price: 420, gf: 'certified', tint: ['#f4dfba', '#e0ac61'],
        note: { ja: '米粉100%。', en: '100% rice flour.' } },
    ],
  },
  {
    id: 's4', ward: 3, oriented: true, status: 'on_request',
    name: { ja: '抹茶 & Co. 和カフェ', en: 'Matcha & Co. Wagashi Café' },
    cuisine: { ja: '和菓子・カフェ', en: 'Wagashi · Café' },
    blurb: { ja: '米粉どら焼きと抹茶。一部メニューは要相談。', en: 'Rice-flour dorayaki & matcha. Some items on request.' },
    price: 2, rating: 4.6, reviews: 241, dist: '徒歩8分', distEn: '8 min walk',
    address: { ja: '東京都港区南青山5-4-2', en: '5-4-2 Minami-Aoyama, Minato-ku, Tokyo' },
    station: { ja: '表参道駅 B1', en: 'Omotesandō · B1' },
    tint: ['#e3ece0', '#a9c19a'],
    hours: [
      { d: 0, o: '1100', c: '1900' }, { d: 1, o: '1100', c: '2000' },
      { d: 2, o: '1100', c: '2000' }, { d: 3, o: '1100', c: '2000' },
      { d: 4, o: '1100', c: '2000' }, { d: 5, o: '1100', c: '2100' },
      { d: 6, o: '1000', c: '2100' },
    ],
    menu: [
      { id: 'm1', name: { ja: '米粉どら焼き', en: 'Rice-flour dorayaki' }, price: 480, gf: 'certified', tint: ['#e5ecd6', '#aebf85'],
        note: { ja: '米粉100%の皮。', en: '100% rice-flour skin.' } },
      { id: 'm2', name: { ja: '抹茶ラテ', en: 'Matcha latte' }, price: 680, gf: 'certified', tint: ['#dfead0', '#9cb377'],
        note: { ja: '豆乳選択可。', en: 'Soy milk available.' } },
      { id: 'm3', name: { ja: '季節の練り切り', en: 'Seasonal nerikiri' }, price: 560, gf: 'on_request', tint: ['#e7edda', '#b3c590'],
        note: { ja: 'つなぎを要確認。', en: 'Confirm binders on request.' } },
    ],
  },
  {
    id: 's5', ward: 1, oriented: true, status: 'on_request',
    name: { ja: 'ひなたカレー', en: 'Hinata Curry' },
    cuisine: { ja: 'カレー', en: 'Curry' },
    blurb: { ja: '米粉ルウのスパイスカレー。サイドは要確認。', en: 'Rice-roux spice curry. Confirm sides on request.' },
    price: 1, rating: 4.5, reviews: 174, dist: '徒歩5分', distEn: '5 min walk',
    address: { ja: '東京都渋谷区宇田川町16-8', en: '16-8 Udagawachō, Shibuya-ku, Tokyo' },
    station: { ja: '渋谷駅 A6', en: 'Shibuya Stn · A6' },
    tint: ['#fbe6d6', '#eaa873'],
    hours: [
      { d: 0, o: '0000', c: '0000' }, { d: 1, o: '1100', c: '2200' },
      { d: 2, o: '1100', c: '2200' }, { d: 3, o: '1100', c: '2200' },
      { d: 4, o: '1100', c: '2200' }, { d: 5, o: '1100', c: '2300' },
      { d: 6, o: '1100', c: '2300' },
    ],
    menu: [
      { id: 'm1', name: { ja: 'チキンカレー', en: 'Chicken curry' }, price: 1180, gf: 'certified', tint: ['#f6dcc0', '#e3a767'],
        note: { ja: '米粉ルウ・GFスパイス。', en: 'Rice roux, GF spices.' } },
      { id: 'm2', name: { ja: 'キーマカレー', en: 'Keema curry' }, price: 1280, gf: 'certified', tint: ['#f4d8b6', '#dd9f5d'],
        note: { ja: '小麦不使用。', en: 'No wheat.' } },
      { id: 'm3', name: { ja: '唐揚げトッピング', en: 'Karaage topping' }, price: 380, gf: 'on_request', tint: ['#f1d6b4', '#d89c5c'],
        note: { ja: '共用フライヤーの場合あり。', en: 'May share a fryer — ask.' } },
    ],
  },
  {
    id: 's6', ward: 6, oriented: false, status: 'contains_hidden_gluten',
    name: { ja: '浅草お好み 和', en: 'Asakusa Okonomi · Nagomi' },
    cuisine: { ja: 'お好み焼き', en: 'Okonomiyaki' },
    blurb: { ja: '米粉お好み焼きを別鉄板で。ソースは小麦含む。', en: 'Rice-flour okonomiyaki on a separate griddle. Sauce contains wheat.' },
    price: 2, rating: 4.3, reviews: 88, dist: '徒歩7分', distEn: '7 min walk',
    address: { ja: '東京都台東区浅草1-33-5', en: '1-33-5 Asakusa, Taito-ku, Tokyo' },
    station: { ja: '浅草駅 1番', en: 'Asakusa Stn · Exit 1' },
    tint: ['#ece7df', '#c2b095'],
    hours: [
      { d: 0, o: '1100', c: '2100' }, { d: 1, o: '1700', c: '2300' },
      { d: 2, o: '1700', c: '2300' }, { d: 3, o: '1700', c: '2300' },
      { d: 4, o: '1700', c: '2300' }, { d: 5, o: '1200', c: '2330' },
      { d: 6, o: '1200', c: '2330' },
    ],
    menu: [
      { id: 'm1', name: { ja: '米粉お好み焼き', en: 'Rice-flour okonomiyaki' }, price: 1380, gf: 'on_request', tint: ['#ece1cb', '#c6a571'],
        note: { ja: '別鉄板で調理可（要予約）。', en: 'Separate griddle on request (reserve).' } },
      { id: 'm2', name: { ja: 'お好みソース', en: 'Okonomi sauce' }, price: 0, gf: 'contains_hidden_gluten', tint: ['#e7ddc8', '#bfa477'],
        note: { ja: '小麦を含みます。GFソースに変更可。', en: 'Contains wheat. GF sauce swap available.' } },
      { id: 'm3', name: { ja: '焼きそば', en: 'Yakisoba' }, price: 980, gf: 'contains_hidden_gluten', tint: ['#e4dac3', '#b89f6f'],
        note: { ja: '小麦麺。米粉麺へ変更不可。', en: 'Wheat noodles — no rice-noodle swap.' } },
    ],
  },
];

const DAYS = [
  { ja: '日', en: 'Sun' }, { ja: '月', en: 'Mon' }, { ja: '火', en: 'Tue' },
  { ja: '水', en: 'Wed' }, { ja: '木', en: 'Thu' }, { ja: '金', en: 'Fri' },
  { ja: '土', en: 'Sat' },
];

Object.assign(window, { WARDS, GF, STORES, DAYS });
