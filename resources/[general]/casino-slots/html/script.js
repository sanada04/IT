'use strict';

const SYMBOLS = [
    { id: 'cherry',  char: '🍒' },
    { id: 'lemon',   char: '🍋' },
    { id: 'orange',  char: '🍊' },
    { id: 'grape',   char: '🍇' },
    { id: 'star',    char: '⭐' },
    { id: 'diamond', char: '💎' },
    { id: 'seven',   char: '7'  },
];
const SYM_MAP = Object.fromEntries(SYMBOLS.map(s => [s.id, s]));

const WIN_INFO = {
    jackpot:  { text: 'JACKPOT!!',  cls: 'jackpot'  },
    bigwin:   { text: 'BIG WIN!',   cls: 'bigwin'   },
    win:      { text: 'WIN!',       cls: 'win'       },
    smallwin: { text: 'SMALL WIN',  cls: 'smallwin' },
    lose:     { text: 'TRY AGAIN',  cls: 'lose'      },
};

let currentBet        = null;
let spinning          = false;
let chanceActive      = false;
let spinSoundInterval = null;
let soundsConfig      = {};

// ── サウンド ──────────────────────────────────────────────

function playSound(key) {
    const def = soundsConfig[key];
    if (!def) return;

    if (def.type === 'mp3') {
        const audio = new Audio(def.file);
        audio.volume = def.volume !== undefined ? def.volume : 1.0;
        audio.play().catch(() => {});
    } else {
        fetch(`https://${GetParentResourceName()}/playSound`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ sound: key })
        });
    }
}

// ── 確変モード ────────────────────────────────────────────

function setChanceMode(active, spinsLeft) {
    const machine = document.getElementById('machine');
    const banner  = document.getElementById('chance-banner');
    const spinsEl = document.getElementById('chance-spins');

    chanceActive = active;
    if (active) {
        machine.classList.add('chance-mode');
        banner.classList.remove('hidden');
        spinsEl.textContent = spinsLeft + 'スピン';
    } else {
        machine.classList.remove('chance-mode');
        banner.classList.add('hidden');
    }
}

function updateChanceSpins(spinsLeft) {
    if (spinsLeft > 0) {
        document.getElementById('chance-spins').textContent = spinsLeft + 'スピン';
    } else {
        setChanceMode(false, 0);
    }
}

// ── 初期化 ──────────────────────────────────────────────

function init(bets, balance) {
    const container = document.getElementById('bet-buttons');
    container.innerHTML = '';
    bets.forEach(amount => {
        const btn = document.createElement('button');
        btn.className = 'bet-btn';
        btn.dataset.amount = amount;
        btn.textContent = '$' + amount.toLocaleString();
        btn.onclick = () => selectBet(amount);
        container.appendChild(btn);
    });

    selectBet(bets[0], true);
    setBalance(balance);
    resetWinDisplay();
    setChanceMode(false, 0);
    initReels();
}

function selectBet(amount, silent = false) {
    if (spinning) return;
    currentBet = amount;
    document.querySelectorAll('.bet-btn').forEach(b => {
        b.classList.toggle('selected', parseInt(b.dataset.amount) === amount);
    });
    if (!silent) playSound('bet');
}

function setBalance(val) {
    document.getElementById('balance').textContent = '$' + Math.floor(val).toLocaleString();
}

// ── リール ──────────────────────────────────────────────

function randomSym() {
    return SYMBOLS[Math.floor(Math.random() * SYMBOLS.length)];
}

function setCenterSym(reelIdx, symId) {
    const sym = SYM_MAP[symId];
    const el = document.getElementById(`r${reelIdx}-center`);
    el.textContent = sym.char;
    el.className = 'sym center' + (symId === 'seven' ? ' seven' : '');
}

function initReels() {
    for (let i = 0; i < 3; i++) {
        const s = randomSym();
        setCenterSym(i, s.id);
        setAdjacentSyms(i, randomSym().char, randomSym().char);
    }
}

function setAdjacentSyms(reelIdx, topChar, bottomChar) {
    document.getElementById(`r${reelIdx}-top`).textContent    = topChar;
    document.getElementById(`r${reelIdx}-bottom`).textContent = bottomChar;
}

function wait(ms) {
    return new Promise(r => setTimeout(r, ms));
}

// ── スピンアニメーション ──────────────────────────────────

let spinIntervals = [null, null, null];

function startSpinning(reelIdx) {
    const center = document.getElementById(`r${reelIdx}-center`);
    const top    = document.getElementById(`r${reelIdx}-top`);
    const bottom = document.getElementById(`r${reelIdx}-bottom`);
    center.classList.add('spinning');
    top.classList.add('spinning');
    bottom.classList.add('spinning');

    spinIntervals[reelIdx] = setInterval(() => {
        const s1 = randomSym(), s2 = randomSym(), s3 = randomSym();
        top.textContent    = s1.char;
        center.textContent = s2.char;
        bottom.textContent = s3.char;
    }, 55);
}

async function stopReel(reelIdx, targetId) {
    clearInterval(spinIntervals[reelIdx]);
    spinIntervals[reelIdx] = null;

    const sym    = SYM_MAP[targetId];
    const center = document.getElementById(`r${reelIdx}-center`);
    const top    = document.getElementById(`r${reelIdx}-top`);
    const bottom = document.getElementById(`r${reelIdx}-bottom`);

    const prev = randomSym();
    const next = randomSym();
    top.textContent    = prev.char;
    bottom.textContent = next.char;

    center.textContent = sym.char;
    center.classList.remove('spinning');
    center.className = 'sym center' + (targetId === 'seven' ? ' seven' : '') + ' stopped';
    top.classList.remove('spinning');
    bottom.classList.remove('spinning');

    playSound('stop');

    await wait(350);
    center.classList.remove('stopped');
}

async function runSpinAnimation(reels) {
    for (let i = 0; i < 3; i++) startSpinning(i);

    for (let i = 0; i < 3; i++) {
        await wait(i === 0 ? 1200 : 400);
        await stopReel(i, reels[i]);
    }
}

// ── 当選表示 ──────────────────────────────────────────────

function resetWinDisplay() {
    const wd = document.getElementById('win-display');
    wd.className = 'win-display';
    document.getElementById('win-text').textContent   = '';
    document.getElementById('win-amount').textContent = '';
    document.querySelector('.reels-frame').classList.remove('win-glow', 'jackpot-glow');
}

function showResult(resultType, payout) {
    const info = WIN_INFO[resultType] || WIN_INFO.lose;
    const wd   = document.getElementById('win-display');
    wd.className = 'win-display ' + info.cls;
    document.getElementById('win-text').textContent = info.text;

    if (payout > 0) {
        document.getElementById('win-amount').textContent = '+$' + payout.toLocaleString();
    }

    const frame = document.querySelector('.reels-frame');
    if (resultType === 'jackpot') {
        frame.classList.add('jackpot-glow');
    } else if (payout > 0) {
        frame.classList.add('win-glow');
    }
}

// ── スピン処理 ──────────────────────────────────────────────

async function onSpin() {
    if (spinning || currentBet === null) return;
    spinning = true;

    const spinBtn  = document.getElementById('spin-btn');
    const closeBtn = document.getElementById('close-btn');
    const betBtns  = document.querySelectorAll('.bet-btn');

    spinBtn.disabled  = true;
    closeBtn.disabled = true;
    betBtns.forEach(b => b.disabled = true);
    resetWinDisplay();

    // スピン音ループ開始
    playSound('spin');
    spinSoundInterval = setInterval(() => playSound('spin'), 650);

    // サーバーにスピン要求
    let result;
    try {
        result = await fetch(`https://${GetParentResourceName()}/spin`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ bet: currentBet })
        }).then(r => r.json());
    } catch (e) {
        clearInterval(spinSoundInterval);
        spinSoundInterval = null;
        spinning = false;
        spinBtn.disabled  = false;
        closeBtn.disabled = false;
        betBtns.forEach(b => b.disabled = false);
        return;
    }

    if (!result.success) {
        clearInterval(spinSoundInterval);
        spinSoundInterval = null;
        const msgs = {
            no_money:    '所持金が足りません',
            invalid_bet: '無効な賭け金です',
            error:       'エラーが発生しました',
        };
        document.getElementById('win-text').textContent = msgs[result.reason] || 'エラー';
        document.getElementById('win-display').className = 'win-display lose';
        spinning = false;
        spinBtn.disabled  = false;
        closeBtn.disabled = false;
        betBtns.forEach(b => b.disabled = false);
        return;
    }

    // リールアニメーション（stopReel 内で stop 音再生）
    await runSpinAnimation(result.reels);

    // スピン音停止
    clearInterval(spinSoundInterval);
    spinSoundInterval = null;

    // 結果音
    const rtype = result.resultType;
    if (rtype === 'jackpot') {
        playSound('jackpot');
    } else if (rtype === 'bigwin') {
        playSound('bigwin');
    } else if (rtype === 'win' || rtype === 'smallwin') {
        playSound('win');
    } else {
        playSound('lose');
    }

    // 結果表示
    showResult(result.resultType, result.payout);

    // 確変突入
    if (result.chanceEntered) {
        await wait(400);
        playSound('chance');
        setChanceMode(true, result.chanceLeft);
    } else if (result.chanceLeft !== undefined) {
        updateChanceSpins(result.chanceLeft);
    }

    // 残高更新
    if (result.newBalance !== undefined) {
        setBalance(result.newBalance);
    } else {
        const bal = await fetch(`https://${GetParentResourceName()}/getBalance`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        }).then(r => r.json());
        if (bal.balance !== undefined) setBalance(bal.balance);
    }

    await wait(500);
    spinning = false;
    spinBtn.disabled  = false;
    closeBtn.disabled = false;
    betBtns.forEach(b => b.disabled = false);
}

// ── 閉じる ──────────────────────────────────────────────

function onClose() {
    if (spinning) return;
    document.getElementById('overlay').classList.add('hidden');
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

// ── NUI メッセージ受信 ──────────────────────────────────────

window.addEventListener('message', function(event) {
    const data = event.data;
    if (data.action === 'open') {
        if (data.sounds) soundsConfig = data.sounds;
        document.getElementById('overlay').classList.remove('hidden');
        init(data.bets, data.balance);
    }
});

// ESC で閉じる
window.addEventListener('keyup', function(e) {
    if (e.key === 'Escape') onClose();
});
