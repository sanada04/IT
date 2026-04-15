var tableInstances = []
var windowIsOpened = false
var selectedWindow = 'none'
var selectedInvoiceType = 'society'
var currentMyInvoices = []
var nearbyPlayers = []
var selectedTargets = []
var pendingTargetModalOpen = false
var jobBills = []

function postAction(payload) {
	$.post('https://okokBilling/action', JSON.stringify(payload))
}

function playOpenSound() {
	var popup = new Audio('popup.mp3')
	popup.volume = 0.4
	popup.play()
}

function playCloseSound() {
	var popuprev = new Audio('popupreverse.mp3')
	popuprev.volume = 0.4
	popuprev.play()
}

function destroyTables() {
	for (var i = 0; i < tableInstances.length; i++) {
		tableInstances[i].destroy()
	}
	tableInstances = []
}

function clearBootstrapBackdrop() {
	$('.modal-backdrop').remove()
	$('body').removeClass('modal-open')
	$('body').css('padding-right', '')
}

function clearBootstrapBackdropDeep() {
	clearBootstrapBackdrop()
	setTimeout(clearBootstrapBackdrop, 30)
	setTimeout(clearBootstrapBackdrop, 180)
}

function closeAllMenus() {
	$('.selection_menu, .invoices_menu, .societyinvoices_menu, .createinvoice_menu, .cityinvoices_menu, .payreference_menu, .police_menu, .loading_menu').fadeOut(100)
	$('.modal').modal('hide')
	clearBootstrapBackdropDeep()
	destroyTables()
	windowIsOpened = false
	selectedWindow = 'none'
}

function escapeHtml(str) {
	return String(str || '')
		.replace(/&/g, '&amp;')
		.replace(/</g, '&lt;')
		.replace(/>/g, '&gt;')
		.replace(/"/g, '&quot;')
		.replace(/'/g, '&#039;')
}

function syncSelectedTargetsWithNearby() {
	var validIds = {}
	for (var i = 0; i < nearbyPlayers.length; i++) {
		validIds[String(nearbyPlayers[i].id)] = true
	}
	selectedTargets = selectedTargets.filter(function(id) {
		return validIds[String(id)] === true
	})
}

function updateSelectedTargetsLabel() {
	var text = '送信先: 未選択'
	if (selectedTargets.length > 0) {
		text = '送信先: ' + selectedTargets.length + '人を選択中'
	}
	$('#selectedTargetsLabel').text(text)
}

function renderJobBillOptions() {
	var select = $('#normal_bill_select')
	if (!select.length) return

	if (!Array.isArray(jobBills) || jobBills.length === 0) {
		select.hide().empty()
		$('#normal_createinvoice_item').prop('readonly', false).attr('placeholder', '項目')
		$('#normal_createinvoice_price').prop('readonly', false).attr('placeholder', '金額')
		return
	}

	var options = '<option value="">請求項目を選択</option>'
	for (var i = 0; i < jobBills.length; i++) {
		var bill = jobBills[i] || {}
		var label = escapeHtml(bill.label || ('項目' + (i + 1)))
		var price = Number(bill.price)
		var hasPrice = !isNaN(price) && price > 0
		options += '<option value="' + i + '">' + label + (hasPrice ? (' (' + price.toLocaleString() + '円)') : '') + '</option>'
	}

	select.html(options).val('').show()
	$('#normal_createinvoice_item').val('').prop('readonly', true).attr('placeholder', '項目')
	$('#normal_createinvoice_price').val('').prop('readonly', false).attr('placeholder', '金額')
}

function renderTargetList() {
	var html = ''
	if (!nearbyPlayers.length) {
		html = '<div class="text-center py-2">近くに送信可能なプレイヤーがいません。</div>'
	} else {
		html += '<div class="d-flex justify-content-between mb-2">'
		html += '<button type="button" class="btn btn-blue btn-sm" id="selectAllTargets">全員選択</button>'
		html += '<button type="button" class="btn btn-red btn-sm" id="clearAllTargets">全解除</button>'
		html += '</div>'
		html += '<div class="targetList">'
		for (var i = 0; i < nearbyPlayers.length; i++) {
			var p = nearbyPlayers[i]
			var checked = selectedTargets.indexOf(p.id) !== -1 ? 'checked' : ''
			html += '<label class="targetRow d-flex align-items-center justify-content-between">'
			html += '<span><input type="checkbox" class="targetCheckbox me-2" data-server-id="' + p.id + '" ' + checked + '> '
			html += escapeHtml(p.name) + ' (ID: ' + p.id + ')</span>'
			html += '<span class="text-muted">' + Number(p.distance || 0).toFixed(1) + 'm</span>'
			html += '</label>'
		}
		html += '</div>'
	}
	html += '<div class="d-flex justify-content-center mt-3">'
	html += '<button type="button" class="btn btn-blue w-100" id="confirmTargetSelection">選択を確定</button>'
	html += '</div>'
	$('#nearPlayersDiv').html(html)
}

function openTargetSelectorModal() {
	renderTargetList()
	var modalEl = document.getElementById('selectPlayerToSendInvoiceModal')
	if (!modalEl) return
	var modalInstance = bootstrap.Modal.getOrCreateInstance(modalEl)
	modalInstance.show()
}

function openSelectionMenu(data) {
	clearBootstrapBackdropDeep()
	var row = ''
	if (data.society === true) {
		row = `
			<div class="col-md-4 mb-3">
				<button type="button" class="btn btn-blue w-100 py-4" id="menuMyInvoices"><i class="fas fa-user"></i><br>個人請求書</button>
			</div>
			<div class="col-md-4 mb-3">
				<button type="button" class="btn btn-blue w-100 py-4" id="menuSocietyInvoices"><i class="fas fa-building"></i><br>組織請求書</button>
			</div>
			<div class="col-md-4 mb-3">
				<button type="button" class="btn btn-blue w-100 py-4" id="menuCreateInvoice"><i class="fas fa-file-invoice"></i><br>請求書作成</button>
			</div>
		`
	} else if (data.create && !data.society) {
		row = `
			<div class="col-md-6 mb-3">
				<button type="button" class="btn btn-blue w-100 py-4" id="menuMyInvoices"><i class="fas fa-user"></i><br>個人請求書</button>
			</div>
			<div class="col-md-6 mb-3">
				<button type="button" class="btn btn-blue w-100 py-4" id="menuCreateInvoice"><i class="fas fa-file-invoice"></i><br>請求書作成</button>
			</div>
		`
	} else {
		row = `
			<div class="col-md-12 mb-3">
				<button type="button" class="btn btn-blue w-100 py-4" id="menuMyInvoices"><i class="fas fa-user"></i><br>個人請求書</button>
			</div>
		`
	}

	$('#menu').html(row)
	$('.selection_menu').fadeIn(150)
	clearBootstrapBackdropDeep()
	windowIsOpened = true
	selectedWindow = 'mainMenu'
}

function statusBadge(status) {
	if (status === 'paid') return '<span class="badge bg-success">支払い済み</span>'
	if (status === 'unpaid') return '<span class="badge bg-danger">未払い</span>'
	if (status === 'autopaid') return '<span class="badge bg-info">自動支払い</span>'
	if (status === 'cancelled') return '<span class="badge bg-secondary">キャンセル</span>'
	return '<span class="badge bg-secondary">不明</span>'
}

function openMyInvoices(data) {
	var rows = ''
	var unpaidTotal = 0
	var invoices = data.invoices || []
	currentMyInvoices = invoices
	for (var i = 0; i < invoices.length; i++) {
		var inv = invoices[i]
		if (inv.status === 'unpaid') unpaidTotal += Number(inv.invoice_value || 0)
		var payButton = inv.status === 'unpaid'
			? `<button type="button" class="btn btn-blue btn-sm payInvoiceBtn ms-2" data-invoice-id="${inv.id}">支払う</button>`
			: ''
		rows += `
			<tr>
				<td class="text-center">${inv.id}</td>
				<td class="text-center">${statusBadge(inv.status)}</td>
				<td class="text-center">${inv.author_name || inv.society_name || '-'}</td>
				<td class="text-center">${Number(inv.invoice_value || 0).toLocaleString()}円</td>
				<td class="text-center itemWithPay">${inv.item || '-'}${payButton}</td>
			</tr>
		`
	}

	$('#invoicesTableData').html(rows)
	$('#view_invoice_payall').text('全て支払う (' + unpaidTotal.toLocaleString() + '円)')

	var invoicesTable = document.getElementById('invoicesTable')
	if (invoicesTable) {
		tableInstances.push(new simpleDatatables.DataTable(invoicesTable, {
			searchable: true,
			perPageSelect: false,
			perPage: 8
		}))
	}

	$('.invoices_menu').fadeIn(150)
	windowIsOpened = true
	selectedWindow = 'myinvoices'
}

function openSocietyInvoices(data) {
	var rows = ''
	var invoices = data.invoices || []
	for (var i = 0; i < invoices.length; i++) {
		var inv = invoices[i]
		var action = inv.status === 'unpaid'
			? `<button class="btn btn-red btn-sm cancelInvoice" data-invoice-id="${inv.id}">キャンセル</button>`
			: '-'
		rows += `
			<tr>
				<td class="text-center">${inv.id}</td>
				<td class="text-center">${statusBadge(inv.status)}</td>
				<td class="text-center">${inv.author_name || '-'}</td>
				<td class="text-center">${Number(inv.invoice_value || 0).toLocaleString()}円</td>
				<td class="text-center">${inv.item || '-'}</td>
			</tr>
		`
	}

	$('#societyInvoicesTableData').html(rows)
	$('#totalpending_value').text(Number(data.awaitedIncome || 0).toLocaleString())

	var societyTable = document.getElementById('societyInvoicesTable')
	if (societyTable) {
		tableInstances.push(new simpleDatatables.DataTable(societyTable, {
			searchable: true,
			perPageSelect: false,
			perPage: 8
		}))
	}

	$('.societyinvoices_menu').fadeIn(150)
	windowIsOpened = true
	selectedWindow = 'societyinvoices'
}

function openCreateInvoice(data) {
	$('#normal_createinvoice_item, #normal_createinvoice_price, #normal_createinvoice_note, #custom_createinvoice_item, #custom_createinvoice_price, #custom_createinvoice_note').val('')
	$('#createinvoice').prop('disabled', true)
	selectedInvoiceType = 'society'
	jobBills = Array.isArray(data.jobBills) ? data.jobBills : []
	nearbyPlayers = data.nearPlayers || []
	selectedTargets = []
	if (nearbyPlayers.length === 1) {
		selectedTargets = [nearbyPlayers[0].id]
	}
	updateSelectedTargetsLabel()
	renderJobBillOptions()
	$('#invoiceBillsList').show()
	$('#invoiceCustom').hide()
	$('.createinvoice_menu').fadeIn(150)
	windowIsOpened = true
	selectedWindow = 'createinvoice'
}

window.addEventListener('message', function(event) {
	var data = event.data || {}
	switch (data.action) {
		case 'mainmenu':
			playOpenSound()
			closeAllMenus()
			openSelectionMenu(data)
			break
		case 'myinvoices':
			playOpenSound()
			closeAllMenus()
			openMyInvoices(data)
			break
		case 'societyinvoices':
			playOpenSound()
			closeAllMenus()
			openSocietyInvoices(data)
			break
		case 'createinvoice':
			closeAllMenus()
			openCreateInvoice(data)
			break
		case 'updateNearbyPlayers':
			nearbyPlayers = data.nearPlayers || []
			syncSelectedTargetsWithNearby()
			updateSelectedTargetsLabel()
			if (pendingTargetModalOpen) {
				pendingTargetModalOpen = false
				openTargetSelectorModal()
			}
			break
	}
})

function getInvoiceFormData() {
	var item = ''
	var value = ''
	var note = ''

	if (selectedInvoiceType === 'personal') {
		item = $('#custom_createinvoice_item').val()
		value = $('#custom_createinvoice_price').val()
		note = $('#custom_createinvoice_note').val()
	} else {
		item = $('#normal_createinvoice_item').val()
		value = $('#normal_createinvoice_price').val()
		note = $('#normal_createinvoice_note').val()
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

$(document).on('click', '#openCustomInvoice', function() {
	selectedInvoiceType = 'personal'
	$('#invoiceBillsList').hide()
	$('#invoiceCustom').show()
	$('#normal_bill_select').val('').hide()
	$('#normal_createinvoice_item').prop('readonly', false).attr('placeholder', '項目')
	$('#normal_createinvoice_price').prop('readonly', false).attr('placeholder', '金額')
	checkIfEmpty()
})

$(document).on('click', '#openBillsListInvoice', function() {
	selectedInvoiceType = 'society'
	$('#invoiceCustom').hide()
	$('#invoiceBillsList').show()
	renderJobBillOptions()
	checkIfEmpty()
})

$(document).on('change', '#normal_bill_select', function() {
	var index = Number($(this).val())
	if (isNaN(index) || index < 0 || index >= jobBills.length) {
		$('#normal_createinvoice_item').val('').prop('readonly', true)
		$('#normal_createinvoice_price').val('').prop('readonly', false)
		checkIfEmpty()
		return
	}

	var bill = jobBills[index] || {}
	var label = bill.label || ''
	var price = Number(bill.price)
	var hasPrice = !isNaN(price) && price > 0
	var isCustom = String(label).toLowerCase() === 'custom'

	if (isCustom) {
		$('#normal_createinvoice_item').val('').prop('readonly', false).attr('placeholder', '項目（自由入力）')
	} else {
		$('#normal_createinvoice_item').val(label).prop('readonly', true).attr('placeholder', '項目')
	}
	if (hasPrice) {
		$('#normal_createinvoice_price').val(price).prop('readonly', true)
	} else {
		$('#normal_createinvoice_price').val('').prop('readonly', false)
	}

	checkIfEmpty()
})

$(document).on('click', '#createinvoice', function() {
	var form = getInvoiceFormData()
	if (!form.item || !form.value) {
		postAction({ action: 'missingInfo' })
		return
	}
	if (Number(form.value) <= 0) {
		postAction({ action: 'negativeAmount' })
		return
	}
	if (!selectedTargets.length) {
		postAction({ action: 'noTargets' })
		return
	}

	postAction({
		action: 'createInvoice',
		invoice_type: selectedInvoiceType,
		targets: selectedTargets,
		targetName: -1,
		society: '',
		society_name: '',
		invoice_value: Number(form.value),
		invoice_item: form.item,
		invoice_notes: 'メモ: ' + form.note
	})

	closeAllMenus()
	postAction({ action: 'close' })
})

$(document).on('click', '#view_invoice_payall', function() {
	for (var i = 0; i < currentMyInvoices.length; i++) {
		if (currentMyInvoices[i].status === 'unpaid') {
			postAction({ action: 'payInvoice', invoice_id: currentMyInvoices[i].id })
		}
	}
	postAction({ action: 'close' })
	closeAllMenus()
})

$(document).on('click', '.payInvoiceBtn', function() {
	var id = $(this).data('invoice-id')
	postAction({ action: 'payInvoice', invoice_id: id })
	postAction({ action: 'close' })
	closeAllMenus()
})

$(document).on('click', '.cancelInvoice', function() {
	var id = $(this).data('invoice-id')
	postAction({ action: 'cancelInvoice', invoice_id: id })
	closeAllMenus()
	postAction({ action: 'close' })
})

$(document).on('click', '#menuMyInvoices', function() {
	closeAllMenus()
	postAction({ action: 'mainMenuOpenMyInvoices' })
})

$(document).on('click', '#menuSocietyInvoices', function() {
	closeAllMenus()
	postAction({ action: 'mainMenuOpenSocietyInvoices' })
})

$(document).on('click', '#menuCreateInvoice', function() {
	closeAllMenus()
	postAction({ action: 'mainMenuOpenCreateInvoice' })
})

$(document).on('click', '#openTargetSelector', function() {
	pendingTargetModalOpen = true
	postAction({ action: 'requestNearbyPlayers' })
})

$(document).on('change', '.targetCheckbox', function() {
	var id = Number($(this).data('server-id'))
	if (this.checked) {
		if (selectedTargets.indexOf(id) === -1) selectedTargets.push(id)
	} else {
		selectedTargets = selectedTargets.filter(function(v) { return v !== id })
	}
	updateSelectedTargetsLabel()
})

$(document).on('click', '#selectAllTargets', function() {
	selectedTargets = nearbyPlayers.map(function(p) { return p.id })
	renderTargetList()
	updateSelectedTargetsLabel()
})

$(document).on('click', '#clearAllTargets', function() {
	selectedTargets = []
	renderTargetList()
	updateSelectedTargetsLabel()
})

$(document).on('click', '#confirmTargetSelection', function() {
	var modalEl = document.getElementById('selectPlayerToSendInvoiceModal')
	if (modalEl) {
		var modalInstance = bootstrap.Modal.getOrCreateInstance(modalEl)
		modalInstance.hide()
	}
})

$(document).on('click', '#closeSelectionMenu, #closeInvoicesMenu, #closeSocietyInvoicesMenu, #closeCreateInvoiceMenu, #closeCityInvoicesMenu, #closePayReferenceMenu, #closePoliceMenu', function() {
	playCloseSound()
	closeAllMenus()
	postAction({ action: 'close' })
})

$(document).ready(function() {
	document.onkeyup = function(data) {
		if (data.which === 27) {
			playCloseSound()
			closeAllMenus()
			postAction({ action: 'close' })
		}
	}
})
