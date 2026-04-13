(function () {
  const TEXT_MAP = new Map([
    // Main tabs / pages
    ['Dashboard', 'ダッシュボード'],
    ['Citizens', '市民'],
    ['Reports', '報告書'],
    ['Dispatch', 'ディスパッチ'],

    // Dashboard
    ['Recent Dispatches', '最近の通報'],
    ['Active Units', '稼働ユニット'],
    ['Weekly Reports', '週間レポート'],
    ['This Week', '今週'],
    ['Last Week', '先週'],
    ['No data', 'データなし'],

    // Shared actions
    ['Search', '検索'],
    ['Create', '作成'],
    ['View', '表示'],
    ['Save', '保存'],
    ['Cancel', 'キャンセル'],
    ['Close', '閉じる'],
    ['Delete', '削除'],
    ['Back', '戻る'],
    ['Attach', '参加'],
    ['Detach', '離脱'],
    ['Refresh', '更新'],
    ['Clear', 'クリア'],

    // Citizens
    ['Name', '氏名'],
    ['Phone', '電話番号'],
    ['Profile', 'プロフィール'],
    ['Gender', '性別'],
    ['Date of Birth', '生年月日'],
    ['Licenses', 'ライセンス'],
    ['Notes', 'メモ'],
    ['Arrests', '逮捕歴'],
    ['Properties', '不動産'],
    ['Vehicles', '車両'],

    // Reports
    ['Report', '報告書'],
    ['Title', 'タイトル'],
    ['Description', '説明'],
    ['Officers', '警察官'],
    ['Suspects', '容疑者'],
    ['Victims', '被害者'],
    ['Evidence', '証拠'],
    ['Charges', '罪状'],
    ['Warrants', '令状'],
    ['Case', '事件'],
    ['Status', 'ステータス'],
    ['Priority', '優先度'],

    // Dispatch
    ['Call', '通報'],
    ['Calls', '通報一覧'],
    ['Information', '詳細情報'],
    ['Street', '場所'],
    ['Units', 'ユニット'],
    ['Respond', '対応'],
    ['Route', 'ルート設定'],
    ['Time', '時間'],
  ]);

  const PARTIAL_MAP = [
    ['Search...', '検索...'],
    ['No calls', '通報はありません'],
    ['No Calls', '通報はありません'],
    ['Latest Dispatch', '最新通報'],
    ['Recent Reports', '最近の報告書'],
    ['Open', '開く'],
  ];

  function translateString(input) {
    if (!input) return input;
    const raw = input.trim();
    if (!raw) return input;

    if (TEXT_MAP.has(raw)) {
      return input.replace(raw, TEXT_MAP.get(raw));
    }

    let out = input;
    for (const [from, to] of PARTIAL_MAP) {
      if (out.includes(from)) out = out.split(from).join(to);
    }
    return out;
  }

  function patchNodeText(node) {
    const next = translateString(node.nodeValue);
    if (next !== node.nodeValue) node.nodeValue = next;
  }

  function patchElement(el) {
    if (!(el instanceof HTMLElement)) return;

    if (el.placeholder) {
      const p = translateString(el.placeholder);
      if (p !== el.placeholder) el.placeholder = p;
    }

    if (el.title) {
      const t = translateString(el.title);
      if (t !== el.title) el.title = t;
    }
  }

  function walk(root) {
    if (!root) return;
    const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT);
    let n;
    while ((n = walker.nextNode())) patchNodeText(n);

    if (root instanceof Element) {
      patchElement(root);
      root.querySelectorAll('*').forEach(patchElement);
    }
  }

  const observer = new MutationObserver((mutations) => {
    for (const m of mutations) {
      if (m.type === 'characterData' && m.target) {
        patchNodeText(m.target);
        continue;
      }
      m.addedNodes.forEach((node) => {
        if (node.nodeType === Node.TEXT_NODE) patchNodeText(node);
        else walk(node);
      });
    }
  });

  function start() {
    walk(document.body);
    observer.observe(document.body, {
      childList: true,
      subtree: true,
      characterData: true,
      attributes: true,
      attributeFilter: ['placeholder', 'title'],
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', start, { once: true });
  } else {
    start();
  }
})();
