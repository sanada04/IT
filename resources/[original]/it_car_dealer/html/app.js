'use strict';

// ===== 状態 =====
let allVehicles   = [];
let allCategories = [];
let currentCat    = 'all';
let selectedVehicle = null;
let notifyTimer   = null;
let pendingBuyVehicle = null;

// ===== NUI ヘルパー =====
const resourceName = (typeof GetParentResourceName === 'function')
    ? GetParentResourceName()
    : 'it_car_dealer';

function nuiPost(action, data = {}) {
    return fetch(`https://${resourceName}/${action}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    });
}

// ===== 価格フォーマット =====
function formatPrice(price) {
    return '¥ ' + Number(price).toLocaleString('ja-JP');
}

// ===== 通知 =====
function showNotify(message, type = 'success') {
    const el   = document.getElementById('notification');
    const icon = document.getElementById('notification-icon');
    const text = document.getElementById('notification-text');
    icon.textContent = type === 'success' ? '✓' : '✕';
    text.textContent = message;
    el.className = `notification ${type}`;
    el.classList.remove('hidden');
    if (notifyTimer) clearTimeout(notifyTimer);
    notifyTimer = setTimeout(() => el.classList.add('hidden'), 4000);
}

// ===== カテゴリーボタン生成 =====
function buildCategories() {
    const nav = document.getElementById('category-nav');
    nav.innerHTML = '';
    allCategories.forEach(cat => {
        const count = cat.id === 'all'
            ? allVehicles.length
            : allVehicles.filter(v => v.category === cat.id).length;
        const btn = document.createElement('button');
        btn.className = 'cat-btn' + (cat.id === currentCat ? ' active' : '');
        btn.dataset.catId = cat.id;
        btn.innerHTML = `
            <span class="cat-icon">${cat.icon}</span>
            <span>${cat.label}</span>
            <span class="cat-count">${count}</span>
        `;
        btn.addEventListener('click', () => selectCategory(cat.id, cat.label));
        nav.appendChild(btn);
    });
}

// ===== カテゴリー選択 =====
function selectCategory(catId, catLabel) {
    currentCat = catId;
    document.querySelectorAll('.cat-btn').forEach(b => {
        b.classList.toggle('active', b.dataset.catId === catId);
    });
    const filtered = catId === 'all' ? allVehicles : allVehicles.filter(v => v.category === catId);
    document.getElementById('content-title').textContent = catLabel;
    document.getElementById('vehicle-count').textContent = filtered.length + '台';
    buildGrid(filtered);
}

// ===== 車両グリッド生成 =====
function buildGrid(vehicles) {
    const grid = document.getElementById('vehicle-grid');
    grid.innerHTML = '';
    vehicles.forEach(v => {
        const card = document.createElement('div');
        card.className = 'vehicle-card';
        card.innerHTML = `
            <div class="card-img-wrap">
                <img src="${v.img}" alt="${v.label}" onerror="this.src=''">
            </div>
            <div class="card-body">
                <div class="card-label">${v.label}</div>
                <div class="card-price">${formatPrice(v.price)}</div>
            </div>
        `;
        card.addEventListener('click', () => openModal(v));
        grid.appendChild(card);
    });
}

// ===== 車両モーダルを開く =====
function openModal(vehicle) {
    selectedVehicle = vehicle;
    const catObj = allCategories.find(c => c.id === vehicle.category);
    const catLabel = catObj ? catObj.label : vehicle.category;

    document.getElementById('modal-img').src             = vehicle.img;
    document.getElementById('modal-vehicle-name').textContent = vehicle.label;
    document.getElementById('modal-price').textContent        = formatPrice(vehicle.price);
    document.getElementById('modal-category-tag').textContent = catLabel;

    // スタッツバー
    const stats = vehicle.stats || { speed: 50, accel: 50, brake: 50, handling: 50 };
    setStatBar('stat-speed',    stats.speed);
    setStatBar('stat-accel',    stats.accel);
    setStatBar('stat-brake',    stats.brake);
    setStatBar('stat-handling', stats.handling);

    document.getElementById('vehicle-modal').classList.remove('hidden');
    // バーアニメーション用に少し遅らせる
    requestAnimationFrame(() => {
        setStatBar('stat-speed',    stats.speed);
        setStatBar('stat-accel',    stats.accel);
        setStatBar('stat-brake',    stats.brake);
        setStatBar('stat-handling', stats.handling);
    });
}

function setStatBar(id, value) {
    const fill = document.getElementById(id);
    const val  = document.getElementById(id + '-val');
    if (fill) fill.style.width = value + '%';
    if (val)  val.textContent  = value;
}

function closeModal() {
    document.getElementById('vehicle-modal').classList.add('hidden');
    selectedVehicle = null;
}

// ===== 3Dプレビュー開始 =====
function startPreview(vehicle) {
    closeModal();
    document.getElementById('preview-vehicle-label').textContent = vehicle.label;
    document.getElementById('preview-vehicle-price').textContent = formatPrice(vehicle.price);
    document.getElementById('preview-overlay').classList.remove('hidden');
    document.getElementById('app').classList.add('hidden');
    selectedVehicle = vehicle;
    nuiPost('preview', { model: vehicle.model, vehicle: vehicle });
}

// ===== ショップに戻る =====
function returnToShop() {
    document.getElementById('preview-overlay').classList.add('hidden');
    document.getElementById('app').classList.remove('hidden');
    selectedVehicle = null;
}

// ===== 購入確認ダイアログ =====
function openConfirmDialog(vehicle) {
    pendingBuyVehicle = vehicle;
    const msg = `<strong>${vehicle.label}</strong> を購入しますか？<br><br>` +
                `購入金額：<strong>${formatPrice(vehicle.price)}</strong>`;
    document.getElementById('confirm-message').innerHTML = msg;
    document.getElementById('confirm-dialog').classList.remove('hidden');
}

function closeConfirmDialog() {
    document.getElementById('confirm-dialog').classList.add('hidden');
    pendingBuyVehicle = null;
}

function executeBuy() {
    if (!pendingBuyVehicle) return;
    nuiPost('buy', {
        model: pendingBuyVehicle.model,
        label: pendingBuyVehicle.label,
        price: pendingBuyVehicle.price
    });
    closeConfirmDialog();
    closeModal();
    document.getElementById('preview-overlay').classList.add('hidden');
}

// ===== NUI メッセージ受信 =====
window.addEventListener('message', (e) => {
    const data = e.data;
    if (!data || !data.action) return;

    switch (data.action) {
        case 'open':
            allVehicles   = data.vehicles   || [];
            allCategories = data.categories || [];
            currentCat    = 'all';
            // ショップ名をサイドバーに反映
            document.querySelector('.brand-sub').textContent = data.shopLabel || 'カーディーラー';
            buildCategories();
            selectCategory('all', '全車種');
            document.getElementById('app').classList.remove('hidden');
            document.getElementById('preview-overlay').classList.add('hidden');
            break;

        case 'close':
            document.getElementById('app').classList.add('hidden');
            document.getElementById('preview-overlay').classList.add('hidden');
            closeModal();
            closeConfirmDialog();
            break;

        case 'enterPreview':
            // クライアント側でカメラ準備完了（必要なら追加処理）
            break;

        case 'returnToShop':
            returnToShop();
            break;

        case 'previewFailed':
            showNotify('プレビューの読み込みに失敗しました', 'error');
            returnToShop();
            break;

        case 'purchaseFailed':
            showNotify(data.message || '購入に失敗しました', 'error');
            break;
    }
});

// ===== イベントリスナー =====
document.addEventListener('DOMContentLoaded', () => {
    // モーダルを閉じる
    document.getElementById('modal-close-btn').addEventListener('click', closeModal);
    document.getElementById('modal-backdrop').addEventListener('click', closeModal);

    // 3Dプレビューボタン
    document.getElementById('btn-3d-preview').addEventListener('click', () => {
        if (selectedVehicle) startPreview(selectedVehicle);
    });

    // モーダル内の購入ボタン
    document.getElementById('btn-buy').addEventListener('click', () => {
        if (selectedVehicle) openConfirmDialog(selectedVehicle);
    });

    // プレビューオーバーレイ内のボタン
    document.getElementById('btn-preview-back').addEventListener('click', () => {
        nuiPost('backToShop');
    });

    document.getElementById('btn-preview-buy').addEventListener('click', () => {
        if (selectedVehicle) openConfirmDialog(selectedVehicle);
    });

    // 購入確認ダイアログ
    document.getElementById('btn-confirm').addEventListener('click', executeBuy);
    document.getElementById('btn-cancel').addEventListener('click', closeConfirmDialog);
    document.getElementById('confirm-backdrop').addEventListener('click', closeConfirmDialog);

    // ショップを閉じる
    document.getElementById('btn-close-shop').addEventListener('click', () => {
        nuiPost('close');
    });

    // ESC キー
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
            if (!document.getElementById('confirm-dialog').classList.contains('hidden')) {
                closeConfirmDialog();
            } else if (!document.getElementById('vehicle-modal').classList.contains('hidden')) {
                closeModal();
            } else if (!document.getElementById('preview-overlay').classList.contains('hidden')) {
                nuiPost('backToShop');
            } else if (!document.getElementById('app').classList.contains('hidden')) {
                nuiPost('close');
            }
        }
    });
});
