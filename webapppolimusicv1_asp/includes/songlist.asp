<%
'==========================================================
' Listado de canciones reutilizable (Song List)
'==========================================================

' Construye la consulta de canciones con artistas (concatenados) y album principal.
' extraJoin / whereClause / orderBy son fragmentos fijos definidos en el codigo
' (los valores de usuario siempre se pasan como parametros "?").
Function SongSql(extraJoin, whereClause, orderBy, prefAlbumId)
    Dim s, pref
    pref = CStr(ToInt(prefAlbumId))
    s = "SELECT s.ID_SONG, s.SONG_NAME, s.SONG_PATH, ISNULL(s.PLAYS, 0) AS PLAYS, " & _
        "ISNULL((SELECT STRING_AGG(LTRIM(RTRIM(a.ARTIST_NAME + ' ' + ISNULL(a.ARTIST_LASTNAME, ''))), ', ') " & _
        "        FROM TBL_PLAYER pl INNER JOIN TBL_ARTIST a ON a.ID_ARTIST = pl.ID_ARTIST " & _
        "        WHERE pl.ID_SONG = s.ID_SONG), 'Artista desconocido') AS ARTISTS, " & _
        "alb.ID_ALBUM, alb.TITLE_ALBUM, alb.ALBUM_IMAGE_PATH " & _
        "FROM TBL_SONG s " & extraJoin & " " & _
        "OUTER APPLY (SELECT TOP 1 al.ID_ALBUM, al.TITLE_ALBUM, al.ALBUM_IMAGE_PATH " & _
        "             FROM TBL_TRACKLIST t INNER JOIN TBL_ALBUM al ON al.ID_ALBUM = t.ID_ALBUM " & _
        "             WHERE t.ID_SONG = s.ID_SONG " & _
        "             ORDER BY CASE WHEN al.ID_ALBUM = " & pref & " THEN 0 ELSE 1 END, al.ID_ALBUM) alb "
    If whereClause <> "" Then s = s & "WHERE " & whereClause & " "
    If orderBy = "" Then orderBy = "s.ID_SONG"
    s = s & "ORDER BY " & orderBy
    SongSql = s
End Function

Function SongCover(rs)
    If IsNull(rs("ID_ALBUM")) Then
        SongCover = AlbumImg("", rs("ID_SONG"))
    Else
        SongCover = AlbumImg(rs("ALBUM_IMAGE_PATH"), rs("ID_ALBUM"))
    End If
End Function

' Pinta la tabla de canciones. Devuelve el numero de filas.
Function RenderSongTable(rs, tableId, emptyMsg)
    Dim n, cover, src, title, artists, delay
    n = 0
    If rs.EOF Then
        Response.Write "<div class=""empty"">" & Ico("music", "") & "<p>" & emptyMsg & "</p></div>"
        RenderSongTable = 0
        Exit Function
    End If
    Response.Write "<div class=""song-table"" id=""" & tableId & """ data-songlist>"
    Response.Write "<div class=""song-head""><span style=""text-align:center"">#</span><span>T&iacute;tulo</span><span class=""h-album"">&Aacute;lbum</span><span>Reproducciones</span><span style=""text-align:right"">" & Ico("clock", "icon-sm") & "</span></div>"
    Do Until rs.EOF
        n = n + 1
        cover = SongCover(rs)
        src = SongUrl(rs("SONG_PATH"))
        title = rs("SONG_NAME") & ""
        artists = rs("ARTISTS") & ""
        delay = n * 40
        If delay > 600 Then delay = 600
%>
        <div class="song-row" id="song-<%= tableId %>-<%= rs("ID_SONG") %>" tabindex="0" style="animation-delay:<%= delay %>ms"
             data-id="<%= rs("ID_SONG") %>" data-src="<%= H(src) %>" data-title="<%= H(title) %>"
             data-artist="<%= H(artists) %>" data-cover="<%= H(cover) %>">
            <div class="idx">
                <span class="num"><%= n %></span>
                <span class="row-play"><%= Ico("play", "icon-sm") %></span>
                <span class="eq"><i></i><i></i><i></i><i></i></span>
            </div>
            <div class="song-main">
                <img src="<%= H(cover) %>" alt="" loading="lazy">
                <div>
                    <div class="song-title"><%= H(title) %></div>
                    <div class="song-artist"><%= H(artists) %></div>
                </div>
            </div>
            <div class="song-album">
                <% If IsNull(rs("ID_ALBUM")) Then %>
                    <span>Sencillo</span>
                <% Else %>
                    <a href="albums.asp?id=<%= rs("ID_ALBUM") %>"><%= H(rs("TITLE_ALBUM")) %></a>
                <% End If %>
            </div>
            <div class="song-plays" data-plays><%= FormatNumber(rs("PLAYS"), 0, -1, 0, -1) %></div>
            <div class="song-dur" data-dur>--:--</div>
        </div>
<%
        rs.MoveNext
    Loop
    Response.Write "</div>"
    RenderSongTable = n
End Function
%>
