; script requires Spencer Macro Utilities! (set keybind for freeze to Middle Mouse Button)

; To use walk against a wall and press the keybind to glitch

#SingleInstance Force
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
SetBatchLines, -1
Process Priority,, High

DllCall("Winmm\timeBeginPeriod", "UInt", 1)

; keybind for glitch (default is F1)
F1::
    SendInput, {Blind}c

    DllCall("Sleep", "UInt", 6)

    SendInput, {Blind}{MButton down}

    Sleep, 750

    SendInput, {Blind}{MButton up}
return

; exit keybind (default is F4)
F4::
    DllCall("Winmm\timeEndPeriod", "UInt", 1)
    ExitApp
