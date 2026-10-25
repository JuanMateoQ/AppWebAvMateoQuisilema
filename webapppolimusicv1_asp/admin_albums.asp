<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/core.asp"-->
<!--#include file="includes/admin_helpers.asp"-->
<%
'==========================================================
' CRUD de Albumes (TBL_ALBUM + TBL_TRACKLIST)
'==========================================================
RequireAdmin
Dim pageTitle, navKey, pageDesc
pageTitle = "Administrar albumes"
navKey = "admin_albums"

Dim action, op, editId, fTitle, fYear, fImg, fSongs, errMsg, rs, selSongs, delMsg, yr

Function SaveAlbum(ByRef id, ttl, iyr, img, sngs)
    Dim c, rsN, msg
    msg = ""
    DbOpen
    On Error Resume Next
    gConn.BeginTrans
    If id > 0 Then
        Set c = NewCmd("UPDATE TBL_ALBUM SET TITLE_ALBUM = ?, RELEASE_YEAR = ?, ALBUM_IMAGE_PATH = ? WHERE ID_ALBUM = ?")
        PStr c, ttl, 50
        PInt c, iyr
        PStrN c, img, 255
        PInt c, id
        c.Execute , , adExecuteNoRecords
    Else
        Set c = NewCmd("INSERT INTO TBL_ALBUM (TITLE_ALBUM, RELEASE_YEAR, ALBUM_IMAGE_PATH) OUTPUT INSERTED.ID_ALBUM VALUES (?, ?, ?)")
        PStr c, ttl, 50
        PInt c, iyr
        PStrN c, img, 255
        Set rsN = c.Execute
        If Err.Number = 0 Then
            If Not rsN.EOF Then id = CLng(rsN(0))
            rsN.Close
        End If
    End If
    If Err.Number = 0 Then SyncLinks "TBL_TRACKLIST", "ID_ALBUM", id, "ID_SONG", sngs
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
    SaveAlbum = msg
End Function

action = LCase(Request.QueryString("action") & "")
errMsg = ""
editId = 0
fTitle = "" : fYear = "" : fImg = "" : fSongs = ""

If IsPost() Then
    If Not CsrfOk() Then
        SetFlash "error", "La sesion del formulario expiro. Intenta nuevamente."
        Response.Redirect "admin_albums.asp"
    End If
    op = FStr("op")
    If op = "delete" Then
        editId = FInt("id")
        delMsg = RunTx(Array("DELETE FROM TBL_TRACKLIST WHERE ID_ALBUM = ?", _
                             "DELETE FROM TBL_ALBUM WHERE ID_ALBUM = ?"), editId)
        If delMsg = "" Then
            SetFlash "success", "Album eliminado correctamente."
        Else
            SetFlash "error", "No se pudo eliminar el album: " & delMsg
        End If
        Response.Redirect "admin_albums.asp"
    ElseIf op = "save" Then
        editId = FInt("id")
        fTitle = FStr("title_album")
        fYear = FStr("release_year")
        fImg = FStr("album_image_path")
        fSongs = Request.Form("songs") & ""
        yr = ToInt(fYear)
        If fTitle = "" Then
            errMsg = "El titulo del album es obligatorio."
        ElseIf Len(fTitle) > 50 Then
            errMsg = "El titulo no puede superar 50 caracteres."
        ElseIf fYear <> "" And (yr < 1800 Or yr > 2100) Then
            errMsg = "El anio debe estar entre 1800 y 2100."
        End If
        If errMsg = "" Then
            If editId > 0 Then
                errMsg = SaveAlbum(editId, fTitle, yr, fImg, fSongs)
                If errMsg = "" Then SetFlash "success", "Album """ & fTitle & """ actualizado correctamente."
            Else
                errMsg = SaveAlbum(editId, fTitle, yr, fImg, fSongs)
                If errMsg = "" Then SetFlash "success", "Album """ & fTitle & """ creado correctamente."
            End If
            If errMsg = "" Then Response.Redirect "admin_albums.asp"
        End If
        If editId > 0 Then action = "edit" Else action = "new"
        Set selSongs = CsvToDict(fSongs)
    End If
ElseIf action = "edit" Then
    editId = QInt("id")
    Set rs = QueryById("SELECT ID_ALBUM, TITLE_ALBUM, RELEASE_YEAR, ALBUM_IMAGE_PATH FROM TBL_ALBUM WHERE ID_ALBUM = ?", editId)
    If rs.EOF Then
        rs.Close
        SetFlash "error", "El album solicitado no existe."
        Response.Redirect "admin_albums.asp"
    End If
    fTitle = rs("TITLE_ALBUM") & ""
    fYear = Nz(rs("RELEASE_YEAR"), "")
    fImg = Nz(rs("ALBUM_IMAGE_PATH"), "")
    rs.Close
    Set selSongs = LinkedIds("SELECT ID_SONG FROM TBL_TRACKLIST WHERE ID_ALBUM = ?", editId)
ElseIf action = "new" Then
    Set selSongs = CsvToDict("")
End If
If action <> "new" And action <> "edit" Then action = ""
%>
<!--#include file="includes/layout_top.asp"-->

<% If action = "new" Or action = "edit" Then %>

    <section class="hero">
        <span class="eyebrow"><%= Ico("shield", "icon-sm") %> Administraci&oacute;n &middot; &Aacute;lbumes</span>
        <h1><% If action = "edit" Then %>Editar <span class="grad">&aacute;lbum</span><% Else %>Nuevo <span class="grad">&aacute;lbum</span><% End If %></h1>
        <p>Completa la informaci&oacute;n del &aacute;lbum y as&iacute;gnale las canciones de su tracklist.</p>
    </section>

    <% If errMsg <> "" Then %>
    <div class="flash error" role="alert"><%= Ico("error", "") %><span><%= H(errMsg) %></span></div>
    <% End If %>

    <form class="form-card" method="post" action="admin_albums.asp" id="album-form" data-no-pjax>
        <%= CsrfField() %>
        <input type="hidden" name="op" value="save">
        <input type="hidden" name="id" value="<%= editId %>">
        <div class="form-grid">
            <div class="field">
                <label for="title_album">T&iacute;tulo del &aacute;lbum <span class="req">*</span></label>
                <input class="input" type="text" id="title_album" name="title_album" maxlength="50" required
                       value="<%= H(fTitle) %>" placeholder="Ej. Rock Album">
            </div>
            <div class="field">
                <label for="release_year">A&ntilde;o de lanzamiento</label>
                <input class="input" type="number" id="release_year" name="release_year" min="1800" max="2100"
                       value="<%= H(fYear) %>" placeholder="Ej. 1976">
            </div>
            <div class="field full">
                <label for="album_image_path">Portada del &aacute;lbum</label>
                <% RenderAssetSelect "album_image_path", fImg, "image", True %>
                <div class="preview-box">
                    <img id="album_image_path-preview" src="<%= H(AlbumImg(fImg, editId)) %>" alt="Vista previa" style="border-radius:10px">
                </div>
                <p class="hint">Si no hay imagen se elige autom&aacute;ticamente una portada de la biblioteca.</p>
            </div>
            <div class="field full">
                <label>Canciones del tracklist</label>
                <% RenderChips "SELECT ID_SONG, SONG_NAME FROM TBL_SONG ORDER BY SONG_NAME", "songs", selSongs %>
            </div>
        </div>
        <div class="form-actions">
            <a class="btn btn-ghost" href="admin_albums.asp">Cancelar</a>
            <button type="submit" class="btn btn-primary" id="btn-save-album"><%= Ico("check", "icon-sm") %> Guardar</button>
        </div>
    </form>

<% Else %>

    <section class="hero">
        <span class="eyebrow"><%= Ico("shield", "icon-sm") %> Administraci&oacute;n</span>
        <h1>Gesti&oacute;n de <span class="grad">&aacute;lbumes</span></h1>
        <p>Crea, edita y elimina &aacute;lbumes y su tracklist en PoliMusic.</p>
    </section>

    <div class="section-head">
        <label class="search-box" for="admin-search">
            <%= Ico("search", "icon-sm") %>
            <input type="search" id="admin-search" placeholder="Filtrar &aacute;lbumes..." data-filter="admin-table" autocomplete="off">
        </label>
        <a class="btn btn-primary" href="admin_albums.asp?action=new" id="btn-new-album"><%= Ico("plus", "icon-sm") %> Nuevo &aacute;lbum</a>
    </div>

    <%
    Dim parts, k
    Set rs = QuerySql("SELECT a.ID_ALBUM, a.TITLE_ALBUM, a.RELEASE_YEAR, a.ALBUM_IMAGE_PATH, " & _
        "(SELECT COUNT(*) FROM TBL_TRACKLIST t WHERE t.ID_ALBUM = a.ID_ALBUM) AS N_SONGS, " & _
        "(SELECT STRING_AGG(s.SONG_NAME, '|') FROM TBL_TRACKLIST t INNER JOIN TBL_SONG s ON s.ID_SONG = t.ID_SONG WHERE t.ID_ALBUM = a.ID_ALBUM) AS SONGS " & _
        "FROM TBL_ALBUM a ORDER BY a.TITLE_ALBUM")
    If rs.EOF Then
    %>
        <div class="empty"><%= Ico("album", "") %><p>No hay &aacute;lbumes. &iexcl;Crea el primero!</p></div>
    <% Else %>
    <table class="admin-table" id="admin-table">
        <thead><tr><th style="width:70px"></th><th>&Aacute;lbum</th><th>Canciones</th><th style="text-align:right">Acciones</th></tr></thead>
        <tbody>
        <%
        Do Until rs.EOF
        %>
            <tr data-row>
                <td>
                    <div class="thumb-sm" style="overflow:hidden">
                        <img src="<%= H(AlbumImg(rs("ALBUM_IMAGE_PATH"), rs("ID_ALBUM"))) %>" alt="" style="width:100%;height:100%;object-fit:cover">
                    </div>
                </td>
                <td>
                    <div style="font-weight:600"><%= H(rs("TITLE_ALBUM")) %></div>
                    <div class="muted"><%= H(Nz(rs("RELEASE_YEAR"), "Sin anio")) %> &middot; <%= rs("N_SONGS") %> canciones</div>
                </td>
                <td>
                    <%
                    If IsNull(rs("SONGS")) Then
                        Response.Write "<span class=""muted"">&mdash;</span>"
                    Else
                        parts = Split(rs("SONGS"), "|")
                        For k = 0 To UBound(parts)
                            Response.Write "<span class=""pill"">" & H(parts(k)) & "</span>"
                        Next
                    End If
                    %>
                </td>
                <td>
                    <div class="actions">
                        <a class="btn btn-ghost btn-sm" href="admin_albums.asp?action=edit&amp;id=<%= rs("ID_ALBUM") %>" id="edit-album-<%= rs("ID_ALBUM") %>"><%= Ico("edit", "icon-sm") %> Editar</a>
                        <form method="post" action="admin_albums.asp" data-confirm="Se eliminar&aacute; el &aacute;lbum &quot;<%= H(rs("TITLE_ALBUM")) %>&quot; y su tracklist. Las canciones no se borrar&aacute;n." data-no-pjax>
                            <%= CsrfField() %>
                            <input type="hidden" name="op" value="delete">
                            <input type="hidden" name="id" value="<%= rs("ID_ALBUM") %>">
                            <button type="submit" class="btn btn-danger btn-sm" id="delete-album-<%= rs("ID_ALBUM") %>"><%= Ico("trash", "icon-sm") %> Eliminar</button>
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
