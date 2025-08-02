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
--

-- g504 (left side)
-- far 6
-- near 4
-- thumb 5

-- The button your gestures are mapped to G1 = 1, G2 = 2 etc..
gestureButtonNumber = 4

-- The button navigation actions are mapped to G1 = 1, G2 = 2 etc..

navigationButtonNumber = 6

scrollLeftButtonNumber = 7
scrollRightButtonNumber = 8

-- The minimal horizontal/vertical distance your mouse needs to be moved for the gesture to recognize in pixels
minMove = 100
minimalHorizontalMovement = minMove
minimalVerticalMovement = minMove

-- auto dispatch within this delay
autoDispatchDelay = 150

-- macroname
nameMacroUp = "macroup"
nameMacroDown = "macrodown"
nameMacroStayStill5 = "macrokey5"
nameMacroStayStill4 = "macrokey4"

-- Default values for
horizontalStartingPosistion = 0
verticalStartingPosistion = 0
horizontalEndingPosistion = 0
verticalEndingPosistion = 0

-- Delay between keypresses in millies
delay = 20

-- Here you can enable/disable features of the script
missionControlEnabled = true
applicationWindowsEnabled = true
moveBetweenSpacesEnabled = true
browserNavigationEnabled = false

-- Toggles debugging messages
debuggingEnabled = false

-- Event detection
function OnEvent(event, arg, family)
	isActionHandled = true
	if debuggingEnabled then
		OutputLogMessage("\nEvent: " .. event .. " for button: " .. arg .. "\n")
	end

	--
	if event == "MOUSE_BUTTON_PRESSED" and (arg == scrollLeftButtonNumber) then
		performPreviousPageGesture()
	end
	if event == "MOUSE_BUTTON_PRESSED" and (arg == scrollRightButtonNumber) then
		performNextPageGesture()
	end

	if event == "MOUSE_BUTTON_PRESSED" and (arg == gestureButtonNumber or arg == navigationButtonNumber) then
		-- if debuggingEnabled then OutputLogMessage("\nEvent: " .. event .. " for button: " .. arg .. "\n") end
		isActionHandled = false
		-- Get stating mouse posistion
		horizontalStartingPosistion, verticalStartingPosistion = GetMousePosition()
		if debuggingEnabled then
			OutputLogMessage("Horizontal starting posistion: " .. horizontalStartingPosistion .. "\n")
			OutputLogMessage("Vertical starting posistion: " .. verticalStartingPosistion .. "\n")
		end

		Sleep(autoDispatchDelay)
		-- Get stating mouse posistion
		horizontalEndingPosistion, verticalEndingPosistion = GetMousePosition()

		if debuggingEnabled then
			OutputLogMessage("Horizontal ending posistion: " .. horizontalEndingPosistion .. "\n")
			OutputLogMessage("Vertical ending posistion: " .. verticalEndingPosistion .. "\n")
		end

		-- Calculate differences between start and end posistions
		horizontalDifference = horizontalStartingPosistion - horizontalEndingPosistion
		verticalDifference = verticalStartingPosistion - verticalEndingPosistion

		-- Determine the direction of the mouse and if the mouse moved far enough
		isStayStill = true
		if horizontalDifference > minimalHorizontalMovement then
			mouseMovedRight(arg)
			isActionHandled = true
			isStayStill = false
		end
		if horizontalDifference < -minimalHorizontalMovement then
			mouseMovedLeft(arg)
			isActionHandled = true
			isStayStill = false
		end
		if verticalDifference > minimalVerticalMovement then
			mouseMovedDown(arg)
			isActionHandled = true
			isStayStill = false
		end
		if verticalDifference < -minimalVerticalMovement then
			mouseMovedUp(arg)
			isActionHandled = true
			isStayStill = false
		end
	end

	if
		event == "MOUSE_BUTTON_RELEASED"
		and (arg == gestureButtonNumber or arg == navigationButtonNumber)
		and not isActionHandled
	then
		if debuggingEnabled then
			OutputLogMessage("\nEvent: " .. event .. " for button: " .. arg .. "\n")
		end
		-- Get stating mouse posistion
		horizontalEndingPosistion, verticalEndingPosistion = GetMousePosition()

		if debuggingEnabled then
			OutputLogMessage("Horizontal ending posistion: " .. horizontalEndingPosistion .. "\n")
			OutputLogMessage("Vertical ending posistion: " .. verticalEndingPosistion .. "\n")
		end

		-- Calculate differences between start and end posistions
		horizontalDifference = horizontalStartingPosistion - horizontalEndingPosistion
		verticalDifference = verticalStartingPosistion - verticalEndingPosistion

		-- Determine the direction of the mouse and if the mouse moved far enough
		isStayStill = true
		if horizontalDifference > minimalHorizontalMovement then
			mouseMovedRight(arg)
			isActionHandled = true
			isStayStill = false
		end
		if horizontalDifference < -minimalHorizontalMovement then
			mouseMovedLeft(arg)
			isActionHandled = true
			isStayStill = false
		end
		if verticalDifference > minimalVerticalMovement then
			mouseMovedDown(arg)
			isActionHandled = true
			isStayStill = false
		end
		if verticalDifference < -minimalVerticalMovement then
			mouseMovedUp(arg)
			isActionHandled = true
			isStayStill = false
		end
		if isStayStill then
			performMacroStayStill(gestureButtonNumber)
		end
		-- Get ending mouse posistion
	end
end

-- Mouese Moved
function mouseMovedUp(buttonNumber)
	if debuggingEnabled then
		OutputLogMessage("mouseMovedUp\n")
	end

	if buttonNumber == gestureButtonNumber then
		performMacroUp()
	end
end

function mouseMovedDown(buttonNumber)
	if debuggingEnabled then
		OutputLogMessage("mouseMovedDown\n")
	end

	if buttonNumber == navigationButtonNumber and applicationWindowsEnabled then
		performApplicationWindowsGesture()
	end
	if buttonNumber == gestureButtonNumber then
		performMacroDown()
	end
end

function mouseMovedLeft(buttonNumber)
	if debuggingEnabled then
		OutputLogMessage("mouseMovedLeft\n")
	end

	if buttonNumber == navigationButtonNumber and moveBetweenSpacesEnabled then
		performSwipeLeftGesture()
	end
	if buttonNumber == gestureButtonNumber and browserNavigationEnabled then
		performNextPageGesture()
	end
end

function mouseMovedRight(buttonNumber)
	if debuggingEnabled then
		OutputLogMessage("mouseMovedRight\n")
	end

	if buttonNumber == navigationButtonNumber and moveBetweenSpacesEnabled then
		performSwipeRightGesture()
	end
	if buttonNumber == gestureButtonNumber and browserNavigationEnabled then
		performPreviousPageGesture()
	end
end

-- Gesture Functions
function performMissionControlGesture()
	if debuggingEnabled then
		OutputLogMessage("performMissionControlGesture\n")
	end
	firstKey = "lctrl"
	secondKey = "up"
	pressTwoKeys(firstKey, secondKey)
end

function performApplicationWindowsGesture()
	if debuggingEnabled then
		OutputLogMessage("performApplicationWindowsGesture\n")
	end
	firstKey = "lctrl"
	secondKey = "down"
	pressTwoKeys(firstKey, secondKey)
end

function performSwipeLeftGesture()
	if debuggingEnabled then
		OutputLogMessage("performSwipeLeftGesture\n")
	end
	firstKey = "lctrl"
	secondKey = "right"
	pressTwoKeys(firstKey, secondKey)
end

function performSwipeRightGesture()
	if debuggingEnabled then
		OutputLogMessage("performSwipeRightGesture\n")
	end
	firstKey = "lctrl"
	secondKey = "left"
	pressTwoKeys(firstKey, secondKey)
end

-- Browser Navigation Functions
function performNextPageGesture()
	if debuggingEnabled then
		OutputLogMessage("performNextPageGesture\n")
	end
	firstKey = "lgui"
	secondKey = "rbracket"
	pressTwoKeys(firstKey, secondKey)
end

function performPreviousPageGesture()
	if debuggingEnabled then
		OutputLogMessage("performPreviousPageGesture\n")
	end
	firstKey = "lgui"
	secondKey = "lbracket"
	pressTwoKeys(firstKey, secondKey)
end

function performMacroUp()
	if debuggingEnabled then
		OutputLogMessage("performMacroUp")
	end
	PlayMacro(nameMacroUp)
end
function performMacroDown()
	if debuggingEnabled then
		OutputLogMessage("performMacroDown")
	end
	PlayMacro(nameMacroDown)
end

function performMacroStayStill(symbol)
	if debuggingEnabled then
		OutputLogMessage("performMacroStayStill " .. tostring(symbol) .. "\n")
	end

	if symbol == gestureButtonNumber then
		-- PlayMacro(nameMacroStayStill5)
		performMissionControlGesture()
	end
	if symbol == navigationButtonNumber then
		PlayMacro(nameMacroStayStill4)
	end
end

-- Helper Functions
function pressTwoKeys(firstKey, secondKey)
	PressKey(firstKey)
	Sleep(delay)
	PressKey(secondKey)
	Sleep(delay)
	ReleaseKey(firstKey)
	ReleaseKey(secondKey)
end
