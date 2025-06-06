#Requires AutoHotkey v2.0
; #MaxHotkeysPerInterval 1000

global capsLockHeld := false
global capsLockTimer := 0
global longPressThreshold := 100
global mouseMoltiplier := 1

global arrowStates := Map("Up", false, "Down", false, "Left", false, "Right", false)
global firstArrowPressTime := 0

global reverseScroll := true

CapsLock:: {
    if(!capsLockHeld)
        global capsLockTimer := A_TickCount

;    if (A_TickCount - capsLockTimer >= longPressThreshold) {
;        ShowText("_layer_", 500)
;    }

    firstArrowPressTime := 0

    global capsLockHeld := true
    global mouseMoltiplier := 1

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
}

#HotIf capsLockHeld && A_TickCount - capsLockTimer >= longPressThreshold

    ; KEYPAD
    PrintScreen:: Send("7")
    ScrollLock:: Send("8")
    Pause:: Send("9")
    Insert:: Send("4")
    Home:: Send("5")
    PgUp:: Send("6")
    Delete:: Send("1")
    End:: Send("2")
    PgDn:: Send("3")
    \:: Send("0")

    ; MOUSE CLICK
    Space:: LButton
    RCtrl:: RButton
    AppsKey::MButton

    ; ARROWS
    Up::
     k::StartArrow("Up")
    Up Up::
     k Up:: StopArrow("Up")
    Down::
       j:: StartArrow("Down")
    Down Up::
       j Up:: StopArrow("Down")
    Left::
       h:: StartArrow("Left")
    Left Up::
       h Up:: StopArrow("Left")
    Right::
        l:: StartArrow("Right")
    Right Up::
        l Up:: StopArrow("Right")

    ; BLOCK DEFAULT ACTION FOR KEYS
    a::
    s::
    d::
    f:: return

    ; BLOCK DEFAULT ACTION FOR LALT, USER FOR SCROLLING
    LAlt:: return

#HotIf

StartArrow(key) {
    global firstArrowPressTime
    arrowStates[key] := true

    if (firstArrowPressTime = 0) {
        firstArrowPressTime := A_TickCount
    }
    ; ShowText(arrowStates["Left"] . " " . arrowStates["Right"] . " " . arrowStates["Up"] . " " . arrowStates["Down"])
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
    if !capsLockHeld
        return

    dx := 0
    dy := 0
    global reverseScroll

    elapsedMove := A_TickCount - firstArrowPressTime
    if arrowStates["Left"]
        if(GetKeyState("LAlt", "P"))
            SendEvent("{WheelLeft " GetSpeed(elapsedMove, true) "}")
        else
            dx -= GetSpeed(elapsedMove)
    if arrowStates["Right"]
        if(GetKeyState("LAlt", "P"))
            SendEvent("{WheelRight " GetSpeed(elapsedMove, true) "}")
        else
            dx += GetSpeed(elapsedMove)
    if arrowStates["Up"]
        if(GetKeyState("LAlt", "P")) {
            direction := reverseScroll ? "{WheelDown}" : "{WheelUp}"
            ShowText(direction)
            SendEvent(direction)
        }
        else
            dy -= GetSpeed(elapsedMove)
    if arrowStates["Down"]
        if(GetKeyState("LAlt", "P")) {
            direction := reverseScroll ? "{WheelUp}" : "{WheelDown}"
            ShowText(direction)
            SendEvent(direction)
        }
        else
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
    if(GetKeyState("f", "P"))
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
