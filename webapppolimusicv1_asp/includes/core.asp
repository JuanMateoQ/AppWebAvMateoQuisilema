<%
'==========================================================
' PoliMusic - Core include (VBScript / ASP Clasico)
' Conexion a BDD, helpers de consultas parametrizadas,
' autenticacion, sesion, mensajes flash y recursos.
'==========================================================
Response.CodePage = 65001
Response.CharSet = "utf-8"
Response.Buffer = True
Response.Expires = -1
Response.AddHeader "Cache-Control", "no-cache, no-store, must-revalidate"

' ---------- Configuracion de base de datos (ver BDD_PoliMusic.sql) ----------
Const DB_SERVER = "localhost"
Const DB_NAME = "BDD_PoliMusic"
Const DB_USER = "usr_polimusic"
Const DB_PASS = "Politecnica1"

' ---------- Recursos ----------
Const RES_ROOT = "SongFilesAndImages_resources/"
Const DEFAULT_SONG_URL = "SongFilesAndImages_resources/SongFiles/bensound-adventure.mp3"
Const DEFAULT_USER_IMG = "SongFilesAndImages_resources/UserImages/default.jpg"
Const DEFAULT_PLAYLIST_IMG = "SongFilesAndImages_resources/PlaylistImages/default.jpg"

' ---------- Constantes ADO ----------
Const adInteger = 3
Const adVarChar = 200
Const adParamInput = 1
Const adCmdText = 1
Const adExecuteNoRecords = 128

Dim gConn, gConnOpen, gFso, gExistsCache
gConnOpen = False
Set gFso = Server.CreateObject("Scripting.FileSystemObject")
Set gExistsCache = Server.CreateObject("Scripting.Dictionary")
gExistsCache.CompareMode = 1

'==========================================================
' Conexion
'==========================================================
Sub DbOpen()
    Dim errMsg
    If gConnOpen Then Exit Sub
    On Error Resume Next

    ' Intento 1: SQLOLEDB nativo (optimo y ligero para ASP clasico)
    Set gConn = Server.CreateObject("ADODB.Connection")
    gConn.ConnectionTimeout = 10
    gConn.CommandTimeout = 30
    gConn.Open "Provider=SQLOLEDB;Data Source=" & DB_SERVER & ";Initial Catalog=" & DB_NAME & _
               ";User ID=" & DB_USER & ";Password=" & DB_PASS & ";"

    If Err.Number <> 0 Then
        Err.Clear
        ' Intento 2: MSOLEDBSQL (driver moderno para SQL Server 2025)
        Set gConn = Server.CreateObject("ADODB.Connection")
        gConn.ConnectionTimeout = 10
        gConn.CommandTimeout = 30
        gConn.Open "Provider=MSOLEDBSQL;Data Source=" & DB_SERVER & ";Initial Catalog=" & DB_NAME & _
                   ";User ID=" & DB_USER & ";Password=" & DB_PASS & ";DataTypeCompatibility=80;Use Encryption for Data=False;"
    End If

    If Err.Number <> 0 Then
        errMsg = Err.Description
        Err.Clear
        On Error GoTo 0
        Response.Clear
        Response.Write "<!DOCTYPE html><html><head><meta charset=""utf-8""><title>PoliMusic - Error de Base de Datos</title></head>" & _
            "<body style=""font-family:sans-serif;background:#120e1a;color:#f5f1ff;padding:40px"">" & _
            "<h1 style=""color:#c8b6ff"">No se pudo conectar a la base de datos</h1>" & _
            "<p>Detalle: " & Server.HTMLEncode(errMsg) & "</p>" & _
            "<p>Servidor: <code>" & Server.HTMLEncode(DB_SERVER) & "</code> | BDD: <code>" & Server.HTMLEncode(DB_NAME) & "</code></p></body></html>"
        Response.End
    End If
    On Error GoTo 0
    gConnOpen = True
End Sub

Sub DbClose()
    On Error Resume Next
    If gConnOpen Then
        If Not gConn Is Nothing Then
            If gConn.State <> 0 Then gConn.Close
            Set gConn = Nothing
        End If
        gConnOpen = False
    End If
    On Error GoTo 0
End Sub

'==========================================================
' Comandos parametrizados (evita inyeccion SQL)
'==========================================================
Function NewCmd(sql)
    Dim c
    DbOpen
    Set c = Server.CreateObject("ADODB.Command")
    Set c.ActiveConnection = gConn
    c.CommandText = sql
    c.CommandType = adCmdText
    Set NewCmd = c
End Function

Sub PInt(c, v)
    If IsNull(v) Then
        c.Parameters.Append c.CreateParameter("p" & c.Parameters.Count, adInteger, adParamInput, 4, Null)
    ElseIf Trim(v & "") = "" Then
        c.Parameters.Append c.CreateParameter("p" & c.Parameters.Count, adInteger, adParamInput, 4, Null)
    Else
        c.Parameters.Append c.CreateParameter("p" & c.Parameters.Count, adInteger, adParamInput, 4, CLng(v))
    End If
End Sub

Sub PStr(c, v, size)
    Dim s
    s = ""
    If Not IsNull(v) Then s = CStr(v & "")
    If Len(s) > size Then s = Left(s, size)
    c.Parameters.Append c.CreateParameter("p" & c.Parameters.Count, adVarChar, adParamInput, size, s)
End Sub

' Cadena que se guarda como NULL si viene vacia
Sub PStrN(c, v, size)
    Dim s
    s = ""
    If Not IsNull(v) Then s = Trim(CStr(v & ""))
    If s = "" Then
        c.Parameters.Append c.CreateParameter("p" & c.Parameters.Count, adVarChar, adParamInput, size, Null)
    Else
        If Len(s) > size Then s = Left(s, size)
        c.Parameters.Append c.CreateParameter("p" & c.Parameters.Count, adVarChar, adParamInput, size, s)
    End If
End Sub

Sub ExecNoRecords(c)
    c.Execute , , adExecuteNoRecords
End Sub

' Consulta simple sin parametros -> Recordset
Function QuerySql(sql)
    Set QuerySql = NewCmd(sql).Execute
End Function

' Consulta con un solo parametro entero -> Recordset
Function QueryById(sql, id)
    Dim c
    Set c = NewCmd(sql)
    PInt c, id
    Set QueryById = c.Execute
End Function

' Ejecuta varias sentencias (cada una con un unico parametro entero) en transaccion.
' Devuelve "" si todo fue bien, o el mensaje de error.
Function RunTx(sqls, id)
    Dim i, c, msg
    msg = ""
    DbOpen
    On Error Resume Next
    gConn.BeginTrans
    For i = 0 To UBound(sqls)
        Set c = NewCmd(sqls(i))
        PInt c, id
        c.Execute , , adExecuteNoRecords
        If Err.Number <> 0 Then
            msg = Err.Description
            Exit For
        End If
    Next
    If msg = "" Then
        gConn.CommitTrans
    Else
        gConn.RollbackTrans
    End If
    If Err.Number <> 0 And msg = "" Then msg = Err.Description
    Err.Clear
    On Error GoTo 0
    RunTx = msg
End Function

' Reemplaza las relaciones N:M de una tabla puente (usar dentro de transaccion)
Sub SyncLinks(tableName, fixedCol, fixedId, otherCol, csv)
    Dim c, arr, i, v, seen
    Set c = NewCmd("DELETE FROM " & tableName & " WHERE " & fixedCol & " = ?")
    PInt c, fixedId
    c.Execute , , adExecuteNoRecords
    Set seen = Server.CreateObject("Scripting.Dictionary")
    arr = Split(csv & "", ",")
    For i = 0 To UBound(arr)
        v = Trim(arr(i))
        If v <> "" And IsNumeric(v) Then
            If Not seen.Exists(v) Then
                seen.Add v, True
                Set c = NewCmd("INSERT INTO " & tableName & " (" & fixedCol & ", " & otherCol & ") VALUES (?, ?)")
                PInt c, fixedId
                PInt c, CLng(v)
                c.Execute , , adExecuteNoRecords
            End If
        End If
    Next
End Sub

' Devuelve un Dictionary con los ids relacionados (para marcar checkboxes)
Function LinkedIds(sql, id)
    Dim d, rs
    Set d = Server.CreateObject("Scripting.Dictionary")
    If id > 0 Then
        Set rs = QueryById(sql, id)
        Do Until rs.EOF
            d(CStr(rs(0))) = True
            rs.MoveNext
        Loop
        rs.Close
    End If
    Set LinkedIds = d
End Function

'==========================================================
' Helpers generales
'==========================================================
Function H(v)
    If IsNull(v) Then
        H = ""
    Else
        H = Server.HTMLEncode(CStr(v & ""))
    End If
End Function

Function Nz(v, d)
    If IsNull(v) Then
        Nz = d
    ElseIf Trim(v & "") = "" Then
        Nz = d
    Else
        Nz = v
    End If
End Function

Function ToInt(ByVal v)
    ToInt = 0
    If IsNull(v) Then Exit Function
    v = Trim(v & "")
    If v = "" Then Exit Function
    If Not IsNumeric(v) Then Exit Function
    If CDbl(v) > 2147483647 Or CDbl(v) < -2147483647 Then Exit Function
    ToInt = CLng(Fix(CDbl(v)))
End Function

Function QInt(name)
    QInt = ToInt(Request.QueryString(name))
End Function

Function FInt(name)
    FInt = ToInt(Request.Form(name))
End Function

Function FStr(name)
    FStr = Trim(Request.Form(name) & "")
End Function

Function IsPost()
    IsPost = (UCase(Request.ServerVariables("REQUEST_METHOD")) = "POST")
End Function

Function Initials(a, b)
    Dim s
    s = ""
    If Trim(a & "") <> "" Then s = s & UCase(Left(Trim(a & ""), 1))
    If Trim(b & "") <> "" Then s = s & UCase(Left(Trim(b & ""), 1))
    If s = "" Then s = "?"
    Initials = s
End Function

Function PastelGradient(seed)
    Dim hue
    hue = (ToInt(seed) * 57 + 260) Mod 360
    PastelGradient = "background:linear-gradient(135deg,hsl(" & hue & ",85%,86%),hsl(" & ((hue + 45) Mod 360) & ",70%,72%));"
End Function

Function Ico(name, cls)
    Ico = "<svg class=""icon " & cls & """ aria-hidden=""true""><use href=""#i-" & name & """></use></svg>"
End Function

Function NewToken()
    Dim i, s, chars
    chars = "abcdef0123456789"
    Randomize
    s = ""
    For i = 1 To 40
        s = s & Mid(chars, Int(Rnd * 16) + 1, 1)
    Next
    NewToken = s
End Function

'==========================================================
' Sesion / Autenticacion
'==========================================================
Function IsLogged()
    IsLogged = (Session("id_user") & "" <> "")
End Function

Function IsAdmin()
    IsAdmin = (Session("user_type") & "" = "1")
End Function

Sub RequireLogin()
    If Not IsLogged() Then
        Response.Redirect "login.asp"
    End If
    If Session("csrf") & "" = "" Then Session("csrf") = NewToken()
End Sub

Sub RequireAdmin()
    RequireLogin
    If Not IsAdmin() Then
        SetFlash "error", "Acceso restringido: solo los administradores pueden ingresar a esa seccion."
        Response.Redirect "default.asp"
    End If
End Sub

Function CsrfField()
    CsrfField = "<input type=""hidden"" name=""csrf"" value=""" & H(Session("csrf")) & """>"
End Function

Function CsrfOk()
    CsrfOk = (Session("csrf") & "" <> "" And Request.Form("csrf") & "" = Session("csrf") & "")
End Function

Sub SetFlash(kind, msg)
    Session("flash_type") = kind
    Session("flash_msg") = msg
End Sub

Sub RenderFlash()
    Dim k, m
    k = Session("flash_type") & ""
    m = Session("flash_msg") & ""
    If m <> "" Then
        If k <> "success" Then k = "error"
        Response.Write "<div class=""flash " & k & """ role=""alert"">"
        If k = "success" Then
            Response.Write Ico("check", "")
        Else
            Response.Write Ico("error", "")
        End If
        Response.Write "<span>" & H(m) & "</span><button type=""button"" class=""close"" data-dismiss aria-label=""Cerrar"">" & Ico("close", "icon-sm") & "</button></div>"
        Session.Contents.Remove "flash_type"
        Session.Contents.Remove "flash_msg"
    End If
End Sub

'==========================================================
' Recursos (rutas "~/carpeta/archivo" guardadas en la BDD)
'==========================================================
Function MapFolder(key)
    Select Case LCase(key)
        Case "songfiles": MapFolder = "SongFiles"
        Case "userimages": MapFolder = "UserImages"
        Case "playlistimages": MapFolder = "PlaylistImages"
        Case "albumimages": MapFolder = "AlbumImages"
        Case "artistimages": MapFolder = "ArtistImages"
        Case Else: MapFolder = key
    End Select
End Function

' "~/songFiles/x.mp3" -> "SongFilesAndImages_resources/SongFiles/x.mp3"
Function AssetUrl(dbPath)
    Dim p, pos
    p = Trim(dbPath & "")
    p = Replace(p, "\", "/")
    If p = "" Then
        AssetUrl = ""
        Exit Function
    End If
    If LCase(Left(p, 4)) = "http" Then
        AssetUrl = p
        Exit Function
    End If
    If Left(p, 2) = "~/" Then p = Mid(p, 3)
    If Left(p, 1) = "/" Then p = Mid(p, 2)
    If LCase(Left(p, Len(RES_ROOT))) <> LCase(RES_ROOT) Then
        pos = InStr(p, "/")
        If pos > 0 Then
            p = RES_ROOT & MapFolder(Left(p, pos - 1)) & Mid(p, pos)
        End If
    End If
    AssetUrl = Replace(p, " ", "%20")
End Function

Function AssetExists(url)
    Dim ok
    ok = False
    If url = "" Or LCase(Left(url, 4)) = "http" Then
        AssetExists = (url <> "")
        Exit Function
    End If
    If gExistsCache.Exists(url) Then
        AssetExists = gExistsCache(url)
        Exit Function
    End If
    On Error Resume Next
    ok = gFso.FileExists(Server.MapPath(Replace(url, "%20", " ")))
    If Err.Number <> 0 Then
        ok = False
        Err.Clear
    End If
    On Error GoTo 0
    gExistsCache(url) = ok
    AssetExists = ok
End Function

' URL reproducible de una cancion (si el mp3 no existe se usa el mp3 de los assets)
Function SongUrl(dbPath)
    Dim u
    u = AssetUrl(dbPath)
    If AssetExists(u) Then
        SongUrl = u
    Else
        SongUrl = DEFAULT_SONG_URL
    End If
End Function

Function SongFileExists(dbPath)
    SongFileExists = AssetExists(AssetUrl(dbPath))
End Function

' Portada de album: si la imagen no existe se usa una de PlaylistImages
Function AlbumImg(dbPath, seed)
    Dim u, n
    u = AssetUrl(dbPath)
    If AssetExists(u) Then
        AlbumImg = u
    Else
        n = (ToInt(seed) Mod 5)
        If n <= 0 Then n = n + 5
        AlbumImg = RES_ROOT & "PlaylistImages/playlist" & n & ".png"
    End If
End Function

Function PlaylistImg(dbPath)
    Dim u
    u = AssetUrl(dbPath)
    If AssetExists(u) Then
        PlaylistImg = u
    Else
        PlaylistImg = DEFAULT_PLAYLIST_IMG
    End If
End Function

Function UserImg(dbPath)
    Dim u
    u = AssetUrl(dbPath)
    If AssetExists(u) Then
        UserImg = u
    Else
        UserImg = DEFAULT_USER_IMG
    End If
End Function

' HTML del avatar del artista (imagen o iniciales con degradado pastel)
Function ArtistAvatar(id, nm, ln, dbPath, extraCls)
    Dim u
    u = AssetUrl(dbPath)
    If AssetExists(u) Then
        ArtistAvatar = "<img src=""" & H(u) & """ alt=""" & H(Trim(nm & " " & ln)) & """ loading=""lazy"">"
    Else
        ArtistAvatar = "<div class=""avatar-initials " & extraCls & """ style=""" & PastelGradient(id) & """>" & H(Initials(nm, ln)) & "</div>"
    End If
End Function

' Lista los archivos de una carpeta de recursos con las extensiones indicadas ("mp3" o "png,jpg")
Function ListResourceFiles(folderName, exts)
    Dim result, fld, f, ext, path
    result = ""
    On Error Resume Next
    path = Server.MapPath(RES_ROOT & folderName)
    If gFso.FolderExists(path) Then
        Set fld = gFso.GetFolder(path)
        For Each f In fld.Files
            ext = LCase(gFso.GetExtensionName(f.Name))
            If InStr("," & exts & ",", "," & ext & ",") > 0 Then
                If result <> "" Then result = result & "|"
                result = result & f.Name
            End If
        Next
    End If
    Err.Clear
    On Error GoTo 0
    If result = "" Then
        ListResourceFiles = Array()
    Else
        ListResourceFiles = Split(result, "|")
    End If
End Function
%>
