<%
'==========================================================
' Layout superior: <head>, sidebar y topbar.
' Variables esperadas: pageTitle, navKey, pageDesc
'==========================================================
If pageTitle & "" = "" Then pageTitle = "PoliMusic"
If pageDesc & "" = "" Then pageDesc = "PoliMusic: escucha, descubre y administra tu musica favorita."

Function NavCls(key)
    If LCase(navKey & "") = LCase(key) Then
        NavCls = "nav-link active"
    Else
        NavCls = "nav-link"
    End If
End Function

Dim lt_hour, lt_greet
lt_hour = Hour(Now())
If lt_hour < 12 Then
    lt_greet = "Buenos d&iacute;as"
ElseIf lt_hour < 19 Then
    lt_greet = "Buenas tardes"
Else
    lt_greet = "Buenas noches"
End If
%><!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><%= H(pageTitle) %> &middot; PoliMusic</title>
    <meta name="description" content="<%= H(pageDesc) %>">
    <meta name="csrf" content="<%= H(Session("csrf")) %>">
    <link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'%3E%3Cpath fill='%23b197fc' d='M12 3v10.55c-.59-.34-1.27-.55-2-.55-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4V7h4V3h-6z'/%3E%3C/svg%3E">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/styles.css?v=3">
</head>
<body class="paused">
<!--#include file="icons.asp"-->
<div class="app">

    <!-- ================= SIDEBAR ================= -->
    <aside class="sidebar" aria-label="Navegacion principal">
        <nav class="panel">
            <a href="default.asp" class="brand" id="brand-link">
                <span class="brand-logo"><%= Ico("logo", "") %></span>
                <span>Poli<b>Music</b></span>
            </a>
            <a href="default.asp" id="nav-home" class="<%= NavCls("home") %>" data-nav="home"><%= Ico("home", "") %> Inicio</a>
            <a href="albums.asp" id="nav-albums" class="<%= NavCls("albums") %>" data-nav="albums"><%= Ico("album", "") %> &Aacute;lbumes</a>
            <a href="artists.asp" id="nav-artists" class="<%= NavCls("artists") %>" data-nav="artists"><%= Ico("artist", "") %> Artistas</a>
            <a href="playlists.asp" id="nav-playlists" class="<%= NavCls("playlists") %>" data-nav="playlists"><%= Ico("playlist", "") %> Playlists</a>
            <% If IsAdmin() Then %>
            <div class="nav-title">Administraci&oacute;n</div>
            <a href="admin_songs.asp" id="nav-admin-songs" class="<%= NavCls("admin_songs") %>" data-nav="admin_songs"><%= Ico("music", "") %> Canciones</a>
            <a href="admin_artists.asp" id="nav-admin-artists" class="<%= NavCls("admin_artists") %>" data-nav="admin_artists"><%= Ico("artist", "") %> Artistas</a>
            <a href="admin_albums.asp" id="nav-admin-albums" class="<%= NavCls("admin_albums") %>" data-nav="admin_albums"><%= Ico("album", "") %> &Aacute;lbumes</a>
            <% End If %>
        </nav>
        <div class="panel grow">
            <div class="nav-title" style="padding-top:0; display:flex; align-items:center; gap:8px;"><%= Ico("library", "icon-sm") %> Tu biblioteca</div>
            <div class="mini-list">
            <%
            Dim lt_rs
            Set lt_rs = QuerySql("SELECT p.ID_PLAYLIST, p.TITLE, p.PHOTO, p.TYPE, u.USERNAME FROM TBL_PLAYLIST p INNER JOIN TBL_USER u ON u.ID_USER = p.ID_USER WHERE p.ID_USER = " & ToInt(Session("id_user")) & " OR p.TYPE = 0 ORDER BY p.ID_PLAYLIST")
            If lt_rs.EOF Then
                Response.Write "<p class=""s"" style=""color:var(--muted);padding:8px;font-size:.85rem"">A&uacute;n no hay playlists disponibles.</p>"
            End If
            Do Until lt_rs.EOF
            %>
                <a class="mini-item" href="playlists.asp?id=<%= lt_rs("ID_PLAYLIST") %>">
                    <img src="<%= H(PlaylistImg(lt_rs("PHOTO"))) %>" alt="" loading="lazy">
                    <div>
                        <div class="t"><%= H(lt_rs("TITLE")) %></div>
                        <div class="s">Playlist &middot; <%= H(lt_rs("USERNAME")) %></div>
                    </div>
                </a>
            <%
                lt_rs.MoveNext
            Loop
            lt_rs.Close
            Set lt_rs = Nothing
            %>
            </div>
        </div>
    </aside>

    <!-- ================= MAIN ================= -->
    <main class="main" id="main">
        <header class="topbar" id="topbar">
            <div class="topbar-left">
                <button type="button" class="round-btn" id="btn-back" aria-label="Atr&aacute;s"><%= Ico("chevron-left", "") %></button>
                <button type="button" class="round-btn" id="btn-forward" aria-label="Adelante"><%= Ico("chevron-right", "") %></button>
                <span class="welcome" id="welcome-msg"><%= lt_greet %>, bienvenido <strong><%= H(Session("username")) %></strong></span>
            </div>
            <div class="topbar-right">
                <div class="user-chip" id="user-chip" title="<%= H(Session("email")) %>">
                    <img src="<%= H(UserImg(Session("user_photo"))) %>" alt="Foto de <%= H(Session("username")) %>">
                    <span class="name"><%= H(Session("username")) %></span>
                    <% If IsAdmin() Then %>
                    <span class="badge admin"><%= H(Session("role_name")) %></span>
                    <% Else %>
                    <span class="badge"><%= H(Session("role_name")) %></span>
                    <% End If %>
                </div>
                <a href="logout.asp" class="btn btn-ghost btn-sm" id="btn-logout" data-no-pjax><%= Ico("logout", "icon-sm") %> Cerrar sesi&oacute;n</a>
            </div>
        </header>
        <div class="content" id="content" data-nav="<%= H(navKey) %>" data-title="<%= H(pageTitle) %> &middot; PoliMusic">
        <% RenderFlash %>
