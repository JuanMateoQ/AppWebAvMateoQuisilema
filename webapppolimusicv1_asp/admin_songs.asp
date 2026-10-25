<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/core.asp"-->
<!--#include file="includes/admin_helpers.asp"-->
<%
'==========================================================
' CRUD de Canciones (TBL_SONG + TBL_PLAYER + TBL_TRACKLIST)
'==========================================================
RequireAdmin
Dim pageTitle, navKey, pageDesc
pageTitle = "Administrar canciones"
navKey = "admin_songs"

Dim action, op, editId, fName, fPath, fPlays, fArtists, fAlbums, errMsg, rs, selArtists, selAlbums, delMsg

Function SaveSong(ByRef id, nm, pth, plays, arts, albs)
    Dim c, rsN, msg
    msg = ""
    DbOpen
    On Error Resume Next
    gConn.BeginTrans
    If id > 0 Then
        Set c = NewCmd("UPDATE TBL_SONG SET SONG_NAME = ?, SONG_PATH = ?, PLAYS = ? WHERE ID_SONG = ?")
        PStr c, nm, 50
        PStr c, pth, 255
        PInt c, plays
        PInt c, id
        c.Execute , , adExecuteNoRecords
    Else
        Set c = NewCmd("INSERT INTO TBL_SONG (SONG_NAME, SONG_PATH, PLAYS) OUTPUT INSERTED.ID_SONG VALUES (?, ?, ?)")
        PStr c, nm, 50
        PStr c, pth, 255
        PInt c, plays
        Set rsN = c.Execute
        If Err.Number = 0 Then
            If Not rsN.EOF Then id = CLng(rsN(0))
            rsN.Close
        End If
    End If
    If Err.Number = 0 Then SyncLinks "TBL_PLAYER", "ID_SONG", id, "ID_ARTIST", arts
    If Err.Number = 0 Then SyncLinks "TBL_TRACKLIST", "ID_SONG", id, "ID_ALBUM", albs
    If Err.Number <> 0 Then
        msg = Err.Description
        Err.Clear
        gConn.RollbackTrans
    Else
        gConn.CommitTrans
        If Err.Number <> 0 Then msg = Err.Description
    End If
    Err.Clear
    On Error GoTo 0
    SaveSong = msg
End Function

action = LCase(Request.QueryString("action") & "")
errMsg = ""
editId = 0
fName = "" : fPath = "" : fPlays = 0 : fArtists = "" : fAlbums = ""

If IsPost() Then
    If Not CsrfOk() Then
        SetFlash "error", "La sesion del formulario expiro. Intenta nuevamente."
        Response.Redirect "admin_songs.asp"
    End If
    op = FStr("op")
    If op = "delete" Then
        editId = FInt("id")
        delMsg = RunTx(Array("DELETE FROM TBL_PLAYLIST_SONG WHERE ID_SONG = ?", _
                             "DELETE FROM TBL_PLAYER WHERE ID_SONG = ?", _
                             "DELETE FROM TBL_TRACKLIST WHERE ID_SONG = ?", _
                             "DELETE FROM TBL_SONG WHERE ID_SONG = ?"), editId)
        If delMsg = "" Then
            SetFlash "success", "Cancion eliminada correctamente."
        Else
            SetFlash "error", "No se pudo eliminar la cancion: " & delMsg
        End If
        Response.Redirect "admin_songs.asp"
    ElseIf op = "save" Then
        editId = FInt("id")
        fName = FStr("song_name")
        fPath = FStr("song_path")
        fPlays = FInt("plays")
        fArtists = Request.Form("artists") & ""
        fAlbums = Request.Form("albums") & ""
        If fName = "" Then
            errMsg = "El nombre de la cancion es obligatorio."
        ElseIf Len(fName) > 50 Then
            errMsg = "El nombre de la cancion no puede superar 50 caracteres."
        ElseIf fPath = "" Then
            errMsg = "Debes seleccionar el archivo de audio."
        ElseIf Len(fPath) > 255 Then
            errMsg = "La ruta del archivo no puede superar 255 caracteres."
        ElseIf fPlays < 0 Then
            errMsg = "Las reproducciones no pueden ser negativas."
        End If
        If errMsg = "" Then
            If editId > 0 Then
                errMsg = SaveSong(editId, fName, fPath, fPlays, fArtists, fAlbums)
                If errMsg = "" Then SetFlash "success", "Cancion """ & fName & """ actualizada correctamente."
            Else
                errMsg = SaveSong(editId, fName, fPath, fPlays, fArtists, fAlbums)
                If errMsg = "" Then SetFlash "success", "Cancion """ & fName & """ creada correctamente."
            End If
            If errMsg = "" Then Response.Redirect "admin_songs.asp"
        End If
        If editId > 0 Then
            action = "edit"
        Else
            action = "new"
        End If
        Set selArtists = CsvToDict(fArtists)
        Set selAlbums = CsvToDict(fAlbums)
    End If
ElseIf action = "edit" Then
    editId = QInt("id")
    Set rs = QueryById("SELECT ID_SONG, SONG_NAME, SONG_PATH, ISNULL(PLAYS, 0) AS PLAYS FROM TBL_SONG WHERE ID_SONG = ?", editId)
    If rs.EOF Then
        rs.Close
        SetFlash "error", "La cancion solicitada no existe."
        Response.Redirect "admin_songs.asp"
    End If
    fName = rs("SONG_NAME") & ""
    fPath = rs("SONG_PATH") & ""
    fPlays = rs("PLAYS")
    rs.Close
    Set selArtists = LinkedIds("SELECT ID_ARTIST FROM TBL_PLAYER WHERE ID_SONG = ?", editId)
    Set selAlbums = LinkedIds("SELECT ID_ALBUM FROM TBL_TRACKLIST WHERE ID_SONG = ?", editId)
ElseIf action = "new" Then
    Set selArtists = CsvToDict("")
    Set selAlbums = CsvToDict("")
End If
If action <> "new" And action <> "edit" Then action = ""
%>
<!--#include file="includes/layout_top.asp"-->

<% If action = "new" Or action = "edit" Then %>

    <section class="hero">
        <span class="eyebrow"><%= Ico("shield", "icon-sm") %> Administraci&oacute;n &middot; Canciones</span>
        <h1><% If action = "edit" Then %>Editar <span class="grad">canci&oacute;n</span><% Else %>Nueva <span class="grad">canci&oacute;n</span><% End If %></h1>
        <p>Completa la informaci&oacute;n de la canci&oacute;n y as&iacute;gnale artistas y &aacute;lbumes.</p>
    </section>

    <% If errMsg <> "" Then %>
    <div class="flash error" role="alert"><%= Ico("error", "") %><span><%= H(errMsg) %></span></div>
    <% End If %>

    <form class="form-card" method="post" action="admin_songs.asp" id="song-form" data-no-pjax>
        <%= CsrfField() %>
        <input type="hidden" name="op" value="save">
        <input type="hidden" name="id" value="<%= editId %>">
        <div class="form-grid">
            <div class="field">
                <label for="song_name">Nombre de la canci&oacute;n <span class="req">*</span></label>
                <input class="input" type="text" id="song_name" name="song_name" maxlength="50" required value="<%= H(fName) %>" placeholder="Ej. Adventure">
            </div>
            <div class="field">
                <label for="plays">Reproducciones</label>
                <input class="input" type="number" id="plays" name="plays" min="0" step="1" value="<%= fPlays %>">
            </div>
            <div class="field full">
                <label for="song_path">Archivo de audio (SongFiles) <span class="req">*</span></label>
                <% RenderAssetSelect "song_path", fPath, "audio", False %>
                <div class="preview-box"><audio controls preload="none" id="song_path-preview"></audio></div>
                <p class="hint">Se guarda en la base de datos con el formato <code>~/songFiles/archivo.mp3</code>.</p>
            </div>
            <div class="field full">
                <label>Artistas (int&eacute;rpretes)</label>
                <% RenderChips "SELECT ID_ARTIST, LTRIM(RTRIM(ARTIST_NAME + ' ' + ISNULL(ARTIST_LASTNAME, ''))) AS LBL FROM TBL_ARTIST ORDER BY ARTIST_NAME", "artists", selArtists %>
            </div>
            <div class="field full">
                <label>&Aacute;lbumes (tracklist)</label>
                <% RenderChips "SELECT ID_ALBUM, TITLE_ALBUM FROM TBL_ALBUM ORDER BY TITLE_ALBUM", "albums", selAlbums %>
            </div>
        </div>
        <div class="form-actions">
            <a class="btn btn-ghost" href="admin_songs.asp">Cancelar</a>
            <button type="submit" class="btn btn-primary" id="btn-save-song"><%= Ico("check", "icon-sm") %> Guardar</button>
        </div>
    </form>

<% Else %>

    <section class="hero">
        <span class="eyebrow"><%= Ico("shield", "icon-sm") %> Administraci&oacute;n</span>
        <h1>Gesti&oacute;n de <span class="grad">canciones</span></h1>
        <p>Crea, edita y elimina canciones del cat&aacute;logo de PoliMusic.</p>
    </section>

    <div class="section-head">
        <label class="search-box" for="admin-search">
            <%= Ico("search", "icon-sm") %>
            <input type="search" id="admin-search" placeholder="Filtrar canciones..." data-filter="admin-table" autocomplete="off">
        </label>
        <a class="btn btn-primary" href="admin_songs.asp?action=new" id="btn-new-song"><%= Ico("plus", "icon-sm") %> Nueva canci&oacute;n</a>
    </div>

    <%
    Set rs = QuerySql("SELECT s.ID_SONG, s.SONG_NAME, s.SONG_PATH, ISNULL(s.PLAYS, 0) AS PLAYS, " & _
        "(SELECT STRING_AGG(LTRIM(RTRIM(a.ARTIST_NAME + ' ' + ISNULL(a.ARTIST_LASTNAME, ''))), '|') FROM TBL_PLAYER p INNER JOIN TBL_ARTIST a ON a.ID_ARTIST = p.ID_ARTIST WHERE p.ID_SONG = s.ID_SONG) AS ARTISTS, " & _
        "(SELECT STRING_AGG(al.TITLE_ALBUM, '|') FROM TBL_TRACKLIST t INNER JOIN TBL_ALBUM al ON al.ID_ALBUM = t.ID_ALBUM WHERE t.ID_SONG = s.ID_SONG) AS ALBUMS, " & _
        "(SELECT MIN(t.ID_ALBUM) FROM TBL_TRACKLIST t WHERE t.ID_SONG = s.ID_SONG) AS FIRST_ALBUM, " & _
        "(SELECT TOP 1 al.ALBUM_IMAGE_PATH FROM TBL_TRACKLIST t INNER JOIN TBL_ALBUM al ON al.ID_ALBUM = t.ID_ALBUM WHERE t.ID_SONG = s.ID_SONG ORDER BY al.ID_ALBUM) AS ALBUM_IMG " & _
        "FROM TBL_SONG s ORDER BY s.ID_SONG")
    If rs.EOF Then
    %>
        <div class="empty"><%= Ico("music", "") %><p>No hay canciones. &iexcl;Crea la primera!</p></div>
    <% Else %>
    <table class="admin-table" id="admin-table">
        <thead><tr><th style="width:60px"></th><th>Canci&oacute;n</th><th>Artistas</th><th>&Aacute;lbumes</th><th>Repr.</th><th style="text-align:right">Acciones</th></tr></thead>
        <tbody>
        <%
        Dim rowCover, rowSrc, parts, k
        Do Until rs.EOF
            If IsNull(rs("FIRST_ALBUM")) Then
                rowCover = AlbumImg("", rs("ID_SONG"))
            Else
                rowCover = AlbumImg(rs("ALBUM_IMG"), rs("FIRST_ALBUM"))
            End If
            rowSrc = SongUrl(rs("SONG_PATH"))
        %>
            <tr data-row>
                <td>
                    <button type="button" class="btn-icon play-fab" style="width:42px;height:42px" title="Escuchar" aria-label="Escuchar <%= H(rs("SONG_NAME")) %>"
                        data-play-single data-id="<%= rs("ID_SONG") %>" data-src="<%= H(rowSrc) %>" data-title="<%= H(rs("SONG_NAME")) %>"
                        data-artist="<%= H(Replace(rs("ARTISTS") & "", "|", ", ")) %>" data-cover="<%= H(rowCover) %>"><%= Ico("play", "icon-sm") %></button>
                </td>
                <td>
                    <div style="font-weight:600"><%= H(rs("SONG_NAME")) %></div>
                    <div class="muted"><%= H(rs("SONG_PATH")) %><% If Not SongFileExists(rs("SONG_PATH")) Then %> &middot; <span style="color:var(--warning)" title="El archivo no existe; se reproduce el mp3 de demostraci&oacute;n">archivo no encontrado</span><% End If %></div>
                </td>
                <td>
                    <%
                    If IsNull(rs("ARTISTS")) Then
                        Response.Write "<span class=""muted"">&mdash;</span>"
                    Else
                        parts = Split(rs("ARTISTS"), "|")
                        For k = 0 To UBound(parts)
                            Response.Write "<span class=""pill"">" & H(parts(k)) & "</span>"
                        Next
                    End If
                    %>
                </td>
                <td>
                    <%
                    If IsNull(rs("ALBUMS")) Then
                        Response.Write "<span class=""muted"">&mdash;</span>"
                    Else
                        parts = Split(rs("ALBUMS"), "|")
                        For k = 0 To UBound(parts)
                            Response.Write "<span class=""pill"">" & H(parts(k)) & "</span>"
                        Next
                    End If
                    %>
                </td>
                <td class="muted"><%= FormatNumber(rs("PLAYS"), 0, -1, 0, -1) %></td>
                <td>
                    <div class="actions">
                        <a class="btn btn-ghost btn-sm" href="admin_songs.asp?action=edit&amp;id=<%= rs("ID_SONG") %>" id="edit-song-<%= rs("ID_SONG") %>"><%= Ico("edit", "icon-sm") %> Editar</a>
                        <form method="post" action="admin_songs.asp" data-confirm="Se eliminar&aacute; la canci&oacute;n &quot;<%= H(rs("SONG_NAME")) %>&quot; y sus relaciones con artistas, &aacute;lbumes y playlists." data-no-pjax>
                            <%= CsrfField() %>
                            <input type="hidden" name="op" value="delete">
                            <input type="hidden" name="id" value="<%= rs("ID_SONG") %>">
                            <button type="submit" class="btn btn-danger btn-sm" id="delete-song-<%= rs("ID_SONG") %>"><%= Ico("trash", "icon-sm") %> Eliminar</button>
                        </form>
                    </div>
                </td>
            </tr>
        <%
            rs.MoveNext
        Loop
        %>
        </tbody>
    </table>
    <% End If
    rs.Close
    %>

<% End If %>
<!--#include file="includes/layout_bottom.asp"-->
