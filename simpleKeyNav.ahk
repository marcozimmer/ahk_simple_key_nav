#Requires AutoHotkey v2.0
#SingleInstance Force

; READ CONFIG FILE
config := "simpleKeyNavConfig.ini"

MyGui := Gui()

global capsLockHeld := false
global capsLockTimer := 0
global longPressThreshold := 200
global mouseMoltiplier := 1

global arrowStates := Map("Up", false, "Down", false, "Left", false, "Right", false)
global firstArrowPressTime := 0

global WinHeld    := false
global AltHeld    := false
global CtrlHeld   := false
global ShiftHeld  := false

global WinTimer   := 0
global AltTimer   := 0
global CtrlTimer  := 0
global ShiftTimer := 0

global HomeRowTimer := 0

GroupSystem          := Map()
GroupHomeRow         := Map()
GroupMouseMove       := Map()
GroupMouseMove2      := Map()
GroupMouseClick      := Map()
GroupMouseMultiplier := Map()
GroupMouseScroll     := Map()
GroupKeyPad          := Map()

; SYSTEM
GroupHomeRow["_sountFeedback"] := IniRead(config, "System", "sountFeedback", true)

; HOME ROW
GroupHomeRow["_lwin"]    := IniRead(config, "HomeRow", "lwin", "a")
GroupHomeRow["_lalt"]    := IniRead(config, "HomeRow", "lalt", "s")
GroupHomeRow["_lctrl"]   := IniRead(config, "HomeRow", "lctrl", "d")
GroupHomeRow["_lshift"]  := IniRead(config, "HomeRow", "lshift", "f")
GroupHomeRow["_rwin"]    := IniRead(config, "HomeRow", "rwin", ";")
GroupHomeRow["_ralt"]    := IniRead(config, "HomeRow", "ralt", "l")
GroupHomeRow["_rctrl"]   := IniRead(config, "HomeRow", "rctrl", "k")
GroupHomeRow["_rshift"]  := IniRead(config, "HomeRow", "rshift", "j")

; MOUSE MOVE
GroupMouseMove["_up"]      := IniRead(config, "MouseMove", "up", "Up")
GroupMouseMove["_down"]    := IniRead(config, "MouseMove", "down", "Down")
GroupMouseMove["_left"]    := IniRead(config, "MouseMove", "left", "Left")
GroupMouseMove["_right"]   := IniRead(config, "MouseMove", "right", "Right")

; ALT MOUSE MOVE
GroupMouseMove2["_up"]    := IniRead(config, "MouseMove2", "up", "i")
GroupMouseMove2["_down"]  := IniRead(config, "MouseMove2", "down", "k")
GroupMouseMove2["_left"]  := IniRead(config, "MouseMove2", "left", "j")
GroupMouseMove2["_right"] := IniRead(config, "MouseMove2", "right", "l")

; ALT MOUSE CLICK
GroupMouseClick["_lclick"] := IniRead(config, "MouseClick", "lclick", "c")
GroupMouseClick["_mclick"] := IniRead(config, "MouseClick", "mclick", "x")
GroupMouseClick["_rclick"] := IniRead(config, "MouseClick", "rclick", "z")

; ALT MOUSE MULTIPLIER
GroupMouseMultiplier["_multiplier1"] := IniRead(config, "MouseMultiplier", "multiplier1", "a")
GroupMouseMultiplier["_multiplier2"] := IniRead(config, "MouseMultiplier", "multiplier2", "s")
GroupMouseMultiplier["_multiplier3"] := IniRead(config, "MouseMultiplier", "multiplier3", "d")


; ALT MOUSE SCROLL
GroupMouseScroll["_reverseVScroll"] := IniRead(config, "MouseScroll", "reverseVScroll", "false")
GroupMouseScroll["_reverseHScroll"] := IniRead(config, "MouseScroll", "reverseHScroll", "false")
GroupMouseScroll["_activeScroll"]   := IniRead(config, "MouseScroll", "activeScroll", "Space")

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

; SetHomeRowHotKeys()

; ******************************************************************************
; CAPSLOCK
; ******************************************************************************

$CapsLock:: {
    if (A_PriorHotkey = "$CapsLock" and A_TimeSincePriorHotkey < 300 and A_TimeSincePriorHotkey > 100) {
        if capsLockHeld {
            SendEscape()
        } else {
            SetCapsLockState(false)

            firstArrowPressTime := 0

            global capsLockTimer := A_TickCount
            global capsLockHeld := true
            global mouseMoltiplier := 1

            SetHotKeys()

            ShowLayer()

            if (GroupHomeRow["_sountFeedback"]) {
                SoundBeep(200, 100)
                SoundBeep(300, 100)
            }

        }
    } else {
        SetCapsLockState(!GetKeyState("CapsLock", "T"))
    }
}

$Esc:: {
    if (capsLockHeld and A_PriorHotkey = "$Esc" and A_TimeSincePriorHotkey < 300 and A_TimeSincePriorHotkey > 100) {
        SendEscape()
    } else {
        Send("{Esc}")
    }
}

SendEscape() {

    if (GroupHomeRow["_sountFeedback"]) {
        SoundBeep(300, 100)
        SoundBeep(200, 100)
    }

    for key in arrowStates {
        arrowStates[key] := false
    }

    firstArrowPressTime := 0
    global capsLockHeld := false

    UnsetHotKeys()
    SetCapsLockState(false)

    HideText()
}


; INIBITE KEY TO DO OTHER
#HotIf capsLockHeld && A_TickCount - capsLockTimer >= longPressThreshold
    ;
#HotIf

#HotIf !capsLockHeld
    ;
#HotIf


; ******************************************************************************
; * HOME ROW
; ******************************************************************************

SetHomeRowHotKeys() {

;    Hotkey(GroupHomeRow["_lwin"],            (*) => StartHomeRow(GroupHomeRow["_lwin"], "LWin"))
;    Hotkey(GroupHomeRow["_lwin"] " UP",      (*) => StopHomeRow(GroupHomeRow["_lwin"], "LWin"))
;    Hotkey(GroupHomeRow["_lalt"],            (*) => StartHomeRow(GroupHomeRow["_lalt"], "Alt"))
;    Hotkey(GroupHomeRow["_lalt"] " UP",      (*) => StopHomeRow(GroupHomeRow["_lalt"], "Alt"))
;    Hotkey(GroupHomeRow["_lctrl"],           (*) => StartHomeRow(GroupHomeRow["_lctrl"], "Ctrl"))
;    Hotkey(GroupHomeRow["_lctrl"] " UP",     (*) => StopHomeRow(GroupHomeRow["_lctrl"], "Ctrl"))
;    Hotkey(GroupHomeRow["_lshift"],          (*) => StartHomeRow(GroupHomeRow["_lshift"], "Shift"))
;    Hotkey(GroupHomeRow["_lshift"] " UP",    (*) => StopHomeRow(GroupHomeRow["_lshift"], "Shift"))
;    Hotkey(GroupHomeRow["_rwin"],            (*) => StartHomeRow(GroupHomeRow["_rwin"], "RWin"))
;    Hotkey(GroupHomeRow["_rwin"] " UP",      (*) => StopHomeRow(GroupHomeRow["_rwin"], "RWin"))
;    Hotkey(GroupHomeRow["_ralt"],            (*) => StartHomeRow(GroupHomeRow["_ralt"], "Alt"))
;    Hotkey(GroupHomeRow["_ralt"] " UP",      (*) => StopHomeRow(GroupHomeRow["_ralt"], "Alt"))
;    Hotkey(GroupHomeRow["_rctrl"],           (*) => StartHomeRow(GroupHomeRow["_rctrl"], "Ctrl"))
;    Hotkey(GroupHomeRow["_rctrl"] " UP",     (*) => StopHomeRow(GroupHomeRow["_rctrl"], "Ctrl"))
;    Hotkey(GroupHomeRow["_rshift"],          (*) => StartHomeRow(GroupHomeRow["_rshift"], "Shift"))
;    Hotkey(GroupHomeRow["_rshift"] " UP",    (*) => StopHomeRow(GroupHomeRow["_rshift"], "Shift"))
;
;    for k, v in GroupHomeRow {
;        Hotkey(v,       "On")
;        Hotkey(v " UP", "On")
;    }

}


; ******************************************************************************
; * SET HOT KEYS
; ******************************************************************************

SetHotKeys() {

    Hotkey(GroupMouseMove["_up"],            (*) => StartArrow("Up"))
    Hotkey(GroupMouseMove["_up"] " UP",      (*) => StopArrow("Up"))
    Hotkey(GroupMouseMove["_left"],          (*) => StartArrow("Left"))
    Hotkey(GroupMouseMove["_left"] " UP",    (*) => StopArrow("Left"))
    Hotkey(GroupMouseMove["_down"],          (*) => StartArrow("Down"))
    Hotkey(GroupMouseMove["_down"] " UP",    (*) => StopArrow("Down"))
    Hotkey(GroupMouseMove["_right"],         (*) => StartArrow("Right"))
    Hotkey(GroupMouseMove["_right"] " UP",   (*) => StopArrow("Right"))

    Hotkey(GroupMouseMove2["_up"],           (*) => StartArrow("Up"))
    Hotkey(GroupMouseMove2["_up"] " UP",     (*) => StopArrow("Up"))
    Hotkey(GroupMouseMove2["_left"],         (*) => StartArrow("Left"))
    Hotkey(GroupMouseMove2["_left"] " UP",   (*) => StopArrow("Left"))
    Hotkey(GroupMouseMove2["_down"],         (*) => StartArrow("Down"))
    Hotkey(GroupMouseMove2["_down"] " UP",   (*) => StopArrow("Down"))
    Hotkey(GroupMouseMove2["_right"],        (*) => StartArrow("Right"))
    Hotkey(GroupMouseMove2["_right"] " UP",  (*) => StopArrow("Right"))

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
    for k, v in GroupMouseMultiplier {
        Hotkey(v,       (*) => )
    }

    Hotkey(GroupMouseScroll["_activeScroll"], (*) =>)

}
    

; ******************************************************************************
; * UNSET HOT KEYS
; ******************************************************************************

UnsetHotKeys() {
    reload()
}


; ******************************************************************************
; * ARROWS
; ******************************************************************************

StartArrow(key) {
    global firstArrowPressTime
    arrowStates[key] := true

    if (firstArrowPressTime = 0) {
        firstArrowPressTime := A_TickCount
    }
}

StopArrow(key) {
    global firstArrowPressTime

    arrowStates[key] := false

    if(!arrowStates["Left"] and !arrowStates["Right"] and !arrowStates["Up"] and !arrowStates["Down"]) {
        firstArrowPressTime := 0
    }
}


; ******************************************************************************
; * HOME ROW
; ******************************************************************************

StartHomeRow(key, value) {
    global HomeRowTimer
    if (HomeRowTimer = 0) {
        HomeRowTimer := A_TickCount
    }

    if (A_PriorHotkey = key and A_TimeSincePriorHotkey > (longPressThreshold * 2)) {
        Send "{" value " Down}"
    }

}

StopHomeRow(key, value) {
    global HomeRowTimer
    Send "{" value " Up}"

    if A_TickCount - HomeRowTimer < (longPressThreshold * 2) {
        Send key
    }
    HomeRowTimer := 0
}
    

; ******************************************************************************
; PRIMARY TIMER
; ******************************************************************************

SetTimer(MoveMouseContinuously, 10)


; ******************************************************************************
; * MOUSE MOVER
; ******************************************************************************

MoveMouseContinuously(*) {
    if !capsLockHeld
        return

    dx := 0
    dy := 0

    elapsedMove := A_TickCount - firstArrowPressTime
    if arrowStates["Left"]
        if(GetKeyState(GroupMouseScroll["_activeScroll"], "P")) {
            direction := GroupMouseScroll["_reverseVScroll"] ? "{WheelLeft}" : "{WheelRight}"
            SendEvent(direction)
        } else
            dx -= GetSpeed(elapsedMove)
    if arrowStates["Right"]
        if(GetKeyState(GroupMouseScroll["_activeScroll"], "P")) {
            direction := GroupMouseScroll["_reverseVScroll"] ? "{WheelRight}" : "{WheelLeft}"
            SendEvent(direction)
        } else
            dx += GetSpeed(elapsedMove)
    if arrowStates["Up"]
        if(GetKeyState(GroupMouseScroll["_activeScroll"], "P")) {
            direction := GroupMouseScroll["_reverseVScroll"] ? "{WheelUp}" : "{WheelDown}"
            SendEvent(direction)
        } else
            dy -= GetSpeed(elapsedMove)
    if arrowStates["Down"]
        if(GetKeyState(GroupMouseScroll["_activeScroll"], "P")) {
            direction := GroupMouseScroll["_reverseVScroll"] ? "{WheelDown}" : "{WheelUp}"
            SendEvent(direction)
        } else
            dy += GetSpeed(elapsedMove)
    if (dx != 0 or dy != 0)
        MouseMove(dx, dy, 0, "R")
}


; ******************************************************************************
; MOUSE SPEED
; ******************************************************************************

GetSpeed(elapsedMove, panning := false) {
    global mouseMoltiplier

    mouseMoltiplier := 1
    if(GetKeyState(GroupMouseMultiplier["_multiplier1"], "P"))
        DoubleMouseMultiplier()
    if(GetKeyState(GroupMouseMultiplier["_multiplier2"], "P"))
        DoubleMouseMultiplier()
    if(GetKeyState(GroupMouseMultiplier["_multiplier3"], "P"))
        DoubleMouseMultiplier()

    timeMoltiplier := min(elapsedMove/100, 12)

    if panning
        ret := Min(4 * (timeMoltiplier * mouseMoltiplier), 8)
    else
        ret:= 2 * (timeMoltiplier * mouseMoltiplier)

    return ret
}


; ******************************************************************************
; MOUSE SPEED MOLTIPLIER
; ******************************************************************************

DoubleMouseMultiplier() {
    global mouseMoltiplier
    mouseMoltiplier := mouseMoltiplier * 1.6
    if mouseMoltiplier > 12
        mouseMoltiplier := 12
}


; ******************************************************************************
; SHOW TEXT
; ******************************************************************************

ShowLayer() {
    ; SCREEN SIZE
    screenWidth := A_ScreenWidth
    screenHeight := A_ScreenHeight

    ; LAST WINDOW FOCUS
    prevWin := WinExist("A")

    ; TEXT OFFSET
    offset   := 0
    fontSize := 12
    fontSpace := fontSize / 125 * A_ScreenDPI
    icoWidth := 40
    textSpace := 50

    MyGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "NoFocus GUI NoActivate")

    ; GUI SPECS
    MyGui.BackColor := "Green"
    WinSetTransparent(140, myGui.Hwnd)

    ; FONT SIZE
    MyGui.SetFont("s" fontSize " cBlack", "Cascadia Mono")

    txt1 := "UP: " GroupMouseMove["_up"] "/" GroupMouseMove2["_up"] " - DOWN: " GroupMouseMove["_down"] "/" GroupMouseMove2["_down"] " - LEFT: " GroupMouseMove["_left"] "/" GroupMouseMove2["_left"] " - RIGHT: " GroupMouseMove["_right"] "/" GroupMouseMove2["_right"]
    txt2 := "Left: " GroupMouseClick["_lclick"] " - Center: " GroupMouseClick["_mclick"] " - Right: " GroupMouseClick["_rclick"]
    txt3 := "Scroll: " GroupMouseScroll["_activeScroll"]
    txt4 := "Multiplier: " GroupMouseMultiplier["_multiplier1"] "/" GroupMouseMultiplier["_multiplier2"] "/" GroupMouseMultiplier["_multiplier3"]

    offset1 := 0
    offset2 := textSpace + offset1 + icoWidth + (fontSpace * StrLen(txt1))
    offset3 := textSpace + offset2 + icoWidth + (fontSpace * StrLen(txt2))
    offset4 := textSpace + offset3 + icoWidth + (fontSpace * StrLen(txt3))
    offset5 := textSpace + offset4 + icoWidth + (fontSpace * StrLen(txt4))

    offset := (screenWidth - offset5 ) / 2

    MyGui.AddPicture( "x" offset + offset1 - icoWidth " y10 w24 h24", "icons/mouse.ico" )
    MyGui.AddText( "x" offset + offset1 " yp", txt1 )

    MyGui.AddPicture( "x" offset + offset2 - icoWidth " y10 w24 h24", "icons/click.ico" )
    MyGui.AddText( "x" offset + offset2 " yp", txt2 )

    MyGui.AddPicture( "x" offset + offset3 - icoWidth " y10 w24 h24", "icons/scroll.ico" )
    MyGui.AddText( "x" offset + offset3 " yp", txt3 )

    MyGui.AddPicture( "x" offset + offset4 - icoWidth " y10 w24 h24", "icons/speed.ico" )
    MyGui.AddText( "x" offset + offset4 " yp", txt4 )

    ; GUI SIZE
    WinGetPos(&xGui, &yGui, &wGui, &hGui, myGui.Hwnd)
    WinSetExStyle("+0x80020", MyGui.Hwnd) ; WS_EX_LAYERED (0x80000) | WS_EX_TRANSPARENT (0x20)

    ; CENTER BOTTOM POSITION
    x := (screenWidth - wGui) // 2
    y := 0 ; screenHeight - hGui - 100

    myGui.Show("Center y" y " w" screenWidth)

    if WinExist("ahk_id " prevWin)
        WinActivate("ahk_id " prevWin)
}

HideText() {
    global MyGui
    MyGui.Destroy()
}
