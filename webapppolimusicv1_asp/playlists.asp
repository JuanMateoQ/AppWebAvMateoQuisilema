<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/core.asp"-->
<!--#include file="includes/songlist.asp"-->
<%
RequireLogin
Dim pageTitle, navKey, pageDesc, plId, rsP, rsS, nRows, cP, plTitle, plImg, plOwner, plDate, plType, plTypeName
navKey = "playlists"
plId = QInt("id")
pageTitle = "Playlists"

If plId > 0 Then
    ' Solo playlists propias o publicas (TYPE = 0 segun TBL_CATALOG)
    Set rsP = QuerySql("SELECT p.ID_PLAYLIST, p.TITLE, p.PHOTO, p.CREATION_DATE, p.TYPE, u.USERNAME, " & _
                    "ISNULL(cat.VALUE, '') AS TYPE_NAME " & _
                    "FROM TBL_PLAYLIST p INNER JOIN TBL_USER u ON u.ID_USER = p.ID_USER " & _
                    "LEFT JOIN TBL_CATALOG cat ON cat.COD_CATALOG_PARENT = '2' AND cat.COD_CATALOG = CAST(p.TYPE AS varchar(8)) " & _
                    "WHERE p.ID_PLAYLIST = " & plId & " AND (p.ID_USER = " & ToInt(Session("id_user")) & " OR p.TYPE = 0)")
    If rsP.EOF Then
        rsP.Close
        SetFlash "error", "La playlist no existe o es privada."
        Response.Redirect "playlists.asp"
    End If
    plTitle = rsP("TITLE") & ""
    plImg = PlaylistImg(rsP("PHOTO"))
    plOwner = rsP("USERNAME") & ""
    plDate = FormatDateTime(rsP("CREATION_DATE"), 2)
    plTypeName = rsP("TYPE_NAME") & ""
    rsP.Close
    pageTitle = plTitle
End If
%>
<!--#include file="includes/layout_top.asp"-->
<% If plId > 0 Then %>

    <section class="detail-hero">
        <img class="cover" src="<%= H(plImg) %>" alt="Portada de <%= H(plTitle) %>">
        <div>
            <span class="kind">Playlist <%= H(plTypeName) %></span>
            <h1><%= H(plTitle) %></h1>
            <div class="meta"><span>Creada por <b><%= H(plOwner) %></b></span><span><%= H(plDate) %></span></div>
        </div>
    </section>
    <div class="actions-row">
        <button type="button" class="play-fab" data-play-all="playlist-songs" title="Reproducir" aria-label="Reproducir playlist"><%= Ico("play", "") %></button>
        <a class="btn btn-ghost btn-sm" href="playlists.asp"><%= Ico("chevron-left", "icon-sm") %> Todas las playlists</a>
    </div>
    <%
    Set rsS = QueryById(SongSql("INNER JOIN TBL_PLAYLIST_SONG ps ON ps.ID_SONG = s.ID_SONG", "ps.ID_PLAYLIST = ?", "s.ID_SONG", 0), plId)
    nRows = RenderSongTable(rsS, "playlist-songs", "Esta playlist est&aacute; vac&iacute;a.")
    rsS.Close
    %>

<% Else %>

    <section class="hero">
        <span class="eyebrow"><%= Ico("playlist", "icon-sm") %> Biblioteca</span>
        <h1>Tus <span class="grad">playlists</span></h1>
        <p>Tus listas de reproducci&oacute;n y las playlists p&uacute;blicas de la comunidad.</p>
    </section>
    <div class="grid">
    <%
    Set rsP = QuerySql("SELECT p.ID_PLAYLIST, p.TITLE, p.PHOTO, p.TYPE, u.USERNAME, ISNULL(cat.VALUE, '') AS TYPE_NAME, " & _
                    "(SELECT COUNT(*) FROM TBL_PLAYLIST_SONG ps WHERE ps.ID_PLAYLIST = p.ID_PLAYLIST) AS N " & _
                    "FROM TBL_PLAYLIST p INNER JOIN TBL_USER u ON u.ID_USER = p.ID_USER " & _
                    "LEFT JOIN TBL_CATALOG cat ON cat.COD_CATALOG_PARENT = '2' AND cat.COD_CATALOG = CAST(p.TYPE AS varchar(8)) " & _
                    "WHERE p.ID_USER = " & ToInt(Session("id_user")) & " OR p.TYPE = 0 ORDER BY p.ID_PLAYLIST")
    If rsP.EOF Then Response.Write "<div class=""empty"" style=""grid-column:1/-1"">" & Ico("playlist", "") & "<p>No hay playlists disponibles.</p></div>"
    Do Until rsP.EOF
    %>
        <a class="card" href="playlists.asp?id=<%= rsP("ID_PLAYLIST") %>">
            <div class="thumb">
                <img src="<%= H(PlaylistImg(rsP("PHOTO"))) %>" alt="<%= H(rsP("TITLE")) %>" loading="lazy">
                <span class="play-fab" data-href="playlists.asp?id=<%= rsP("ID_PLAYLIST") %>&amp;autoplay=1"><%= Ico("play", "") %></span>
            </div>
            <h3><%= H(rsP("TITLE")) %></h3>
            <p><%= H(rsP("TYPE_NAME")) %> &middot; <%= rsP("N") %> canciones &middot; <%= H(rsP("USERNAME")) %></p>
        </a>
    <%
        rsP.MoveNext
    Loop
    rsP.Close
    %>
    </div>

<% End If %>
<!--#include file="includes/layout_bottom.asp"-->
