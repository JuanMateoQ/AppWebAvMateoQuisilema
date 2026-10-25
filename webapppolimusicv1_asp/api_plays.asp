<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/core.asp"-->
<%
'==========================================================
' API: incrementar reproducciones de una cancion
' POST api_plays.asp?id=N  -> { "plays": N }
'==========================================================
Response.ContentType = "application/json"

If UCase(Request.ServerVariables("REQUEST_METHOD")) <> "POST" Then
    Response.Status = "405 Method Not Allowed"
    Response.Write "{""error"":""Method not allowed""}"
    Response.End
End If

If Session("id_user") & "" = "" Then
    Response.Status = "401 Unauthorized"
    Response.Write "{""error"":""Not authenticated""}"
    Response.End
End If

Dim songId, c, rs, newPlays
songId = ToInt(Request.QueryString("id"))
If songId <= 0 Then
    Response.Status = "400 Bad Request"
    Response.Write "{""error"":""Invalid id""}"
    Response.End
End If

On Error Resume Next
Set c = NewCmd("UPDATE TBL_SONG SET PLAYS = ISNULL(PLAYS, 0) + 1 WHERE ID_SONG = ?")
PInt c, songId
c.Execute , , adExecuteNoRecords

If Err.Number <> 0 Then
    Err.Clear
    On Error GoTo 0
    Response.Status = "500 Internal Server Error"
    Response.Write "{""error"":""DB error""}"
    Response.End
End If
On Error GoTo 0

Set rs = QueryById("SELECT ISNULL(PLAYS, 0) AS PLAYS FROM TBL_SONG WHERE ID_SONG = ?", songId)
If rs.EOF Then
    rs.Close
    Response.Write "{""plays"":0}"
Else
    newPlays = rs("PLAYS")
    rs.Close
    Response.Write "{""plays"":" & newPlays & "}"
End If
DbClose
%>
