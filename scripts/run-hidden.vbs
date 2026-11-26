' Runs a console program with no window and waits for it to exit.
'
' Task Scheduler cannot hide the console of a task that runs only while the
' user is logged on, so the collector is started from Windows Script Host
' instead: WSH is a GUI process and the child inherits a hidden window from
' it. Run's third argument blocks until the child exits, so Task Scheduler
' still sees one long-running process and its MultipleInstances and restart
' settings behave as they would when running node.exe directly.
'
' Usage: wscript.exe run-hidden.vbs <executable> [argument ...]

Dim index, command
command = ""
For index = 0 To WScript.Arguments.Count - 1
    command = command & """" & WScript.Arguments(index) & """" & " "
Next

If Len(command) = 0 Then
    WScript.Quit 1
End If

WScript.Quit CreateObject("WScript.Shell").Run(Trim(command), 0, True)
