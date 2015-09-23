SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
if not A_IsAdmin
{
   Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
   ExitApp
}
SettingsDir = %A_Appdata%\AHKSuite
SettingsFile = %A_Appdata%\AHKSuite\MacroSuiteSettings.ini ;no purpose except to make reading the code easier, stores the location of the settings .ini file. Change once here to change everywhere.
#InstallKeybdHook ;debugging tool for key presses


;IMPORTANT NOTE!!!!!!!
; ":=" DENOTES AN EXPRESSION. "=" IS A NON-EXPRESSION ASSIGNMENT
;FILENAMES CONTAIN ILLEGAL CHARACTERS IN AN EXPRESSION, SO TO ASSIGN A FILEPATH TO A VARIABLE, SUCH AS THIS, YOU MUST USE A NON-EXPRESSION ASSIGNMENT "="! Took me too long to figure that one out.
;-----------------------------------------------------------------------------------------------------------
;PERSISTENT VARIABLE INITIALIZATION
;Check if first run, and write variables to ini file for persistence.
IniRead, FirstRun, %SettingsFile%, Global, FirstRun, 1
if FirstRun = 1
	{
		IfNotExist, %SettingsDir%
			FileCreateDir %SettingsDir%
		;These variables are written to the ini file, and are PERSISTENT throughout runs.
		IniWrite, 0, %SettingsFile%, Global, FirstRun
		IniWrite, 940, %SettingsFile%, GuiPos, Guix ;sets the default x position of gui on first run
		IniWrite, 540, %SettingsFile%, GuiPos, Guiy ;sets the default y position of gui on first run
		IniWrite, Headset, %SettingsFile%, AudioStates, OutputState ;sets default output device to headset on first run
		
	}
IniRead, Guix, %SettingsFile%, GuiPos, Guix ;reads the saved x position of gui from ini file when script is started
IniRead, Guiy, %SettingsFile%, GuiPos, Guiy ;reads the saved y position of gui from ini file when script is started
IniRead, OutputState, %SettingsFile%, AudioStates, OutputState ;reads the last saved audio device from ini file.
;The following IniReads look for the hotkey settings in the .ini file. If the user has not changed the hotkeys, there will be nothing found in the .ini file; and the value will default to what is at the end of each IniRead.
IniRead, HelpGuiHotkey, %SettingsFile%, Hotkeys, HelpGuiHotkey, !F1
IniRead, GoogleSearchHotkey, %SettingsFile%, Hotkeys, GoogleSearchHotkey, ^b
IniRead, NvidiaSurroundHotkey, %SettingsFile%, Hotkeys, NvidiaSurroundHotkey, !Numpad2
IniRead, TeamSpeakHotkey, %SettingsFile%, Hotkeys, TeamSpeakHotkey, #t
IniRead, SteamLibraryHotkey, %SettingsFile%, Hotkeys, SteamLibraryHotkey, #s
IniRead, OpenDirHotkey, %SettingsFile%, Hotkeys, OpenDirHotkey, ^+a
IniRead, PandoraHotkey, %SettingsFile%, Hotkeys, PandoraHotkey, !p
IniRead, RedditHotkey, %SettingsFile%, Hotkeys, RedditHotkey, !r
IniRead, YouTubeHotkey, %SettingsFile%, Hotkeys, YouTubeHotkey, !y
IniRead, BorderlessFullscreenHotkey, %SettingsFile%, Hotkeys, BorderlessFullscreenHotkey, ^+f
IniRead, MonitorShutOffHotkey, %SettingsFile%, Hotkeys, MonitorShutOffHotkey, ^!F12
IniRead, WASDToggleHotkey, %SettingsFile%, Hotkeys, WASDToggleHotkey, !SC029 ;SC029 designiates the console key; it is not recognized easily by AHK and must be designated this way.
IniRead, ShowGuiHotkey, %SettingsFile%, Hotkeys, ShowGuiHotkey, ^CtrlBreak

;End Hotkey Setup
;-----------------------------------------------------------------------------------------------------------
;Hotkey Initialization
;Initializes hotkey's after they've been retrieved from the .ini file above.
Hotkey, %HelpGuiHotkey%, HelpGuiHotkey
Hotkey, %GoogleSearchHotkey%, GoogleSearchHotkey
Hotkey, %NvidiaSurroundHotkey%, NvidiaSurroundHotkey
Hotkey, %TeamSpeakHotkey%, TeamSpeakHotkey
Hotkey, %SteamLibraryHotkey%, SteamLibraryHotkey
Hotkey, %OpenDirHotkey%, OpenDirHotkey
Hotkey, %PandoraHotkey%, PandoraHotkey
Hotkey, %RedditHotkey%, RedditHotkey
Hotkey, %YouTubeHotkey%, YouTubeHotkey
Hotkey, %BorderlessFullscreenHotkey%, BorderlessFullscreenHotkey
Hotkey, %MonitorShutOffHotkey%, MonitorShutOffHotkey
Hotkey, %WASDToggleHotkey%, WASDToggleHotkey
Hotkey, %ShowGuiHotkey%, ShowGuiHotkey
;-----------------------------------------------------------------------------------------------------------
;GUI INITIALIZATION
;Gui 1 Initialization
;Gui 1 is the main control component.
gui, 1:-caption +toolwindow
;+alwaysontop
gui, 1:add, button, gToggleAll, Global On/Off ;adds the global toggle button
gui, 1:add, button, gWASDToggle x10, WASD Toggle ;adds the WASD toggle button
gui, 1:add, button, gAudioToggle x10, Audio Device ;adds the button for audio device toggling
gui, 1:add, button, gMonitorToggle x10 w130, Monitor Toggle
gui, 1:add, button, gShowHelpButton x10 w130, Show Hotkeys
gui, 1:add, text, c00f9ff x97 y10, ON ;adds global toggle ON indicator
gui, 1:add, text, cRed x97 y10, OFF ;adds global toggle OFF indicator
gui, 1:add, text, c00ff5f x97 y38, Normal ;adds indicator showing WASD keys are normal
gui, 1:add, text, c00ff5f x97 y38, Arrow Keys ;adds indicator showing WASD keys are ARROW keys
gui, 1:add, text, c00ff5f x97 y66, Speakers ;adds indicator showing audio device is the speakers
gui, 1:add, text, c00ff5f x97 y66, Headset ;adds indicator showing audio device is the headset
GuiControl, 1:hide, OFF ;hides the OFF indicator for global toggle, as it defaults to ON
GuiControl, 1:hide, Arrow Keys ;hides the Arrow Keys indicator for WASD Toggle, as default is normal.
GuiControl, 1:hide, Speakers ;hides the speakers indicator until AudioToggle subroutine is run
GuiControl, 1:hide, Headset ;hides the headset indicator until AudioToggle subroutine is run
gui, 1:color, 2b2b2b
gui, 1:show,x%Guix% y%Guiy% 
OnMessage(0x201, "WM_LBUTTONDOWN") ;this allows the gui to be moved when left-clicked anywhere on it. Without it, would not be able to move gui, as it has no boarders or titlebar.
;~~~~~~~~~~~~~~~~
;Gui 2 Initialization
;Gui 2 is the help component
gui, 2:add, text, , Alt + F1: Show/Hide help window!
gui, 2:add, text, , Ctrl + b: runs a google search on selection
gui, 2:add, text, , Alt + Num2: Toggles Nvidia Surround
gui, 2:add, text, , Win + t: Activates TeamSpeak
gui, 2:add, text, , Win + s: Toggles steam library
gui, 2:add, text, , Shift + Ctrl + a: opens AHK directory
gui, 2:add, text, , Alt + p: Opens browser tab to Pandora
gui, 2:add, text, , Alt + r: Opens browser tab to Reddit
gui, 2:add, text, , Alt + y: Opens browser tab to Youtube
gui, 2:add, text, , Alt + Ctrl + f: Makes active window a borderless window.
gui, 2:add, text, , Ctrl + Pause: Brings control panel to the front.
;gui, 2:color, 2b2b2b ;for now leave as deafault color. Otherwise text is hard to read.


;-----------------------------------------------------------------------------------------------------------
;AUDIO INITIALIZATION
;Initializes audio device indicator on gui and updates the local variable with that of the saved variable
GuiControl, 1:show, %OutputState%
;-----------------------------------------------------------------------------------------------------------
;NON-PERSISTENT VARIABLE INITIALIZATION 
;These variables are independent of first run, they reset when the script is restarted!
toggleGlobal := 1 ;ensures the default value of the global macro toggle is ON.
toggleWASD := 0 ;ensures the default value of the WASD toggle is normal WASD keys
;-----------------------------------------------------------------------------------------------------------
;return
;This return is needed to prevent the script from falling into the functions/labels below.
;The script will stop here and everything below this point will only be run if it's called or the hotkey is pressed.
;-----------------------------------------------------------------------------------------------------------
;FUNCTIONS/SUBROUTINES
;Defines all functions/sub-routines
WM_LBUTTONDOWN()
;Activates when Left-Mouse button is pressed down on main control GUI (gui 1)
{
	Global
	;Another tidbit of helpfullness to know in AHK. For a function to be able to access global variables, such as "SettingsFile," the word Global must be the first line in the function. This is not a problem with the labels I have below, because they aren't functions, they're just regular code that gets jumped to when called. 
	If A_Gui = 1
	{
		PostMessage, 0xA1, 2
		sleep 500 ;sleep is neccessary to prevent it from going to fast after post message. Not sure why, but with sleep here, the rest of this function isn't run until the dragging is over.
		Gui,1:+LastFound ;makes gui 1 the last found window
		WinGetPos,Guix,Guiy ;gets the position of the last found window (now gui 1)
		IniWrite, %Guiy%, %SettingsFile%, GuiPos, Guiy
		IniWrite, %Guix%, %SettingsFile%, GuiPos, Guix
	}
}
return
;~~~~~~~~~~~~~~~~
ToggleAll:
	;Msgbox,%toggleGlobal% ; debug message
	If toggleGlobal = 1
	{
		GuiControl,Hide,ON 
		GuiControl,Show,OFF ;changes the state of the indicator in the gui to show macros are OFF
	}
	Else if toggleGlobal = 0
	{
		GuiControl,Hide,OFF
		GuiControl,Show,ON ;changes the state of the indicator in the gui to show macros are ON
	}
	Else
	{
		msgbox, "Global Toggle just broke! Restart script!"
	}
	toggleGlobal := !toggleGlobal ;inverts the state of the global macro toggle.
return
;~~~~~~~~~~~~~~~~
WASDToggle:
	;msgbox before %toggleWASD% ;debug: shows toggleWASD status before subroutine is run.
	If toggleWASD = 1
	{
		;msgbox, "WASD" ;debug message
		GuiControl, hide, Arrow Keys
		GuiControl, Show, Normal ;updates gui indicator to show the WASD keys are normal
		Suspend, off ;turns off suspend, just in case it was left on during use.
	}
	Else if toggleWASD = 0
	{
		;msgbox, "Arrow Keys" ;debug message
		GuiControl, hide, Normal
		GuiControl, show, Arrow Keys ;updates gui indicator to show WASD keys are ARROW keys
	}
	Else
	{
		msgbox, "WASD Toggle broke, please restart script."
	}
	toggleWASD := !toggleWASD ;inverts the state of toggleWASD after the logic is run.
	;msgbox after %toggleWASD% ;debug: shows toggleWASD status after subroutine is run
return
;~~~~~~~~~~~~~~~~
AudioToggle:
	Run, mmsys.cpl 
	WinWait,Sound ; Change "Sound" to the name of the window in your local language 
	;msgbox %OutputState%
	if OutputState = Speakers
	{
	  ControlSend,SysListView321,{Down 1} ; This number selects the matching audio device in the list, change it accordingly 
	  OutputState := "Headset"
	  IniWrite, Headset, %SettingsFile%, AudioStates, OutputState
	  GuiControl, hide, Speakers
	  GuiControl, show, Headset
	  ;msgbox, "output changed to headset" ;debug message
	}
	Else if OutputState = Headset
	{
	  ControlSend,SysListView321,{Down 2} ; This number selects the matching audio device in the list, change it accordingly
	  OutputState := "Speakers"
	  IniWrite, Speakers, %SettingsFile%, AudioStates, OutputState
	  GuiControl, hide, Headset
	  GuiControl, show, Speakers
	  ;msgbox, "output changed to speakers" ;debug messaged
	}
	Else
		msgbox, "Your audio playback device list has unknown devices. Please disable them."
	ControlClick,&Set Default ; Change "&Set Default" to the name of the button in your local language 
	ControlClick,OK 
	WinClose,Sound ; Failsafe to ensure window closes
return
;~~~~~~~~~~~~~~~~
MonitorToggle:
	Gosub MonitorShutOffHotkey
return
;~~~~~~~~~~~~~~~~
ShowHelpButton:
	GoSub HelpGuiHotkey
return
;~~~~~~~~~~~~~~~~
RemapHotkeys:
;BEFORE THIS IS FINISHED, GET THE GUI SETUP FIRST.
msgbox RemapHotkeys Label Called. Quitting.
Exit
	Loop, 13 ;THIS NUMBER MUST BE THE NUMBER OF HOTKEYS IN THE SCRIPT
	{
		LoopCount := LoopCount + 1
		HotKeyNum := "HotKey"LoopCount
		;msgbox %HotKeyNum% ;debug message
		Gui submit
		IfInString, HotKey1, ^
		{
			CtrlModifier := "Ctrl +"
			NumOfModifiers := NumOfModifiers + 1
		}
		IfInString, HotKey1, !
		{
			AltModifier := "Alt +"
			NumOfModifiers := NumOfModifiers + 1
		}
		IfInString, HotKey1, +
		{
			ShiftModifier := "Shift +"
			NumOfModifiers := NumOfModifiers + 1
		}
		IfInString, HotKey1, #
		{
			WinModifier := "Windows +"
			NumOfModifiers := NumOfModifiers + 1
		}
		StringTrimLeft, HotKey1, HotKey1, NumOfModifiers
		msgbox, %CtrlModifier% %AltModifier% %ShiftModifier% %WinModifier% %HotKeyNum%
	}

return
;-----------------------------------------------------------------------------------------------------------
;Auto-Text Replace
;-----------------------------------------------------------------------------------------------------------
::brb::be right back
::btw::by the way
::&shrug::¯\_({U+30c4})_/¯
::&dshrug::¯\_({U+CA0}_{U+CA0})_/¯
::&suprise::( {U+361}° {U+35C}{U+296} {U+361}°)
::&fuckyou::{U+51F8}(-_-){U+51F8}
::&disappoint::{U+CA0}_{U+CA0}
::&smile::{U+30c4}
::&sopl::System.out.println(
;~~~~~~~~~~~~~~~~
; WASD to Arrow Keys
;----------------------------
#If (toggleWASD = 1 && toggleGlobal = 1) OR CoH = 1
	w::up
	s::down
	a::left
	d::right
	q::Numpad0
	SC029::Suspend
#If
;-----------------------------------------------------------------------------------------------------------
;Hotkey Labels
;-----------------------------------------------------------------------------------------------------------

HelpGuiHotkey:
	if not toggle
		gui, 2:show, Center
	if toggle
		gui, 2:hide
	toggle := !toggle
return
;~~~~~~~~~~~~~~~~
RemapHotkeyGui:
	gui, 3:show
;~~~~~~~~~~~~~~~~
;runs google search on selection
GoogleSearchHotkey: 
	If toggleGlobal = 0
		return
	Else
	{
	  { 
		 BlockInput, on 
		 prevClipboard = %clipboard% 
		 clipboard = 
		 Send, ^c 
		 BlockInput, off 
		 ClipWait, 2 
		 if ErrorLevel = 0 
		 { 
			searchQuery=%clipboard% 
			GoSub, GoogleSearch 
		 } 
		 clipboard = %prevClipboard% 
		 return 
	  } 

	  GoogleSearch: 
		 StringReplace, searchQuery, searchQuery, `r`n, %A_Space%, All 
		 Loop 
		 { 
			noExtraSpaces=1 
			StringLeft, leftMost, searchQuery, 1 
			IfInString, leftMost, %A_Space% 
			{ 
			   StringTrimLeft, searchQuery, searchQuery, 1 
			   noExtraSpaces=0 
			} 
			StringRight, rightMost, searchQuery, 1 
			IfInString, rightMost, %A_Space% 
			{ 
			   StringTrimRight, searchQuery, searchQuery, 1 
			   noExtraSpaces=0 
			} 
			If (noExtraSpaces=1) 
			   break 
		 } 
		 StringReplace, searchQuery, searchQuery, \, `%5C, All 
		 StringReplace, searchQuery, searchQuery, %A_Space%, +, All 
		 StringReplace, searchQuery, searchQuery, `%, `%25, All 
		 IfInString, searchQuery, . 
		 { 
			IfInString, searchQuery, + 
			   Run, %browser% http://www.google.com/search?hl=en&q=%searchQuery% 
			else 
			   Run, %browser% %searchQuery% 
		 } 
		 else 
			Run, %browser% http://www.google.com/search?hl=en&q=%searchQuery% 
	return
	}
;~~~~~~~~~~~~~~~~
;toggles nvidia surround
NvidiaSurroundHotkey:
	If toggleGlobal = 0
		return
	Else
	{
		Run, "C:\Users\Patrick\Documents\AutoHotKey Scripts\Nvidia Surround Toggle v7.exe"
	}
  Return
;~~~~~~~~~~~~~~~~
;toggles teamspeak
TeamSpeakHotkey:
	If toggleGlobal = 0
		return
	Else
	{
		IfWinExist, TeamSpeak 3
		{
		  IfWinActive
			WinMinimize, TeamSpeak 3
		  Else
			WinActivate, TeamSpeak 3
		}
		Else
		{
		  Run "C:\Program Files\TeamSpeak 3 Client\ts3client_win64.exe"
		  Winwait, TeamSpeak 3
		  WinActivate TeamSpeak 3
		}
	}
  return
;~~~~~~~~~~~~~~~~
;toggles steam library
SteamLibraryHotkey:
	If toggleGlobal = 0
		return
	Else
	{
	  IfWinExist,Steam 
	  {
		IfWinActive,Steam
		{
		  WinMinimize, Steam
		  return
		}
		Else
		{
		  WinActivate
		  MouseGetPos,Mx,My
		  CoordMode,Mouse,Relative
		  MouseClick,L,152,19,1,0
		  MouseMove,%Mx%,%My%,0
		  return
		}
	  }
	  Else 
	  {
		Run,"C:\Program Files (x86)\Steam\Steam.exe"
		WinWait,Steam
		MouseGetPos,Mx,My
		CoordMode,Mouse,Relative
		MouseClick,L,212,50,1,0
		MouseMove,%Mx%,%My%,0
		return
	  }
	}
return
;~~~~~~~~~~~~~~~~
OpenDirHotkey:
	If toggleGlobal = 0
		return
	Else
	{
	  IfWinExist,AutoHotKey Scripts
		WinActivate,AutoHotKey Scripts
	  Else
		Run,C:\Users\Patrick\My Documents\AutoHotKey Scripts
	}
return
;~~~~~~~~~~~~~~~~
;Opens waterfox tab to Pandora
PandoraHotkey:
	If toggleGlobal = 0
		return
	Else
	{
		Run, http://www.pandora.com/
	}
return
;~~~~~~~~~~~~~~~~
;Opens a waterfox tab to Reddit (PCMR)
RedditHotkey:
	If toggleGlobal = 0
		return
	Else
	{
		Run, http://www.reddit.com/r/pcmasterrace
	}
return
;~~~~~~~~~~~~~~~~
;Opens a waterfox tab to Youtube Sub page
YouTubeHotkey:
	If toggleGlobal = 0
		return
	Else
	{
		Run, https://www.youtube.com/feed/subscriptions
	}
return
;~~~~~~~~~~~~~~~~
;Makes active window a borderless window
BorderlessFullscreenHotkey:
	WinSet, Style, -0xC40000, A ;0xC40000 is the code for the titlebar/border around a window. The - in-front tells AHK to remove that styling (make the window borderless) The A means to apply this to the currently active window.
	WinMove, A, , 0, 0, 1920, 1080 ;moves the (A)ctive window to strech from 0,0 to 1920,1080
	;IF YOU HAVE A DIFFERENT RESOLUTION MONITOR, YOU MUST CHANGE THE LAST TWO NUMBERS TO MATCH!
return ;this return just means the end of the code, and allows the hotkey to be used as many times as you like as long as the macro is running. In other words, the macro won't close after the first use.
;~~~~~~~~~~~~~~~~
;Monitor Shut-off and Computer-Lock toggle
;AHK Documentation says blockinput should temp disable itself when an alt-key combo is pressed.
;It is not disabling itself, so Ctrl+alt+delete must be used instead.
MonitorShutOffHotkey:
	BlockInput, On ;prevents monitor from being turned on accidentally
	sleep 5000
	SendMessage 0x112, 0xF170, 2, , Program Manager ;turns off monitor
return
;~~~~~~~~~~~~~~~~
;Toggle WASD toggle with a hotkey. Achieves the same function as the button in the control gui but with a hotkey. Both are there for user convenience (some games may not minimize well to get to the control gui).
WASDToggleHotkey:
	Suspend, Permit
	Gosub, WASDToggle
return
;-----------------------------------------------------------------------------------------------------------
ShowGuiHotkey:
	gui, 1:+lastfound
	WinActivate
return
	