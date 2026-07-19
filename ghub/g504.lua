--[[
Author: Mark van den Berg
Version: 0.8
Date: 01-05-2020

Special credits to https://github.com/wookiefriseur for showing a way to do this for windows gestures which inspired this script
For some windows gestures check https://github.com/wookiefriseur/LogitechMouseGestures

This script wil let you use a button on your mouse to act like the "Gesture button" from Logitech Options.
It will also let you use another button on your mouse for navigating between browser pages using gestures.

The default settings below will be for the multytasking gestures from macOS
 - Up 		Mission Control 	(Control+Up-Arrow)
 - Down 	Application Windows (Control+Down-Arrow)
 - Left 	move right a space 	(Control+Right-Arrow)
 - Right 	move left a space 	(Control+Left-Arrow)

The default settings below will be for the navigation gestures for in browsers
 - Up 		{ no action }
 - Down 	{ no action }
 - Left 	next page 		(Command+Right-Bracket)
 - Right 	previous page 	(Command+Left-Bracket)
]]

-- g504 (left side)
-- far 6  |  near 4  |  thumb 5

-- Button mapping
GESTURE_BUTTON = 6
NAVIGATION_BUTTON = 4
SCROLL_LEFT_BUTTON = 7
SCROLL_RIGHT_BUTTON = 8

-- Gesture sensitivity (pixels)
MIN_MOVE = 100

-- Auto-dispatch delay (ms): when held, direction is detected after this delay
AUTO_DISPATCH_DELAY = 150

-- Macro names
MACRO_UP = "macroup"
MACRO_DOWN = "macrodown"
MACRO_LEFT = "macroleft"
MACRO_RIGHT = "macroright"
MACRO_STAY_5 = "macrokey5"
MACRO_STAY_4 = "macrokey4"

-- Key press delay (ms)
KEY_DELAY = 20

-- Feature toggles
MISSION_CONTROL_ENABLED = true
APPLICATION_WINDOWS_ENABLED = true
MOVE_BETWEEN_SPACES_ENABLED = true
BROWSER_NAVIGATION_ENABLED = false

DEBUG_ENABLED = true

-- State
local startX = 0
local startY = 0
local actionHandled = false

function OnEvent(event, arg, family)
	debugLog("Event: " .. event .. " for button: " .. arg)

	if event == "MOUSE_BUTTON_PRESSED" and arg == SCROLL_LEFT_BUTTON then
		scrollLeftClickAction()
	elseif event == "MOUSE_BUTTON_PRESSED" and arg == SCROLL_RIGHT_BUTTON then
		scrollRightClickAction()
	elseif event == "MOUSE_BUTTON_PRESSED" and (arg == GESTURE_BUTTON or arg == NAVIGATION_BUTTON) then
		actionHandled = false
		startX, startY = GetMousePosition()
		debugLog("Start: " .. startX .. ", " .. startY)
		Sleep(AUTO_DISPATCH_DELAY)
		local endX, endY = GetMousePosition()
		debugLog("Auto-dispatch end: " .. endX .. ", " .. endY)
		local direction = resolveDirection(startX, startY, endX, endY)
		if direction then
			fireAction(direction, arg)
			actionHandled = true
		end
	elseif
		event == "MOUSE_BUTTON_RELEASED"
		and (arg == GESTURE_BUTTON or arg == NAVIGATION_BUTTON)
		and not actionHandled
	then
		local endX, endY = GetMousePosition()
		debugLog("Release end: " .. endX .. ", " .. endY)
		local direction = resolveDirection(startX, startY, endX, endY)
		if direction then
			fireAction(direction, arg)
		else
			performStayStill(arg)
		end
		actionHandled = true
	end
end

function resolveDirection(sX, sY, eX, eY)
	local dx = sX - eX
	local dy = sY - eY
	local adx = math.abs(dx)
	local ady = math.abs(dy)

	if adx < MIN_MOVE and ady < MIN_MOVE then
		return nil
	end

	if adx > ady then
		if dx > 0 then
			return "right"
		else
			return "left"
		end
	else
		if dy > 0 then
			return "down"
		else
			return "up"
		end
	end
end

function fireAction(direction, button)
	debugLog("Action: " .. direction .. " (button " .. button .. ")")
	if direction == "up" then
		if button == NAVIGATION_BUTTON then
			performMissionControl()
		elseif button == GESTURE_BUTTON then
			PlayMacro(MACRO_UP)
		end
	elseif direction == "down" then
		if button == NAVIGATION_BUTTON and APPLICATION_WINDOWS_ENABLED then
			performApplicationWindows()
		elseif button == GESTURE_BUTTON then
			PlayMacro(MACRO_DOWN)
		end
	elseif direction == "left" then
		if button == NAVIGATION_BUTTON and MOVE_BETWEEN_SPACES_ENABLED then
			performSwipeLeft()
		elseif button == GESTURE_BUTTON then
			PlayMacro(MACRO_LEFT)
		end
	elseif direction == "right" then
		if button == NAVIGATION_BUTTON and MOVE_BETWEEN_SPACES_ENABLED then
			performSwipeRight()
		elseif button == GESTURE_BUTTON then
			PlayMacro(MACRO_RIGHT)
		end
	end
end

function performStayStill(button)
	debugLog("Stay still (button " .. button .. ")")
	if button == GESTURE_BUTTON then
		performMissionControl()
	elseif button == NAVIGATION_BUTTON then
		PlayMacro(MACRO_STAY_4)
	end
end

-- Gesture actions
function performMissionControl()
	pressKeys("lctrl", "up")
end

function performApplicationWindows()
	pressKeys("lctrl", "down")
end

function performSwipeLeft()
	pressKeys("lctrl", "right")
end

function performSwipeRight()
	pressKeys("lctrl", "left")
end

-- Scroll click actions
function scrollLeftClickAction()
	pressKeys("lctrl", "lshift", "tab")
end

function scrollRightClickAction()
	pressKeys("lctrl", "tab")
end

-- Browser navigation
function performNextPage()
	pressKeys("lgui", "rbracket")
end

function performPreviousPage()
	pressKeys("lgui", "lbracket")
end

-- Utility
function pressKeys(...)
	local keys = { ... }
	for _, key in ipairs(keys) do
		PressKey(key)
		Sleep(KEY_DELAY)
	end
	for _, key in ipairs(keys) do
		ReleaseKey(key)
	end
end

function debugLog(msg)
	if DEBUG_ENABLED then
		OutputLogMessage(msg .. "\n")
	end
end
