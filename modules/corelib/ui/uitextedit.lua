function UITextEdit:onStyleApply(styleName, styleNode)
    for name, value in pairs(styleNode) do
        if name == 'vertical-scrollbar' then
            addEvent(function()
                self:setVerticalScrollBar(self:getParent():getChildById(value))
            end)
        elseif name == 'horizontal-scrollbar' then
            addEvent(function()
                self:setHorizontalScrollBar(self:getParent():getChildById(value))
            end)
        end
    end
end

function UITextEdit:onMouseWheel(mousePos, mouseWheel)
    if self.verticalScrollBar and self:isMultiline() then
        if mouseWheel == MouseWheelUp then
            self.verticalScrollBar:decrement()
        else
            self.verticalScrollBar:increment()
        end
        return true
    elseif self.horizontalScrollBar then
        if mouseWheel == MouseWheelUp then
            self.horizontalScrollBar:increment()
        else
            self.horizontalScrollBar:decrement()
        end
        return true
    end
end

function UITextEdit:saveUserTextVirtualOffset()
    local virtualOffset = self:getTextVirtualOffset()
    self.userTextVirtualOffset = { x = virtualOffset.x, y = virtualOffset.y }
end

function UITextEdit:restoreUserTextVirtualOffset()
    local savedOffset = self.userTextVirtualOffset
    if not savedOffset then
        return
    end

    local virtualOffset = self:getTextVirtualOffset()
    if virtualOffset.x == savedOffset.x and virtualOffset.y == savedOffset.y then
        return
    end

    virtualOffset.x = savedOffset.x
    virtualOffset.y = savedOffset.y
    self:setTextVirtualOffset(virtualOffset)
    self:updateScrollBars()
end

function UITextEdit:onFocusChange(focused, reason)
    if focused and reason == MouseFocusReason and self:isMultiline() then
        self:restoreUserTextVirtualOffset()
    end
end

function UITextEdit:onTextAreaUpdate(virtualOffset, virtualSize, totalSize)
    self:updateScrollBars()
end

function UITextEdit:setVerticalScrollBar(scrollbar)
    self.verticalScrollBar = scrollbar
    self.verticalScrollBar.onValueChange = function(scrollbar, value)
        local virtualOffset = self:getTextVirtualOffset()
        virtualOffset.y = value
        self:setTextVirtualOffset(virtualOffset)
        if not self.updatingTextScrollBars then
            self:saveUserTextVirtualOffset()
        end
    end
    self:updateScrollBars()
end

function UITextEdit:setHorizontalScrollBar(scrollbar)
    self.horizontalScrollBar = scrollbar
    self.horizontalScrollBar.onValueChange = function(scrollbar, value)
        local virtualOffset = self:getTextVirtualOffset()
        virtualOffset.x = value
        self:setTextVirtualOffset(virtualOffset)
        if not self.updatingTextScrollBars then
            self:saveUserTextVirtualOffset()
        end
    end
    self:updateScrollBars()
end

function UITextEdit:updateScrollBars()
    local scrollSize = self:getTextTotalSize()
    local scrollWidth = math.max(scrollSize.width - self:getTextVirtualSize().width, 0)
    local scrollHeight = math.max(scrollSize.height - self:getTextVirtualSize().height, 0)

    local scrollbar = self.verticalScrollBar
    if scrollbar then
        self.updatingTextScrollBars = true
        scrollbar:setMinimum(0)
        scrollbar:setMaximum(scrollHeight)
        scrollbar:setValue(self:getTextVirtualOffset().y)
        self.updatingTextScrollBars = false
    end

    local scrollbar = self.horizontalScrollBar
    if scrollbar then
        self.updatingTextScrollBars = true
        scrollbar:setMinimum(0)
        scrollbar:setMaximum(scrollWidth)
        scrollbar:setValue(self:getTextVirtualOffset().x)
        self.updatingTextScrollBars = false
    end

end

-- todo: ontext change, focus to cursor
