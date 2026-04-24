'use strict';

const resourceName = (typeof GetParentResourceName === 'function')
    ? GetParentResourceName() : 'it_vehicle_sell';

let allVehicles    = [];
let selectedPlates = new Set();
let sellRate       = 1 / 3;
let notifyTimer    = null;

// ===== NUI ヘルパー =====
function nuiPost(action, data = {}) {
    return fetch(`https://${resourceName}/${action}`, {
        method:  'POST',
        headers: { 'Content-Type': 'application/json' },
        body:    JSON.stringify(data),
    });
}

// ===== ユーティリティ =====
function formatPrice(n) {
    return '¥ ' + Number(n).toLocaleString('ja-JP');
}

function condColor(pct) {
    if (pct >= 70) return '#22c55e';
    if (pct >= 40) return '#f59e0b';
    return '#ef4444';
}

function calcSellPrice(marketPrice) {
    return Math.floor(marketPrice * sellRate);
}

function showError(msg) {
    const el = document.getElementById('notification');
    document.getElementById('notify-icon').textContent = '✕';
    document.getElementById('notify-text').textContent = msg;
    el.className = 'notification error';
    el.classList.remove('hidden');
    if (notifyTimer) clearTimeout(notifyTimer);
    notifyTimer = setTimeout(() => el.classList.add('hidden'), 4000);
}

// ===== 選択バー更新 =====
function updateSelectionBar() {
    const count = selectedPlates.size;
    let total = 0;
    selectedPlates.forEach(plate => {
        const v = allVehicles.find(x => x.plate === plate);
        if (v) total += calcSellPrice(v.marketPrice);
    });

    document.getElementById('sel-count').textContent = `${count}台選択中`;
    document.getElementById('sel-total').textContent = formatPrice(total);
    document.getElementById('btn-sell-selected').disabled = count === 0;

    document.querySelectorAll('.vehicle-card').forEach(card => {
        card.classList.toggle('selected', selectedPlates.has(card.dataset.plate));
    });
}

// ===== カードのトグル =====
function toggleCard(plate) {
    if (selectedPlates.has(plate)) {
        selectedPlates.delete(plate);
    } else {
        selectedPlates.add(plate);
    }
    updateSelectionBar();
}

// ===== 車両リスト構築 =====
function buildVehicleList() {
    const list = document.getElementById('vehicle-list');
    document.getElementById('vehicle-count-label').textContent =
        `${allVehicles.length}台の車両`;
    list.innerHTML = '';

    allVehicles.forEach(v => {
        const price = calcSellPrice(v.marketPrice);
        const card  = document.createElement('div');
        card.className = 'vehicle-card';
        card.dataset.plate = v.plate;
        card.innerHTML = `
            <div class="card-check">✓</div>
            <div class="card-top">
                <div>
                    <div class="card-name">${v.label}</div>
                    <div class="card-brand">${v.brand || ''}</div>
                </div>
            </div>
            <div class="card-plate">${v.plate}</div>
            <div class="card-conditions">
                <div class="cond-row">
                    <span class="cond-label">燃料</span>
                    <div class="cond-track"><div class="cond-fill" style="width:${v.fuel}%;background:${condColor(v.fuel)}"></div></div>
                    <span class="cond-val">${v.fuel}%</span>
                </div>
                <div class="cond-row">
                    <span class="cond-label">エンジン</span>
                    <div class="cond-track"><div class="cond-fill" style="width:${v.engine}%;background:${condColor(v.engine)}"></div></div>
                    <span class="cond-val">${v.engine}%</span>
                </div>
                <div class="cond-row">
                    <span class="cond-label">ボディ</span>
                    <div class="cond-track"><div class="cond-fill" style="width:${v.body}%;background:${condColor(v.body)}"></div></div>
                    <span class="cond-val">${v.body}%</span>
                </div>
            </div>
            <div class="card-price-row">
                <span class="card-price-label">売却価格（市場価格の1/3）</span>
                <span class="card-price">${price > 0 ? formatPrice(price) : '価格不明'}</span>
            </div>
        `;
        card.addEventListener('click', () => toggleCard(v.plate));
        list.appendChild(card);
    });

    updateSelectionBar();
}

// ===== 確認ダイアログ =====
function openConfirmDialog() {
    if (selectedPlates.size === 0) return;

    const selected = allVehicles.filter(v => selectedPlates.has(v.plate));
    let total = 0;

    document.getElementById('confirm-list').innerHTML = selected.map(v => {
        const price = calcSellPrice(v.marketPrice);
        total += price;
        return `
            <div class="confirm-item">
                <div class="confirm-item-left">
                    <div class="confirm-item-name">${v.label}${v.brand ? ` (${v.brand})` : ''}</div>
                    <div class="confirm-item-plate">${v.plate}</div>
                </div>
                <div class="confirm-item-price">${price > 0 ? formatPrice(price) : '¥ 0'}</div>
            </div>
        `;
    }).join('');

    document.getElementById('confirm-total').textContent = formatPrice(total);
    document.getElementById('confirm-dialog').classList.remove('hidden');
}

function closeConfirmDialog() {
    document.getElementById('confirm-dialog').classList.add('hidden');
}

// ===== UI 開閉 =====
function closeUI() {
    document.getElementById('app').classList.add('hidden');
    closeConfirmDialog();
    selectedPlates.clear();
    nuiPost('closeUI');
}

function executeSell() {
    if (selectedPlates.size === 0) return;
    nuiPost('sellVehicles', { plates: [...selectedPlates] });
    document.getElementById('app').classList.add('hidden');
    closeConfirmDialog();
    selectedPlates.clear();
}

// ===== イベントリスナー =====
document.getElementById('btn-close').addEventListener('click', closeUI);
document.getElementById('btn-sell-selected').addEventListener('click', openConfirmDialog);
document.getElementById('dialog-close').addEventListener('click', closeConfirmDialog);
document.getElementById('btn-confirm-cancel').addEventListener('click', closeConfirmDialog);
document.getElementById('btn-confirm-sell').addEventListener('click', executeSell);

document.addEventListener('keydown', e => {
    if (e.key !== 'Escape') return;
    if (!document.getElementById('confirm-dialog').classList.contains('hidden')) {
        closeConfirmDialog();
    } else {
        closeUI();
    }
});

// ===== インタラクトヒント =====
let hintLeaveTimer = null;

function showHint() {
    const el = document.getElementById('interact-hint');
    if (hintLeaveTimer) { clearTimeout(hintLeaveTimer); hintLeaveTimer = null; }
    el.classList.remove('hidden', 'hint-leave');
    void el.offsetWidth; // reflow でアニメーションをリセット
    el.classList.add('hint-enter');
}

function hideHint() {
    const el = document.getElementById('interact-hint');
    el.classList.remove('hint-enter');
    el.classList.add('hint-leave');
    hintLeaveTimer = setTimeout(() => {
        el.classList.add('hidden');
        el.classList.remove('hint-leave');
        hintLeaveTimer = null;
    }, 220);
}

// ===== NUI メッセージ受信 =====
window.addEventListener('message', e => {
    const data = e.data;
    if (data.action === 'showHint') {
        showHint();
    } else if (data.action === 'hideHint') {
        hideHint();
    } else if (data.action === 'openUI') {
        allVehicles    = data.vehicles || [];
        sellRate       = data.sellRate || (1 / 3);
        selectedPlates.clear();
        buildVehicleList();
        document.getElementById('app').classList.remove('hidden');
    }
});
