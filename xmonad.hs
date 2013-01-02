import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.SetWMName
import XMonad.Layout.IM
import XMonad.Layout.Grid
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Reflect
import XMonad.Layout.Tabbed
import XMonad.Util.Cursor
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Util.Replace
import XMonad.Util.Run(spawnPipe)
import XMonad.Prompt
import System.Exit 
import System.IO
import qualified XMonad.StackSet as W
import qualified Data.Map as M

myFont                      = "xft:Monaco for Powerline-7:bold"
ppTitleFgColor              = "#FFFFFF"
ppTitleBgColor              = "#333333"
ppCurrentFgColor            = "#1793D1"
ppCurrentBgColor            = "#333333"
ppUrgentFgColor             = "#FF0000"
ppUrgentBgColor             = "#333333"
ppHiddenFgColor             = "#999999"
ppHiddenBgColor             = "#333333"
ppSepFgColor                = ""
ppSepBgColor                = ""
ppWsSepFgColor              = "#1793D1"
ppWsSepBgColor              = ""

ppSeparator                 = ""
ppWsSeparator               = ""

myNormalBorderColor         = "#333333"
myFocusedBorderColor        = "#0088CC"

myBorderWidth               = 1
myModMask                   = controlMask
myTerminal                  = "xterm"
myWorkspaces                = ["1:Term \11137","2:Web \11137","3:Code \11137","4 \11137","5 \11137","6 \11137","7 \11137","8:Read \11137","9:Chat \11137"]

myManageHook                = composeAll
    [ className             =? "Pidgin"         --> doShift "9:Chat \11137"
    , className             =? "Evince"         --> doShift "8:Read \11137"
    , className             =? "Firefox"        --> doShift "2:Web \11137"
    , className             =? "Eclipse"        --> doShift "3:Code \11137"
    ]

myLayoutHook                = onWorkspace "1:Term \11137" gridLayout $ onWorkspace "2:Web \11137" webLayout $ onWorkspace "8:Read \11137" tabbedLayout $  onWorkspace "9:Chat \11137" chatLayout $ defaultLayout
    where
        defaultLayout       = avoidStruts ( tall ||| Mirror tall ||| Full )
            where 
                tall        = Tall nmaster delta ratio
                nmaster     = 1
                ratio       = 1/2
                delta       = 2/100

        gridLayout          = avoidStruts $ Grid

        webLayout           = avoidStruts ( Mirror tall ||| tall ||| Full)
            where 
                tall        = Tall nmaster delta ratio
                nmaster     = 1
                ratio       = 3/4
                delta       = 2/100 

        chatLayout          = avoidStruts $ withIM (18/100) (Role "buddy_list") Grid

        tabbedLayout        = avoidStruts ( tabbed shrinkText tabConfig ||| Full) 

tabConfig = defaultTheme 
    { fontName              = myFont
    , activeBorderColor     = "#1793D1"
    , activeTextColor       = "#333333"
    , activeColor           = "#1793D1"
    , inactiveBorderColor   = "#333333"
    , inactiveTextColor     = "#FFFFFF"
    , inactiveColor         = "#333333"
    }

myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
    [ ((0, 0x1008ff03), spawn "xbacklight -10")
    , ((0, 0x1008ff02), spawn "xbacklight +10")
    , ((0, 0x1008ff4b), spawn "~/bin/run-dialog")
    , ((0, 0x1008ff06), spawn "~/bin/keyboard-backlight down")
    , ((0, 0x1008ff05), spawn "~/bin/keyboard-backlight up")
    , ((0, 0x1008ff16), spawn "mpc prev")
    , ((0, 0x1008ff14), spawn "mpc toggle")
    , ((0, 0x1008ff17), spawn "mpc next")
    , ((0, 0x1008ff12), spawn "amixer set Master toggle")
    , ((0, 0x1008ff11), spawn "amixer set Master 5%-")
    , ((0, 0x1008ff13), spawn "amixer set Master 5%+")
    , ((modMask, xK_Return), spawn $ XMonad.terminal conf)
    , ((modMask, xK_q), kill)
    , ((mod1Mask, xK_Tab), sendMessage NextLayout)
    , ((modMask .|. shiftMask, xK_space), setLayout $XMonad.layoutHook conf)
    , ((modMask, xK_r), refresh)
    , ((modMask, xK_Tab), windows W.focusDown)
    , ((modMask, xK_j), windows W.focusDown)
    , ((modMask .|. shiftMask, xK_Tab), windows W.focusUp)
    , ((modMask, xK_k), windows W.focusUp)
  --  , ((modMask, xK_m), windows W.focusMaster)
    , ((modMask, xK_m), windows W.swapMaster)
    , ((modMask .|. shiftMask, xK_j), windows W.swapDown)
    , ((modMask .|. shiftMask, xK_k), windows W.swapUp)
    , ((modMask, xK_h), sendMessage Shrink)
    , ((modMask, xK_l), sendMessage Expand)
    , ((modMask, xK_t), withFocused $ windows . W.sink)
    , ((modMask, xK_comma), sendMessage (IncMasterN 1))
    , ((modMask, xK_period), sendMessage (IncMasterN (-1)))
    , ((modMask .|. shiftMask, xK_q), io (exitWith ExitSuccess))
    , ((modMask .|. shiftMask, xK_r), restart "xmonad" True)
    ]
    ++

    [((m .|. modMask, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]

myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
    [ ((modMask, button1), (\w -> focus w >> mouseMoveWindow w))
    , ((modMask, button2), (\w -> focus w >> windows W.swapMaster))
    , ((modMask, button3), (\w -> focus w >> mouseResizeWindow w))
    ]

myLogHook :: Handle -> X ()
myLogHook h = dynamicLogWithPP $ xmobarPP
    { ppOutput      = hPutStrLn h
    , ppLayout      = const ""
    , ppTitle       = xmobarColor ppTitleFgColor ppTitleBgColor . shorten 100
    , ppSep         = xmobarColor ppSepFgColor ppSepBgColor ppSeparator
    , ppWsSep       = xmobarColor ppWsSepFgColor ppWsSepBgColor ppWsSeparator
    , ppCurrent     = xmobarColor ppCurrentFgColor ppCurrentBgColor . pad
    , ppUrgent      = xmobarColor ppUrgentFgColor ppUrgentBgColor . pad
    , ppHidden      = xmobarColor ppHiddenFgColor ppHiddenBgColor . pad
    }

myStartupHook :: X ()
myStartupHook = do 
    setDefaultCursor xC_left_ptr >> setWMName "LG3D"
    spawn "~/.xmonad/autostart"

main = do
    workspaceBar                <- spawnPipe "xmobar ~/.xmonad/xmobar.hs"
    xmonad $ defaultConfig 
        { terminal              = myTerminal
        , borderWidth           = myBorderWidth
        , focusFollowsMouse     = myFocusFollowsMouse
        , modMask               = myModMask
        , workspaces            = myWorkspaces
        , normalBorderColor     = myNormalBorderColor
        , focusedBorderColor    = myFocusedBorderColor
        , keys                  = myKeys
        , mouseBindings         = myMouseBindings
        , logHook               = (myLogHook workspaceBar)
        , layoutHook            = myLayoutHook
        , manageHook            = manageDocks <+> myManageHook
        , startupHook           = myStartupHook
        }
