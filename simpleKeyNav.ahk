#Requires AutoHotkey v2.0
; #MaxHotkeysPerInterval 1000

global capsLockHeld := false
global capsLockTimer := 0
global longPressThreshold := 100
global mouseMoltiplier := 1

global arrowStates := Map("Up", false, "Down", false, "Left", false, "Right", false)
global firstArrowPressTime := 0

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

    ; Tastierino numerico simulato
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

    ; Click mouse
    Space:: LButton
    RCtrl:: RButton
    AppsKey::MButton

    ; Frecce con accelerazione
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

    ; Inibitore dei tasti per il moltiplicatore del movimento del mouse
    a::
    s::
    d::
    f:: return

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

; Timer centrale
SetTimer(MoveMouseContinuously, 10)

MoveMouseContinuously(*) {
    if !capsLockHeld
        return

    dx := 0
    dy := 0

    elapsedMove := A_TickCount - firstArrowPressTime
    if arrowStates["Left"]
        dx -= GetSpeed(elapsedMove)
    if arrowStates["Right"]
        dx += GetSpeed(elapsedMove)
    if arrowStates["Up"]
        dy -= GetSpeed(elapsedMove)
    if arrowStates["Down"]
        dy += GetSpeed(elapsedMove)

    if (dx != 0 or dy != 0)
        MouseMove(dx, dy, 0, "R")
}

GetSpeed(elapsedMove) {
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

    ; ShowText(timeMoltiplier . " " . mouseMoltiplier . " " . (timeMoltiplier * mouseMoltiplier))

    return 2 * (timeMoltiplier * mouseMoltiplier)
}

DoubleMouseMultiplier() {
    global mouseMoltiplier
    mouseMoltiplier := mouseMoltiplier * 2
    if mouseMoltiplier > 12
        mouseMoltiplier := 12
}

HalveMouseMultiplier() {
    global mouseMoltiplier
    mouseMoltiplier := mouseMoltiplier / 2
    if mouseMoltiplier < 1
        mouseMoltiplier := 1
}

ShowText(txt, duration := 500) {
    MyGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000")  ; senza bordi né barra e WS_EX_NOACTICE

    MyGui.BackColor := "Black"
    MyGui.SetFont("s10 cWhite", "Segoe UI")
    MyGui.Add("Text", "Center w200", txt)

    ; Ottieni dimensioni schermo
    screenWidth := A_ScreenWidth
    screenHeight := A_ScreenHeight

    ; Ottieni dimensioni GUI
    WinGetPos(&xGui, &yGui, &wGui, &hGui, myGui.Hwnd)

    ; Calcola posizione: centrata in basso
    x := (screenWidth - wGui) // 2
    y := screenHeight - hGui - 100

    myGui.Show("AutoSize Center y" y)

    ; Aspetta e chiude
    SetTimer(() => MyGui.Destroy(), -duration)
}
