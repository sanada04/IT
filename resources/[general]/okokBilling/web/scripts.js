var tableInstances     = []
var windowIsOpened     = false
var selectedWindow     = 'none'
var selectedInvoiceType = 'society'
var currentMyInvoices  = []
var nearbyPlayers      = []
var selectedTargets    = []
var pendingTargetModalOpen = false
var jobBills           = []

// ── Utilities ──────────────────────────────────────────────────────

function postAction(payload) {
	$.post('https://okokBilling/action', JSON.stringify(payload))
}

function playOpenSound() {
	var s = new Audio('popup.mp3'); s.volume = 0.4; s.play()
}

function playCloseSound() {
	var s = new Audio('popupreverse.mp3'); s.volume = 0.4; s.play()
}

function escapeHtml(str) {
	return String(str || '')
		.replace(/&/g, '&amp;').replace(/</g, '&lt;')
		.replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#039;')
}

function destroyTables() {
	for (var i = 0; i < tableInstances.length; i++) tableInstances[i].destroy()
	tableInstances = []
}

function clearBootstrapBackdrop() {
	$('.modal-backdrop').remove()
	$('body').removeClass('modal-open').css('padding-right', '')
}

function clearBootstrapBackdropDeep() {
	clearBootstrapBackdrop()
	setTimeout(clearBootstrapBackdrop, 30)
	setTimeout(clearBootstrapBackdrop, 180)
}

// ── Avatar color helper ────────────────────────────────────────────

var AVATAR_COLORS = ['#4f80ff','#e05474','#3ecf78','#f5a623','#a06aff','#25c4d4','#ff7043','#26a69a']
function avatarColor(id) { return AVATAR_COLORS[Math.abs(id) % AVATAR_COLORS.length] }

// ── Panel management ───────────────────────────────────────────────

function switchPanel(id) {
	$('.panel').removeClass('active')
	$('#panel-' + id).addClass('active')
	$('.sidebar-nav-item').removeClass('active')
	$('.sidebar-nav-item[data-panel="' + id + '"]').addClass('active')
}

// ── Close everything ───────────────────────────────────────────────

function closeAllMenus() {
	closePicker()
	$('#app').removeClass('show').hide()
	$('.modal').modal('hide')
	clearBootstrapBackdropDeep()
	destroyTables()
	windowIsOpened = false
	selectedWindow = 'none'
}

// ── Open main menu (builds sidebar nav) ───────────────────────────

function openSelectionMenu(data) {
	clearBootstrapBackdropDeep()

	var nav = ''
	nav += `<button class="sidebar-nav-item" data-panel="myinvoices" data-action="mainMenuOpenMyInvoices">
		<i class="fas fa-receipt"></i><span>個人請求書</span>
	</button>`
	if (data.society) {
		nav += `<button class="sidebar-nav-item" data-panel="societyinvoices" data-action="mainMenuOpenSocietyInvoices">
			<i class="fas fa-building"></i><span>組織請求書</span>
		</button>`
	}
	if (data.society || data.create) {
		nav += `<button class="sidebar-nav-item" data-panel="createinvoice" data-action="mainMenuOpenCreateInvoice">
			<i class="fas fa-plus-circle"></i><span>請求書作成</span>
		</button>`
	}
	$('#sidebarNav').html(nav)
	switchPanel('home')
	$('#app').addClass('show').show()
	windowIsOpened = true
	selectedWindow = 'mainMenu'
}

// ── My Invoices ────────────────────────────────────────────────────

function openMyInvoices(data) {
	var invoices = data.invoices || []
	currentMyInvoices = invoices
	var rows = ''
	var unpaidTotal = 0

	for (var i = 0; i < invoices.length; i++) {
		var inv = invoices[i]
		if (inv.status === 'unpaid') unpaidTotal += Number(inv.invoice_value || 0)
		var payBtn = inv.status === 'unpaid'
			? `<button class="payInvoiceBtn" data-invoice-id="${inv.id}"><i class="fas fa-yen-sign"></i> 支払う</button>`
			: ''
		rows += `<tr>
			<td class="text-center">${inv.id}</td>
			<td class="text-center">${statusBadge(inv.status)}</td>
			<td class="text-center">${escapeHtml(inv.author_name || inv.society_name || '-')}</td>
			<td class="text-center">${Number(inv.invoice_value || 0).toLocaleString()}円</td>
			<td class="text-center">${escapeHtml(inv.item || '-')}${payBtn}</td>
		</tr>`
	}

	$('#invoicesTableData').html(rows)
	$('#view_invoice_payall').html('<i class="fas fa-yen-sign"></i> 全て支払う (' + unpaidTotal.toLocaleString() + '円)')

	var el = document.getElementById('invoicesTable')
	if (el) tableInstances.push(new simpleDatatables.DataTable(el, { searchable: true, perPageSelect: false, perPage: 8 }))

	$('#app').addClass('show').show()
	switchPanel('myinvoices')
	windowIsOpened = true
	selectedWindow = 'myinvoices'
}

// ── Society Invoices ───────────────────────────────────────────────

function openSocietyInvoices(data) {
	var invoices = data.invoices || []
	var rows = ''

	for (var i = 0; i < invoices.length; i++) {
		var inv = invoices[i]
		var action = inv.status === 'unpaid'
			? `<button class="cancelInvoice" data-invoice-id="${inv.id}"><i class="fas fa-ban"></i> キャンセル</button>`
			: '-'
		rows += `<tr>
			<td class="text-center">${inv.id}</td>
			<td class="text-center">${statusBadge(inv.status)}</td>
			<td class="text-center">${escapeHtml(inv.author_name || '-')}</td>
			<td class="text-center">${Number(inv.invoice_value || 0).toLocaleString()}円</td>
			<td class="text-center">${escapeHtml(inv.item || '-')} ${action}</td>
		</tr>`
	}

	$('#societyInvoicesTableData').html(rows)
	$('#totalpending_value').text(Number(data.awaitedIncome || 0).toLocaleString())

	var el = document.getElementById('societyInvoicesTable')
	if (el) tableInstances.push(new simpleDatatables.DataTable(el, { searchable: true, perPageSelect: false, perPage: 8 }))

	$('#app').addClass('show').show()
	switchPanel('societyinvoices')
	windowIsOpened = true
	selectedWindow = 'societyinvoices'
}

// ── Create Invoice ─────────────────────────────────────────────────

function openCreateInvoice(data) {
	$('#normal_createinvoice_item, #normal_createinvoice_price, #normal_createinvoice_note').val('')
	$('#custom_createinvoice_item, #custom_createinvoice_price, #custom_createinvoice_note').val('')
	$('#createinvoice').prop('disabled', true)
	$('.bill-card').removeClass('active')
	$('.type-btn').removeClass('active')
	$('#typeJobBtn').addClass('active')

	selectedInvoiceType = 'society'
	jobBills = Array.isArray(data.jobBills) ? data.jobBills : []
	nearbyPlayers = data.nearPlayers || []
	selectedTargets = nearbyPlayers.length === 1 ? [nearbyPlayers[0].id] : []

	updateSelectedTargetsLabel()
	renderBillCards()

	$('#jobMode').show()
	$('#personalMode').hide()

	$('#app').addClass('show').show()
	switchPanel('createinvoice')
	windowIsOpened = true
	selectedWindow = 'createinvoice'
}

// ── Status badge ───────────────────────────────────────────────────

function statusBadge(status) {
	if (status === 'paid')      return '<span class="badge bg-success"><i class="fas fa-check-circle"></i> 支払い済み</span>'
	if (status === 'unpaid')    return '<span class="badge bg-danger"><i class="fas fa-times-circle"></i> 未払い</span>'
	if (status === 'autopaid')  return '<span class="badge bg-info"><i class="fas fa-clock"></i> 自動支払い</span>'
	if (status === 'cancelled') return '<span class="badge bg-secondary"><i class="fas fa-ban"></i> キャンセル</span>'
	return '<span class="badge bg-secondary">不明</span>'
}

// ── Bill cards (replaces <select>) ────────────────────────────────

function renderBillCards() {
	if (!jobBills.length) {
		$('#billGrid').html('<div class="bill-empty">請求項目がありません</div>')
		$('#billsSection').hide()
		$('#normal_createinvoice_item').prop('readonly', false)
		$('#normal_createinvoice_price').prop('readonly', false)
		return
	}
	var html = ''
	for (var i = 0; i < jobBills.length; i++) {
		var b = jobBills[i] || {}
		var label = escapeHtml(b.label || ('項目' + (i + 1)))
		var price = Number(b.price)
		var hasPrice = !isNaN(price) && price > 0
		html += `<div class="bill-card" data-index="${i}">
			<div class="bill-card-label">${label}</div>
			${hasPrice ? '<div class="bill-card-price">' + price.toLocaleString() + '円</div>' : ''}
		</div>`
	}
	$('#billGrid').html(html)
	$('#billsSection, #jobMode').show()
	$('#normal_createinvoice_item').val('').prop('readonly', true)
	$('#normal_createinvoice_price').val('').prop('readonly', false)
}

// ── Player grid (replaces checkbox list) ──────────────────────────

function renderPlayerGrid() {
	var html = ''
	if (!nearbyPlayers.length) {
		html = '<div class="picker-empty"><i class="fas fa-user-slash" style="font-size:28px;opacity:.3;margin-bottom:8px;display:block"></i>近くに送信可能なプレイヤーがいません</div>'
	} else {
		for (var i = 0; i < nearbyPlayers.length; i++) {
			var p = nearbyPlayers[i]
			var sel = selectedTargets.indexOf(p.id) !== -1
			var initial = (p.name || '?').charAt(0).toUpperCase()
			var color = avatarColor(p.id)
			html += `<div class="player-card${sel ? ' selected' : ''}" data-id="${p.id}">
				<div class="player-check"><i class="fas fa-check"></i></div>
				<div class="player-avatar" style="background:${color}">${escapeHtml(initial)}</div>
				<div class="player-name">${escapeHtml(p.name || '不明')}</div>
				<div class="player-meta">
					<span>ID: ${p.id}</span><br>
					<span class="player-dist-badge">${Number(p.distance || 0).toFixed(1)}m</span>
				</div>
			</div>`
		}
	}
	$('#playerGrid').html(html)
	updatePickerCount()
}

function updatePickerCount() {
	$('#pickerCount').text(selectedTargets.length + '人選択中')
}

// ── Picker open / close ────────────────────────────────────────────

function openPicker() {
	renderPlayerGrid()
	$('#playerPickerOverlay').addClass('open')
}

function closePicker() {
	$('#playerPickerOverlay').removeClass('open')
}

// ── Selected targets label ─────────────────────────────────────────

function updateSelectedTargetsLabel() {
	var $el = $('#selectedTargetsLabel')
	if (selectedTargets.length > 0) {
		$el.html('<i class="fas fa-users"></i> ' + selectedTargets.length + '人を選択中').addClass('has-targets')
	} else {
		$el.html('<i class="fas fa-user-slash"></i> 送信先: 未選択').removeClass('has-targets')
	}
	updatePickerCount()
}

function syncSelectedTargetsWithNearby() {
	var valid = {}
	nearbyPlayers.forEach(function(p) { valid[String(p.id)] = true })
	selectedTargets = selectedTargets.filter(function(id) { return valid[String(id)] })
}

// ── Form helpers ───────────────────────────────────────────────────

function getInvoiceFormData() {
	var item = '', value = '', note = ''
	if (selectedInvoiceType === 'personal') {
		item  = $('#custom_createinvoice_item').val()
		value = $('#custom_createinvoice_price').val()
		note  = $('#custom_createinvoice_note').val()
	} else {
		item  = $('#normal_createinvoice_item').val()
		value = $('#normal_createinvoice_price').val()
		note  = $('#normal_createinvoice_note').val()
	}
	if (!note) note = '特になし'
	return { item: item, value: value, note: note }
}

window.checkIfEmpty = function() {
	var form = getInvoiceFormData()
	var valid = form.item && form.value && Number(form.value) > 0
	$('#createinvoice').prop('disabled', !valid)
}

window.checkReference = function() {}
window.lookcitizen = function() {}

// ── Message handler (FiveM NUI) ────────────────────────────────────

window.addEventListener('message', function(e) {
	var data = e.data || {}
	switch (data.action) {
		case 'mainmenu':
			playOpenSound()
			closeAllMenus()
			openSelectionMenu(data)
			break
		case 'myinvoices':
			playOpenSound()
			destroyTables()
			openMyInvoices(data)
			break
		case 'societyinvoices':
			playOpenSound()
			destroyTables()
			openSocietyInvoices(data)
			break
		case 'createinvoice':
			openCreateInvoice(data)
			break
		case 'updateNearbyPlayers':
			nearbyPlayers = data.nearPlayers || []
			syncSelectedTargetsWithNearby()
			updateSelectedTargetsLabel()
			if (pendingTargetModalOpen) {
				pendingTargetModalOpen = false
				openPicker()
			}
			break
	}
})

// ── Sidebar nav click ──────────────────────────────────────────────

$(document).on('click', '.sidebar-nav-item', function() {
	var action = $(this).data('action')
	if (action) {
		destroyTables()
		switchPanel('loading')
		postAction({ action: action })
	}
})

// ── Type switch (仕事 / 個人) ──────────────────────────────────────

$(document).on('click', '#typeJobBtn', function() {
	selectedInvoiceType = 'society'
	$('.type-btn').removeClass('active')
	$(this).addClass('active')
	$('#jobMode').show()
	$('#personalMode').hide()
	renderBillCards()
	checkIfEmpty()
})

$(document).on('click', '#typePersonalBtn', function() {
	selectedInvoiceType = 'personal'
	$('.type-btn').removeClass('active')
	$(this).addClass('active')
	$('#jobMode').hide()
	$('#personalMode').show()
	checkIfEmpty()
})

// ── Bill card selection ────────────────────────────────────────────

$(document).on('click', '.bill-card', function() {
	var index = Number($(this).data('index'))
	var bill  = jobBills[index] || {}
	$('.bill-card').removeClass('active')
	$(this).addClass('active')

	var label   = bill.label || ''
	var price   = Number(bill.price)
	var isCustom = String(label).toLowerCase() === 'custom'

	if (isCustom) {
		$('#normal_createinvoice_item').val('').prop('readonly', false).attr('placeholder', '項目を入力')
	} else {
		$('#normal_createinvoice_item').val(label).prop('readonly', true)
	}

	if (!isNaN(price) && price > 0) {
		$('#normal_createinvoice_price').val(price).prop('readonly', true)
	} else {
		$('#normal_createinvoice_price').val('').prop('readonly', false)
	}

	checkIfEmpty()
})

// ── Player picker ──────────────────────────────────────────────────

$(document).on('click', '#openTargetSelector', function() {
	pendingTargetModalOpen = true
	postAction({ action: 'requestNearbyPlayers' })
})

$(document).on('click', '#pickerClose', function() {
	closePicker()
})

$(document).on('click', '.player-card', function() {
	var id = Number($(this).data('id'))
	if (selectedTargets.indexOf(id) !== -1) {
		selectedTargets = selectedTargets.filter(function(v) { return v !== id })
		$(this).removeClass('selected')
	} else {
		selectedTargets.push(id)
		$(this).addClass('selected')
	}
	updatePickerCount()
})

$(document).on('click', '#selectAllTargets', function() {
	selectedTargets = nearbyPlayers.map(function(p) { return p.id })
	renderPlayerGrid()
})

$(document).on('click', '#clearAllTargets', function() {
	selectedTargets = []
	renderPlayerGrid()
})

$(document).on('click', '#confirmTargetSelection', function() {
	closePicker()
	updateSelectedTargetsLabel()
})

// ── Create invoice ─────────────────────────────────────────────────

$(document).on('click', '#createinvoice', function() {
	var form = getInvoiceFormData()
	if (!form.item || !form.value) { postAction({ action: 'missingInfo' }); return }
	if (Number(form.value) <= 0)   { postAction({ action: 'negativeAmount' }); return }
	if (!selectedTargets.length)   { postAction({ action: 'noTargets' }); return }

	postAction({
		action:         'createInvoice',
		invoice_type:   selectedInvoiceType,
		targets:        selectedTargets,
		targetName:     -1,
		society:        '',
		society_name:   '',
		invoice_value:  Number(form.value),
		invoice_item:   form.item,
		invoice_notes:  'メモ: ' + form.note
	})
	closeAllMenus()
	postAction({ action: 'close' })
})

// ── Pay / cancel ───────────────────────────────────────────────────

$(document).on('click', '#view_invoice_payall', function() {
	currentMyInvoices.forEach(function(inv) {
		if (inv.status === 'unpaid') postAction({ action: 'payInvoice', invoice_id: inv.id })
	})
	postAction({ action: 'close' })
	closeAllMenus()
})

$(document).on('click', '.payInvoiceBtn', function() {
	postAction({ action: 'payInvoice', invoice_id: $(this).data('invoice-id') })
	postAction({ action: 'close' })
	closeAllMenus()
})

$(document).on('click', '.cancelInvoice', function() {
	postAction({ action: 'cancelInvoice', invoice_id: $(this).data('invoice-id') })
	closeAllMenus()
	postAction({ action: 'close' })
})

// ── Close button ───────────────────────────────────────────────────

$(document).on('click', '#appClose', function() {
	playCloseSound()
	closeAllMenus()
	postAction({ action: 'close' })
})

// ── ESC key ────────────────────────────────────────────────────────

$(document).ready(function() {
	document.onkeyup = function(e) {
		if (e.key === 'Escape') {
			if ($('#playerPickerOverlay').hasClass('open')) {
				closePicker()
			} else if (windowIsOpened) {
				playCloseSound()
				closeAllMenus()
				postAction({ action: 'close' })
			}
		}
	}
})
