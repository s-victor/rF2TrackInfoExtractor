# rF2TrackInfoExtractor

A simple tool for batch extracting track GDB (Game Database File) info from all installed track mods in `rFactor 2` and exporting to spreadsheet file (CSV).

![preview](https://github.com/user-attachments/assets/c9789147-2221-4237-8af6-ad5404385f52)

![spreadsheet](https://github.com/user-attachments/assets/5a63230d-29c8-4906-82a3-17de0545e1ef)

## Exported field names from GDB file
- GDBName
- TrackName
- EventName
- VenueName
- Location
- Length
- TrackType
- Track Record
- Max Vehicles
- PitlaneBoundary
- RacePitKPH
- NormalPitKPH
- FormationSpeedKPH
- NumStartingLights
- Latitude
- Longitude
- Altitude
- RaceDate
- TimezoneRelativeGMT
- DSTRange

## Usage
1. Download `rF2TrackInfoExtractor` from [Release](https://github.com/s-victor/rF2TrackInfoExtractor/releases) page.

2. Extract `rF2TrackInfoExtractor.exe` file, place it in `rFactor 2` game root folder. This is required for correctly locating and accessing rF2's `ModMgr.exe` tool (which is located in "rFactor 2\Bin64" folder) for extracting files from `MAS` file.

3. Launch `rF2TrackInfoExtractor`, click `Extract GDB` button to begin extracting GDB files from all installed track mods. All GDB files will be extracted to `rFactor 2\TrackDatabase` folder.

4. Once extracted GDB files, click `Export Data` button to process and export track and layout info from all GDB files to spreadsheet file (CSV), which then can be further processed or opened with spreadsheet programs like `Excel` or `LibreOffice Calc`.

Note, extraction and exporting progress are displayed in log viewer and status bar, click `Stop` button any time to stop extraction or exporting. 

## License
rF2TrackInfoExtractor is licensed under the [MIT License](./LICENSE.txt).
