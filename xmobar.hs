Config  { font            = "xft:Monaco for Powerline-7:bold"
        , bgColor         = "#333333"
        , fgColor         = "#FFFFFF"
        , position        = Static { xpos = 0, ypos = 0, width = 1380, height = 16 }
        , lowerOnStart    = True
        , commands        = [ Run MPD ["-t", "<state>: <artist> - <title>"] 10
                            , Run Battery ["-t","Battery: <left>% - <timeleft>"] 10
                            , Run Date "%a %b %_d %l:%M" "date" 10
                            , Run StdinReader
                            ]
        , sepChar         = "%"
        , alignSep        = "}{"
        , template        = " XMonad | %StdinReader% }{ ⮃ %mpd% ⮃ %battery% ⮃ %date% ⮃"
        }
