<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/core.asp"-->
<!--#include file="includes/songlist.asp"-->
<%
RequireLogin
Dim pageTitle, navKey, pageDesc, albumId, rsA, rsS, nRows, aTitle, aYear, aImg
navKey = "albums"
albumId = QInt("id")
pageTitle = "Albumes"

If albumId > 0 Then
    Set rsA = QueryById("SELECT ID_ALBUM, TITLE_ALBUM, RELEASE_YEAR, ALBUM_IMAGE_PATH FROM TBL_ALBUM WHERE ID_ALBUM = ?", albumId)
    If rsA.EOF Then
        rsA.Close
        SetFlash "error", "El album solicitado no existe."
        Response.Redirect "albums.asp"
    End If
    aTitle = rsA("TITLE_ALBUM") & ""
    aYear = Nz(rsA("RELEASE_YEAR"), "s/f")
    aImg = AlbumImg(rsA("ALBUM_IMAGE_PATH"), rsA("ID_ALBUM"))
    rsA.Close
    pageTitle = aTitle
    pageDesc = "Album " & aTitle & " en PoliMusic."
End If
%>
<!--#include file="includes/layout_top.asp"-->
<% If albumId > 0 Then %>

    <section class="detail-hero">
        <img class="cover" src="<%= H(aImg) %>" alt="Portada de <%= H(aTitle) %>">
        <div>
            <span class="kind">&Aacute;lbum</span>
            <h1><%= H(aTitle) %></h1>
            <div class="meta"><span>Lanzamiento: <b><%= H(aYear) %></b></span></div>
        </div>
    </section>
    <div class="actions-row">
        <button type="button" class="play-fab" data-play-all="album-songs" title="Reproducir &aacute;lbum" aria-label="Reproducir &aacute;lbum"><%= Ico("play", "") %></button>
        <a class="btn btn-ghost btn-sm" href="albums.asp"><%= Ico("chevron-left", "icon-sm") %> Todos los &aacute;lbumes</a>
    </div>
    <%
    Set rsS = QueryById(SongSql("INNER JOIN TBL_TRACKLIST tk ON tk.ID_SONG = s.ID_SONG", "tk.ID_ALBUM = ?", "s.ID_SONG", albumId), albumId)
    nRows = RenderSongTable(rsS, "album-songs", "Este &aacute;lbum a&uacute;n no tiene canciones.")
    rsS.Close
    %>

<% Else %>

    <section class="hero">
        <span class="eyebrow"><%= Ico("album", "icon-sm") %> Colecci&oacute;n</span>
        <h1>Todos los <span class="grad">&aacute;lbumes</span></h1>
        <p>Explora los &aacute;lbumes disponibles en PoliMusic y reproduce su lista de canciones.</p>
    </section>
    <div class="grid">
    <%
    Set rsA = QuerySql("SELECT a.ID_ALBUM, a.TITLE_ALBUM, a.RELEASE_YEAR, a.ALBUM_IMAGE_PATH, (SELECT COUNT(*) FROM TBL_TRACKLIST t WHERE t.ID_ALBUM = a.ID_ALBUM) AS N FROM TBL_ALBUM a ORDER BY a.TITLE_ALBUM")
    If rsA.EOF Then Response.Write "<div class=""empty"" style=""grid-column:1/-1"">" & Ico("album", "") & "<p>No hay &aacute;lbumes registrados.</p></div>"
    Do Until rsA.EOF
    %>
        <a class="card" href="albums.asp?id=<%= rsA("ID_ALBUM") %>">
            <div class="thumb">
                <img src="<%= H(AlbumImg(rsA("ALBUM_IMAGE_PATH"), rsA("ID_ALBUM"))) %>" alt="<%= H(rsA("TITLE_ALBUM")) %>" loading="lazy">
                <span class="play-fab" data-href="albums.asp?id=<%= rsA("ID_ALBUM") %>&amp;autoplay=1"><%= Ico("play", "") %></span>
            </div>
            <h3><%= H(rsA("TITLE_ALBUM")) %></h3>
            <p><%= H(Nz(rsA("RELEASE_YEAR"), "s/f")) %> &middot; <%= rsA("N") %> canciones</p>
        </a>
    <%
        rsA.MoveNext
    Loop
    rsA.Close
    %>
    </div>

<% End If %>
<!--#include file="includes/layout_bottom.asp"-->
