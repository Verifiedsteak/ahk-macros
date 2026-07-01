; PLEASE fix this future me

#Requires AutoHotkey v2.0
#SingleInstance Force
SetWorkingDir(A_ScriptDir)
SendMode("Input")
SetKeyDelay(-1, -1)
SetMouseDelay(-1)
DllCall("Winmm\timeBeginPeriod", "UInt", 1)
ProcessSetPriority("High")

; Admin
if (!A_IsAdmin) {
    try {
        if (A_IsCompiled) {
            Run '*RunAs "' A_ScriptFullPath '" /restart'
        } else {
            Run '*RunAs "' A_AhkPath '" /restart "' A_ScriptFullPath '"'
        }

        ExitApp()
    }
}

class ScriptInstance {
    ; Skidded from Spencer Macro Utilities (Ty)
    static frozenPids := []

    static SetFreeze(enabled) {
        if (enabled) {
            if (this.frozenPids.Length == 0) {
                this.frozenPids := this.CurrentTargetPids()
            }

            for pid in this.frozenPids {
                this.ToggleProcessState(pid, true)
            }
        } else {
            for pid in this.frozenPids {
                this.ToggleProcessState(pid, false)
            }

            this.frozenPids := []
        }
    }

    static ToggleProcessState(pid, suspend) {
        hProcess := DllCall("OpenProcess", "UInt", 0x1F0FFF, "Int", 0, "UInt", pid, "Ptr")

        if (!hProcess) {
            return
        }

        if (suspend) {
            DllCall("ntdll.dll\ZwSuspendProcess", "Ptr", hProcess)
        } else {
            DllCall("ntdll.dll\ZwResumeProcess", "Ptr", hProcess)
        }

        DllCall("CloseHandle", "Ptr", hProcess)
    }

    static CurrentTargetPids() {
        try {
            activePid := WinGetPID("A")
            return [activePid]
        } catch {
            return []
        }
    }
}

; Camera Sensitivity
CS := 0.36

; Keybind
global KEYBIND := "Q"

; Experimental
DOFREEZE := false

SPINS := 20
SPIN := Round(180 * 2.5 / CS)

; Timings
SPACEDELAY := 10
HELDSPACE := DOFREEZE ? 20 : 40
FREEZEDURATION := 100
CRAWLSPIN := 4
SPINDELAY := 4
SPININTERVAL := 8

; Mouse
MOUSEEVENT_MOVE := 0x0001

; Gui
Window := Gui("+Resize -DPIScale", "Macro by klosai :)")

Window.BackColor := "0x121212"
DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", Window.Hwnd, "UInt", 20, "Ptr*", 1, "UInt", 4)

Window.SetFont("s25 cffffff", "Segoe UI Semibold")
Window.AddText("w500", "Pressure Jump")

Window.SetFont("s16 cffffff", "Segoe UI")
Window.AddText("w500", "240 FPS for best experience")
Window.AddText("w500", "Freeze : " (DOFREEZE ? "true" : "false"))
Window.AddText("w500", "Keybind : " KEYBIND)
Window.AddText("w500", "Camera Sensitivity : " Round(CS, 2))

Window.OnEvent("Close", WindowC)
Window.Show("w1000 h500")

Hotkey(KEYBIND, RunMacro)

Running := false

RunMacro(HotKeyName) {
    global Running

    if (Running == true) {
        return
    }

    Running := true
    try {
        global SPIN, SPINS, DOFREEZE
        global SPACEDELAY, HELDSPACE, FREEZEDURATION
        global CRAWLSPIN, SPINDELAY, SPININTERVAL, MOUSEEVENT_MOVE

        SendInput("{Space down}")
        SendInput("{C down}")
        SendInput("{C up}")

        DllCall("Sleep", "UInt", SPACEDELAY)
        DllCall("Sleep", "UInt", HELDSPACE)

        SendInput("{Space up}")

        DllCall("Sleep", "UInt", CRAWLSPIN)

        if (DOFREEZE) {
            Freeze(FREEZEDURATION)
        }

        DllCall("Sleep", "UInt", SPINDELAY)

        i := 0

        while (++i <= SPINS) {
            ToolTip(i)
            DllCall("mouse_event",
                "UInt", MOUSEEVENT_MOVE,
                "Int", SPIN,
                "Int", 0,
                "UInt", 0,
                "UPtr", 0
            )

            MSleep(SPININTERVAL)
        }
        ToolTip()
        DllCall("Sleep", "UInt", SPINDELAY)
    } finally {
        Running := false
    }
}

Freeze(Duration) {
    ScriptInstance.SetFreeze(true)
    DllCall("Sleep", "UInt", Duration)
    ScriptInstance.SetFreeze(false)
}

MSleep(ms) {
    DllCall("Sleep", "UInt", ms)
}

; Exit
WindowC(Window) {
    SendInput("{Space up}")
    SendInput("{C up}")

    DllCall("Winmm\timeEndPeriod", "UInt", 1)
    ExitApp()
}