Option Explicit

Const adInteger = 3
Const adParamInput = 1
Const adVarChar = 200


Dim db
Set db = CreateObject("ADODB.Connection")
db.Open "DSN=sqlbackup;CHARSET=latin1"

Dim add_log
Set add_log = CreateObject("ADODB.Command")
With add_log
	Set .ActiveConnection = db
	.Prepared = True
	.CommandText = "INSERT INTO log(cmd, err, errorlevel) VALUES (?, ?, ?)"
	.Parameters.Append .CreateParameter("cmd", adVarChar, adParamInput, 65535)
	.Parameters.Append .CreateParameter("err", adVarChar, adParamInput, 255)
	.Parameters.Append .CreateParameter("errorlevel", adInteger, adParamInput, 4)
End With

Dim rs
Set rs = db.Execute("SELECT * FROM batch")
Dim wsh
Set wsh = CreateObject("WScript.Shell")
While Not rs.EOF
	Dim cmd
	cmd = rs(0).Value
	WScript.Echo cmd
	Dim proc
	Set proc = wsh.Exec("cmd /c " & cmd)
	While proc.Status = 0
		WScript.Sleep 100 'ms
	Wend
	If proc.ExitCode = 0 Then
		add_log("err") = Null
	Else
		add_log("err") = proc.StdErr.ReadAll()
		WScript.Echo ">", add_log("err")
	End If
	add_log("cmd") = cmd
	add_log("errorlevel") = proc.ExitCode
	add_log.Execute
	rs.MoveNext
Wend
