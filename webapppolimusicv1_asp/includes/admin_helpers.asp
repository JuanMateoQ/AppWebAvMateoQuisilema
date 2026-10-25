<%
'==========================================================
' Helpers para las pantallas de administracion (CRUD)
'==========================================================

' Convierte "1, 3, 5" en Dictionary {"1":True,...}
Function CsvToDict(csv)
    Dim d, arr, i, v
    Set d = Server.CreateObject("Scripting.Dictionary")
    arr = Split(csv & "", ",")
    For i = 0 To UBound(arr)
        v = Trim(arr(i))
        If v <> "" And IsNumeric(v) Then d(CStr(CLng(v))) = True
    Next
    Set CsvToDict = d
End Function

' Checkboxes estilo "chip" a partir de una consulta (col 0 = id, col 1 = etiqueta)
Sub RenderChips(sql, fieldName, selected)
    Dim rs, idv
    Set rs = QuerySql(sql)
    If rs.EOF Then
        Response.Write "<p class=""hint"">No hay registros disponibles.</p>"
    Else
        Response.Write "<div class=""chips"">"
        Do Until rs.EOF
            idv = CStr(rs(0))
            Response.Write "<label class=""chip""><input type=""checkbox"" name=""" & fieldName & """ value=""" & idv & """"
            If selected.Exists(idv) Then Response.Write " checked"
            Response.Write "><span>" & H(rs(1)) & "</span></label>"
            rs.MoveNext
        Loop
        Response.Write "</div>"
    End If
    rs.Close
End Sub

' Select de archivos existentes en SongFilesAndImages_resources.
' kind = "audio" | "image". El valor se guarda con el formato de la BDD: "~/carpeta/archivo"
Sub RenderAssetSelect(fieldName, current, kind, allowEmpty)
    Dim folders, keys, exts, i, j, files, val, cur, found, opts, sel
    cur = Trim(current & "")
    found = False
    opts = ""
    If kind = "audio" Then
        folders = Array("SongFiles")
        keys = Array("songFiles")
        exts = "mp3,wav,ogg"
    Else
        folders = Array("PlaylistImages", "UserImages", "AlbumImages", "ArtistImages")
        keys = Array("playlistImages", "userImages", "albumImages", "ArtistImages")
        exts = "png,jpg,jpeg,gif,webp"
    End If

    For i = 0 To UBound(folders)
        files = ListResourceFiles(folders(i), exts)
        If UBound(files) >= 0 Then
            opts = opts & "<optgroup label=""" & H(folders(i)) & """>"
            For j = 0 To UBound(files)
                val = "~/" & keys(i) & "/" & files(j)
                sel = ""
                If LCase(val) = LCase(cur) Or LCase(AssetUrl(val)) = LCase(AssetUrl(cur)) Then
                    If Not found Then
                        sel = " selected"
                        found = True
                    End If
                End If
                opts = opts & "<option value=""" & H(val) & """ data-url=""" & H(AssetUrl(val)) & """" & sel & ">" & H(files(j)) & "</option>"
            Next
            opts = opts & "</optgroup>"
        End If
    Next

    Response.Write "<select class=""input"" id=""" & fieldName & """ name=""" & fieldName & """ data-preview=""" & kind & """>"
    If allowEmpty Then
        Response.Write "<option value="""" data-url="""""
        If cur = "" Then Response.Write " selected"
        Response.Write ">&mdash; Sin imagen (portada autom&aacute;tica) &mdash;</option>"
    End If
    If cur <> "" And Not found Then
        Response.Write "<option value=""" & H(cur) & """ data-url=""" & H(AssetUrl(cur)) & """ selected>" & H(cur) & " (archivo no encontrado)</option>"
    End If
    Response.Write opts
    Response.Write "</select>"
End Sub
%>
