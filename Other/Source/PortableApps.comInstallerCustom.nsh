!macro CustomCodePostInstall

; Prepare folder to extract with 7zip
CreateDirectory "$INSTDIR\7zTemp"
SetOutPath "$INSTDIR\7zTemp"
File "${NSISDIR}\..\7zip\7z.exe"
File "${NSISDIR}\..\7zip\7z.dll"
SetOutPath $INSTDIR

inetc::get /CONNECTTIMEOUT 30 /NOCOOKIES /TRANSLATE "Downloading SourceTree..." "Connecting..." second minute hour s "%dkB (%d%%) of %dkB @ %d.%01dkB/s" " (%d %s%s remaining)" "https://product-downloads.atlassian.com/software/sourcetree/windows/ga/SourceTreeSetup-3.3.8.exe" "$INSTDIR\7zTemp\SourceTreeSetup-3.3.8.exe" /END

; Extract
ExecDOS::exec `"$INSTDIR\7zTemp\7z.exe" e "$INSTDIR\7zTemp\SourceTreeSetup-3.3.8.exe" "SourceTree-3.3.8-full.nupkg" -o"$INSTDIR\7zTemp"` "" ""
ExecDOS::exec `"$INSTDIR\7zTemp\7z.exe" x "$INSTDIR\7zTemp\SourceTree-3.3.8-full.nupkg" "lib\net45" -o"$INSTDIR\7zTemp"` "" ""
ExecDOS::exec `xcopy "$INSTDIR\7zTemp\lib\net45" "$INSTDIR\App\SourceTree" /S /i` "" ""

; Cleanup
RMDir /r "$INSTDIR\7zTemp"

!macroend
