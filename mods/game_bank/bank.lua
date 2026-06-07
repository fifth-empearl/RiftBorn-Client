Bank = Bank or {}

Bank.opcode = 86
Bank.currentCurrencyId = nil
Bank.totalLogs = 0
Bank.pageSize = 0
Bank.currentPage = 1

local currenciesAmount = {}
local externalWindowNames = {
	"WithdrawWindow",
	"DepositWindow",
	"TransferWindow",
	"MessageWindow",
}

local function commaValue(amount)
	local formatted = tostring(amount or 0)
	while true do
		local nextValue, replacements = formatted:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
		formatted = nextValue
		if replacements == 0 then
			break
		end
	end
	return formatted
end

local function getCurrencies()
	return BankCurrencies.clientCurrencies or {}
end

local function getCurrentCurrency()
	for _, currency in ipairs(getCurrencies()) do
		if currency.currencyId == Bank.currentCurrencyId then
			return currency
		end
	end
	return nil
end

local function updateCurrencyWidgets(window, currency)
	if not window or not currency then
		return
	end

	if window.currencyIcon then
		window.currencyIcon:setItemId(currency.itemId)
		window.currencyIcon:setItemCount(currency.displayCount or 1)
		window.currencyIcon:setShowCount(false)
	end

	if window.currencyName then
		window.currencyName:setText(currency.name or "")
		window.currencyName:setTooltip(currency.name or "")
	end
end

function Bank.updateDialogCurrencyDisplays(currency)
	currency = currency or getCurrentCurrency()
	if not Bank.UI or not currency then
		return
	end

	updateCurrencyWidgets(Bank.UI.WithdrawWindow, currency)
	updateCurrencyWidgets(Bank.UI.DepositWindow, currency)
	updateCurrencyWidgets(Bank.UI.TransferWindow, currency)
end

function Bank.hideExternalWindows()
	if not Bank.UI then
		return
	end

	for _, windowName in ipairs(externalWindowNames) do
		local window = Bank.UI[windowName]
		if window then
			window:setVisible(false)
		end
	end

	if Bank.UI.transferLogsWindow then
		Bank.UI.transferLogsWindow:setVisible(false)
	end
end

function Bank.destroyExternalWindows()
	if not Bank.UI then
		return
	end

	for _, windowName in ipairs(externalWindowNames) do
		local window = Bank.UI[windowName]
		if window then
			window:destroy()
			Bank.UI[windowName] = nil
		end
	end
end

function Bank.setupMainWindow()
	Bank.UI = g_ui.displayUI("bank")
	Bank.UI:setVisible(false)
	for _, windowName in ipairs(externalWindowNames) do
		Bank.UI[windowName] = g_ui.createWidget(windowName, rootWidget)
		Bank.UI[windowName]:setVisible(false)
	end
	Bank.UI.transferLogsWindow = g_ui.displayUI("bankTransfer")
	Bank.UI.transferLogsWindow:setVisible(false)

	Bank.UI.internalPanel.withdrawButton.onClick = function()
		if g_keyboard.isCtrlPressed() then
			Bank.sendOpcode({ topic = "withdraw-all", currencyId = Bank.currentCurrencyId })
		else
			Bank.updateDialogCurrencyDisplays()
			Bank.UI.WithdrawWindow:setVisible(true)
			Bank.UI.LockUI:setVisible(true)
			Bank.UI.WithdrawWindow.amount:setText("")
			Bank.UI.WithdrawWindow:raise()
			Bank.UI.WithdrawWindow:focus()
		end
	end

	Bank.UI.internalPanel.depositButton.onClick = function()
		if g_keyboard.isCtrlPressed() then
			Bank.sendOpcode({ topic = "deposit-all", currencyId = Bank.currentCurrencyId })
		else
			Bank.updateDialogCurrencyDisplays()
			Bank.UI.DepositWindow:setVisible(true)
			Bank.UI.LockUI:setVisible(true)
			Bank.UI.DepositWindow.amount:setText("")
			Bank.UI.DepositWindow:raise()
			Bank.UI.DepositWindow:focus()
		end
	end

	Bank.UI.internalPanel.transferButton.onClick = function()
		Bank.updateDialogCurrencyDisplays()
		Bank.UI.TransferWindow:setVisible(true)
		Bank.UI.LockUI:setVisible(true)
		Bank.UI.TransferWindow.name:setText("")
		Bank.UI.TransferWindow.amount:setText("")
		Bank.UI.TransferWindow.transferAllCheck:setChecked(false)
		Bank.UI.TransferWindow.amount:setEnabled(true)
		Bank.UI.TransferWindow:raise()
		Bank.UI.TransferWindow:focus()
	end

	Bank.UI.logsButton.onClick = function()
		Bank.currentPage = 1
		Bank.sendOpcode({ topic = "transfer-logs-request", currencyId = Bank.currentCurrencyId, page = Bank.currentPage })
		Bank.UI.transferLogsWindow:setVisible(true)
		Bank.UI.LockUI:setVisible(true)
		Bank.UI.transferLogsWindow:raise()
		Bank.UI.transferLogsWindow:focus()
	end

	Bank.UI.closeButton.onClick = function()
		Bank.UI:setVisible(false)
		Bank.hideExternalWindows()
		Bank.UI.LockUI:setVisible(false)
	end

	Bank.UI.transferLogsWindow.transferLogsNextPage.onClick = function()
		local nextPage = Bank.currentPage + 1
		if Bank.pageSize > 0 and nextPage <= math.ceil(Bank.totalLogs / Bank.pageSize) then
			Bank.currentPage = nextPage
			Bank.sendOpcode({ topic = "transfer-logs-request", currencyId = Bank.currentCurrencyId, page = nextPage })
		end
	end

	Bank.UI.transferLogsWindow.transferLogsPrevPage.onClick = function()
		local prevPage = Bank.currentPage - 1
		if prevPage >= 1 then
			Bank.currentPage = prevPage
			Bank.sendOpcode({ topic = "transfer-logs-request", currencyId = Bank.currentCurrencyId, page = prevPage })
		end
	end

	Bank.UI.transferLogsWindow.transferLogsCloseButton.onClick = function()
		Bank.UI.transferLogsWindow:setVisible(false)
		Bank.UI.LockUI:setVisible(false)
	end

	Bank.setupAmountDialog(Bank.UI.WithdrawWindow, "withdraw")
	Bank.setupAmountDialog(Bank.UI.DepositWindow, "deposit")
	Bank.setupTransferWindow()
	Bank.setupMessageWindow()
	Bank.setupCurrencyDisplay()
end

function Bank.setupAmountDialog(window, topic)
	window.amount.onTextChange = function(widget)
		Bank.validateAmountInput(widget)
	end

	window.confirm.onClick = function()
		local amount = Bank.getInputAmount(window.amount)
		if amount and amount > 0 then
			Bank.sendOpcode({ topic = topic, currencyId = Bank.currentCurrencyId, amount = amount })
			window:setVisible(false)
			Bank.UI.LockUI:setVisible(false)
		else
			window:setVisible(false)
			Bank.showMessageWindow("Error", "Please enter a valid amount.")
		end
	end

	window.close.onClick = function()
		window:setVisible(false)
		Bank.UI.LockUI:setVisible(false)
	end

	window.onKeyDown = function(widget, keyCode)
		if keyCode == KeyEnter then
			window.confirm.onClick()
			return true
		elseif keyCode == KeyEscape then
			window.close.onClick()
			return true
		end
		return false
	end
end

function Bank.setupTransferWindow()
	local window = Bank.UI.TransferWindow

	window.name.onTextChange = function(widget)
		Bank.validateNameInput(widget)
	end
	window.amount.onTextChange = function(widget)
		Bank.validateAmountInput(widget)
	end
	window.transferAllCheck.onCheckChange = function(widget, checked)
		window.amount:setEnabled(not checked)
	end

	window.confirm.onClick = function()
		local name = window.name:getText()
		if #name == 0 then
			window:setVisible(false)
			Bank.showMessageWindow("Error", "Please enter a valid name.")
			return
		end

		if window.transferAllCheck:isChecked() then
			Bank.sendOpcode({ topic = "transfer", currencyId = Bank.currentCurrencyId, transferTo = name, transferAll = true })
			window:setVisible(false)
			Bank.UI.LockUI:setVisible(false)
			return
		end

		local amount = Bank.getInputAmount(window.amount)
		if amount and amount > 0 then
			Bank.sendOpcode({ topic = "transfer", currencyId = Bank.currentCurrencyId, transferTo = name, amount = amount })
			window:setVisible(false)
			Bank.UI.LockUI:setVisible(false)
		else
			window:setVisible(false)
			Bank.showMessageWindow("Error", "Please enter a valid amount.")
		end
	end

	window.close.onClick = function()
		window:setVisible(false)
		Bank.UI.LockUI:setVisible(false)
	end

	window.onKeyDown = function(widget, keyCode)
		if keyCode == KeyEnter then
			window.confirm.onClick()
			return true
		elseif keyCode == KeyEscape then
			window.close.onClick()
			return true
		end
		return false
	end
end

function Bank.setupMessageWindow()
	Bank.UI.MessageWindow.okay.onClick = function()
		Bank.UI.MessageWindow:setVisible(false)
		Bank.UI.LockUI:setVisible(false)
	end

	Bank.UI.MessageWindow.onKeyDown = function(widget, keyCode)
		if keyCode == KeyEnter or keyCode == KeyEscape then
			Bank.UI.MessageWindow.okay.onClick()
			return true
		end
		return false
	end
end

function Bank.setupCurrencyDisplay()
	local currenciesScrollMenu = Bank.UI.internalPanel.currenciesScrollMenu
	currenciesScrollMenu:clearOptions()

	for _, currency in ipairs(getCurrencies()) do
		currenciesScrollMenu:addOption(currency.name)
	end

	if getCurrencies()[1] then
		Bank.setCurrentCurrency(getCurrencies()[1].name)
	end

	currenciesScrollMenu.onOptionChange = function(_, option)
		Bank.setCurrentCurrency(option)
	end
end

function Bank.setCurrentCurrency(selectedCurrencyName)
	for _, currency in ipairs(getCurrencies()) do
		if currency.name == selectedCurrencyName then
			Bank.UI.internalPanel.currencyDisplay:setItemId(currency.itemId)
			Bank.UI.internalPanel.currencyDisplay:setItemCount(currency.displayCount or 1)
			Bank.UI.internalPanel.currencyDisplay:setShowCount(false)

			local bankAmount = currenciesAmount.bank and currenciesAmount.bank[currency.currencyId] or 0
			local inventoryAmount = currenciesAmount.inventory and currenciesAmount.inventory[currency.currencyId] or 0

			Bank.UI.internalPanel.bankAmountPanel.text:setText(commaValue(bankAmount))
			Bank.UI.internalPanel.inventoryAmountPanel.text:setText(commaValue(inventoryAmount))
			Bank.currentCurrencyId = currency.currencyId
			Bank.updateDialogCurrencyDisplays(currency)
			break
		end
	end
end

function Bank.updateCurrentFocusedCurrency()
	local selectedOption = Bank.UI.internalPanel.currenciesScrollMenu:getText()
	Bank.setCurrentCurrency(selectedOption)
end

function Bank.showMessageWindow(title, message)
	Bank.UI.MessageWindow:setText(title)
	Bank.UI.MessageWindow.message:setText(message)
	Bank.UI.LockUI:setVisible(true)
	Bank.UI.MessageWindow:setVisible(true)
	Bank.UI.MessageWindow:raise()
	Bank.UI.MessageWindow:focus()
	Bank.UI.MessageWindow:setHeight(math.min(140, Bank.UI.MessageWindow.message:getTextSize().height + 100))
end

function Bank.populateTransferLogs(logs, totalLogs, pageSize, currentPage)
	Bank.UI.transferLogsWindow.transferLogsPanel:destroyChildren()

	for _, log in ipairs(logs or {}) do
		local logEntry = g_ui.createWidget("TransferLogEntry", Bank.UI.transferLogsWindow.transferLogsPanel)
		local text
		if log.direction == "SENT" then
			text = string.format("SENT: %s | %s | to %s - %s", commaValue(log.amount), log.currencyName, log.otherPartyName, log.transactionTime)
		else
			text = string.format("RECEIVED: %s | %s | from %s - %s", commaValue(log.amount), log.currencyName, log.otherPartyName, log.transactionTime)
		end
		logEntry:setText(text)
		logEntry:setTooltip(text)
	end

	local totalPages = math.max(1, math.ceil((totalLogs or 0) / math.max(1, pageSize or 1)))
	Bank.UI.transferLogsWindow.transferLogsPagesLabel:setText(currentPage .. "/" .. totalPages)
	Bank.UI.transferLogsWindow.transferLogsNextPage:setEnabled(currentPage < totalPages)
	Bank.UI.transferLogsWindow.transferLogsPrevPage:setEnabled(currentPage > 1)
end

function Bank.getInputAmount(textEdit)
	local amountText = textEdit:getText()
	return tonumber((amountText:gsub(",", "")))
end

function Bank.validateAmountInput(textEdit)
	local cursorPos = textEdit:getCursorPos()
	local amountText = textEdit:getText()
	local numericOnly = amountText:gsub("[^%d]", "")
	local amount = tonumber(numericOnly)
	if amount and amount > 100000000000 then
		amount = 100000000000
	end

	if amount then
		local formattedAmount = commaValue(amount)
		local oldCommaCount = select(2, amountText:gsub(",", ""))
		local newCommaCount = select(2, formattedAmount:gsub(",", ""))
		local cursorAdjustment = newCommaCount - oldCommaCount
		textEdit:setText(formattedAmount)
		textEdit:setCursorPos(math.min(math.max(0, cursorPos + cursorAdjustment), #formattedAmount))
	else
		textEdit:setText("")
	end
end

function Bank.validateNameInput(textEdit)
	local cursorPos = textEdit:getCursorPos()
	local lettersOnly = textEdit:getText():gsub("[^%a%s%-']", ""):gsub("^%s+", "")
	if #lettersOnly > 50 then
		lettersOnly = lettersOnly:sub(1, 50)
	end
	textEdit:setText(lettersOnly)
	textEdit:setCursorPos(math.min(cursorPos, #lettersOnly))
end

function Bank.onExtendedOpcode(protocol, opcode, data)
	if type(data) ~= "table" then
		return
	end

	local topic = data.topic
	if topic == "base-data-reply" then
		currenciesAmount = data.data or {}
		Bank.updateCurrentFocusedCurrency()
	elseif topic == "message" then
		Bank.showMessageWindow(data.title or "Bank", data.message or "")
	elseif topic == "not-enough-balance-withdraw" then
		Bank.showMessageWindow("Withdraw failed", "There is not enough balance in your account.")
	elseif topic == "not-enough-balance-transfer" then
		Bank.showMessageWindow("Transfer failed", "There is not enough balance in your account.")
	elseif topic == "not-enough-currency-deposit" then
		Bank.showMessageWindow("Deposit failed", "You do not have enough currency to deposit.")
	elseif topic == "not-enough-capacity" then
		Bank.showMessageWindow("Error", "Not enough capacity.")
	elseif topic == "not-enough-slots" then
		Bank.showMessageWindow("Error", "Not enough empty slots in your main backpack.")
	elseif topic == "player-not-online" then
		Bank.showMessageWindow("Error", "Player " .. data.playerName .. " is invalid or not online.")
	elseif topic == "action-exhaust" then
		Bank.showMessageWindow("Error", "You need to wait " .. data.timeLeft .. " seconds before performing the next banking action.")
	elseif topic == "transfer-success" then
		Bank.showMessageWindow("Transfer Success", data.message)
	elseif topic == "deposit-success" then
		Bank.showMessageWindow("Deposit Success", data.message)
	elseif topic == "withdraw-success" then
		Bank.showMessageWindow("Withdraw Success", data.message)
	elseif topic == "transfer-logs-reply" then
		Bank.totalLogs = data.totalLogs or 0
		Bank.pageSize = data.pageSize or 0
		Bank.currentPage = data.currentPage or 1
		Bank.populateTransferLogs(data.logs, Bank.totalLogs, Bank.pageSize, Bank.currentPage)
	end
end

function Bank.sendOpcode(data)
	local protocolGame = g_game.getProtocolGame()
	if protocolGame then
		protocolGame:sendExtendedJSONOpcode(Bank.opcode, data)
	end
end

function Bank.toggle()
	if not Bank.UI then
		return
	end

	if Bank.UI:isVisible() then
		Bank.UI:setVisible(false)
		Bank.hideExternalWindows()
		Bank.UI.LockUI:setVisible(false)
	else
		Bank.sendOpcode({ topic = "request-base-data" })
		Bank.UI:setVisible(true)
		Bank.UI:focus()
	end
end

function Bank.onStart()
	if Bank.UI then
		return
	end

	Bank.setupMainWindow()
	if not Bank.Button then
		Bank.Button = modules.client_topmenu.addRightGameToggleButton("bankButton", tr("Bank"), "/images/options/button_bank", Bank.toggle)
	end
	Bank.sendOpcode({ topic = "request-base-data" })
end

function Bank.onEnd()
	if Bank.UI then
		Bank.destroyExternalWindows()
		if Bank.UI.transferLogsWindow then
			Bank.UI.transferLogsWindow:destroy()
		end
		Bank.UI:destroy()
		Bank.UI = nil
	end
	if Bank.Button then
		Bank.Button:destroy()
		Bank.Button = nil
	end
	currenciesAmount = {}
	Bank.currentCurrencyId = nil
end

function Bank.init()
	ProtocolGame.registerExtendedJSONOpcode(Bank.opcode, Bank.onExtendedOpcode)
	connect(g_game, { onGameStart = Bank.onStart, onGameEnd = Bank.onEnd })
	if g_game.isOnline() then
		Bank.onStart()
	end
end

function Bank.terminate()
	ProtocolGame.unregisterExtendedJSONOpcode(Bank.opcode)
	disconnect(g_game, { onGameStart = Bank.onStart, onGameEnd = Bank.onEnd })
	Bank.onEnd()
end
