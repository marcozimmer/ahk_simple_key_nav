#Requires AutoHotkey v2.0
; #MaxHotkeysPerInterval 1000

global capsLockHeld := false
global capsLockTimer := 0
global longPressThreshold := 100
global mouseMoltiplier := 1

global arrowStates := Map("Up", false, "Down", false, "Left", false, "Right", false)
global firstArrowPressTime := 0

global reverseVScroll := true
global reverseHScroll := false


; READ CONFIG FILE

config := "simpleKeyNavConfig.ini"

GroupMouseMove  := Map()
GroupMouseMove2 := Map()
GroupMouseClick := Map()
GroupKeyPad     := Map()

; MOUSE MOVE
GroupMouseMove["_up"]      := IniRead(config, "MouseMove", "up", "Up")
GroupMouseMove["_down"]    := IniRead(config, "MouseMove", "down", "Down")
GroupMouseMove["_left"]    := IniRead(config, "MouseMove", "left", "Left")
GroupMouseMove["_right"]   := IniRead(config, "MouseMove", "right", "Right")

; ALT MOUSE MOVE
GroupMouseMove2["_up2"]    := IniRead(config, "MouseMove2", "up", "i")
GroupMouseMove2["_down2"]  := IniRead(config, "MouseMove2", "down", "k")
GroupMouseMove2["_left2"]  := IniRead(config, "MouseMove2", "left", "j")
GroupMouseMove2["_right2"] := IniRead(config, "MouseMove2", "right", "l")

; ALT MOUSE CLICK
GroupMouseClick["_lclick"] := IniRead(config, "MouseClick", "lclick", "c")
GroupMouseClick["_mclick"] := IniRead(config, "MouseClick", "mclick", "x")
GroupMouseClick["_rclick"] := IniRead(config, "MouseClick", "rclick", "z")

; KEYPAD
GroupKeyPad["_1"]          := IniRead(config, "KeyPad", "1", "PrintScreen")
GroupKeyPad["_2"]          := IniRead(config, "KeyPad", "2", "ScrollLock")
GroupKeyPad["_3"]          := IniRead(config, "KeyPad", "3", "Pause")
GroupKeyPad["_4"]          := IniRead(config, "KeyPad", "4", "Insert")
GroupKeyPad["_5"]          := IniRead(config, "KeyPad", "5", "Home")
GroupKeyPad["_6"]          := IniRead(config, "KeyPad", "6", "PgUp")
GroupKeyPad["_7"]          := IniRead(config, "KeyPad", "7", "Delete")
GroupKeyPad["_8"]          := IniRead(config, "KeyPad", "8", "End")
GroupKeyPad["_9"]          := IniRead(config, "KeyPad", "9", "PgDn")
GroupKeyPad["_0"]          := IniRead(config, "KeyPad", "0", "\")

CapsLock:: {
    if(!capsLockHeld)
        global capsLockTimer := A_TickCount

;    if (A_TickCount - capsLockTimer >= longPressThreshold) {
;        ShowText("_layer_", 500)
;    }

    firstArrowPressTime := 0

    global capsLockHeld := true
    global mouseMoltiplier := 1

    SetHotKeys()

}

CapsLock Up:: {
    elapsed := A_TickCount - capsLockTimer

    if (elapsed < longPressThreshold) {
        SetCapsLockState(!GetKeyState("CapsLock", "T"))
    }

    for key in arrowStates {
        arrowStates[key] := false
    }

    firstArrowPressTime := 0
    global capsLockHeld := false

    UnsetHotKeys()
}

;#HotIf capsLockHeld && A_TickCount - capsLockTimer >= longPressThreshold
;
;#HotIf

SetHotKeys() {
    Hotkey(GroupMouseMove["_up"],            (*) => StartArrow("Up"))
    Hotkey(GroupMouseMove["_up"] " UP",      (*) => StopArrow("Up"))
    Hotkey(GroupMouseMove["_left"],          (*) => StartArrow("Left"))
    Hotkey(GroupMouseMove["_left"] " UP",    (*) => StopArrow("Left"))
    Hotkey(GroupMouseMove["_down"],          (*) => StartArrow("Down"))
    Hotkey(GroupMouseMove["_down"] " UP",    (*) => StopArrow("Down"))
    Hotkey(GroupMouseMove["_right"],         (*) => StartArrow("Right"))
    Hotkey(GroupMouseMove["_right"] " UP",   (*) => StopArrow("Right"))

    Hotkey(GroupMouseMove2["_up2"],          (*) => StartArrow("Up"))
    Hotkey(GroupMouseMove2["_up2"] " UP",    (*) => StopArrow("Up"))
    Hotkey(GroupMouseMove2["_left2"],        (*) => StartArrow("Left"))
    Hotkey(GroupMouseMove2["_left2"] " UP",  (*) => StopArrow("Left"))
    Hotkey(GroupMouseMove2["_down2"],        (*) => StartArrow("Down"))
    Hotkey(GroupMouseMove2["_down2"] " UP",  (*) => StopArrow("Down"))
    Hotkey(GroupMouseMove2["_right2"],       (*) => StartArrow("Right"))
    Hotkey(GroupMouseMove2["_right2"] " UP", (*) => StopArrow("Right"))

    Hotkey(GroupMouseClick["_lclick"],       (*) => Send("{LButton down}"))
    Hotkey(GroupMouseClick["_lclick"] " UP", (*) => Send("{LButton up}"))
    Hotkey(GroupMouseClick["_mclick"],       (*) => Send("{MButton down}"))
    Hotkey(GroupMouseClick["_mclick"] " UP", (*) => Send("{MButton up}"))
    Hotkey(GroupMouseClick["_rclick"],       (*) => Send("{RButton down}"))
    Hotkey(GroupMouseClick["_rclick"] " UP", (*) => Send("{RButton up}"))

    Hotkey(GroupKeyPad["_1"],                (*) => Send("1"))
    Hotkey(GroupKeyPad["_2"],                (*) => Send("2"))
    Hotkey(GroupKeyPad["_3"],                (*) => Send("3"))
    Hotkey(GroupKeyPad["_4"],                (*) => Send("4"))
    Hotkey(GroupKeyPad["_5"],                (*) => Send("5"))
    Hotkey(GroupKeyPad["_6"],                (*) => Send("6"))
    Hotkey(GroupKeyPad["_7"],                (*) => Send("7"))
    Hotkey(GroupKeyPad["_8"],                (*) => Send("8"))
    Hotkey(GroupKeyPad["_9"],                (*) => Send("9"))
    Hotkey(GroupKeyPad["_0"],                (*) => Send("0"))

    try {
        for k, v in GroupMouseMove {
            Hotkey(v,       "On")
            Hotkey(v " UP", "On")
        }
        for k, v in GroupMouseMove2 {
            Hotkey(v,       "On")
            Hotkey(v " UP", "On")
        }
        for k, v in GroupMouseClick {
            Hotkey(v,       "On")
            Hotkey(v " UP", "On")
        }
        for k, v in GroupKeyPad {
            Hotkey(v,       "On")
        }
    }
}
    
UnsetHotKeys() {
    try {
        for k, v in GroupMouseMove  {
            Hotkey(v,       "Off")
            Hotkey(v " UP", "Off")
        }
        for k, v in GroupMouseMove2 {
            Hotkey(v,       "Off")
            Hotkey(v " UP", "Off")
        }
        for k, v in GroupMouseClick {
            Hotkey(v,       "Off")
            Hotkey(v " UP", "Off")
        }
        for k, v in GroupKeyPad     {
            Hotkey(v,       "Off")
        }
    }
}

StartArrow(key) {
    global firstArrowPressTime
    arrowStates[key] := true

    if (firstArrowPressTime = 0) {
        firstArrowPressTime := A_TickCount
    }
    ; ShowText(key . " " . arrowStates["Left"] . " " . arrowStates["Right"] . " " . arrowStates["Up"] . " " . arrowStates["Down"])
}

StopArrow(key) {
    global firstArrowPressTime

    arrowStates[key] := false

    if(!arrowStates["Left"] and !arrowStates["Right"] and !arrowStates["Up"] and !arrowStates["Down"]) {
        firstArrowPressTime := 0
    }
}

; PRIMARY TIMER
SetTimer(MoveMouseContinuously, 10)

MoveMouseContinuously(*) {
    global reverseVScroll
    global reverseHScroll

    if !capsLockHeld
        return

    dx := 0
    dy := 0

    elapsedMove := A_TickCount - firstArrowPressTime
    if arrowStates["Left"]
        if(GetKeyState("Space", "P")) {
            direction := reverseVScroll ? "{WheelLeft}" : "{WheelRight}"
            SendEvent(direction)
        } else
            dx -= GetSpeed(elapsedMove)
    if arrowStates["Right"]
        if(GetKeyState("Space", "P")) {
            direction := reverseVScroll ? "{WheelRight}" : "{WheelLeft}"
            SendEvent(direction)
        } else
            dx += GetSpeed(elapsedMove)
    if arrowStates["Up"]
        if(GetKeyState("Space", "P")) {
            direction := reverseVScroll ? "{WheelUp}" : "{WheelDown}"
            SendEvent(direction)
        } else
            dy -= GetSpeed(elapsedMove)
    if arrowStates["Down"]
        if(GetKeyState("Space", "P")) {
            direction := reverseVScroll ? "{WheelDown}" : "{WheelUp}"
            SendEvent(direction)
        } else
            dy += GetSpeed(elapsedMove)
    if (dx != 0 or dy != 0)
        MouseMove(dx, dy, 0, "R")
}

GetSpeed(elapsedMove, panning := false) {
    global mouseMoltiplier

    mouseMoltiplier := 1
    if(GetKeyState("a", "P"))
        DoubleMouseMultiplier()
    if(GetKeyState("s", "P"))
        DoubleMouseMultiplier()
    if(GetKeyState("d", "P"))
        DoubleMouseMultiplier()

    timeMoltiplier := min(elapsedMove/100, 12)

    if panning
        ret := Min(4 * (timeMoltiplier * mouseMoltiplier), 8)
    else
        ret:= 2 * (timeMoltiplier * mouseMoltiplier)

    ; ShowText(timeMoltiplier . " " . mouseMoltiplier . " " . (timeMoltiplier * mouseMoltiplier))

    return ret
}

DoubleMouseMultiplier() {
    global mouseMoltiplier
    mouseMoltiplier := mouseMoltiplier * 2
    if mouseMoltiplier > 12
        mouseMoltiplier := 12
}

; NOT USED
HalveMouseMultiplier() {
    global mouseMoltiplier
    mouseMoltiplier := mouseMoltiplier / 2
    if mouseMoltiplier < 1
        mouseMoltiplier := 1
}

ShowText(txt, duration := 500) {
    MyGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000")  ; NO BORDERS NO BAR: WS_EX_NOACTICE

    ; GUI SPECS
    MyGui.BackColor := "Black"
    MyGui.SetFont("s10 cWhite", "Segoe UI")
    MyGui.Add("Text", "Center w200", txt)

    ; SCREEN SIZE
    screenWidth := A_ScreenWidth
    screenHeight := A_ScreenHeight

    ; GUI SIZE
    WinGetPos(&xGui, &yGui, &wGui, &hGui, myGui.Hwnd)

    ; CENTER BOTTOM POSITION
    x := (screenWidth - wGui) // 2
    y := screenHeight - hGui - 100

    myGui.Show("AutoSize Center y" y)

    ; WAIT AND CLOSE GUI
    SetTimer(() => MyGui.Destroy(), -duration)
}
