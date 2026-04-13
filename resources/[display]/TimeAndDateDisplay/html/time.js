const clockLine = document.getElementById('clockLine')
const dateLine = document.getElementById('dateLine')
const extraBlock = document.getElementById('extraBlock')
const timeCard = document.querySelector('.time-card')

function parseDatetime(datetime) {
    if (!datetime || typeof datetime !== 'string') {
        return { time: '--:--', date: '' }
    }
    const atIdx = datetime.indexOf(' at ')
    if (atIdx !== -1) {
        return {
            date: datetime.slice(0, atIdx).trim(),
            time: datetime.slice(atIdx + 4).trim(),
        }
    }
    // HH:MM のみ
    if (/^\d{1,2}:\d{2}$/.test(datetime.trim())) {
        return { time: datetime.trim(), date: '' }
    }
    // 日付のみ
    return { time: '', date: datetime.trim() }
}

function escapeHtml(s) {
    const div = document.createElement('div')
    div.textContent = s
    return div.innerHTML
}

function render(payload) {
    const datetime = payload.datetime
    const { time, date } = parseDatetime(datetime)

    if (time && date) {
        clockLine.textContent = time
        dateLine.textContent = date
        timeCard.setAttribute('data-mode', 'datetime')
    } else if (time) {
        clockLine.textContent = time
        dateLine.textContent = ''
        timeCard.setAttribute('data-mode', 'time')
    } else if (date) {
        clockLine.textContent = date
        dateLine.textContent = ''
        timeCard.setAttribute('data-mode', 'date')
    } else {
        clockLine.textContent = '--'
        dateLine.textContent = ''
        timeCard.setAttribute('data-mode', 'empty')
    }

    const parts = []

    if (payload.serverName) {
        parts.push(
            `<div class="time-card__extra-row"><span class="time-card__server">${escapeHtml(payload.serverName)}</span></div>`
        )
    }
    if (payload.playerName) {
        parts.push(
            `<div class="time-card__extra-row"><span class="time-card__extra-label">Name</span><span class="time-card__extra-value">${escapeHtml(String(payload.playerName))}</span></div>`
        )
    }
    if (payload.playerId !== undefined && payload.playerId !== null) {
        parts.push(
            `<div class="time-card__extra-row"><span class="time-card__extra-label">ID</span><span class="time-card__extra-value">${escapeHtml(String(payload.playerId))}</span></div>`
        )
    }

    if (parts.length) {
        extraBlock.innerHTML = parts.join('')
        extraBlock.classList.remove('hidden')
    } else {
        extraBlock.innerHTML = ''
        extraBlock.classList.add('hidden')
    }

    timeCard.classList.remove('time-card--tick')
    void timeCard.offsetWidth
    timeCard.classList.add('time-card--tick')
}

/* サーバーイベント前でも時計アイコン・レイアウトが確定するよう初期モード */
if (timeCard) {
    timeCard.setAttribute('data-mode', 'time')
}

window.addEventListener('message', (event) => {
    const data = event.data
    if (data.action === 'setTimeAndDate') {
        if (data.datetime !== undefined) {
            render(data)
        } else if (typeof data.time === 'string') {
            render({
                datetime: data.time,
                serverName: null,
                playerName: null,
                playerId: null,
            })
        }
    }
})
