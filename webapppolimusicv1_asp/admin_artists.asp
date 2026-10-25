<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/core.asp"-->
<!--#include file="includes/admin_helpers.asp"-->
<%
'==========================================================
' CRUD de Artistas (TBL_ARTIST + TBL_PLAYER)
'==========================================================
RequireAdmin
Dim pageTitle, navKey, pageDesc
pageTitle = "Administrar artistas"
navKey = "admin_artists"

Dim action, op, editId, fName, fLast, fImg, fSongs, errMsg, rs, selSongs, delMsg

Function SaveArtist(ByRef id, nm, ln, img, sngs)
    Dim c, rsN, msg
    msg = ""
    DbOpen
    On Error Resume Next
    gConn.BeginTrans
    If id > 0 Then
        Set c = NewCmd("UPDATE TBL_ARTIST SET ARTIST_NAME = ?, ARTIST_LASTNAME = ?, ARTIST_IMAGE = ? WHERE ID_ARTIST = ?")
        PStr c, nm, 100
        PStrN c, ln, 100
        PStrN c, img, 255
        PInt c, id
        c.Execute , , adExecuteNoRecords
    Else
        Set c = NewCmd("INSERT INTO TBL_ARTIST (ARTIST_NAME, ARTIST_LASTNAME, ARTIST_IMAGE) OUTPUT INSERTED.ID_ARTIST VALUES (?, ?, ?)")
        PStr c, nm, 100
        PStrN c, ln, 100
        PStrN c, img, 255
        Set rsN = c.Execute
        If Err.Number = 0 Then
            If Not rsN.EOF Then id = CLng(rsN(0))
            rsN.Close
        End If
    End If
    If Err.Number = 0 Then SyncLinks "TBL_PLAYER", "ID_ARTIST", id, "ID_SONG", sngs
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
    SaveArtist = msg
End Function

action = LCase(Request.QueryString("action") & "")
errMsg = ""
editId = 0
fName = "" : fLast = "" : fImg = "" : fSongs = ""

If IsPost() Then
    If Not CsrfOk() Then
        SetFlash "error", "La sesion del formulario expiro. Intenta nuevamente."
        Response.Redirect "admin_artists.asp"
    End If
    op = FStr("op")
    If op = "delete" Then
        editId = FInt("id")
        delMsg = RunTx(Array("DELETE FROM TBL_PLAYER WHERE ID_ARTIST = ?", _
                             "DELETE FROM TBL_ARTIST WHERE ID_ARTIST = ?"), editId)
        If delMsg = "" Then
            SetFlash "success", "Artista eliminado correctamente."
        Else
            SetFlash "error", "No se pudo eliminar el artista: " & delMsg
        End If
        Response.Redirect "admin_artists.asp"
    ElseIf op = "save" Then
        editId = FInt("id")
        fName = FStr("artist_name")
        fLast = FStr("artist_lastname")
        fImg = FStr("artist_image")
        fSongs = Request.Form("songs") & ""
        If fName = "" Then
            errMsg = "El nombre del artista es obligatorio."
        ElseIf Len(fName) > 100 Then
            errMsg = "El nombre no puede superar 100 caracteres."
        End If
        If errMsg = "" Then
            If editId > 0 Then
                errMsg = SaveArtist(editId, fName, fLast, fImg, fSongs)
                If errMsg = "" Then SetFlash "success", "Artista actualizado correctamente."
            Else
                errMsg = SaveArtist(editId, fName, fLast, fImg, fSongs)
                If errMsg = "" Then SetFlash "success", "Artista """ & fName & " " & fLast & """ creado correctamente."
            End If
            If errMsg = "" Then Response.Redirect "admin_artists.asp"
        End If
        If editId > 0 Then action = "edit" Else action = "new"
        Set selSongs = CsvToDict(fSongs)
    End If
ElseIf action = "edit" Then
    editId = QInt("id")
    Set rs = QueryById("SELECT ID_ARTIST, ARTIST_NAME, ARTIST_LASTNAME, ARTIST_IMAGE FROM TBL_ARTIST WHERE ID_ARTIST = ?", editId)
    If rs.EOF Then
        rs.Close
        SetFlash "error", "El artista solicitado no existe."
        Response.Redirect "admin_artists.asp"
    End If
    fName = rs("ARTIST_NAME") & ""
    fLast = Nz(rs("ARTIST_LASTNAME"), "")
    fImg = Nz(rs("ARTIST_IMAGE"), "")
    rs.Close
    Set selSongs = LinkedIds("SELECT ID_SONG FROM TBL_PLAYER WHERE ID_ARTIST = ?", editId)
ElseIf action = "new" Then
    Set selSongs = CsvToDict("")
End If
If action <> "new" And action <> "edit" Then action = ""
%>
<!--#include file="includes/layout_top.asp"-->

<% If action = "new" Or action = "edit" Then %>

    <section class="hero">
        <span class="eyebrow"><%= Ico("shield", "icon-sm") %> Administraci&oacute;n &middot; Artistas</span>
        <h1><% If action = "edit" Then %>Editar <span class="grad">artista</span><% Else %>Nuevo <span class="grad">artista</span><% End If %></h1>
        <p>Completa la informaci&oacute;n del artista y asoc&iacute;ale sus canciones.</p>
    </section>

    <% If errMsg <> "" Then %>
    <div class="flash error" role="alert"><%= Ico("error", "") %><span><%= H(errMsg) %></span></div>
    <% End If %>

    <form class="form-card" method="post" action="admin_artists.asp" id="artist-form" data-no-pjax>
        <%= CsrfField() %>
        <input type="hidden" name="op" value="save">
        <input type="hidden" name="id" value="<%= editId %>">
        <div class="form-grid">
            <div class="field">
                <label for="artist_name">Nombre <span class="req">*</span></label>
                <input class="input" type="text" id="artist_name" name="artist_name" maxlength="100" required
                       value="<%= H(fName) %>" placeholder="Ej. Juan">
            </div>
            <div class="field">
                <label for="artist_lastname">Apellido</label>
                <input class="input" type="text" id="artist_lastname" name="artist_lastname" maxlength="100"
                       value="<%= H(fLast) %>" placeholder="Ej. Gabriel">
            </div>
            <div class="field full">
                <label for="artist_image">Imagen del artista</label>
                <% RenderAssetSelect "artist_image", fImg, "image", True %>
                <div class="preview-box" id="artist-preview-box">
                    <% Dim artPrevUrl
                    artPrevUrl = AssetUrl(fImg)
                    If artPrevUrl <> "" And AssetExists(artPrevUrl) Then %>
                    <img src="<%= H(artPrevUrl) %>" id="artist_image-preview" alt="Vista previa" style="border-radius:50%">
                    <% Else %>
                    <div id="artist_image-preview" style="width:64px;height:64px;border-radius:50%;background:var(--surface-2);border:1px solid var(--border)"></div>
                    <% End If %>
                </div>
                <p class="hint">Si no hay imagen se genera un avatar autom&aacute;tico con las iniciales.</p>
            </div>
            <div class="field full">
                <label>Canciones (int&eacute;rprete en)</label>
                <% RenderChips "SELECT ID_SONG, SONG_NAME FROM TBL_SONG ORDER BY SONG_NAME", "songs", selSongs %>
            </div>
        </div>
        <div class="form-actions">
            <a class="btn btn-ghost" href="admin_artists.asp">Cancelar</a>
            <button type="submit" class="btn btn-primary" id="btn-save-artist"><%= Ico("check", "icon-sm") %> Guardar</button>
        </div>
    </form>

<% Else %>

    <section class="hero">
        <span class="eyebrow"><%= Ico("shield", "icon-sm") %> Administraci&oacute;n</span>
        <h1>Gesti&oacute;n de <span class="grad">artistas</span></h1>
        <p>Crea, edita y elimina artistas del cat&aacute;logo de PoliMusic.</p>
    </section>

    <div class="section-head">
        <label class="search-box" for="admin-search">
            <%= Ico("search", "icon-sm") %>
            <input type="search" id="admin-search" placeholder="Filtrar artistas..." data-filter="admin-table" autocomplete="off">
        </label>
        <a class="btn btn-primary" href="admin_artists.asp?action=new" id="btn-new-artist"><%= Ico("plus", "icon-sm") %> Nuevo artista</a>
    </div>

    <%
    Set rs = QuerySql("SELECT a.ID_ARTIST, a.ARTIST_NAME, a.ARTIST_LASTNAME, a.ARTIST_IMAGE, " & _
        "(SELECT STRING_AGG(s.SONG_NAME, '|') FROM TBL_PLAYER p INNER JOIN TBL_SONG s ON s.ID_SONG = p.ID_SONG WHERE p.ID_ARTIST = a.ID_ARTIST) AS SONGS " & _
        "FROM TBL_ARTIST a ORDER BY a.ARTIST_NAME, a.ARTIST_LASTNAME")
    If rs.EOF Then
    %>
        <div class="empty"><%= Ico("artist", "") %><p>No hay artistas. &iexcl;Crea el primero!</p></div>
    <% Else %>
    <table class="admin-table" id="admin-table">
        <thead><tr><th style="width:70px"></th><th>Artista</th><th>Canciones</th><th style="text-align:right">Acciones</th></tr></thead>
        <tbody>
        <%
        Dim parts, k, arAvHtml
        Do Until rs.EOF
        %>
            <tr data-row>
                <td>
                    <div class="thumb-sm round" style="overflow:hidden">
                        <%= ArtistAvatar(rs("ID_ARTIST"), rs("ARTIST_NAME"), rs("ARTIST_LASTNAME"), rs("ARTIST_IMAGE"), "sm") %>
                    </div>
                </td>
                <td>
                    <div style="font-weight:600"><%= H(Trim(rs("ARTIST_NAME") & " " & rs("ARTIST_LASTNAME"))) %></div>
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
                        <a class="btn btn-ghost btn-sm" href="admin_artists.asp?action=edit&amp;id=<%= rs("ID_ARTIST") %>" id="edit-artist-<%= rs("ID_ARTIST") %>"><%= Ico("edit", "icon-sm") %> Editar</a>
                        <form method="post" action="admin_artists.asp" data-confirm="Se eliminar&aacute; el artista &quot;<%= H(Trim(rs("ARTIST_NAME") & " " & rs("ARTIST_LASTNAME"))) %>&quot; y sus relaciones con canciones." data-no-pjax>
                            <%= CsrfField() %>
                            <input type="hidden" name="op" value="delete">
                            <input type="hidden" name="id" value="<%= rs("ID_ARTIST") %>">
                            <button type="submit" class="btn btn-danger btn-sm" id="delete-artist-<%= rs("ID_ARTIST") %>"><%= Ico("trash", "icon-sm") %> Eliminar</button>
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
