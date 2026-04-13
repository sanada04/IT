const UI = document.getElementById("ui");
const RANKING = document.getElementById("ranking");
const DIG_PROGRESS = document.getElementById("dig-progress");
const PROGRESS_FILL = document.getElementById("progress-fill");
const TAB_BUY = document.getElementById("tab-buy");
const TAB_RANKING = document.getElementById("tab-ranking");
const TAB_SELL = document.getElementById("tab-sell");
const SELL_LIST = document.getElementById("sell-list");
const SELL_EMPTY = document.getElementById("sell-empty");
const DETECTOR_PRICE = document.getElementById("detector-price");
const BTN_BUY_DETECTOR = document.getElementById("btn-buy-detector");
const BTN_CLOSE_X = document.getElementById("btn-close-x");
const BTN_SELL_ALL_GLOBAL = document.getElementById("btn-sell-all-global");

let shopData = null;
var localeStrings = {};
function applyLocale(strings) {
    if (!strings) return;
    localeStrings = strings;
    document.querySelectorAll("[data-i18n]").forEach(function (el) {
        var k = el.getAttribute("data-i18n");
        if (strings[k]) el.textContent = strings[k];
    });
    document.querySelectorAll("[data-i18n-html]").forEach(function (el) {
        var k = el.getAttribute("data-i18n-html");
        if (strings[k]) el.innerHTML = strings[k];
    });
}

var metalDetectorBeepLast = 0;
var metalDetectorBeepInterval = 0;
var metalDetectorBeepVolume = 0.5;
var metalDetectorAudioContext = null;

function metalDetectorBeepTick(intervalMs, volume) {
    metalDetectorBeepInterval = intervalMs;
    metalDetectorBeepVolume = typeof volume === "number" ? Math.max(0, Math.min(1, volume)) : 0.5;
    var now = Date.now();
    if (now - metalDetectorBeepLast >= metalDetectorBeepInterval) {
        metalDetectorPlayBeep();
        metalDetectorBeepLast = now;
    }
}

function metalDetectorBeepStop() {
    metalDetectorBeepLast = 0;
}

function metalDetectorPlayBeep() {
    try {
        if (!metalDetectorAudioContext) {
            metalDetectorAudioContext = new (window.AudioContext || window.webkitAudioContext)();
        }
        var ctx = metalDetectorAudioContext;
        if (ctx.state === "suspended") ctx.resume();
        var osc = ctx.createOscillator();
        var gain = ctx.createGain();
        osc.type = "sine";
        osc.frequency.value = 800;
        osc.connect(gain);
        gain.connect(ctx.destination);
        gain.gain.setValueAtTime(0.15 * metalDetectorBeepVolume, ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.06);
        osc.start(ctx.currentTime);
        osc.stop(ctx.currentTime + 0.06);
    } catch (e) {}
}

function metalDetectorPlayDigReadySound() {
    try {
        if (!metalDetectorAudioContext) {
            metalDetectorAudioContext = new (window.AudioContext || window.webkitAudioContext)();
        }
        var ctx = metalDetectorAudioContext;
        if (ctx.state === "suspended") ctx.resume();
        var t = ctx.currentTime;
        [1200, 1400].forEach(function (freq, i) {
            var osc = ctx.createOscillator();
            var gain = ctx.createGain();
            osc.type = "sine";
            osc.frequency.value = freq;
            osc.connect(gain);
            gain.connect(ctx.destination);
            gain.gain.setValueAtTime(0, t + i * 0.08);
            gain.gain.setValueAtTime(0.2, t + i * 0.08 + 0.01);
            gain.gain.exponentialRampToValueAtTime(0.001, t + i * 0.08 + 0.12);
            osc.start(t + i * 0.08);
            osc.stop(t + i * 0.08 + 0.12);
        });
    } catch (e) {}
}

/* ----- タブ切り替え ----- */
document.querySelectorAll(".tab-btn").forEach(function (btn) {
    btn.addEventListener("click", function () {
        var tab = this.getAttribute("data-tab");
        document.querySelectorAll(".tab-btn").forEach(function (b) { b.classList.remove("active"); });
        document.querySelectorAll(".tab-content").forEach(function (c) { c.classList.remove("active"); });
        this.classList.add("active");
        var content = document.getElementById("tab-" + tab);
        if (content) content.classList.add("active");
        if (tab === "ranking") {
            fetch("https://" + GetParentResourceName() + "/getRanking", { method: "POST" });
        }
    });
});

/* ----- NUI メッセージ ----- */
window.addEventListener("message", function (event) {
    var data = event.data;

    if (data.type === "open") {
        if (data.strings) applyLocale(data.strings);
        UI.classList.remove("hidden");
        UI.style.display = "block";
        document.querySelector(".tab-btn[data-tab='buy']").click();
    }

    if (data.type === "shopData") {
        shopData = data.data || null;
        if (shopData) {
            var price = shopData.metalDetectorPrice != null ? shopData.metalDetectorPrice : 0;
            DETECTOR_PRICE.textContent = "$" + price;
            var items = shopData.sellItems || [];
            if (items.length === 0) {
                SELL_LIST.innerHTML = "";
                SELL_EMPTY.classList.remove("hidden");
            } else {
                SELL_EMPTY.classList.add("hidden");
                var html = "";
                items.forEach(function (it) {
                    var name = it.label || it.name || "???";
                    var amt = it.amount != null ? it.amount : 0;
                    var minP = it.priceMin != null ? it.priceMin : 0;
                    var maxP = it.priceMax != null ? it.priceMax : minP;
                    var priceText = minP === maxP ? ("$" + minP) : ("$" + minP + "～$" + maxP);
                    html += "<div class=\"sell-item\" data-name=\"" + escapeAttr(it.name) + "\">";
                    html += "<span class=\"name\">" + escapeHtml(name) + "</span>";
                    html += "<span class=\"amount\">x" + amt + "</span>";
                    html += "<span class=\"price\">" + priceText + "/個</span>";
                    var sellOne = (localeStrings.sell_one != null) ? localeStrings.sell_one : "1個売る";
                    var sellAllBtn = (localeStrings.sell_all_btn != null) ? localeStrings.sell_all_btn : "全て売る";
                    html += "<button type=\"button\" class=\"btn-sell\" data-name=\"" + escapeAttr(it.name) + "\" data-amount=\"1\">" + escapeHtml(sellOne) + "</button>";
                    if (amt > 1) {
                        html += "<button type=\"button\" class=\"btn-sell btn-sell-all\" data-name=\"" + escapeAttr(it.name) + "\" data-amount=\"" + amt + "\">" + escapeHtml(sellAllBtn) + "</button>";
                    }
                    html += "</div>";
                });
                SELL_LIST.innerHTML = html;
                SELL_LIST.querySelectorAll(".btn-sell").forEach(function (b) {
                    b.addEventListener("click", function () {
                        var itemName = this.getAttribute("data-name");
                        var amount = parseInt(this.getAttribute("data-amount"), 10) || 1;
                        fetch("https://" + GetParentResourceName() + "/sellItem", {
                            method: "POST",
                            body: JSON.stringify({ itemName: itemName, amount: amount }),
                            headers: { "Content-Type": "application/json" }
                        });
                    });
                });
            }
        }
    }

    if (data.type === "ranking") {
        var list = data.ranking || [];
        var html = "";
        var rankPosFmt = (localeStrings.rank_pos != null) ? localeStrings.rank_pos : "%s位";
        var rankingEmpty = (localeStrings.ranking_empty != null) ? localeStrings.ranking_empty : "まだデータがありません";
        list.forEach(function (p, i) {
            var rankClass = i === 0 ? "top1" : i === 1 ? "top2" : i === 2 ? "top3" : "";
            var rank = i + 1;
            var rankStr = rankPosFmt.replace("%s", rank);
            var name = p.name != null && p.name !== "" ? p.name : (p.citizenid || "???");
            var xp = p.xp != null ? p.xp : 0;
            html += "<div class=\"rank-item " + rankClass + "\"><span class=\"rank-num\">" + escapeHtml(rankStr) + "</span><span class=\"rank-name\">" + escapeHtml(name) + "</span><span class=\"rare-count\">" + xp + " XP</span></div>";
        });
        if (list.length === 0) {
            html = "<p style='text-align:center;color:#888;padding:20px;'>" + escapeHtml(rankingEmpty) + "</p>";
        }
        RANKING.innerHTML = html;
    }

    if (data.type === "digStart") {
        DIG_PROGRESS.classList.remove("hidden");
        DIG_PROGRESS.style.display = "block";
        PROGRESS_FILL.style.width = "0%";
        var duration = data.duration || 5000;
        var start = Date.now();
        var interval = setInterval(function () {
            var elapsed = Date.now() - start;
            var pct = Math.min(100, (elapsed / duration) * 100);
            PROGRESS_FILL.style.width = pct + "%";
            if (pct >= 100) clearInterval(interval);
        }, 50);
    }

    if (data.type === "digEnd") {
        PROGRESS_FILL.style.width = "100%";
        setTimeout(function () {
            DIG_PROGRESS.classList.add("hidden");
            DIG_PROGRESS.style.display = "none";
        }, 200);
    }

    if (data.type === "worldLabel") {
        var el = document.getElementById("world-label");
        if (!el) return;
        if (data.visible && data.text) {
            el.textContent = data.text;
            el.classList.remove("hidden");
            el.style.display = "block";
            var x = (typeof data.x === "number") ? data.x : 0.5;
            var y = (typeof data.y === "number") ? data.y : 0.5;
            el.style.left = (x * 100) + "%";
            el.style.top = (y * 100) + "%";
        } else {
            el.classList.add("hidden");
            el.style.display = "none";
        }
    }

    if (data.type === "metalDetectorBeep") {
        if (data.active && typeof data.distance === "number" && data.detectDistance > data.digDistance) {
            var t = (data.distance - data.digDistance) / (data.detectDistance - data.digDistance);
            t = Math.max(0, Math.min(1, t));
            var heat = 1 - t;
            if (data.inRange !== false) {
                var intervalMs;
                if (data.veryClose && (data.intervalVeryClose != null)) {
                    intervalMs = data.intervalVeryClose;
                } else {
                    intervalMs = (data.intervalMin != null ? data.intervalMin : 280) + t * ((data.intervalMax != null ? data.intervalMax : 1800) - (data.intervalMin != null ? data.intervalMin : 280));
                }
                var volume = heat;
                metalDetectorBeepTick(intervalMs, volume);
            } else {
                metalDetectorBeepStop();
            }
        } else {
            metalDetectorBeepStop();
        }
    }

    if (data.type === "digReadySound") {
        metalDetectorPlayDigReadySound();
    }
});

BTN_BUY_DETECTOR.addEventListener("click", function () {
    fetch("https://" + GetParentResourceName() + "/buyDetector", { method: "POST" });
});

if (BTN_CLOSE_X) {
    BTN_CLOSE_X.addEventListener("click", function () {
        closeUI();
    });
}

if (BTN_SELL_ALL_GLOBAL) {
    BTN_SELL_ALL_GLOBAL.addEventListener("click", function () {
        if (!shopData || !Array.isArray(shopData.sellItems)) return;
        var items = shopData.sellItems;
        items.forEach(function (it) {
            var amt = it.amount != null ? it.amount : 0;
            if (!it.name || amt <= 0) return;
            fetch("https://" + GetParentResourceName() + "/sellItem", {
                method: "POST",
                body: JSON.stringify({ itemName: it.name, amount: amt }),
                headers: { "Content-Type": "application/json" }
            });
        });
    });
}

window.addEventListener("keydown", function (e) {
    if (e.key === "Escape" || e.key === "Esc") {
        if (!UI.classList.contains("hidden")) {
            closeUI();
        }
    }
});

function closeUI() {
    fetch("https://" + GetParentResourceName() + "/close", { method: "POST" });
    UI.classList.add("hidden");
    UI.style.display = "none";
}

function escapeHtml(text) {
    var div = document.createElement("div");
    div.textContent = text;
    return div.innerHTML;
}

function escapeAttr(text) {
    return String(text)
        .replace(/&/g, "&amp;")
        .replace(/"/g, "&quot;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;");
}
