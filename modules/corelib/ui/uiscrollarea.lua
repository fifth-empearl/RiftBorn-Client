-- @docclass
UIScrollArea = extends(UIWidget, 'UIScrollArea')

-- public functions
function UIScrollArea.create()
    local scrollarea = UIScrollArea.internalCreate()
    scrollarea:setClipping(true)
    scrollarea.inverted = false
    scrollarea.alwaysScrollMaximum = false
    return scrollarea
end

function UIScrollArea:onStyleApply(styleName, styleNode)
    for name, value in pairs(styleNode) do
        if name == 'vertical-scrollbar' then
            addEvent(function()
                local parent = self:getParent()
                if parent then
                    self:setVerticalScrollBar(parent:getChildById(value))
                end
            end)
        elseif name == 'horizontal-scrollbar' then
            addEvent(function()
                local parent = self:getParent()
                if parent then
                    self:setHorizontalScrollBar(self:getParent():getChildById(value))
                end
            end)
        elseif name == 'inverted-scroll' then
            self:setInverted(value)
        elseif name == 'always-scroll-maximum' then
            self:setAlwaysScrollMaximum(value)
        end
    end
end

function UIScrollArea:updateScrollBars()
    local childrenRect = self:getChildrenRect()
    local paddingRect = self:getPaddingRect()
    local virtualOffset = self:getVirtualOffset()
    local scrollWidth = math.max((childrenRect.x + childrenRect.width + virtualOffset.x) - (paddingRect.x + paddingRect.width), 0)
    local scrollHeight = math.max((childrenRect.y + childrenRect.height + virtualOffset.y) - (paddingRect.y + paddingRect.height), 0)

    local scrollbar = self.verticalScrollBar
    if scrollbar then
        if self.inverted then
            scrollbar:setMinimum(-scrollHeight)
            scrollbar:setMaximum(0)
        else
            scrollbar:setMinimum(0)
            scrollbar:setMaximum(scrollHeight)
        end
    end

    local scrollbar = self.horizontalScrollBar
    if scrollbar then
        if self.inverted then
            scrollbar:setMinimum(-scrollWidth)
            scrollbar:setMaximum(0)
        else
            scrollbar:setMinimum(0)
            scrollbar:setMaximum(scrollWidth)
        end
    end

    if self.lastScrollWidth ~= scrollWidth then
        self:onScrollWidthChange()
    end
    if self.lastScrollHeight ~= scrollHeight then
        self:onScrollHeightChange()
    end

    self.lastScrollWidth = scrollWidth
    self.lastScrollHeight = scrollHeight
end

function UIScrollArea:setVerticalScrollBar(scrollbar)
    self.verticalScrollBar = scrollbar
    connect(self.verticalScrollBar, 'onValueChange', function(scrollbar, value)
        local virtualOffset = self:getVirtualOffset()
        virtualOffset.y = value
        self:setVirtualOffset(virtualOffset)
        signalcall(self.onScrollChange, self, virtualOffset)
    end)
    self:updateScrollBars()
end

function UIScrollArea:setHorizontalScrollBar(scrollbar)
    self.horizontalScrollBar = scrollbar
    connect(self.horizontalScrollBar, 'onValueChange', function(scrollbar, value)
        local virtualOffset = self:getVirtualOffset()
        virtualOffset.x = value
        self:setVirtualOffset(virtualOffset)
        signalcall(self.onScrollChange, self, virtualOffset)
    end)
    self:updateScrollBars()
end

function UIScrollArea:setInverted(inverted)
    self.inverted = inverted
    self:updateScrollBars()
end

function UIScrollArea:setInvertedScroll(inverted)
    self:setInverted(inverted)
end

function UIScrollArea:setAlwaysScrollMaximum(value)
    self.alwaysScrollMaximum = value
end

function UIScrollArea:onLayoutUpdate()
    self:updateScrollBars()
end

function UIScrollArea:onMouseWheel(mousePos, mouseWheel)
    if self.verticalScrollBar then
        if not self.verticalScrollBar:isOn() then
            return false
        end
        if mouseWheel == MouseWheelUp then
            local minimum = self.verticalScrollBar:getMinimum()
            if self.verticalScrollBar:getValue() <= minimum then
                return false
            end
            self.verticalScrollBar:decrement()
        else
            local maximum = self.verticalScrollBar:getMaximum()
            if self.verticalScrollBar:getValue() >= maximum then
                return false
            end
            self.verticalScrollBar:increment()
        end
    elseif self.horizontalScrollBar then
        if not self.horizontalScrollBar:isOn() then
            return false
        end
        if mouseWheel == MouseWheelUp then
            local maximum = self.horizontalScrollBar:getMaximum()
            if self.horizontalScrollBar:getValue() >= maximum then
                return false
            end
            self.horizontalScrollBar:increment()
        else
            local minimum = self.horizontalScrollBar:getMinimum()
            if self.horizontalScrollBar:getValue() <= minimum then
                return false
            end
            self.horizontalScrollBar:decrement()
        end
    end
    return true
end

function UIScrollArea:ensureChildVisible(child, offset)
    if self.dragging or not child then
        return
    end

    local paddingRect = self:getPaddingRect()
    local childRect = {
        x = child:getX(),
        y = child:getY(),
        width = child:getWidth(),
        height = child:getHeight()
    }

    offset = offset or { x = 0, y = 0 }

    if childRect.width > paddingRect.width or childRect.height > paddingRect.height then
        return
    end

    if self.verticalScrollBar then
        local deltaY = paddingRect.y - childRect.y
        if deltaY > 0 then
            self.verticalScrollBar:decrement(deltaY)
        end

        deltaY = (childRect.y + childRect.height + offset.y) - (paddingRect.y + paddingRect.height)
        if deltaY > 0 then
            self.verticalScrollBar:increment(deltaY)
        end
    end

    if self.horizontalScrollBar then
        local deltaX = paddingRect.x - childRect.x
        if deltaX > 0 then
            self.horizontalScrollBar:decrement(deltaX)
        end

        deltaX = (childRect.x + childRect.width + offset.x) - (paddingRect.x + paddingRect.width)
        if deltaX > 0 then
            self.horizontalScrollBar:increment(deltaX)
        end
    end
end

function UIScrollArea:onChildFocusChange(focusedChild, oldFocused, reason)
    if focusedChild and (reason == MouseFocusReason or reason == KeyboardFocusReason) then
        self:ensureChildVisible(focusedChild)
    end
end

function UIScrollArea:onScrollWidthChange()
    if self.alwaysScrollMaximum and self.horizontalScrollBar then
        self.horizontalScrollBar:setValue(self.horizontalScrollBar:getMaximum())
    end
end

function UIScrollArea:onScrollHeightChange()
    if self.alwaysScrollMaximum and self.verticalScrollBar then
        self.verticalScrollBar:setValue(self.verticalScrollBar:getMaximum())
    end
end
