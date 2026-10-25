<%@ Language="VBScript" CodePage="65001" %>
<!--#include file="includes/core.asp"-->
<%
'==========================================================
' Login: valida contra TBL_USER y guarda datos en la sesion
'==========================================================
Dim loginError, uName, uPass, c, rs

loginError = ""
uName = ""

If IsLogged() Then Response.Redirect "default.asp"

If IsPost() Then
    On Error Resume Next
    uName = FStr("username")
    uPass = Request.Form("password") & ""

    If uName = "" Or uPass = "" Then
        loginError = "Ingresa tu usuario y contrasena."
    Else
        Dim dbPass, passOk, cHash, rsHash
        passOk = False

        Dim safeName
        safeName = Replace(uName, "'", "''")
        Set rs = QuerySql("SELECT u.ID_USER, u.USERNAME, u.PASSWORD, u.EMAIL, u.USER_PHOTO, u.USER_TYPE, " & _
                          "ISNULL(cat.VALUE, CASE WHEN u.USER_TYPE = 1 THEN 'ADMIN' ELSE 'USER' END) AS ROLE_NAME " & _
                          "FROM TBL_USER u " & _
                          "LEFT JOIN TBL_CATALOG cat ON cat.COD_CATALOG_PARENT = '1' AND cat.COD_CATALOG = CAST(u.USER_TYPE AS varchar(8)) " & _
                          "WHERE u.USERNAME = '" & safeName & "'")

        If Err.Number <> 0 Then
            loginError = "Error de conexion: " & Err.Description
            Err.Clear
        ElseIf rs Is Nothing Then
            loginError = "No se pudo conectar a la base de datos."
        ElseIf rs.EOF Then
            loginError = "Usuario o contrasena incorrectos."
            rs.Close
        Else
            dbPass = rs("PASSWORD") & ""
            ' Comparacion directa para contrasenas en texto plano (como 12345678)
            If dbPass = uPass Then
                passOk = True
            ElseIf Len(dbPass) = 40 Then
                ' Soporte para hash SHA1 almacenado en hex (como username1)
                Set rsHash = QuerySql("SELECT CASE WHEN '" & Replace(dbPass, "'", "''") & "' = CONVERT(varchar(50), HASHBYTES('SHA1', '" & Replace(uPass, "'", "''") & "'), 2) THEN 1 ELSE 0 END AS OK")
                If Not rsHash.EOF Then
                    If rsHash("OK") = 1 Then passOk = True
                End If
                rsHash.Close
            End If

            If passOk Then
                Session.Contents.RemoveAll
                Session("id_user") = CStr(rs("ID_USER"))
                Session("username") = rs("USERNAME") & ""
                Session("email") = rs("EMAIL") & ""
                Session("user_photo") = rs("USER_PHOTO") & ""
                Session("user_type") = CStr(rs("USER_TYPE"))
                Session("role_name") = rs("ROLE_NAME") & ""
                Session("csrf") = NewToken()
                rs.Close
                DbClose
                Response.Redirect "default.asp"
            Else
                loginError = "Usuario o contrasena incorrectos."
                rs.Close
            End If
        End If
    End If
End If
DbClose
%><!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Iniciar sesi&oacute;n &middot; PoliMusic</title>
    <meta name="description" content="Inicia sesi&oacute;n en PoliMusic para escuchar y administrar tu m&uacute;sica.">
    <link rel="icon" href="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'%3E%3Cpath fill='%23b197fc' d='M12 3v10.55c-.59-.34-1.27-.55-2-.55-2.21 0-4 1.79-4 4s1.79 4 4 4 4-1.79 4-4V7h4V3h-6z'/%3E%3C/svg%3E">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Outfit:wght@500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/styles.css?v=3">
</head>
<body class="login-body">
<!--#include file="includes/icons.asp"-->
<div class="blob b1"></div>
<div class="blob b2"></div>
<div class="blob b3"></div>

<main class="login-wrap">
    <section class="login-art" aria-hidden="true">
        <div class="brand" style="padding:0">
            <span class="brand-logo"><%= Ico("logo", "") %></span>
            <span>Poli<b>Music</b></span>
        </div>
        <div>
            <h2>Tu m&uacute;sica,<br>en tono pastel.</h2>
            <p>Escucha tus canciones favoritas, descubre &aacute;lbumes y artistas, y lleva tus playlists a donde vayas.</p>
            <div class="art-stack">
                <img src="SongFilesAndImages_resources/PlaylistImages/playlist1.png" alt="">
                <img src="SongFilesAndImages_resources/PlaylistImages/playlist2.png" alt="">
                <img src="SongFilesAndImages_resources/PlaylistImages/playlist3.png" alt="">
            </div>
        </div>
        <div class="wave">
            <i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i>
        </div>
    </section>

    <section class="login-form">
        <h1>Bienvenido de nuevo</h1>
        <p class="sub">Inicia sesi&oacute;n para continuar escuchando.</p>

        <% If Request.QueryString("bye") = "1" And loginError = "" Then %>
        <div class="flash success" role="status"><%= Ico("check", "") %><span>Has cerrado sesi&oacute;n correctamente. &iexcl;Vuelve pronto!</span></div>
        <% End If %>
        <% If loginError <> "" Then %>
        <div class="flash error" role="alert"><%= Ico("error", "") %><span><%= H(loginError) %></span></div>
        <% End If %>

        <form method="post" action="login.asp" id="login-form" autocomplete="on" novalidate>
            <div class="field">
                <label for="username">Usuario</label>
                <div class="input-icon">
                    <%= Ico("user", "") %>
                    <input class="input" type="text" id="username" name="username" maxlength="50" required
                           placeholder="Tu nombre de usuario" value="<%= H(uName) %>" autofocus>
                </div>
            </div>
            <div class="field">
                <label for="password">Contrase&ntilde;a</label>
                <div class="input-icon">
                    <%= Ico("lock", "") %>
                    <input class="input" type="password" id="password" name="password" maxlength="50" required placeholder="&bull;&bull;&bull;&bull;&bull;&bull;&bull;&bull;">
                    <button type="button" class="toggle-pass" id="toggle-pass" aria-label="Mostrar contrase&ntilde;a"><%= Ico("eye", "") %></button>
                </div>
            </div>
            <button type="submit" class="btn btn-primary" id="btn-login"><%= Ico("headphones", "") %> Iniciar sesi&oacute;n</button>
        </form>

        <div class="demo">
            Usuarios de prueba:<br>
            Normal: <b>userNormal</b> / <b>12345678</b><br>
            Administrador: <b>userAdmin</b> / <b>12345678</b>
        </div>
    </section>
</main>

<script>
(function () {
    var btn = document.getElementById('toggle-pass');
    var inp = document.getElementById('password');
    btn.addEventListener('click', function () {
        inp.type = inp.type === 'password' ? 'text' : 'password';
        inp.focus();
    });
    document.getElementById('login-form').addEventListener('submit', function (e) {
        var u = document.getElementById('username');
        if (!u.value.trim() || !inp.value) {
            e.preventDefault();
            (u.value.trim() ? inp : u).focus();
            this.classList.remove('shake'); void this.offsetWidth; this.classList.add('shake');
        }
    });
})();
</script>
</body>
</html>
