#Requires AutoHotkey v2.0

#Include <github>
#Include <GuiCtrlTips>
#Include <FindText>

CoordMode "Pixel", "Client"
CoordMode "Mouse", "Client"
try TraySetIcon "andersson.ico"
currentVersion := "v0.1"
repo := "JustaNikkeBot"
usr := "JUSTadICE-CHaN"

global g_settings := Map(
    "ShopsAutomation", 1,
        "NormalShop", 1,
            "NormalCoreDust", 1,
            "NormalProfile", 1,
            "NormalPackage", 1,
            "BodyGoldGem", 1,
        "Cash Shop", 1, 
            "Daily", 1,
            "Weekly", 1,
            "Monthly", 1,
        "Arena Shop", 1,
            "ArenaFire", 1,
            "ArenaWater", 1,
            "ArenaWind", 1,
            "ArenaElec", 1,
            "ArenaIron", 1,
            "ArenaBox", 1, 
            "ArenaFurnace", 1,
            "ArenaPackage", 1,
    "SimulationAutomation", 1, 
        "SimulationOverclock", 1,
    "ArenaAutomation", 1, ; yeah im not even trying lmao
    "InterceptionAutomation", 1, 
        "BeginnerInterception", 1,
        "AdvancedInterception", 1,
    "OutpostAutomation", 1, 
    "AdviceAutomation", 1,
    "FriendshipAutomation", 1,
    "MailAutomation", 1,
    "MissionAutomation", 1,
    "CoopAutomation", 1,
    "SoloRaidAutomation", 1, 
    "PassAutomation", 1, 
    "SelfClosing", 0,
    "OpenBlablalink", 1,
)

global g_numeric_settings := Map(
    "SleepTime", 1000,
    "InterceptionBoss", 1,
    "Tolerance", 1,
    "MirrorCDK", "",
    "Version", currentVersion,
    "Username", "JUSTadICE"
)

JAGui := Gui("+Resize", "JustaNikkeBot - " currentVersion)
JAGui.Tips := GuiCtrlTips(JAGui) 
JAGui.Tips.SetBkColor(0xFFFFFF)
JAGui.Tips.SetTxColor(0x000000)
JAGui.Tips.SetMargins(3, 3, 3, 3)
JAGui.MarginY := Round(JAGui.MarginY * 0.9)

JAGui.SetFont("Bold")
TextKeyInfo := JAGui.Add("Text", "R1 +0x0100", "Close: Ctrl+1 Pause: Ctrl+2")
JAGui.Tips.SetTip(TextKeyInfo, "JustaNikkeBot Shortcuts: `r`nCtrl+1: Close Program NOW `r`nCtrl+2: Pause Current Program Task")
LinkProject := JAGui.Add("Link", "R1 xs", '<a href="https://github.com/JUSTadICE-CHaN/JustaNikkeBot">GitHub</a>')
JAGui.Tips.SetTip(LinkProject, "Click to visit Github page for latest version, reporting issues, etc")

JAGui.SetFont()

BtnHelp := JAGui.Add("Button", "R1 x+8", "HELP")
JAGui.Tips.SetTip(BtnHelp, "Click to see important information for setup of the bot")
BtnHelp.OnEvent("Click", ClickOnHelp)

BtnClear := JAGui.Add("Button", "R1 x+8", "Clear Log")
JAGui.Tips.SetTip(BtnClear, "This should clear all of the logs... maybe...")
BtnClear.OnEvent("Click", (*) => LogBox.Value := "")

Tab := JAGui.Add("Tab3", "xm")
Tab.Add(["Settings", "Missions", "Shops", "Battle", "Rewards", "Log"])
Tab.UseTab("Settings")

cbOpenBlablaLink := AddCheckBoxSetting(JAGui, "OpenBlablalink", "Automatically open BlablaLink after completing tasks ", "R1.2 " )
JAGui.Tips.SetTip(cbOpenBlablalink, "When checked after completing all tasks, open blablalink")

cbSelfClosing := AddCheckBoxSetting(JAGui, "SelfClosing", "Automatically closes the program once all tasks are complete ", "R1.2 ")
JAGui.Tips.SetTip(cbSelfClosing, "When checked just makes sure to close the application after all tasks are complete")

TextToleranceLabel := JAGui.Add("Text", "Section +0x0100", "Image Tolerance")
JAGui.Tips.SetTip(TextToleranceLabel, "Adjust the similarity threshold for image recognition. `r`nThe higher the value, the looser the match, and the easier to identify the target, but it may also cause misjudgement. `r`nThe lower the value, the higher the accuracy, but it may miss some slightly different targets. `r`nPlease adjust appropriately according to your game resolution and zoom")

SliderTolerance := JAGui.Add("Slider", "w200 Range100-200 TickInterval1 ToolTip vToleranceSlider", g_numeric_settings["Tolerance"] * 100)
JAGui.Tips.SetTip(SliderTolerance, "Drag the slider to adjust the tolerance of the image recognition. The range is from 1.00 (strictest) to 2.00 (loosest). The specific value will be displayed in the text box on the right.")
SliderTolerance.OnEvent("Change", (CtrlObj, Info) => ChangeSlider("Tolerance", CtrlObj))
toleranceDisplayEditControl := JAGui.Add("Edit", "x+10 yp w50 ReadOnly h20 vToleranceDisplay", Format("{:.1f}", g_numeric_settings["Tolerance"]))

BtnSaveSettings := JAGui.Add("Button", "xs R1 +0x4000", "Save current settings")
JAGui.Tips.SetTip(BtnSaveSettings, "Click this button to save the settings of all current tabs to the config file (settings.ini) for auto loading configs on next-launch")
BtnSaveSettings.OnEvent("Click", SaveSettings)

Tab.UseTab("Log")
LogBox := JAGui.Add("Edit", "r20 w270 ReadOnly")
LogBox.Value := "Starting Log...`r`n"

JAGui.Show

Initialization() {
    ; if !A_IsAdmin {
    ;     MsgBox "pls start as admin ty"
    ;     ExitApp
    ; }
    global BattleActive := 1
    global nikkeID := ""
    global NikkeX := 0
    global NikkeY := 0
    global NikkeW := 0
    global NikkeH := 0
    global NikkeXP := 0
    global NikkeYP := 0
    global scrRatio := 1
    global WinRatio := 1

    targetExe := "nikke.exe"
    if WinExist("ahk_exe " targetExe) {
        winID := WinExist("ahk_exe " targetExe)
        actualWinTitle := WinGetTitle(winID)
        WinActivate(winID)
    }
    else {
        MsgBox("The program " targetExe " was not found, please launch")
        Pause
    }
    nikkeID := winID
    WinGetClientPos &NikkeX, &NikkeY, &NikkeW, &NikkeH, nikkeID 
    WinGetPos &NikkeXP, &NikkeYP, &NikkeWP, &NikkeHP, nikkeID 
    GameRatio := Round(NikkeW / NikkeH, 3)
    if NikkeW != 1920 || NikkeH != 1080 {
        MsgBox "Please change game to 16:9 ratio, 1920x1080"
        ExitApp
    }
}

WriteSettings(*) {
    global g_settings, g_numeric_settings
    for key, value in g_settings {
        IniWrite(value, "settings.ini", "Toggles", key)
    }
    for key, value in g_numeric_settings {
        IniWrite(value, "settings.ini", "NumericSettings", key)
    }
}

LoadSettings() {
    global g_settings, g_numeric_settings
    default_settings := g_settings.Clone()
    for key, defaultValue in default_settings {
        readValue := IniRead("settings.ini", "Toggles", key, defaultValue)
        g_settings[key] := readValue
    }
    default_numeric_settings := g_numeric_settings.Clone() 
    for key, defaultValue in default_numeric_settings {
        readValue := IniRead("settings.ini", "NumericSettings", key, defaultValue)
        g_numeric_settings[key] := readValue
    }
}

ChangeSlider(settingName, CtrlObj) {
    global g_numeric_settings, toleranceDisplayEditControl
    local actualValue := CtrlObj.Value / 100.0
    g_numeric_settings[settingName] := actualValue
    local formattedValue := Format("{:.2f}", actualValue)
    toleranceDisplayEditControl.Value := formattedValue
}

ToggleSetting(settingKey, guiCtrl, *) {
    global g_settings
    g_settings[settingKey] := 1 - g_settings[settingKey]
}

SaveSettings(*) {
    WriteSettings()
    MsgBox "Settings Saved!"
    AddLog("Settings Saved!", true)
}

IsCheckedToString(foo) {
    if foo
        return "Checked"
    else
        return ""
}

AddCheckBoxSetting(guiObj, settingKey, displayText, options := "") {
    global g_settings

    if !g_settings.Has(settingKey) {
        MsgBox("Error: Setting Key '" settingKey "' is not defined in settings" , "Error adding control" , "IconX")
        return
    }
    initialState := IsCheckedToString(g_settings[settingKey])
    fullOptions := options (options ? " " : "") initialState
    cbCtrl := guiObj.Add("Checkbox", fullOptions, displayText)
    cbCtrl.OnEvent("Click", (guiCtrl, eventInfo) => ToggleSetting(settingKey, guiCtrl, eventInfo))
    return cbCtrl 
}

ClickOnHelp(*) {
    MsgBox "JJO"
}

AddLog(text, forceOutput := false) { 
    if (!IsObject(LogBox) || !LogBox.Hwnd) {
        return
    }
    static lastText := ""  
    global LogBox
    if (text = lastText && !forceOutput)
        return
    lastText := text  
    timestamp := FormatTime(, "HH:mm:ss")
    LogBox.Value .= timestamp " - " text "`r`n"
    SendMessage(0x0115, 7, 0, LogBox) 
}

; Text:="|<IntroScreen>*101$48.zzzzzzzzzs7zzzzzzU1zzzzzy00zzzzzw00Tzzzzk00Tzzzzk00DzzzzU800D801U800D841b9wQ69wtU84M6NwtUM40YM41k841UMA1a8wFUtw3b9wFktwlU80Mks0lU80Mls0tzzzzzzzzU"

; if (ok:=FindText(&X, &Y, 1063-150000, 636-150000, 1063+150000, 636+150000, 0, 0, Text))
; {
;   FindText().Click(X+27, Y+186, "L")
; }

Initialization()
