<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/core.asp"-->
<!--#include file="includes/songlist.asp"-->
<%
RequireLogin
Dim pageTitle, navKey, pageDesc, artistId, rsA, rsS, nRows, arId, arName, arLast, arImg, arFull, arSongs
navKey = "artists"
artistId = QInt("id")
pageTitle = "Artistas"

If artistId > 0 Then
    Set rsA = QueryById("SELECT a.ID_ARTIST, a.ARTIST_NAME, a.ARTIST_LASTNAME, a.ARTIST_IMAGE, (SELECT COUNT(*) FROM TBL_PLAYER p WHERE p.ID_ARTIST = a.ID_ARTIST) AS N FROM TBL_ARTIST a WHERE a.ID_ARTIST = ?", artistId)
    If rsA.EOF Then
        rsA.Close
        SetFlash "error", "El artista solicitado no existe."
        Response.Redirect "artists.asp"
    End If
    arId = rsA("ID_ARTIST")
    arName = rsA("ARTIST_NAME") & ""
    arLast = rsA("ARTIST_LASTNAME") & ""
    arImg = rsA("ARTIST_IMAGE") & ""
    arSongs = rsA("N")
    rsA.Close
    arFull = Trim(arName & " " & arLast)
    pageTitle = arFull
    pageDesc = "Canciones de " & arFull & " en PoliMusic."
End If
%>
<!--#include file="includes/layout_top.asp"-->
<% If artistId > 0 Then %>

    <section class="detail-hero">
        <div class="cover round" style="overflow:hidden"><%= ArtistAvatar(arId, arName, arLast, arImg, "lg") %></div>
        <div>
            <span class="kind">Artista</span>
            <h1><%= H(arFull) %></h1>
            <div class="meta"><span><b><%= arSongs %></b> canciones</span></div>
        </div>
    </section>
    <div class="actions-row">
        <button type="button" class="play-fab" data-play-all="artist-songs" title="Reproducir" aria-label="Reproducir canciones del artista"><%= Ico("play", "") %></button>
        <a class="btn btn-ghost btn-sm" href="artists.asp"><%= Ico("chevron-left", "icon-sm") %> Todos los artistas</a>
    </div>
    <div class="section-head"><h2>Populares</h2></div>
    <%
    Set rsS = QueryById(SongSql("INNER JOIN TBL_PLAYER pa ON pa.ID_SONG = s.ID_SONG", "pa.ID_ARTIST = ?", "ISNULL(s.PLAYS, 0) DESC, s.ID_SONG", 0), artistId)
    nRows = RenderSongTable(rsS, "artist-songs", "Este artista a&uacute;n no tiene canciones.")
    rsS.Close
    %>

<% Else %>

    <section class="hero">
        <span class="eyebrow"><%= Ico("artist", "icon-sm") %> Talento</span>
        <h1>Nuestros <span class="grad">artistas</span></h1>
        <p>Descubre a los artistas de PoliMusic y escucha sus canciones m&aacute;s populares.</p>
    </section>
    <div class="grid">
    <%
    Set rsA = QuerySql("SELECT a.ID_ARTIST, a.ARTIST_NAME, a.ARTIST_LASTNAME, a.ARTIST_IMAGE, (SELECT COUNT(*) FROM TBL_PLAYER p WHERE p.ID_ARTIST = a.ID_ARTIST) AS N FROM TBL_ARTIST a ORDER BY a.ARTIST_NAME, a.ARTIST_LASTNAME")
    If rsA.EOF Then Response.Write "<div class=""empty"" style=""grid-column:1/-1"">" & Ico("artist", "") & "<p>No hay artistas registrados.</p></div>"
    Do Until rsA.EOF
    %>
        <a class="card round" href="artists.asp?id=<%= rsA("ID_ARTIST") %>">
            <div class="thumb">
                <%= ArtistAvatar(rsA("ID_ARTIST"), rsA("ARTIST_NAME"), rsA("ARTIST_LASTNAME"), rsA("ARTIST_IMAGE"), "") %>
                <span class="play-fab" data-href="artists.asp?id=<%= rsA("ID_ARTIST") %>&amp;autoplay=1"><%= Ico("play", "") %></span>
            </div>
            <h3><%= H(Trim(rsA("ARTIST_NAME") & " " & rsA("ARTIST_LASTNAME"))) %></h3>
            <p>Artista &middot; <%= rsA("N") %> canciones</p>
        </a>
    <%
        rsA.MoveNext
    Loop
    rsA.Close
    %>
    </div>

<% End If %>
<!--#include file="includes/layout_bottom.asp"-->
