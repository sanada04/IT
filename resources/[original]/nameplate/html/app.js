var COLORS = ['#ffffff','#ff5555','#ff9933','#ffdd22','#44ee66','#33ccff','#bb55ff','#ff44bb'];
var state  = { nc: '#ffffff', tc: '#ffd700' };

// ── ネームプレート描画 ────────────────────────────────────────────

function esc(s) {
    return String(s)
        .replace(/&/g,'&amp;')
        .replace(/</g,'&lt;')
        .replace(/>/g,'&gt;');
}

function toRgba(a) {
    if (!a || a.length < 3) return '#fff';
    return 'rgba(' + a[0] + ',' + a[1] + ',' + a[2] + ',' + ((a[3] != null ? a[3] : 255) / 255).toFixed(2) + ')';
}

function renderPlates(list) {
    var layer = document.getElementById('np-layer');
    if (!list || list.length === 0) { layer.innerHTML = ''; return; }

    var html = '';
    for (var i = 0; i < list.length; i++) {
        var p  = list[i];
        var sc = Math.max(0.45, 1.0 - p.dist * 0.035);
        var fs = Math.round(15 * sc);
        var ts = Math.round(13 * sc);
        var shadow = '1px 1px 0 #000,-1px -1px 0 #000,1px -1px 0 #000,-1px 1px 0 #000';

        html += '<div style="position:absolute;left:' + (p.x * 100).toFixed(2) + '%;top:' + (p.y * 100).toFixed(2) + '%;transform:translate(-50%,-100%);text-align:center;white-space:nowrap;">';
        if (p.title) {
            html += '<div style="font-size:' + ts + 'px;font-weight:600;color:' + toRgba(p.tc) + ';text-shadow:' + shadow + ';">【' + esc(p.title) + '】</div>';
        }
        html += '<div style="font-size:' + fs + 'px;font-weight:700;color:' + toRgba(p.nc) + ';text-shadow:' + shadow + ';">' + esc(p.name) + '</div>';
        html += '</div>';
    }
    layer.innerHTML = html;
}

// ── 設定パネル ────────────────────────────────────────────────────

function hexToRgba(hex) {
    hex = hex.replace('#','');
    return [parseInt(hex.slice(0,2),16), parseInt(hex.slice(2,4),16), parseInt(hex.slice(4,6),16), 255];
}

function rgbaToHex(a) {
    return '#' + [a[0],a[1],a[2]].map(function(v){ return Math.max(0,Math.min(255,v)).toString(16).padStart(2,'0'); }).join('');
}

function buildSwatches(rowId, key, pickerId) {
    var row = document.getElementById(rowId);
    row.innerHTML = '';
    COLORS.forEach(function(c) {
        var btn = document.createElement('button');
        btn.className = 'sw' + (state[key] === c ? ' on' : '');
        btn.style.backgroundColor = c;
        btn.dataset.c = c;
        btn.addEventListener('click', function() {
            state[key] = c;
            row.querySelectorAll('.sw').forEach(function(s){ s.classList.toggle('on', s.dataset.c === c); });
            document.getElementById(pickerId).value = c;
            updatePreview();
        });
        row.appendChild(btn);
    });
}

function updatePreview() {
    var name  = document.getElementById('ni').value || '（名前未設定）';
    var title = document.getElementById('ti').value;
    var pn = document.getElementById('pv-name');
    var pt = document.getElementById('pv-title');
    pn.textContent = name;
    pn.style.color = state.nc;
    if (title.trim()) {
        pt.textContent = '【' + title + '】';
        pt.style.color = state.tc;
    } else {
        pt.textContent = '';
    }
}

function updCnt(inId, cntId) {
    var el = document.getElementById(inId);
    document.getElementById(cntId).textContent = el.value.length + ' / ' + el.maxLength;
}

function openUI(data) {
    data = data || {};
    state.nc = Array.isArray(data.nameColor)  ? rgbaToHex(data.nameColor)  : '#ffffff';
    state.tc = Array.isArray(data.titleColor) ? rgbaToHex(data.titleColor) : '#ffd700';

    document.getElementById('ni').value  = data.name  || '';
    document.getElementById('ti').value  = data.title || '';
    document.getElementById('ncp').value = state.nc;
    document.getElementById('tcp').value = state.tc;

    updCnt('ni','nc'); updCnt('ti','tc');
    buildSwatches('ns','nc','ncp');
    buildSwatches('ts','tc','tcp');
    updatePreview();

    var ui = document.getElementById('ui');
    ui.style.display = 'flex';
    document.getElementById('ni').focus();
}

function closeUI() {
    document.getElementById('ui').style.display = 'none';
    fetch('https://nameplate/close', { method: 'POST', body: '{}' });
}

function saveUI() {
    var name  = document.getElementById('ni').value.trim();
    var title = document.getElementById('ti').value.trim();
    if (!name) {
        var el = document.getElementById('ni');
        el.classList.add('err');
        setTimeout(function(){ el.classList.remove('err'); }, 500);
        return;
    }
    fetch('https://nameplate/save', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name: name, title: title, nameColor: hexToRgba(state.nc), titleColor: hexToRgba(state.tc) })
    });
    document.getElementById('ui').style.display = 'none';
}

// ── イベント ──────────────────────────────────────────────────────

document.getElementById('ni').addEventListener('input',  function(){ updCnt('ni','nc'); updatePreview(); });
document.getElementById('ti').addEventListener('input',  function(){ updCnt('ti','tc'); updatePreview(); });
document.getElementById('ncp').addEventListener('input', function(){ state.nc = this.value; document.getElementById('ns').querySelectorAll('.sw').forEach(function(s){ s.classList.remove('on'); }); updatePreview(); });
document.getElementById('tcp').addEventListener('input', function(){ state.tc = this.value; document.getElementById('ts').querySelectorAll('.sw').forEach(function(s){ s.classList.remove('on'); }); updatePreview(); });
document.getElementById('save-btn').addEventListener('click',   saveUI);
document.getElementById('cancel-btn').addEventListener('click', closeUI);
document.getElementById('close-btn').addEventListener('click',  closeUI);

document.addEventListener('keydown', function(e) {
    if (document.getElementById('ui').style.display !== 'flex') return;
    if (e.key === 'Escape') closeUI();
    if (e.key === 'Enter' && e.target.tagName !== 'BUTTON') saveUI();
});

// ── FiveMメッセージ受信 ───────────────────────────────────────────

window.addEventListener('message', function(e) {
    var msg = e.data;
    if (!msg) return;
    if (msg.action === 'plates') renderPlates(msg.plates);
    if (msg.action === 'open')   openUI(msg.data);
    if (msg.action === 'close')  document.getElementById('ui').style.display = 'none';
});
