---@diagnostic disable: undefined-global, lowercase-global, redundant-parameter

local events = require 'samp.events'
local imgui = require 'mimgui'
local enc = require 'encoding'
local wm = require 'windows.message'
local vkeys = require 'vkeys'

script_name('Moon Developer')
script_authors('Moon Glance', 'neverlessy')
script_version('1.0.0')
script_description('All rights reserved. © Moon Glance 2022')

local scriptTag = '{637282}[Moon Dev] {bababa}'
local m = imgui
local new = m.new
local v2 = m.ImVec2
local v4 = m.ImVec4
local posX = m.SetCursorPosX
local posY = m.SetCursorPosY
local sampMsg = sampAddChatMessage
local flags = imgui.WindowFlags
enc.default = 'CP1251'
local u8 = enc.UTF8
local fonts = {}
local userScreenX, userScreenY = getScreenResolution()
local fontCarInfo = renderCreateFont("Arial", 9, 5)
local menuType = {false, false, false, true, false, false, false, false}
local moonDevMenu, vehicleInfo = new.bool(), new.bool()
local dialogIdBool, dialogColorBool, dialogButtonIdBool, dialogListItemBool, dialogLogBool, vehicleInfoNotCarBool, vehicleInfoCarBool, vehicleModSpeedSlider, vehicleRenderDistSlider = new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(), new.bool(true), new.float(3.6), new.int(50)

local moonDevMenuFrame = m.OnFrame(
    function() return moonDevMenu[0] end,
    function(player)
        m.SetNextWindowPos(v2(400, 550), m.Cond.FirstUseEver, v2(0.5, 0.5))
        m.SetNextWindowSize(v2(750, 400), m.Cond.FirstUseEver)
        m.Begin("Main Window", moonDevMenu, flags.NoResize + flags.NoCollapse + flags.NoScrollbar + flags.NoTitleBar)
            --
            m.PushFont(fonts[25])
            m.BeginChild('#MenuButtons', v2(220, 400), true)
                if m.Button(u8"Диалоги", v2(200, 50), posY(9), posX(10)) then
                    switchMenu(2)
                end
                if m.Button(u8"Обьекты", v2(200, 50), posX(10)) then
                    switchMenu(3)
                end
                if m.Button(u8"Транспорт", v2(200, 50), posX(10)) then
                    switchMenu(4)
                end
                m.Button(u8"Текстдравы", v2(200, 50), posX(10))
                m.Button(u8"Чат", v2(200, 50), posX(10))
                m.Button(u8"Персонаж", v2(200, 50), posX(10))
                m.Button(u8"Цель", v2(200, 50), posX(10))
            m.EndChild() m.SameLine()
            m.PopFont()
            m.BeginChild('#Content', v2(510, 400), false, posX(230))
            if menuType[1] then -- Меню при активации скрипта.
                m.PushFont(fonts[50])
                    m.Text(u8"Добро пожаловать", posX(90), posY(150))
                m.PopFont()
                m.PushFont(fonts[25])
                    m.Text(u8"Выберите вкладку", posX(200), posY(200))
                m.PopFont()
            end
            if menuType[2] then
                m.PushFont(fonts[25])
                    m.Checkbox(u8" Номер диалога в заголовке", dialogIdBool, posY(9))
                    m.Checkbox(u8" Показ цветовых кодов", dialogColorBool)
                    m.Checkbox(u8" Номер кнопки в названии кнопки", dialogButtonIdBool)
                    m.Checkbox(u8" Номер листайтема в списке", dialogListItemBool)
                    m.Checkbox(u8" Сохранять информацию о диалоге в лог", dialogLogBool)
                m.PopFont()
            end
            if menuType[4] then
                m.PushFont(fonts[25])
                    m.Checkbox(u8" Информация об авто вне транспорта", vehicleInfoNotCarBool, posY(9))
                    m.Checkbox(u8" Информация об авто в транспорте", vehicleInfoCarBool)
                    if vehicleInfoCarBool[0] or vehicleInfoNotCarBool[0] then
                        m.SliderFloat(u8' Множитель скорости', vehicleModSpeedSlider, 1.0, 10.0)
                    end
                    m.SliderInt(u8' Дальность рендера', vehicleRenderDistSlider, 1, 250)
                m.PopFont()
            end
            m.EndChild()
            --
        m.End()
        player.HideCursor = false
    end
)


local vehicleInfoFrame = m.OnFrame(
    function() return vehicleInfo[0] end,
    function(player)
        m.SetNextWindowPos(v2(userScreenX - 300, userScreenY / 2), m.Cond.FirstUseEver, v2(0.5, 0.5))
        m.SetNextWindowSize(v2(350, 200), m.Cond.FirstUseEver)
        m.Begin("VehicleWindow", vehicleInfo, flags.NoResize + flags.NoCollapse + flags.NoScrollbar + flags.NoTitleBar)
            if isCharInAnyCar(PLAYER_PED) and vehicleInfoCarBool[0] then
                handle = storeCarCharIsInNoSave(PLAYER_PED)
                doorStatus = getCarDoorLockStatus(handle)
                if doorStatus then
                    doorStatus = u8'Открыты'
                else
                    doorStatus = u8'Закрыты'
                end
                m.CenterText(u8"Информация об авто", posY(2)) m.Separator()
                getNameOfVehicleModel()
                m.CenterText(u8"Модель: "..getNameOfVehicleModel(getCarModel(handle)).." ["..getCarModel(handle).."]")
                m.CenterText(u8"Цвет: "..select(1, getCarColours(handle))..'/'..select(2, getCarColours(handle)))
                m.CenterText(u8"Здоровье: "..select(1, getCarHealth(handle)))
                m.CenterText(u8"Двери: "..doorStatus)
                m.CenterText(u8"Скорость: "..string.format('%.2f', select(1, getCarSpeed(handle) * vehicleModSpeedSlider[0])))
                m.CenterText(u8"X: "..string.format('%.2f', select(1, getCarCoordinates(handle))).." | QX: "..string.format('%.2f', select(1, getVehicleQuaternion(handle))))
                m.CenterText(u8"Y: "..string.format('%.2f', select(2, getCarCoordinates(handle))).." | QY: "..string.format('%.2f', select(2, getVehicleQuaternion(handle))))
                m.CenterText(u8"Z: "..string.format('%.2f', select(3, getCarCoordinates(handle))).." | QZ: "..string.format('%.2f', select(3, getVehicleQuaternion(handle))))
                m.CenterText(u8"QW: "..string.format('%.2f', select(4, getVehicleQuaternion(handle))))
            end
        m.End()
        player.HideCursor = true
    end
)

function switchMenu(newMenu)
    for i = 1, 8 do
        if i ~= newMenu then
            menuType[i] = false
        end
    end
    menuType[newMenu] = true
end

m.OnInitialize(function()
    m.DarkTheme()
    local config = m.ImFontConfig()
    config.MergeMode = true
    local glyph_ranges = m.GetIO().Fonts:GetGlyphRangesCyrillic()
    m.GetIO().Fonts:AddFontFromFileTTF('trebucbd.ttf', 14.0, nil, glyph_ranges)
    fonts = {
        [15] = m.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory()..'/resource/MoonDeveloper/fonts/SFDR.otf', 15.0, nil, glyph_ranges),
        [25] = m.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory()..'/resource/MoonDeveloper/fonts/FSm.otf', 18.0, nil, glyph_ranges),
        [50] = m.GetIO().Fonts:AddFontFromFileTTF(getWorkingDirectory()..'/resource/MoonDeveloper/fonts/SFDR.otf', 50.0, nil, glyph_ranges)
    }
    m.GetIO().IniFilename = nil
end)

function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    while not isSampAvailable() do wait(0) end
    sampMsg(scriptTag..'Скрипт успешно загружен', -1)
    addEventHandler('onWindowMessage', function(msg, wparam, lparam)
        if msg == wm.WM_KEYDOWN or msg == wm.WM_SYSKEYDOWN then
            if wparam == vkeys.VK_F2 then
                moonDevMenu[0] = not moonDevMenu[0]
            end
        end
    end)
    while true do wait(0)
        if not isCharInAnyCar(PLAYER_PED) and vehicleInfoNotCarBool[0] then
            vehicleInfo[0] = false
            for _, handle in ipairs(getAllVehicles()) do
                cPosX, cPosY, cPosZ = getCarCoordinates(handle)
                X, Y = convert3DCoordsToScreen(cPosX, cPosY, cPosZ)
                idcar = getCarModel(handle)
                primaryColor, secondaryColor = getCarColours(handle)
                health = getCarHealth(handle)
                doorStatus = getCarDoorLockStatus(handle)
                if doorStatus then
                    doorStatus = 'Открыто'
                else
                    doorStatus = 'Закрыто'
                end
                speed = string.format('%.2f', getCarSpeed(handle) * vehicleModSpeedSlider[0])
                --
                if isCharInArea3d(PLAYER_PED, cPosX + vehicleRenderDistSlider[0], cPosY + vehicleRenderDistSlider[0], cPosZ + vehicleRenderDistSlider[0], cPosX - vehicleRenderDistSlider[0], cPosY - vehicleRenderDistSlider[0], cPosZ - vehicleRenderDistSlider[0], false) then
                    text = "{FFFFFF}Модель: {637282}"..getNameOfVehicleModel(idcar)..' ['..idcar..']\n{FFFFFF}Цвет: {637282}'..primaryColor..'{FFFFFF} / {637282}'..secondaryColor..'\n{FFFFFF}Здоровье: {637282}'..health..'\n{FFFFFF}Позиция Х: {637282}'..string.format('%.2f', cPosX)..'\n{FFFFFF}Позиция Y: {637282}'..string.format('%.2f', cPosY)..'\n{FFFFFF}Позиция Z: {637282}'..string.format('%.2f', cPosZ)..'\n{FFFFFF}Состояние дверей: {637282}'..doorStatus..'\n{FFFFFF}Скорость: {637282}'..speed
                    renderFontDrawText(fontCarInfo, text, X, Y, 0xFFAAAAAA)
                end
            end
        elseif isCharInAnyCar(PLAYER_PED) and vehicleInfoCarBool[0] then
            vehicleInfo[0] = true
        elseif isCharInAnyCar(PLAYER_PED) and not vehicleInfoCarBool[0] then
            vehicleInfo[0] = false
        elseif not isCharInAnyCar(PLAYER_PED) then
            vehicleInfo[0] = false
        end
    end
end


function events.onShowDialog(id, style, title, button1, button2, text)
    if dialogLogBool[0] then
        listitem = {}
        separator = '\n'
        for str in string.gmatch(text, "([^"..separator.."]+)") do
                table.insert(listitem, str)
        end
        file = io.open(getWorkingDirectory().."/moonloader.log", "r+")
        file:seek("end",0)
        file:write("\n========================Moon Logging========================\n")
        file:write("TIMESTAMP: "..os.date("%X | %x", os.time(os.date("*t")))..'')
        file:write("\n============================================================\n")
        file:write("Номер диалога: "..id..'\n')
        file:write("Стиль: "..style..'\n')
        if style == 2 or style == 4 or style == 5 then
            file:write("Количество листайтемов: "..sampGetListboxItemsCount()..'\n')
        end
        file:write("Заголовок: "..title..'\n')
        file:write("Кнопка 0: "..button1..'\n')
        file:write("Кнопка 1: "..button2..'\n')
        file:write("Текст: ")
        for i = 1, #listitem do
            file:write("\n\t"..listitem[i])
        end
        file:write("\n============================================================\n")
        file:flush()
        file:close()
    end
    if dialogListItemBool[0] and (style == 2 or style == 4 or style == 5) then
        listitem = {}
        separator = '\n'
        for str in string.gmatch(text, "([^"..separator.."]+)") do
                table.insert(listitem, str)
        end
        for i = 1, #listitem do
            lastItem = listitem[i]
            listitem[i] = '['..i..'] '..listitem[i]
            text = text.gsub(text, lastItem, listitem[i])
        end
    end
    if dialogColorBool[0] then
        if text:find('%x+') then
            colors = {}
            for i = 1, 500 do
                colors[i] = text:match("{(%x+)}")
                if colors[i] ~= nil then
                    text = text.gsub(text, '{'..colors[i]..'}', '~'..colors[i]..'~')
                end
            end
            for v = 1, 500 do
                if colors[v] ~= nil then
                    text = text.gsub(text, '~'..colors[v]..'~', '{'..colors[v]..'}['..colors[v]..'] ')
                end
            end
        end
    end
    if dialogIdBool[0] then
        title = title..' {637282}['..id..']'
    end
    if dialogButtonIdBool[0] then
        button1 = button1..' {637282}[0]'
        button2 = button2..' {637282}[1]'
    end
    return {id, style, title, button1, button2, text}
end

function onScriptTerminate(script, quitGame)
    sampMsg(scriptTag..'Скрипт завершил работу', -1)
end

function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end

function imgui.DarkTheme()
    imgui.SwitchContext()
    --==[ STYLE ]==--
    imgui.GetStyle().WindowPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().FramePadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(5, 5)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2, 2)
    imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
    imgui.GetStyle().IndentSpacing = 0
    imgui.GetStyle().ScrollbarSize = 10
    imgui.GetStyle().GrabMinSize = 10

    --==[ BORDER ]==--
    imgui.GetStyle().WindowBorderSize = 1
    imgui.GetStyle().ChildBorderSize = 2
    imgui.GetStyle().PopupBorderSize = 1
    imgui.GetStyle().FrameBorderSize = 1
    imgui.GetStyle().TabBorderSize = 1

    --==[ ROUNDING ]==--
    imgui.GetStyle().WindowRounding = 5
    imgui.GetStyle().ChildRounding = 5
    imgui.GetStyle().FrameRounding = 5
    imgui.GetStyle().PopupRounding = 5
    imgui.GetStyle().ScrollbarRounding = 5
    imgui.GetStyle().GrabRounding = 5
    imgui.GetStyle().TabRounding = 5

    --==[ ALIGN ]==--
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
    imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)
    
    --==[ COLORS ]==--
    imgui.GetStyle().Colors[imgui.Col.Text]                   = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
    imgui.GetStyle().Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(0.25, 0.25, 0.26, 0.54)
    imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.51, 0.51, 0.51, 1.00)
    imgui.GetStyle().Colors[imgui.Col.CheckMark]              = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Button]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Header]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.47, 0.47, 0.47, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Separator]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(1.00, 1.00, 1.00, 0.25)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(1.00, 1.00, 1.00, 0.67)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(1.00, 1.00, 1.00, 0.95)
    imgui.GetStyle().Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.28, 0.28, 0.28, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = imgui.ImVec4(0.07, 0.10, 0.15, 0.97)
    imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = imgui.ImVec4(0.14, 0.26, 0.42, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.61, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(1.00, 0.43, 0.35, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(1.00, 0.00, 0.00, 0.35)
    imgui.GetStyle().Colors[imgui.Col.DragDropTarget]         = imgui.ImVec4(1.00, 1.00, 0.00, 0.90)
    imgui.GetStyle().Colors[imgui.Col.NavHighlight]           = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight]  = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg]      = imgui.ImVec4(0.80, 0.80, 0.80, 0.20)
    imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
end