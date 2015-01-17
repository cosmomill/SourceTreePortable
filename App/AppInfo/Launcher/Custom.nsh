; This script will get the last part of a string after a specified character.
; Useful to get file extensions, last file name or last directory part.
 
Function GetAfterChar
  Exch $0 ; chop char
  Exch
  Exch $1 ; input string
  Push $2
  Push $3
  StrCpy $2 0
  loop:
    IntOp $2 $2 - 1
    StrCpy $3 $1 1 $2
    StrCmp $3 "" 0 +3
      StrCpy $0 ""
      Goto exit2
    StrCmp $3 $0 exit1
    Goto loop
  exit1:
    IntOp $2 $2 + 1
    StrCpy $0 $1 "" $2
  exit2:
    Pop $3
    Pop $2
    Pop $1
    Exch $0 ; output
FunctionEnd

!macro _getAfterCharConstructor OUT PATH SEPARATOR 
  Push "${PATH}"
  Push "${SEPARATOR}"
  Call GetAfterChar
  Pop "${OUT}"
!macroend

!define GetAfterChar '!insertmacro "_getAfterCharConstructor"'

; StrReplace
; Replaces all occurrences of a given needle within a haystack with another string
; Written by dandaman32
 
Var STR_REPLACE_VAR_0
Var STR_REPLACE_VAR_1
Var STR_REPLACE_VAR_2
Var STR_REPLACE_VAR_3
Var STR_REPLACE_VAR_4
Var STR_REPLACE_VAR_5
Var STR_REPLACE_VAR_6
Var STR_REPLACE_VAR_7
Var STR_REPLACE_VAR_8
 
Function StrReplace
  Exch $STR_REPLACE_VAR_2
  Exch 1
  Exch $STR_REPLACE_VAR_1
  Exch 2
  Exch $STR_REPLACE_VAR_0
    StrCpy $STR_REPLACE_VAR_3 -1
    StrLen $STR_REPLACE_VAR_4 $STR_REPLACE_VAR_1
    StrLen $STR_REPLACE_VAR_6 $STR_REPLACE_VAR_0
    loop:
      IntOp $STR_REPLACE_VAR_3 $STR_REPLACE_VAR_3 + 1
      StrCpy $STR_REPLACE_VAR_5 $STR_REPLACE_VAR_0 $STR_REPLACE_VAR_4 $STR_REPLACE_VAR_3
      StrCmp $STR_REPLACE_VAR_5 $STR_REPLACE_VAR_1 found
      StrCmp $STR_REPLACE_VAR_3 $STR_REPLACE_VAR_6 done
      Goto loop
    found:
      StrCpy $STR_REPLACE_VAR_5 $STR_REPLACE_VAR_0 $STR_REPLACE_VAR_3
      IntOp $STR_REPLACE_VAR_8 $STR_REPLACE_VAR_3 + $STR_REPLACE_VAR_4
      StrCpy $STR_REPLACE_VAR_7 $STR_REPLACE_VAR_0 "" $STR_REPLACE_VAR_8
      StrCpy $STR_REPLACE_VAR_0 $STR_REPLACE_VAR_5$STR_REPLACE_VAR_2$STR_REPLACE_VAR_7
      StrLen $STR_REPLACE_VAR_6 $STR_REPLACE_VAR_0
      Goto loop
    done:
  Pop $STR_REPLACE_VAR_1 ; Prevent "invalid opcode" errors and keep the
  Pop $STR_REPLACE_VAR_1 ; stack as it was before the function was called
  Exch $STR_REPLACE_VAR_0
FunctionEnd
 
!macro _strReplaceConstructor OUT NEEDLE NEEDLE2 HAYSTACK
  Push "${HAYSTACK}"
  Push "${NEEDLE}"
  Push "${NEEDLE2}"
  Call StrReplace
  Pop "${OUT}"
!macroend
 
!define StrReplace '!insertmacro "_strReplaceConstructor"'

Function BackupUserConfig
	;${DebugMsg} "SourceTree user config directory is $R8"
	WriteINIStr $EXEDIR\Data\settings\$AppIDSettings.ini $AppIDSettings LastUserConfigPath $R8
	
	; Check if LastUserConfigPath has changed
	StrCmp $LastUserConfigPath $R8 done
		error:
			; Restore backuped user config
			;${DebugMsg} "SourceTree Restore backuped user config $EXEDIR\Data\user.config"
			${If} ${FileExists} $EXEDIR\Data\user.config
				CopyFiles /SILENT $EXEDIR\Data\user.config $R8
			${EndIf}
		done:
			; Backup user config
			;${DebugMsg} "SourceTree Backup user config $R8\user.config"
			${If} ${FileExists} $R8\user.config
				CopyFiles /SILENT $R8\user.config $EXEDIR\Data
			${EndIf}
FunctionEnd

${SegmentFile}

Var LastLocalAppData
Var LastDocuments
Var LastUserConfigPath

${SegmentPre}	
	
ClearErrors

; Custom Code for using last LOCALAPPDATA in launcher.ini[Environment] - use %LastLocalAppData%  
ReadINIStr $LastLocalAppData $EXEDIR\Data\settings\$AppIDSettings.ini $AppIDSettings LastLocalAppData
StrCpy $0 $LastLocalAppData
${SetEnvironmentVariable} LastLocalAppData $0
${DebugMsg} "SourceTree LastLocalAppData is $LastLocalAppData"

; Custom Code for using last DOCUMENTS in launcher.ini[Environment] - use %LastDocuments%  
ReadINIStr $LastDocuments $EXEDIR\Data\settings\$AppIDSettings.ini $AppIDSettings LastDocuments
StrCpy $0 $LastDocuments
${SetEnvironmentVariable} LastDocuments $0
${DebugMsg} "SourceTree LastDocuments is $LastDocuments"

; Custom Code for using last LastUserConfigPath in launcher.ini[Environment] - use %LastUserConfigPath%  
ReadINIStr $LastUserConfigPath $EXEDIR\Data\settings\$AppIDSettings.ini $AppIDSettings LastUserConfigPath
StrCpy $0 $LastUserConfigPath
${SetEnvironmentVariable} LastUserConfigPath $0
${DebugMsg} "SourceTree LastUserConfigPath is $LastUserConfigPath"

; Custom Code for using last DOCUMENTS with double backslash in launcher.ini[Environment] - use %LastDocuments:DoubleBackslash%
${StrReplace} $0 '\' '??' $LastDocuments
${StrReplace} $1 '??' '\\' $0
${SetEnvironmentVariable} LastDocuments:DoubleBackslash $1
${DebugMsg} "SourceTree LastDocuments:DoubleBackslash is $1"

; Check if LastPortableAppsBaseDir has changed
StrCmp $EXEDIR $LastDrive$LastDirectory done
	error:
		${DebugMsg} "SourceTree LastPortableAppsBaseDir has changed."
		MessageBox MB_OK|MB_ICONSTOP "The path to the App directory which contains the portable app$\r$\nhas changed since last start up. To restore user settings,$\r$\nread and accept the license agreement, skip setup and restart$\r$\nSourceTree."
		${GetParent} $LastUserConfigPath $0 
		${GetAfterChar} $1 $0 "\"
		${DebugMsg} "SourceTree delete old user config directory $EXEDIR\Data\ClientFiles\$1"
		RMDir /r $EXEDIR\Data\ClientFiles\$1
	done:

!macroend

${SegmentPost}

${Locate} "$EXEDIR\Data\ClientFiles" "/L=F /M=user.config" "BackupUserConfig"
	
!macroend