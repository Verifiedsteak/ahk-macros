#SingleInstance Force
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
SetBatchLines, -1

DPI := 800
CS := 0.36
N := 4000 * (288 / (DPI * CS))

Q::
SendInput, c

sleep, 7

SendInput, {Space down}
Sleep, 45
SendInput, {Space up}

Sleep, 7

start := A_TickCount

Loop
{
    if (A_TickCount - start > 250)
        break

    DllCall("mouse_event", "UInt", 0x01, "Int", N, "Int", 0)
    Sleep, 3
}
return

F3::ExitApp
