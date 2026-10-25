<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/core.asp"-->
<!--#include file="includes/songlist.asp"-->
<%
RequireLogin
Dim pageTitle, navKey, pageDesc
pageTitle = "Inicio"
navKey = "home"
pageDesc = "Escucha el listado completo de canciones de PoliMusic."

Dim rsSongs, rsAlb, rsArt, nSongs, totalPlays, rsStats
Set rsStats = QuerySql("SELECT (SELECT COUNT(*) FROM TBL_SONG) AS N_SONGS, (SELECT COUNT(*) FROM TBL_ALBUM) AS N_ALBUMS, (SELECT COUNT(*) FROM TBL_ARTIST) AS N_ARTISTS, (SELECT ISNULL(SUM(PLAYS),0) FROM TBL_SONG) AS N_PLAYS")
%>
<!--#include file="includes/layout_top.asp"-->

<section class="hero">
    <span class="eyebrow"><%= Ico("headphones", "icon-sm") %> Tu espacio musical</span>
    <h1>&iexcl;Hola, <span class="grad"><%= H(Session("username")) %></span>!</h1>
    <p>Bienvenido a PoliMusic. Tienes <b><%= rsStats("N_SONGS") %></b> canciones, <b><%= rsStats("N_ALBUMS") %></b> &aacute;lbumes y <b><%= rsStats("N_ARTISTS") %></b> artistas esperando por ti &middot; <b><%= FormatNumber(rsStats("N_PLAYS"), 0, -1, 0, -1) %></b> reproducciones en total.</p>
</section>
<% rsStats.Close %>

<!-- Accesos rapidos: albumes -->
<section class="section" style="margin-top:0">
    <div class="quick-grid">
    <%
    Set rsAlb = QuerySql("SELECT TOP 6 ID_ALBUM, TITLE_ALBUM, ALBUM_IMAGE_PATH FROM TBL_ALBUM ORDER BY ID_ALBUM")
    Do Until rsAlb.EOF
    %>
        <a class="quick" href="albums.asp?id=<%= rsAlb("ID_ALBUM") %>">
            <img src="<%= H(AlbumImg(rsAlb("ALBUM_IMAGE_PATH"), rsAlb("ID_ALBUM"))) %>" alt="">
            <span><%= H(rsAlb("TITLE_ALBUM")) %></span>
            <span class="play-fab" aria-hidden="true"><%= Ico("play", "") %></span>
        </a>
    <%
        rsAlb.MoveNext
    Loop
    rsAlb.Close
    %>
    </div>
</section>

<!-- ============ SONG LIST ============ -->
<section class="section" id="song-list-section" aria-labelledby="songlist-title">
    <div class="songlist-intro">
        <div class="bubble"><%= Ico("music", "") %></div>
        <div style="flex:1">
            <h2 id="songlist-title">Song List</h2>
            <p>A continuaci&oacute;n se presenta el listado de canciones disponibles. Haz clic en cualquiera para reproducirla.</p>
        </div>
        <button type="button" class="play-fab" data-play-all="songs-all" title="Reproducir todo" aria-label="Reproducir todo"><%= Ico("play", "") %></button>
    </div>
    <div class="section-head">
        <p>Todas las canciones</p>
        <label class="search-box" for="song-search">
            <%= Ico("search", "icon-sm") %>
            <input type="search" id="song-search" placeholder="Buscar canci&oacute;n, artista o &aacute;lbum..." data-filter="songs-all" autocomplete="off">
        </label>
    </div>
    <%
    Set rsSongs = QuerySql(SongSql("", "", "s.ID_SONG", 0))
    nSongs = RenderSongTable(rsSongs, "songs-all", "No hay canciones registradas todav&iacute;a.")
    rsSongs.Close
    %>
    <div class="empty" id="songs-all-noresults" hidden><%= Ico("search", "") %><p>No se encontraron canciones con ese criterio.</p></div>
</section>

<!-- Albumes -->
<section class="section">
    <div class="section-head">
        <h2>&Aacute;lbumes populares</h2>
        <a class="link" href="albums.asp">Mostrar todos</a>
    </div>
    <div class="grid">
    <%
    Set rsAlb = QuerySql("SELECT a.ID_ALBUM, a.TITLE_ALBUM, a.RELEASE_YEAR, a.ALBUM_IMAGE_PATH, (SELECT COUNT(*) FROM TBL_TRACKLIST t WHERE t.ID_ALBUM = a.ID_ALBUM) AS N FROM TBL_ALBUM a ORDER BY a.ID_ALBUM")
    Do Until rsAlb.EOF
    %>
        <a class="card" href="albums.asp?id=<%= rsAlb("ID_ALBUM") %>">
            <div class="thumb">
                <img src="<%= H(AlbumImg(rsAlb("ALBUM_IMAGE_PATH"), rsAlb("ID_ALBUM"))) %>" alt="<%= H(rsAlb("TITLE_ALBUM")) %>" loading="lazy">
                <span class="play-fab" data-href="albums.asp?id=<%= rsAlb("ID_ALBUM") %>&amp;autoplay=1"><%= Ico("play", "") %></span>
            </div>
            <h3><%= H(rsAlb("TITLE_ALBUM")) %></h3>
            <p><%= H(Nz(rsAlb("RELEASE_YEAR"), "s/f")) %> &middot; <%= rsAlb("N") %> canciones</p>
        </a>
    <%
        rsAlb.MoveNext
    Loop
    rsAlb.Close
    %>
    </div>
</section>

<!-- Artistas -->
<section class="section">
    <div class="section-head">
        <h2>Artistas</h2>
        <a class="link" href="artists.asp">Mostrar todos</a>
    </div>
    <div class="grid">
    <%
    Set rsArt = QuerySql("SELECT ID_ARTIST, ARTIST_NAME, ARTIST_LASTNAME, ARTIST_IMAGE FROM TBL_ARTIST ORDER BY ID_ARTIST")
    Do Until rsArt.EOF
    %>
        <a class="card round" href="artists.asp?id=<%= rsArt("ID_ARTIST") %>">
            <div class="thumb">
                <%= ArtistAvatar(rsArt("ID_ARTIST"), rsArt("ARTIST_NAME"), rsArt("ARTIST_LASTNAME"), rsArt("ARTIST_IMAGE"), "") %>
            </div>
            <h3><%= H(Trim(rsArt("ARTIST_NAME") & " " & rsArt("ARTIST_LASTNAME"))) %></h3>
            <p>Artista</p>
        </a>
    <%
        rsArt.MoveNext
    Loop
    rsArt.Close
    %>
    </div>
</section>

<!--#include file="includes/layout_bottom.asp"-->
