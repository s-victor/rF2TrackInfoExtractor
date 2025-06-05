; This script requires AutoHotKey v2 to run

#SingleInstance Ignore
#NoTrayIcon
KeyHistory 0

; Metadata
TITLE := "rF2 Track Info Extractor"
DESCRIPTION := "Track info extractor for rF2."
AUTHOR := "S.Victor"
VERSION := "0.1.0"

; Game path check
if (!FileExist(A_WorkingDir "\Bin64\ModMgr.exe"))
{
    MsgBox(
        "This program must be placed in 'rFactor 2' root folder to run.`n`n"
        "Please place this program in 'rFactor 2' root folder, then try again.`n`n",
        TITLE,
    )
    ExitApp
}

; Set environment path to mod manager executable folder
EnvSet "Path", A_WorkingDir "\Bin64\"

; Constant & Variable
CRLF := "`r`n"
PATH_LOCATION := A_WorkingDir "\Installed\Locations"
PATH_OUTPUT := A_WorkingDir "\TrackDatabase"
DATABASE_PATH := A_WorkingDir "\TrackData.csv"
DATAFIELDS := [
    "GDBName",
    "TrackName",
    "EventName",
    "VenueName",
    "Location",
    "Length",
    "TrackType",
    "Track Record",
    "Max Vehicles",
    "PitlaneBoundary",
    "RacePitKPH",
    "NormalPitKPH",
    "FormationSpeedKPH",
    "NumStartingLights",
    "Latitude",
    "Longitude",
    "Altitude",
    "RaceDate",
    "TimezoneRelativeGMT",
    "DSTRange",
]
DATATEMPLATE := Map(
    "GDBName", "",
    "TrackName", "",
    "EventName", "",
    "VenueName", "",
    "Location", "",
    "Length", "",
    "TrackType", "",
    "Track Record", "",
    "Max Vehicles", "128",
    "PitlaneBoundary", "1",  ; whether has pit lane boundary, 0 = must request pit
    "RacePitKPH", "100",
    "NormalPitKPH", "100",
    "FormationSpeedKPH", "100",
    "NumStartingLights", "5",
    "Latitude", "0",
    "Longitude", "0",
    "Altitude", "0",
    "RaceDate", "July 3, 2007",
    "TimezoneRelativeGMT", "0",  ; before DST
    "DSTRange", "(0, 0, 0, 0)",  ; start day, end day, start year, end year
)

; GUI
ToolGui := Gui(, TITLE " v" VERSION)
ToolGui.SetFont(, "Arial")
StatBar := ToolGui.Add("StatusBar", , "")

panel_width := 400
win_margin_x := ToolGui.MarginX
win_margin_y := ToolGui.MarginY

; Buttons
button_pos_y := win_margin_x

ButtonClear := ToolGui.Add("Button", "x" win_margin_x - 1 " y" button_pos_y " h23", "Clear Log")
ButtonClear.OnEvent("Click", DialogConfirmClear)

ButtonExtract := ToolGui.Add("Button", "x" win_margin_x + 73 " y" button_pos_y " h23", "Extract GDB")
ButtonExtract.OnEvent("Click", ExtratGDB)

ButtonStop := ToolGui.Add("Button", "x" win_margin_x + 158 " y" button_pos_y " h23", "Stop")
ButtonStop.OnEvent("Click", StopExtract)
ButtonStop.Enabled := false

ButtonParse := ToolGui.Add("Button", "x" win_margin_x + 203 " y" button_pos_y " h23", "Export Data")
ButtonParse.OnEvent("Click", ExportTrackData)

ButtonAbout := ToolGui.Add("Button", "x365 y" button_pos_y " h23", "About")
ButtonAbout.OnEvent("Click", DialogAbout)

; Output tab
output_pos_y := button_pos_y + 32
output_height := 383

OutputLog := ToolGui.Add(
    "Edit",
    " x" win_margin_x
    " y" output_pos_y
    " w" panel_width
    " h" output_height - output_pos_y
    " ReadOnly"
)
OutputLog.SetFont(, "Consolas")
ToolGui.Add("GroupBox", "x" win_margin_x " y" output_height + 1 " w401 h30 cGray",)
GenProgress := ToolGui.Add("Progress", "x" win_margin_x + 1 " y" output_height + 9 " w398 h20 cGreen vMyProgress", 100)

; Start GUI
ToolGui.Show()

; Function
ExtratGDB(*)
{
    if (DialogConfirmExtract() = "No")
    {
        return
    }

    UpdatePath(PATH_OUTPUT)
    ToggleGenerateState(false)

    ; Get total file counts
    total_files := 0
    Loop Files, PATH_LOCATION "\*.mas", "R"
    {
        total_files += 1
    }

    ; Extract GDB files from MAS file
    CMD_EXE := "ModMgr.exe *.gdb -x`""
    counter := 0
    Loop Files, PATH_LOCATION "\*.mas", "R"
    {
        if (!ButtonStop.Enabled)
        {
            break
        }
        try
        {
            Run CMD_EXE A_LoopFilePath "`"", PATH_OUTPUT, "Hide"
            EditPaste("Processed: " A_LoopFileName CRLF, OutputLog)
        }
        catch Error
        {
            EditPaste("Failed: " A_LoopFilePath CRLF, OutputLog)
        }
        counter := A_Index
        GenProgress.Value := 100 * counter / total_files
        StatBar.SetText(" Processing: " counter "/" total_files)
    }
    if (counter < total_files)
    {
        StatBar.SetText(" Cancelled, processed files: " counter "/" total_files)
    }
    else
    {
        StatBar.SetText(" Completed, processed files: " counter "/" total_files)
    }
    ToggleGenerateState(true)
}


ExportTrackData(*)
{
    DialogSaveToFile()
    if (!DATABASE_PATH)
    {
        return
    }

    ; Remove old file
    if FileExist(DATABASE_PATH)
    {
        FileDelete(DATABASE_PATH)
    }

    ToggleGenerateState(false)
    OutputLog.Value := ""

    ; Write field name
    For field_name in DATAFIELDS
    {
        FileAppend("`"" field_name "`",", DATABASE_PATH)
    }
    FileAppend("`n", DATABASE_PATH)

    ; Get total file counts
    total_files := 0
    Loop Files, PATH_OUTPUT "\*.GDB"
    {
        total_files += 1
    }

    ; Write data
    counter := 0
    Loop Files, PATH_OUTPUT "\*.GDB"
    {
        if (!ButtonStop.Enabled)
        {
            break
        }
        ParseGameDataBaseFile(A_LoopFilePath, A_LoopFileName)
        EditPaste("Processed: " A_LoopFileName CRLF, OutputLog)
        counter := A_Index
        GenProgress.Value := 100 * counter / total_files
        StatBar.SetText(" Processing: " counter "/" total_files)
    }
    if (counter < total_files)
    {
        StatBar.SetText(" Cancelled, processed files: " counter "/" total_files)
    }
    else
    {
        StatBar.SetText(" Completed, processed files: " counter "/" total_files)
    }
    ToggleGenerateState(true)
}


ParseGameDataBaseFile(file_path, file_name)
{
    output := DATATEMPLATE.Clone()
    output["GDBName"] := file_name
    Loop read, file_path
    {
        Loop parse, A_LoopReadLine, "`n"
        {
            For field_name in DATAFIELDS
            {
                if InStr(A_LoopField, field_name, 1) and (SubStr(Trim(A_LoopField), 1, 1) != "/")
                {
                    output[field_name] := Trim(StrSplit(A_LoopField, ["=", "/"])[2])
                    break
                }
            }
        }
    }

    ; Write dataset
    For field_name in DATAFIELDS
    {
        FileAppend("`"" output[field_name] "`",", DATABASE_PATH)
    }
    FileAppend("`n", DATABASE_PATH)
}


UpdatePath(path)
{
    if (!DirExist(path))
    {
        DirCreate(path)
    }
}


ToggleGenerateState(state)
{
    ButtonClear.Enabled := state
    ButtonExtract.Enabled := state
    ButtonParse.Enabled := state
    OutputLog.Enabled := state
    ButtonStop.Enabled := not state
}


StopExtract(*)
{
    ToggleGenerateState(true)
}


DialogSaveToFile()
{
    global DATABASE_PATH
    ToolGui.Opt("+OwnDialogs")
    DATABASE_PATH := FileSelect("S16", "TrackData.csv", "Save As", "CSV file (*.csv)")
}


DialogConfirmExtract(*)
{
    ToolGui.Opt("+OwnDialogs")
    return MsgBox(
        "Extract Game Database File (GDB) to following folder?`n`n"
        A_WorkingDir "\TrackDatabase\`n`n"
        "Old file will be overridden.",
        "Confirm",
        "YesNo"
    )
}


DialogConfirmClear(*)
{
    if (OutputLog.Value == "")
        return
    ToolGui.Opt("+OwnDialogs")
    choice := MsgBox(
        "Clear all log?",
        "Confirm",
        "YesNo"
    )
    if (choice == "Yes")
    {
        OutputLog.Value := ""
    }
}


DialogAbout(*)
{
    ToolGui.Opt("+OwnDialogs")
    info := TITLE " v" VERSION CRLF "by " AUTHOR CRLF CRLF DESCRIPTION CRLF CRLF
    MsgBox(info, "About")
}