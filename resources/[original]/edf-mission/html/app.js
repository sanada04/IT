var selectedDiff  = 'normal';
var currentParty  = null;
var myServerId    = null;
var sentInvites   = {};  // targetSrc -> true (greyed out after sending)

// ── Difficulty selector ───────────────────────────────────────────
document.getElementById('diff-row').addEventListener('click', function(e) {
    var btn = e.target.closest('.dbtn');
    if (!btn) return;
    selectedDiff = btn.dataset.d;
    document.querySelectorAll('.dbtn').forEach(function(b) {
        b.classList.toggle('sel', b === btn);
    });
});

// ── Party buttons ─────────────────────────────────────────────────
document.getElementById('create-btn').addEventListener('click', function() {
    fetch('https://edf-mission/createParty', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ difficulty: selectedDiff }),
    });
});

document.getElementById('leave-btn').addEventListener('click', function() {
    fetch('https://edf-mission/leaveParty', { method: 'POST', body: '{}' });
    currentParty = null;
    sentInvites  = {};
    renderParty(null);
});

document.getElementById('start-btn').addEventListener('click', function() {
    fetch('https://edf-mission/startMission', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ difficulty: selectedDiff }),
    });
});

document.getElementById('close-btn').addEventListener('click', closeMenu);
document.getElementById('result-close').addEventListener('click', function() {
    fetch('https://edf-mission/resultClose', { method: 'POST', body: '{}' });
    document.getElementById('result').style.display = 'none';
});

document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        if (document.getElementById('result').style.display === 'flex') {
            document.getElementById('result-close').click();
        } else if (document.getElementById('ui').style.display === 'flex') {
            closeMenu();
        }
    }
});

function closeMenu() {
    fetch('https://edf-mission/close', { method: 'POST', body: '{}' });
    document.getElementById('ui').style.display = 'none';
}

// ── Nearby player list ────────────────────────────────────────────
function renderNearby(players) {
    var list  = document.getElementById('nearby-list');
    var count = document.getElementById('nearby-count');

    if (!players || players.length === 0) {
        list.innerHTML   = '<div class="no-nearby">範囲内（15m）にプレイヤーがいません</div>';
        count.textContent = '';
        return;
    }

    count.textContent = players.length + '人';
    list.innerHTML = '';
    players.forEach(function(p) {
        var row = document.createElement('div');
        row.className = 'nearby-item';

        var left = document.createElement('span');
        left.className = 'nearby-name';
        left.innerHTML = esc(p.name) +
            '<span class="nearby-dist">' + p.dist + 'm</span>';

        var btn = document.createElement('button');
        btn.className   = 'invite-btn';
        btn.textContent = '招待';
        btn.dataset.src = p.src;

        if (sentInvites[p.src]) {
            btn.disabled     = true;
            btn.textContent  = '送信済み';
        } else if (!currentParty) {
            btn.disabled    = true;
            btn.title       = 'パーティを作成してから招待できます';
        }

        btn.addEventListener('click', function() {
            if (btn.disabled) return;
            btn.disabled    = true;
            btn.textContent = '送信済み';
            sentInvites[p.src] = true;
            fetch('https://edf-mission/invitePlayer', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ targetSrc: p.src }),
            });
        });

        row.appendChild(left);
        row.appendChild(btn);
        list.appendChild(row);
    });
}

// ── Party member list ─────────────────────────────────────────────
function renderParty(party) {
    var list   = document.getElementById('member-list');
    var count  = document.getElementById('member-count');
    var idDisp = document.getElementById('party-id-display');

    if (!party || !party.members || party.members.length === 0) {
        list.innerHTML    = '<div class="no-member">パーティなし</div>';
        count.textContent = '0 / 8';
        idDisp.textContent = '';
        return;
    }

    count.textContent = party.members.length + ' / 8';
    idDisp.textContent = 'パーティID: ' + party.id;

    list.innerHTML = '';
    party.members.forEach(function(m) {
        var div    = document.createElement('div');
        var isMe   = (m.src === myServerId);
        div.className = 'member-item' + (isMe ? ' me' : '');

        var crown = (m.src === party.leader) ? '<span class="member-crown">♛ </span>' : '';
        var you   = isMe ? ' <span style="font-size:11px;opacity:.6">(あなた)</span>' : '';
        div.innerHTML = crown + esc(m.name) + you;
        list.appendChild(div);
    });

    if (party.difficulty) {
        document.querySelectorAll('.dbtn').forEach(function(b) {
            b.classList.toggle('sel', b.dataset.d === party.difficulty);
        });
        selectedDiff = party.difficulty;
    }
}

// ── Result screen ────────────────────────────────────────────────
function showResult(success, ranking, myId) {
    var title = document.getElementById('result-title');
    title.textContent = success ? 'ミッション完了！' : 'ミッション失敗';
    title.className   = 'result-title' + (success ? '' : ' failed');

    var tbody = document.getElementById('ranking-body');
    tbody.innerHTML = '';

    var medals = ['🥇', '🥈', '🥉'];
    (ranking || []).forEach(function(r, i) {
        var tr = document.createElement('tr');
        if (r.src === myId) tr.className = 'rank-me';
        var medal = medals[i] ? medals[i] + ' ' : '';
        var you   = r.src === myId
            ? ' <span style="font-size:11px;opacity:.6">(あなた)</span>' : '';
        tr.innerHTML =
            '<td>' + medal + (i + 1) + '</td>' +
            '<td>' + esc(r.name) + you + '</td>' +
            '<td>' + r.kills + '</td>';
        tbody.appendChild(tr);
    });

    if (!ranking || ranking.length === 0) {
        tbody.innerHTML =
            '<tr><td colspan="3" style="text-align:center;color:rgba(255,255,255,.3);padding:16px">データなし</td></tr>';
    }

    document.getElementById('result').style.display = 'flex';
}

// ── Wave countdown ───────────────────────────────────────────────
var countdownTimer = null;

function showCountdown(wave, total, seconds) {
    var overlay  = document.getElementById('countdown-overlay');
    var label    = document.getElementById('countdown-wave-label');
    var numEl    = document.getElementById('countdown-number');

    label.textContent = 'WAVE  ' + wave + '  /  ' + total;
    overlay.style.display = 'flex';

    if (countdownTimer) clearTimeout(countdownTimer);

    var count = seconds;

    function tick() {
        if (count > 0) {
            numEl.textContent  = count;
            numEl.style.color  = '#fff';
            numEl.style.animation = 'none';
            void numEl.offsetWidth;
            numEl.style.animation = 'countPop 1s ease-out forwards';
            count--;
            countdownTimer = setTimeout(tick, 1000);
        } else {
            numEl.textContent  = 'GO!';
            numEl.style.color  = '#44ff44';
            numEl.style.animation = 'none';
            void numEl.offsetWidth;
            numEl.style.animation = 'goPop 0.9s ease-out forwards';
            countdownTimer = setTimeout(function() {
                overlay.style.display = 'none';
                numEl.style.color = '#fff';
            }, 900);
        }
    }
    tick();
}

function esc(s) {
    return String(s)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;');
}

// ── FiveM message handler ────────────────────────────────────────
window.addEventListener('message', function(e) {
    var msg = e.data;
    if (!msg) return;

    switch (msg.action) {
        case 'open':
            sentInvites = {};
            document.getElementById('ui').style.display = 'flex';
            renderNearby(msg.nearbyPlayers || []);
            break;

        case 'close':
            document.getElementById('ui').style.display     = 'none';
            document.getElementById('result').style.display = 'none';
            break;

        case 'partyUpdated':
            currentParty = msg.party;
            renderParty(msg.party);
            // Re-render nearby to update invite button states
            break;

        case 'missionStart':
            document.getElementById('ui').style.display = 'none';
            currentParty = null;
            sentInvites  = {};
            break;

        case 'countdown':
            showCountdown(msg.wave, msg.total, msg.seconds);
            break;

        case 'missionEnd':
            myServerId = msg.myId;
            showResult(msg.success, msg.ranking, msg.myId);
            break;
    }
});
