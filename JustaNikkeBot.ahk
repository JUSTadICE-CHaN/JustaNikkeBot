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
            "NormalPackage", 1,
            "BodyGoldGem", 1,
        "CashShop", 1, 
            "Daily", 1,
            "Weekly", 1,
            "Monthly", 1,
        "ArenaShop", 1,
            "ArenaFire", 1,
            "ArenaWater", 1,
            "ArenaWind", 1,
            "ArenaElec", 1,
            "ArenaIron", 1,
            "ArenaBox", 1, 
            "ArenaFurnace", 1,
            "ArenaPackage", 1,
        ; "ScrapShop", 1,
            "ScrapShopGem", 1,
            "ScrapShopVoucher", 0,
            "ScrapShopResources", 1,
    "SimulationAutomation", 1, 
        "SimulationOverClock", 1,
    "TribeTowerAutomation", 1,
        "CompanyTower", 1,
        "MainTower", 1,
    "ArenaAutomation", 1, ; yeah im not even trying lmao
        "RookieArena", 1,
        "SpecialArena", 1,
        "ChampionArenaBet", 1,
    "InterceptionAutomation", 1, 
        "BeginnerInterception", 1,
        "AdvancedInterception", 1,
        "InterceptionSC", 1,
    "CollectionAutomation", 1,
        "OutpostAutomation", 1,
        "OutpostBoardAutomation", 1, 
        "AdviceAutomation", 1,
        "FriendshipAutomation", 1,
        "MailAutomation", 1,
        "MissionAutomation", 1,
        "EventStageAutomation", 1,
        "FreeRecruitAutomation", 1,
        "CoopAutomation", 1,
        "SoloRaidAutomation", 1, 
        "PassAutomation", 1, 
    "SelfClosing", 0,
    "OpenBlablalink", 1,
    "AdjustSize", 1,
)

global g_numeric_settings := Map(
    "SleepTime", 1000,
    "InterceptionBoss", 1,
    "Tolerance", 1,
    "Version", currentVersion,
    "Username", "JUSTadICE"
)

Victory := 0
PicTolerance := g_numeric_settings["Tolerance"]
SetWorkingDir A_ScriptDir

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
Tab.Add(["Settings", "Tasks", "Shops", "Battle", "Rewards", "Log"])

; Settings Tab
Tab.UseTab("Settings")

cbAdjustSize := AddCheckboxSetting(JAGui, "AdjustSize", "Enable window adjustment",  "R1.2")
JAGui.Tips.SetTip(cbAdjustSize, "When checked, JustaNikkeBot will try to adjust the window to the appropriate size before running, and restore it after completion")

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

TextTestModeLabel := JAGui.Add("Text", "xs R1.2 Section +0x0100", "Debug Mode")
JAGui.Tips.SetTip(TextTestModeLabel, "Execute the corresponding task directly")
TestModeEditControl := JAGui.Add("Edit", "x+10 yp-5 w145 h20")
JAGui.Tips.SetTip(TestModeEditControl, "Enter the function name of the task to be executed")
BtnTestMode := JAGui.Add("Button", "x+5", "Start").OnEvent("Click", TestMode)

; Tasks Tab
Tab.UseTab("Tasks")

TextTaskInfo := JAGui.Add("Text", "R1.2 +0x0100", "These are master toggle switches for enabling/disabling whole tasks")
cbShop := AddCheckBoxSetting(JAGui, "ShopsAutomation", "Shop Purchases", "R1.2")
JAGui.Tips.SetTip(cbShop, "Master Switch: Controls whether to execute all tasks related to store purchases. `r`nFor specific purchases set them in the 'Shop' Tab")

cbSimulationRoom := AddCheckBoxSetting(JAGui, "SimulationAutomation", "Simulation Room", "R1.2")
JAGui.Tips.SetTip(cbSimulationRoom, "Master Switch: Controls whether to execute all tasks related to the Simulation Room including normal and overclock. `r`nFor specific details refer to 'Battle' Tab")

cbArena := AddCheckBoxSetting(JAGui, "ArenaAutomation", "Arena", "R1.2 Section")
JAGui.Tips.SetTip(cbArena, "Master Switch: Controls whether to execute all tasks related to the arena. `r`nFor specific details refer to 'Battle' Tab")

cbTower := AddCheckBoxSetting(JAGui, "TribeTowerAutomation", "Tribe Tower", "R1.2 xs")
JAGui.Tips.SetTip(cbTower, "Master Switch: Controls whether to execute all tasks related to the Tribe Tower. `r`nFor specific details refer to 'Battle' Tab")

cbInterception := AddCheckBoxSetting(JAGui, "InterceptionAutomation", "Interception", "R1.2 xs")
JAGui.Tips.SetTip(cbInterception, "Master Switch: Controls whether to execute all tasks related to Interception. `r`nFor specific details refer to 'Battle' Tab")

cbAward := AddCheckBoxSetting(JAGui, "CollectionAutomation", "Collect Rewards", "R1.2 xs")
JAGui.Tips.SetTip(cbAward, "Master Switch: Controls whether to execute all auto-collection of various daily rewards. `r`nFor specific details refer to 'Rewards' Tab")

; Shops Tab
Tab.UseTab("Shop")

TextCashShopTitle := JAGui.Add("Text", "R1.2 Section +0x0100", "===Cash Shop===")
JAGui.Tips.SetTip(TextCashShopTitle, "Configure settings related to in-game cash shop purchases")

cbCashShop := AddCheckboxSetting(JAGui, "CashShop", "Collect Free Gems", "R1.2 xs")
JAGui.Tips.SetTip(cbCashShop, "Automatically collect daily, weekly and monthly free gems from the cash shop`r`nImportant: If your game account cannot access the cash shop normally due to network issues, please do not check this option as it may cause the program to hang")

TextNormalShopTitle := JAGui.Add("Text", "R1.2 xs Section +0x0100", "===Normal Shop===") 
JAGui.Tips.SetTip(TextNormalShopTitle, "Configure settings related to in-game normal shop (purchases using credit points)")

cbNormalShop := AddCheckboxSetting(JAGui, "NormalShop", "Daily Free 2 Times", "R1.2 ")
JAGui.Tips.SetTip(cbNormalShop, "Automatically collect daily free items from normal shop, then use free refresh to collect again")

cbNormalShopDust := AddCheckboxSetting(JAGui, "NormalCoreDust", "Buy Core Dust Box with Credits", "R1.2 ")
JAGui.Tips.SetTip(cbNormalShopDust, "When checked, automatically buy Core Dust Box if available for purchase with credit points in normal shop")

cbNormalShopPackage := AddCheckboxSetting(JAGui, "NormalPackage", "Buy Profile Customization Pack", "R1.2 ")
JAGui.Tips.SetTip(cbNormalShopPackage, "When checked, automatically buy Profile Customization Pack if available for purchase with in-game currency in normal shop")

TextArenaShopTitle := JAGui.Add("Text", " R1 xs +0x0100", "===Arena Shop===")
JAGui.Tips.SetTip(TextArenaShopTitle, "Configure settings related to in-game arena shop (purchases using arena tokens)") 

cbBookFire := AddCheckboxSetting(JAGui, "ArenaFire", "Fire", "R1.2")
JAGui.Tips.SetTip(cbBookFire, "Automatically buy all Fire Code Manuals in arena shop")

cbBookWater := AddCheckboxSetting(JAGui, "ArenaWater", "Water", "R1.2 X+0.5")
JAGui.Tips.SetTip(cbBookWater, "Automatically buy all Water Code Manuals in arena shop")

cbBookWind := AddCheckboxSetting(JAGui, "ArenaWind", "Wind", "R1.2 X+0.5") 
JAGui.Tips.SetTip(cbBookWind, "Automatically buy all Wind Code Manuals in arena shop")

cbBookElec := AddCheckboxSetting(JAGui, "ArenaElec", "Electric", "R1.2 X+0.5")
JAGui.Tips.SetTip(cbBookElec, "Automatically buy all Electric Code Manuals in arena shop")

cbBookIron := AddCheckboxSetting(JAGui, "ArenaIron", "Iron", "R1.2 X+0.5")
JAGui.Tips.SetTip(cbBookIron, "Automatically buy all Iron Code Manuals in arena shop")

cbBookBox := AddCheckboxSetting(JAGui, "ArenaBox", "Buy Code Manual Box", "xs R1.2")
JAGui.Tips.SetTip(cbBookBox, "Automatically buy Code Manual Box in arena shop, which can randomly contain various attribute code manuals")

cbArenaShopPackage := AddCheckboxSetting(JAGui, "ArenaPackage", "Buy Profile Customization Pack", "R1.2")
JAGui.Tips.SetTip(cbArenaShopPackage, "Automatically buy Profile Customization Pack in arena shop")

cbArenaShopFurnace := AddCheckboxSetting(JAGui, "ArenaFurnace", "Buy Company Weapon Furnace", "R1.2")
JAGui.Tips.SetTip(cbArenaShopFurnace, "Automatically buy Company Weapon Furnace in arena shop, used for equipment conversion")

TextScrapShopTitle := JAGui.Add("Text", "R1.2 xs Section +0x0100", "===Scrap Shop===")
JAGui.Tips.SetTip(TextScrapShopTitle, "Configure settings related to in-game scrap shop (purchases using scrap)")

cbScrapShopGem := AddCheckboxSetting(JAGui, "ScrapShopGem", "Buy Gems", "R1.2")
JAGui.Tips.SetTip(cbScrapShopGem, "Automatically buy gems in scrap shop")

cbScrapShopVoucher := AddCheckboxSetting(JAGui, "ScrapShopVoucher", "Buy All Affection Vouchers", "R1.2")
JAGui.Tips.SetTip(cbScrapShopVoucher, "Automatically buy all affection vouchers in scrap shop, used to increase Nikke affection")

cbScrapShopResources := AddCheckboxSetting(JAGui, "ScrapShopResources", "Buy All Training Resources", "R1.2")
JAGui.Tips.SetTip(cbScrapShopResources, "Automatically buy all available training resources in scrap shop")

; Battle Tab
Tab.UseTab("Battle")

TextArenaTitleBattle := JAGui.Add("Text", "R1.2 Section +0x0100", "===Arena===")
JAGui.Tips.SetTip(TextArenaTitleBattle, "Settings related to various arena challenges")

cbRookieArena := AddCheckboxSetting(JAGui, "RookieArena", "Rookie Arena", "R1.2")
JAGui.Tips.SetTip(cbRookieArena, "Use five daily free challenge attempts to challenge the third position")

cbSpecialArena := AddCheckboxSetting(JAGui, "SpecialArena", "Special Arena", "R1.2")
JAGui.Tips.SetTip(cbSpecialArena, "Use two daily free challenge attempts to challenge the third position")

cbChampionArena := AddCheckboxSetting(JAGui, "ChampionArenaBet", "Champion Arena Bet", "R1.2")
JAGui.Tips.SetTip(cbChampionArena, "Follow trend betting during event periods")

TextInterceptionTeamTitle := JAGui.Add("Text", "R1.2 xs Section +0x0100", "===Abnormal Interception Team===")
JAGui.Tips.SetTip(TextInterceptionTeamTitle, "Set teams to use against different bosses during abnormal interception tasks")

DropDownListBoss := JAGui.Add("DropDownList", "Choose" String(g_numeric_settings["InterceptionBoss"]), ["Kraken(Stone), Team 1", "Mirror Container(Hand), Team 2", "Indivillia(Clothes), Team 3", "Radical(Head), Team 4", "Death(Foot), Team 5"])
JAGui.Tips.SetTip(DropDownListBoss, "Choose priority boss for abnormal interception tasks`r`nEnsure corresponding team number is configured for that boss in game`r`nFor example, choosing Kraken(Stone), Team 1 means program will use your Team 1 to challenge Kraken`r`nWill use sniper or launcher character in position 3 to hit red circles")
DropDownListBoss.OnEvent("Change", (CtrlObj, Info) => ChangeNum("InterceptionBoss", CtrlObj))

cbInterceptionShot := AddCheckboxSetting(JAGui, "InterceptionSC", "Screenshot Results", "x+5 yp+3 R1.2")
JAGui.Tips.SetTip(cbInterceptionShot, "When checked, automatically capture and save battle results screen to 'Screenshots' folder in program directory after each abnormal interception battle")

TextSimRoomTitleBattle := JAGui.Add("Text", "R1.2 xs Section +0x0100", "===Simulation Room===")
JAGui.Tips.SetTip(TextSimRoomTitleBattle, "Daily quick simulation for normal simulation room. This feature requires quick simulation to be unlocked in game`r`nThis option can be checked in the 'Tasks' tab")

cbSimulationOverClock := AddCheckboxSetting(JAGui, "SimulationOverClock", "Simulation Room Overclock", "R1.2")
JAGui.Tips.SetTip(cbSimulationOverClock, "When checked, automatically perform simulation room overclock challenges`r`nProgram will try to use your last chosen buff tag combination for overclock challenges`r`nChallenge difficulty must be 25")

TextTowerTitleBattle := JAGui.Add("Text", "R1.2 xs Section +0x0100", "===Tribe Towers===")
JAGui.Tips.SetTip(TextTowerTitleBattle, "Settings related to infinite tower challenges")

cbCompanyTower := AddCheckboxSetting(JAGui, "CompanyTower", "Company Tower", "R1.2")
JAGui.Tips.SetTip(cbCompanyTower, "When checked, automatically challenge all available company towers until unable to clear or daily attempts exhausted`r`nWill skip task if any tower shows 0/3")

cbUniversalTower := AddCheckboxSetting(JAGui, "MainTower", "Main Tower", "R1.2")
JAGui.Tips.SetTip(cbUniversalTower, "When checked, automatically challenge universal infinite tower until unable to clear")

; Rewards Tab
Tab.UseTab("Rewards")

TextNormalAwardTitle := JAGui.Add("Text", "R1.2 Section +0x0100", "===Regular Rewards===")
JAGui.Tips.SetTip(TextNormalAwardTitle, "Settings for various daily claimable regular rewards")

cbOutpostDefence := AddCheckboxSetting(JAGui, "OutpostAutomation", "Claim Outpost Defense Rewards + 1 Free Annihilation", "R1.2  Y+M  Section")
JAGui.Tips.SetTip(cbOutpostDefence, "Automatically claim outpost base offline rewards and execute one daily free quick annihilation for extra resources")

cbExpedition := AddCheckboxSetting(JAGui, "OutpostBoardAutomation", "Claim and Redeploy Outpost Board Quests", "R1.2 xs+15") 
JAGui.Tips.SetTip(cbExpedition, "Automatically claim completed commission rewards and redeploy new commissions based on available Nikkes")

cbLoveTalking := AddCheckboxSetting(JAGui, "AdviceAutomation", "Nikke Advice", "R1.2 xs Section")
JAGui.Tips.SetTip(cbLoveTalking, "Automatically perform daily Nikke consultations to increase affection`r`nYou can set Nikkes as favorites in game to adjust consultation priority`r`nWill loop until attempts exhausted")

cbFriendPoint := AddCheckboxSetting(JAGui, "FriendshipAutomation", "Friend Points", "R1.2 xs")
JAGui.Tips.SetTip(cbFriendPoint, "Automatically collect and return friend points")

cbMail := AddCheckboxSetting(JAGui, "MailAutomation", "Mailbox Collection", "R1.2")
JAGui.Tips.SetTip(cbMail, "Automatically collect all rewards from mailbox")

cbMission := AddCheckboxSetting(JAGui, "MissionAutomation", "Mission Collection", "R1.2")
JAGui.Tips.SetTip(cbMission, "Automatically collect rewards from completed daily missions, weekly missions, main missions and achievements")

cbPass := AddCheckboxSetting(JAGui, "PassAutomation", "Battle Pass Collection", "R1.2")
JAGui.Tips.SetTip(cbPass, "Automatically collect all claimable level rewards from current battle pass")

cbActivity := AddCheckboxSetting(JAGui, "EventStageAutomation", "Mini Events (Need Stage 11)", "R1.2")
JAGui.Tips.SetTip(cbActivity, "For current small story events`r`nAutomatically battle or quick battle latest challenge stage`r`nThen quick battle main event stage 11 until attempts exhausted")

TextLimitedAwardTitle := JAGui.Add("Text", "R1.2 Section +0x0100", "===Limited Time Rewards===")
JAGui.Tips.SetTip(TextLimitedAwardTitle, "Settings for limited time rewards or events during specific event periods")

cbFreeRecruit := AddCheckboxSetting(JAGui, "FreeRecruitAutomation", "Daily Free Recruitment During Events", "R1.2")
JAGui.Tips.SetTip(cbFreeRecruit, "When checked, automatically perform free recruitment if available during specific events")

cbCooperate := AddCheckboxSetting(JAGui, "CoopAutomation", "Co-op Battle", "R1.2")
JAGui.Tips.SetTip(cbCooperate, "Automatically participate in three daily co-op battles, will do nothing during battle")  

cbSoloRaid := AddCheckboxSetting(JAGui, "SoloRaidAutomation", "Solo Raid Daily", "R1.2")
JAGui.Tips.SetTip(cbSoloRaid, "Automatically participate in solo raids, auto battle or quick battle latest stage")

; Log Tab
Tab.UseTab("Log")
LogBox := JAGui.Add("Edit", "r20 w270 ReadOnly")
LogBox.Value := "Starting Log...`r`n"

Tab.UseTab()
BtnStart := JAGui.Add("Button", "Default w80 xm+100", "START!")
JAGui.Tips.SetTip(BtnStart, "Click to start the bot!`r`nThe bot will automatically execute all checked tasks according to your settings in each tab`r`nBefore clicking, please make sure the game client is running in the foreground and is at the lobby screen")
BtnStart.OnEvent("Click", StartMain)

JAGui.Show

StartMain(*) {
    Initialization
    Login() 
    if g_settings["ShopsAutomation"] {
        if g_settings["CashShop"]
            CashShop()
        if g_settings["NormalShop"]
            NormalShop()
        if g_settings["ArenaShop"]
            ArenaShop()
    }
}

Initialization() {
    ; if !A_IsAdmin {
    ;     MsgBox "pls start as admin ty"
    ;     ExitApp
    ; }
    global stdScreenW := 1920
    global stdScreenH := 1080
    global BattleActive := 1
    global nikkeID := ""
    global NikkeX := 0
    global NikkeY := 0
    global NikkeW := 0
    global NikkeH := 0
    global NikkeXP := 0
    global NikkeYP := 0
    global NikkeWP := 0
    global NikkeHP := 0
    global scrRatio := 1
    global currentScale := 1
    global WinRatio := 1
    global TrueRatio := 1
    LogBox.Value := ""
    WriteSettings()
    ;Set window title match mode to exact match
    SetTitleMatchMode 3

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
    currentScale := A_ScreenDPI / 96
    scrRatio := NikkeH / stdScreenH
    WinRatio := Round(NikkeW / 1774, 3)

    TrueRatio := Round(1 * WinRatio, 3)
    GameRatio := Round(NikkeW / NikkeH, 3)

    AddLog("`nCurrent bot version is " currentVersion "`nScreen width is " A_ScreenWidth "`nScreen height is " A_ScreenHeight "`nNikke width is " NikkeW "`nNikke height is " NikkeH "`nGame aspect ratio is " GameRatio "`nDPI scale is " currentScale "`nNominal scale is " WinRatio "`nImage scale factor is " TrueRatio "`nImage tolerance is " PicTolerance)
    if g_settings["AdjustSize"] {
        global OriginalW := NikkeW
        global OriginalH := NikkeH

        ; Now support 1080p
        if (A_ScreenWidth = 1920 and A_ScreenHeight = 1080) {
            AddLog("Standard 1080p resolution")
            AdjustSize(1773, 997)
        }
        else if (A_ScreenWidth = 2560 and A_ScreenHeight = 1080) {
            AddLog("1080p ultrawide (21:9)")
            AdjustSize(1773, 997) ; Adjust this if you have an ultrawide capture resolution
        }
        else if (A_ScreenWidth = 3840 and A_ScreenHeight = 1080) {
            AddLog("1080p super ultrawide (32:9)")
            AdjustSize(1773, 997)
        }
        else {
            AddLog("Resolution not specifically handled")
        }
    }
}

AdjustSize(TargetX, TargetY) {
    global NikkeX := 0
    global NikkeY := 0
    global NikkeW := 0
    global NikkeH := 0
    global NikkeXP := 0
    global NikkeYP := 0
    global NikkeWP := 0
    global NikkeHP := 0
    global scrRatio := 1
    global currentScale := 1
    global WinRatio := 1
    global TrueRatio := 1
    WinGetPos(&X, &Y, &Width, &Height, nikkeID)
    WinGetClientPos(&ClientX, &ClientY, &ClientWidth, &ClientHeight, nikkeID)
    ; Calculate height and width of non-client area (title bar and borders)
    NonClientHeight := Height - ClientHeight
    NonClientWidth := Width - ClientWidth 
    NewClientX := (A_ScreenWidth / 2) - (NikkeWP / 2)
    NewClientY := (A_ScreenHeight / 2) - (NikkeHP / 2)
    NewClientWidth := TargetX
    NewClientHeight := TargetY
    ; Calculate new window size to accommodate new client area
    NewWindowX := NewClientX
    NewWindowY := NewClientY
    NewWindowWidth := NewClientWidth + NonClientWidth
    NewWindowHeight := NewClientHeight + NonClientHeight
    ; Use WinMove to move and resize window
    WinMove 0, 0, NewWindowWidth, NewWindowHeight, nikkeID
    Sleep 600
    WinGetClientPos &NikkeX, &NikkeY, &NikkeW, &NikkeH, nikkeID
    WinGetPos &NikkeXP, &NikkeYP, &NikkeWP, &NikkeHP, nikkeID
    scrRatio := NikkeH / stdScreenH
}

BackToLobby() {
    AddLog("Entering Lobby")
    TextArkIcon:="|<Ark Icon>*160$42.00DzU0001zzw0007zzzU00Tzzzs00zzzzw01zwAzy07zsADzU7zkA3zkDzUS1zkTz1z1zsTz3zUzwzz7zkzyzzzzszyzzzzzzzTzzzzzzTz7zzzzDz3zkzzDz1zkzz7zUzUzy3zUS1zw1zkA3zw0zwA7zs0TyADzk0DzzzzU03zzzy001zzzs000DzzU0001zw00U"
    while !(ok:=FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1 * PicTolerance, 0.1 * PicTolerance, TextArkIcon, , 0, , , , , TrueRatio, TrueRatio)) {
        ; click home button bottom left till u get to lobby lol
        UserClick(166, 1022, scrRatio)
        Sleep 500
    }  
    if !WinActive(nikkeID) {
        MsgBox "Window is not focused, program terminated"
        Pause
    } 
    sleep 1000
}

Login() {
    AddLog("Logging In")
    check := 0

    while True {
        Text:="|<Ark Icon>*160$42.00DzU0001zzw0007zzzU00Tzzzs00zzzzw01zwAzy07zsADzU7zkA3zkDzUS1zkTz1z1zsTz3zUzwzz7zkzyzzzzszyzzzzzzzTzzzzzzTz7zzzzDz3zkzzDz1zkzz7zUzUzy3zUS1zw1zkA3zw0zwA7zs0TyADzk0DzzzzU03zzzy001zzzs000DzzU0001zw00U"
        if (check = 3) {
            break
        }
        if (ok:=FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1 * PicTolerance, 0.1 * PicTolerance, Text, , 0, , , , , TrueRatio, TrueRatio)) {
            check++
            AddLog("Verifying... " check)
            continue
        }
        else check := 0

        Text:="|<Customer Support>*125$21.zkTzk0zwTVz7z7lkQyM1nb07Qk0N6030k0M6030k0M6037s0tzUDDz7tzzzDwA1w1UT0Dzs0Ty003k00S003w01w"
        if (ok:=FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1 * PicTolerance, 0.1 * PicTolerance, Text, , 0, , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X+859, Y+550, "L")
            Sleep 1000
            AddLog("Clicked To Continue")
            checkcontinue := 1
            continue
        }
    
        UserClick(166, 1022, scrRatio)
        Sleep 500
    }
    AddLog("Already in lobby screen, login successful")
}

CashShop() {
    BackToLobby
    AddLog("===Cash Shop Task Started===")
    AddLog("Looking for Cash Shop...")
    Text:="|<Cash Shop Text>*195$42.00000703w00070Dy0007ATz3kT7ySDDszbzQ0Dxvbbw00xz77w07wzb7w7DwTr7SDQxzb7TyTwzb7DwDwS003k000000000000000000000000000000000000000000000000000000000000000000007kk0000Txs002ATwn0z7zwRzlzbzy0znnbbTstvXb7DxtvXb70wtvnbjsTtvzbyzwttz7yTttsw70Dk000700000070U"
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1 * PicTolerance, 0.1 * PicTolerance, Text, , 0, , , , , TrueRatio, TrueRatio)) {
        AddLog("Found Cash Shop!")
        FindText().Click(X, Y, "L")
        TextGift:="|<GiftBoxIcon>*85$48.zzzzzzsDzzzzzzU3zzzzzz01zzzzzz01zzzzzy00zzzzzy00zzzzzy00zzzzzy00y3y3zy00w1w1zz01skslzz01ssFtzzU3sQ1lzzsDw001zzzzy003zzzzzzzzzzzzU1s0Dzzz00s0Dzzz00s0Dzzz00s0DzzzU"
        TextNotif:="|<Notif Icon>*198$34.0000Q00007w0001kQ000AQE000bsjzzyznzzzvzjzzzDyTzzwztzzzvzbzzzjwzzzyTmzzzwQPzzzw3Dzzzzszzzzz3zzzzyDzzzzszzzzzXzzzzyDzzzzszzzzzXzzzzyDzzzzszzzzzXzzzzyDzzzzszzzzzXzzzzwDzzzzkzzzzy3zzzzsDzzzz0zzzzw3zzzzUDzzzw0U"
        TextGemPackage:="|<GemPackage>*161$44.zzzzzzzDzzzzzzvzzzzzzyzzzzzzzjzzzzkTzzzzzk1zzzzzsyDzzzzyTnzzzzzjyzzzzznzbzzzzwztzzzzzjyTzzzztzDzzzzyDXzzzzzk1zzzzzz1zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzxwTCyDzyQ3U61zz7QMVbDznz4QFnzww1740zz6ANl7zztX68NrzyA1U61zzrazlszzzzzwzzzzzzUDzzzzzwDzzzs"
        TextReward:="|<RewardScreen>*141$97.zk1w0MT1wDUz07k1zs0S0ADUy7UTU1s0Ts06067US7kDU0M07w03033kD3s7k0A03y7VVzXs7Vs3sS67Vz3VkzVs7Vw1wC73Vz3kkzkw3kw0wD33kzVsMTsS1sy0S7VVsTkwADwC0sT0T3kkwDsQC7y70QD0DVksQDsS67z7UCDX7VsMS7wD33zXW67l3kwAD3y7VVzVl77kVsS67Vz3VkzksXXskwC73Vz3kk0sMlVsMQD33kzU0M0wAMlwAC01VsTk0Q0S48MyCD01kwDs0S7z6A8S67U1sQDs8S7zX6AT33UVsS7wAD3zl36DXVkkwD3y67VzsXWDU0sMS7Vz33kzsFl7k0QAD3Vz3Vkzw0k3s0AC73kzVksTy0s3sAC73VsTksQDz0Q1wC73VkwDsQC7zUC0wD3VksQDsSC7zkD0y7VVssS7wC73zs7UT3kksQD3y73U1w3UT3sMQC01z3Vk0w3kDVwAC701z3kk0y1s7kw4D301zk"


        if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1 * PicTolerance, 0.1 * PicTolerance, TextGift, , 0, , , , , TrueRatio, TrueRatio)) {
            AddLog("Free Gems Found!")
            FindText().Click(X, Y, "L")
            while (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1 * PicTolerance, 0.1 * PicTolerance, TextNotif, , 0, , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y, "L")
                if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1 * PicTolerance, 0.1 * PicTolerance, TextGemPackage, , 0, , , , , TrueRatio, TrueRatio)) {
                    FindText().Click(X, Y, "L")
                    while (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1 * PicTolerance, 0.1 * PicTolerance, TextReward, , 0, , , , , TrueRatio, TrueRatio)) {
                        FindText().Click(X, Y, "L")
                    }
                }
            }
        }
        else {
            AddLog("No Free Gems Found")
            AddLog("===Cash Top Task Completed===")
            return
        }

        ; A system here it scans for red notif icon if there is one, click it, then fall into a conditional statement where you keep purchasing the gem package until there are no more red icons. 
        AddLog("Cash Shop Rewards Claimed")
    }
    AddLog("Cash Shop Button not Found")
    AddLog("===Cash Top Task Completed===")
    BackToLobby
}

; Icon shared by rest of shops

NormalShop() {
    BackToLobby
    AddLog("===Normal Shop Task Started===")
    AddLog("Looking for Normal Shop...")
    Text:="|<Shop Text>*168$59.zzyDzzzzzzw3sDzzzzzzU1kTzzzsUQ03UzzUDU0MC311y0D00UyC01s0C3U1zw01ksADU0zs633sMT203kS67kky603UwADVVsT031sMT31kzw63kkQC01zwA7Vk0Q067kMD3U1sMw01kS7kDkzs03UwDzzVzs0Tbzzzz3zyDzzzzzy7zzzzzzzzyDz"
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1 * PicTolerance, 0.1 * PicTolerance, Text, , 0, , , , , TrueRatio, TrueRatio)) {
        AddLog("Found Shop!")
        FindText().Click(X, Y, "L")
    }
    else {
        AddLog("Shop Icon not Found? (Probably Bug)")
        BackToLobby
        return
    }
    Sleep 1000

    TextNormalSign:="|<Big Normal Shop Icon>*200$42.zztzzzzzzkzzzzzzUTzzzzz0Dzzzzy07zzzzy03zzzzz01zzzzzU0zzzzzk0Tzzzzs0Dzzzzs07zzzzs03zzzzk03zzzzV07zzzz3UDzzzy7kTzzzsDszzzzkTzzzzzkzzzzzzVzzzzzy3zzzzzw7zzzzzsC00000kQ00000Us000001k000003U00000b000000y000000w000000z000000zs00000zzk00Dzzzk00Tzzzk00Tzzzzzzzzzy0003zzy0003zzy0003zzy0003zzy0003zzy0003zzy0003zzy0003zU"
    TextNormalIcon:="|<Small Normal Shop Icon>*150$24.znzzzVzzz0zzz0TzzUDzzk7zzk3zzY7zzCDzyTTzwzzztzzzl00Fa001A001M001k001w00EzU0zzzzzz00Tz00Tz00Tz00Tz00TU"
    if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1 * PicTolerance, 0.1 * PicTolerance, TextNormalSign, , 0, , , , , TrueRatio, TrueRatio)) {
        AddLog("Entered Normal Shop")
    }
    else if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1 * PicTolerance, 0.1 * PicTolerance, TextNormalIcon, , 0, , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
        AddLog("Entered Normal Shop")
    }
    else {
        AddLog("Could not find/enter Normal Shop")
        return
    }

    PurchasableItems := Map(
         "Free Item", {
            Text: "|<100% Text>*188$28.X0kAkA30UQnAm1nAnADAnAwwnAnknAnC3A30uAkA38U",
            Setting: true,
            Tolerance: 0.1 * PicTolerance
        },
        "Dust Box", {
            Text: "|<Core Dust Box>*189$62.DU0003w0007w0000zU00vz3XFkDxWCDsnwzy3bxrzy0zjzktzRyzUAvbwCTrTisrCty3bRrvjwziTUzrxytzDnbsDtzTjD1skw3wDnls",
            Setting: g_settings["NormalCoreDust"],
            Tolerance: 0.2 * PicTolerance
        },
        "Basic Personalization Package", {
            Text: "|<Profile Package>*170$33.zzzk07zzw00zzzU07zzw00zzzU07zzs00zzz007zzs00zzz007zzk00zzy007zzk0Azzw0DzzzU1Vzzw0ADzzU1jzzs0Bbzz01jzzsCQDzz1zVzzkNDjzy31xzzkwTjzwDXhzzXsBjzwz1V1zXvgM0sTzz003zzs007zy000Tz4",
            Setting: g_settings["NormalPackage"],
            Tolerance: 0.1 * PicTolerance
        }
    )
    loop 2 {
        TextCheckBox:="|<Checkbox For Multi Purchase>*152$57.s0DzzzzzzwTwzzzzzzzjznzzzzzztzzTzzzzzzTztzzy0zzvzzDzzl7zzTztzzyQHa3zzDzznWQkTztzzy0na/zzDzzkCQnTztzzyDnaPzzDzzny0nTztzzyTs6NzzTzzzzzzjznzzzzzzw00zzzzzzzs0Tzzzzzzw"
        TextCartIcon:="|<BuyCollection>1EB1F6-0.90$28.1zzzw7zzzkDzzzs0007U000D0001w0007s000zU003z000Tw003zs00DzU01zy007zs00zz007zwTzzzVzzzy000Tw001zk007zzzzzyTzbzkTwDy1zUTs7y1zkTsDzXzky"
        TextCoreGemCheck:="|<CoreGemCheck>*180$92.zzzzzzzzz000000Dzzzzzzzzk000003zzzzzzzzw000000zzzzzzzzz01w000Dzzzzzzzzk0zU003zzzzzzzzw0Tw000zzzzzzzzz0D73kyDzzzzzzzzk3UlyDrzzzzzzzzw0s0xnvzzzzzzzzz0C0CQszzzzzzzzzk3U3bCDzzzzzzzzw0wQtnX00000003z07zDwsk0000000Tk0zVyC400200007w07kD3U03zzzU01z0000000DzzzzU0Tk000000M0Tzzt07w000000800000Dlz0000005y00000yTk000002Ok0000D7w000000fu02001tz0000002+U1h00STk000000Vc0/k07bw000000cO02w01lz0000003700h00QTk000001Tk0000D7w000000Nk00007lz0000001UjzzzzwTk0000001zzzzzy7w00000000zzzzzVz00000000DzzzzsTk00000007zzzzy7w00000001zzzzzVz00000000zzzzxUTk0000000zzzzzs7w0000000yzzzzw1z0000000TfzzzzkTk000000Tjzzzzw7w003U00Dszzzzy1z000w00DzLzvzzUTk00BU03zzzyjzs7w005400zzzy7zs1z001mU0CzyzXzy0Tk00Kq03zzztzzU7w007jk0zzzzHzs1z001vq0Dzzzzzy0Tk00jyk1yzzzzzU7w00/rK0zzrzzzs1z003sAU/zzzzrwDTk00w2M2"
        TextCartIconFinal:="|<ConfirmCollection>*186$25.1zzzUzzzy000D0003k003s001y001z000zk00zs00zy00Tz00TzU0DzXzzzXzzzlzzzs00Dy007zzzzzrznzUzkzkTkTsDsDyDyDU"
        TextReward:="|<RewardScreen>*141$97.zk1w0MT1wDUz07k1zs0S0ADUy7UTU1s0Ts06067US7kDU0M07w03033kD3s7k0A03y7VVzXs7Vs3sS67Vz3VkzVs7Vw1wC73Vz3kkzkw3kw0wD33kzVsMTsS1sy0S7VVsTkwADwC0sT0T3kkwDsQC7y70QD0DVksQDsS67z7UCDX7VsMS7wD33zXW67l3kwAD3y7VVzVl77kVsS67Vz3VkzksXXskwC73Vz3kk0sMlVsMQD33kzU0M0wAMlwAC01VsTk0Q0S48MyCD01kwDs0S7z6A8S67U1sQDs8S7zX6AT33UVsS7wAD3zl36DXVkkwD3y67VzsXWDU0sMS7Vz33kzsFl7k0QAD3Vz3Vkzw0k3s0AC73kzVksTy0s3sAC73VsTksQDz0Q1wC73VkwDsQC7zUC0wD3VksQDsSC7zkD0y7VVssS7wC73zs7UT3kksQD3y73U1w3UT3sMQC01z3Vk0w3kDVwAC701z3kk0y1s7kw4D301zk"
        
        sleep 1000
        if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1 * PicTolerance, 0.1 * PicTolerance, TextCheckBox, , 0, , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X, Y, "L")
        }
        for Name, item in PurchasableItems {
            if (!item.Setting) {
                continue
            }

            if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, item.Tolerance, item.Tolerance, item.Text, , , , , , , TrueRatio, TrueRatio)) {
                loop ok.Length {
                    FindText().Click(ok[A_Index].x, ok[A_Index].y, "L")
                    Sleep 1000
                }
            }
            else {
                AddLog("Item: " name  " not found")
            }   
        }
        if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1 * PicTolerance, 0.1 * PicTolerance, TextCartIcon, , 0, , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X, Y, "L")
            ; sleep 1000
            while (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0, 0, TextCoreGemCheck, , 0, , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X+199, Y+26, "L")
            }
            if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1 * PicTolerance, 0.1 * PicTolerance, TextCartIconFinal, , 0, , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y, "L")
            }
            sleep 1000
            while (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1 * PicTolerance, 0.1 * PicTolerance, TextReward, , 0, , , , , TrueRatio, TrueRatio)) {
                    FindText().Click(X, Y, "L")
            }
        }
        else {
            AddLog("No Items found")
        }

        Text:="|<FREE>*172$27.10k808631DCHts9W3110kM9s6TDDAk83tm30U"
        TextConfirm:="|<TextConfirm>*183$26.zy3zzw0Dzw07zy3zzz3zzDXzzVlzzkwTzsSDzwDXzy7tzz3ySTVz73kzlsMTkT0Dwbs7z8z3zWDtzslzzwQTzz7XzzXsTzlz1zkzw30TzU0Dzy0Ty"
        if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1 * PicTolerance, 0.1 * PicTolerance, Text, , 0, , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X-63, Y+17, "L")
            AddLog("Refreshing Shop...")
            Sleep 500
            if (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1 * PicTolerance, 0.1 * PicTolerance, TextConfirm, , 0, , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y, "L")
            }
            AddLog("Shop Refreshed!")
            Sleep 500
        }
        else {
            AddLog("Refreshes Exhausted")
            break
        }
    }
    AddLog("===Normal Shop Task Completed===") 
}

ArenaShop() {
    AddLog("===Arena Shop Task Started===")
    AddLog("Entering Arena Shop...")
    TextArenaIconS:="|<TextArenaIconS>*125$33.zz07zzzU0TzzsD1zzy7wDzzXXlzzwQSBzx73ltz8sQDbXD73yQtsUzt7A0Tz8lU3zsaC4DzAlklztnCC7uT8lsSLz4D3Xzw1w0zzkTkDzz7z7zU"
    TextArena:="|<ArenaText>*163$69.0z0000000000Ds0000000001z0000000000Dw0000000003zUSsDUSS0T0Tw3z7z3zsDy3rkTtzwTzXzsyS3zDbXzwSD7XkT1sSS7U1swT3kTznkw3zDzsS3zyS7Vztzz3kTznkwTzDzwS3s0S7blvsDXkD3nkwwDS0wS1zyS7bzzk7nk7zXkwTzy0yS0TkS7Vxw"
    if !(ok := FindText(&X , &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1 * PicTolerance, 0.1 * PicTolerance, TextArena, , 0, , , , , TrueRatio, TrueRatio)) {
        if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1 * PicTolerance, 0.1 * PicTolerance, TextArenaIconS, , 0, , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X, Y, "L")
        }
    }
    AddLog("Entered Arena Shop!")

    PurchasableItems := Map(
         "Book iron", {
            Text: "|<BookIron>#769-0.90$34.00U0000BzbUk1lU00000Dz00U0000100020400001000000000108000E0U0010000040E000E10000041U0800z7U003xz208Drw80UzTU023xy40E73sE103o1000zU40E3y0020Ds2080D000U2Q0U001020E0008100010400000E000E200010800041U000EC00000lU0083k3k0kDs03a0s3s082",
            Setting: g_settings["ArenaIron"],
            Tolerance: 0.1 * PicTolerance
        },
        "Book Water", {
            Text: "|<BooKWater>*130$29.5zzzyPzzzsvzzzlrzzzWzzzzjzzzzRzzzyfzzzpTzzzjzyzzSzxvyxznXz/z37rjw6DjTkDzSzUTypy0Tzrw0zrjs3zjTk7zSzkTynzvzzrzzzpjzzzjTzzzSzzzyrzzzxzzzzrzzzzjzzzzTzzzyz",
            Setting: g_settings["ArenaWater"],
            Tolerance: 0.1 * PicTolerance
        },
        "Book Wind", {
            Text: "|<BookWind>7BF82E-0.82/EEB92E-0.78/462F2A-0.97$35.0C000+08000E1000000U000k30005U6000808000M00000k1U000U20C04040w080019sM0kzqkk3U28U02Dy30081zw80MT00M0UTy0k100A10602840804E80k0D0M0U000k300010400040800080E000E3U000k600010A00020s000A1fk00M3zns0k4",
            Setting: g_settings["ArenaWind"],
            Tolerance: 0.1 * PicTolerance
        },
        "Arena Box", {
            Text: "|<ArenaBox>E7972D-0.78$60.00001k00000000Ty00000000zzU00000002A000000000A00000000s3U000000700Q0000U0w00DU1kDsC0000C7wTxk00001nzTn000000Nzr00000000Ry0U000000Bw0E000010Dw02000080Dy00M007U0Do00200M001k00000U001k000460001EQ006g00010LU0Ty00S00Rs0Tz03k00Tj0Ty06C00TvkDk0My00TzQ7k17y00Tzk3U4Ty00Tzw1U3zy00QTw0U7zy00Nbw1U7zy00Nsw007zy00RzQ007zy00NzQ007zy00RzA007zy00RzQ007zy00NzQ007zy00RzA007zy00RzQ007zy00STQ007zy00TXA007zy00TwQ007zy00Tzw007zy00Tjw007zy00Tzw007zy00Tvw007zy00Tbw007zw007vw007zs001zw007zk000Tw007z00007w007y00001w007s00000Q007U000004006000U",
            Setting: g_settings["ArenaBox"],
            Tolerance: 0.1 * PicTolerance
        },
        "Arena Furnace", {
            Text: "|<ArenaFurnace>*120$66.0000000000000000000000000000000000000zs00000000D4800000000NmDw0000000NpjrU000000PnDjzk00001fkDfzg00003vsA7zW00007vw83zh0000Dtw83rdU001zzy81VVU003zzy80XVk003zzy803VE003zzy803lE003zzy800nE003zzwc00rk007zztc00rk003zztc00rU003zzxc00v0001zzzc03q0000zzzc07q0000zzzg07m0000zzzc07m0000zzzc03m0000zzzc00u0001zzvc00v0003zzv800P0003zzsc00P0003zzs804P0003zzy80Iz0003zzyA0yt0003zzyA1zt0003zzyC1xt0003zzyDyxt0003zzzC6jx0003zzzw03xU007zzz000BU007zzz000AU00Dzzz800AU00Dzzxe00AU00DzzwS03wU007zzwC000U003zzzj000k003zzzTzk0s007zzzzzzws00Dzzzzzzys00Dzzzzzzyk00Dzzzzzzzk00Tzzzzzzzk00DzzzzFzzl00DzzzzzyHl007zzzzzzzN807zzzzzzzV907zzzjzzzl807zzzzzzzt80TzzzzzzqN80zzzzzzzUN91zzzzzzzUN93zzzzzzzkt97zzzzTzzkt9DznzyDzvkN9DzXzwDztUN17z1zs000aPV0000000Hzzz03xjzzzzzzzzzzzzzzzzzzzzzzzzzzzzzU",
            Setting: g_settings["ArenaFurnace"],
            Tolerance: 0.1 * PicTolerance
        },
        "ArenaPackage", {
            Text: "|<Profile Package>*170$33.zzzk07zzw00zzzU07zzw00zzzU07zzs00zzz007zzs00zzz007zzk00zzy007zzk0Azzw0DzzzU1Vzzw0ADzzU1jzzs0Bbzz01jzzsCQDzz1zVzzkNDjzy31xzzkwTjzwDXhzzXsBjzwz1V1zXvgM0sTzz003zzs007zy000Tz4",
            Setting: g_settings["ArenaPackage"],
            Tolerance: 0.1 * PicTolerance
        }
    )

    TextCheckBox:="|<Checkbox For Multi Purchase>*152$57.s0DzzzzzzwTwzzzzzzzjznzzzzzztzzTzzzzzzTztzzy0zzvzzDzzl7zzTztzzyQHa3zzDzznWQkTztzzy0na/zzDzzkCQnTztzzyDnaPzzDzzny0nTztzzyTs6NzzTzzzzzzjznzzzzzzw00zzzzzzzs0Tzzzzzzw"
    TextCartIcon:="|<BuyCollection>1EB1F6-0.90$28.1zzzw7zzzkDzzzs0007U000D0001w0007s000zU003z000Tw003zs00DzU01zy007zs00zz007zwTzzzVzzzy000Tw001zk007zzzzzyTzbzkTwDy1zUTs7y1zkTsDzXzky"
    TextCartIconFinal:="|<ConfirmCollection>109FE2-0.81$22.DzzwTzzlzzzU002000A000k007U00S003w00Dk01zU07y00zk07z7zzszzzU00y003y00Dzzzz7z7sDsDUzUy3z3yTyS"
    TextReward:="|<RewardScreen>*141$97.zk1w0MT1wDUz07k1zs0S0ADUy7UTU1s0Ts06067US7kDU0M07w03033kD3s7k0A03y7VVzXs7Vs3sS67Vz3VkzVs7Vw1wC73Vz3kkzkw3kw0wD33kzVsMTsS1sy0S7VVsTkwADwC0sT0T3kkwDsQC7y70QD0DVksQDsS67z7UCDX7VsMS7wD33zXW67l3kwAD3y7VVzVl77kVsS67Vz3VkzksXXskwC73Vz3kk0sMlVsMQD33kzU0M0wAMlwAC01VsTk0Q0S48MyCD01kwDs0S7z6A8S67U1sQDs8S7zX6AT33UVsS7wAD3zl36DXVkkwD3y67VzsXWDU0sMS7Vz33kzsFl7k0QAD3Vz3Vkzw0k3s0AC73kzVksTy0s3sAC73VsTksQDz0Q1wC73VkwDsQC7zUC0wD3VksQDsSC7zkD0y7VVssS7wC73zs7UT3kksQD3y73U1w3UT3sMQC01z3Vk0w3kDVwAC701z3kk0y1s7kw4D301zk"
    
    sleep 500
    if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1 * PicTolerance, 0.1 * PicTolerance, TextCheckBox, , 0, , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")
    }
    for Name, item in PurchasableItems {
        if (!item.Setting) {
            continue
        }

        if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, item.Tolerance, item.Tolerance, item.Text, , , , , , , TrueRatio, TrueRatio)) {
            loop ok.Length {
                FindText().Click(ok[A_Index].x, ok[A_Index].y, "L")
            }
        }
        else {
            AddLog("Item: " name  " not found")
        }   
    }
    if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1 * PicTolerance, 0.1 * PicTolerance, TextCartIcon, , 0, , , , , TrueRatio, TrueRatio)) {
        FindText().Click(X, Y, "L")

        if (ok := FindText(&X, &Y, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1 * PicTolerance, 0.1 * PicTolerance, TextCartIconFinal, , 0, , , , , TrueRatio, TrueRatio)) {
            FindText().Click(X, Y, "L")
        }
        sleep 1000
        while (ok := FindText(&X := "wait", &Y := 3, NikkeX, NikkeY, NikkeX + NikkeW, NikkeY + NikkeH, 0.1 * PicTolerance, 0.1 * PicTolerance, TextReward, , 0, , , , , TrueRatio, TrueRatio)) {
                FindText().Click(X, Y, "L")
        }
    }
    else {
        AddLog("No Items found")
    }
    AddLog("===Arena Shop Task Completed===")
    sleep 500
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
UserClick(sX, sY, k) {
    uX := Round(sX * k) ;Calculate transformed coordinates
    uY := Round(sY * k)  
    CoordMode "Mouse", "Client"
    Send "{Click " uX " " uY "}" ;Click transformed coordinates
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

TestMode(BtnTestMode, Info) {
    funcName := TestModeEditControl.Value
    if (funcName = "") {
        MsgBox("请输入要执行的函数名！")
        return
    }
    Initialization()
    %funcName%() 
}

ChangeNum(settingKey, GUICtrl, *) {
    global g_numeric_settings
    g_numeric_settings[settingKey] := GUICtrl.Value
}

^1:: {
    ExitApp
}

^2:: {
    ; try {
    ;     if g_settings["AdjustSize"] {
    ;         AdjustSize(OriginalW, OriginalH)
    ;     }
    ; }
    Pause
}