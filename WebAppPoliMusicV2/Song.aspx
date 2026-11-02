<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Song.aspx.cs" Inherits="WebAppPoliMusicV2.Song" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>PoliMusic · Song list</title>
    <style type="text/css">
        :root {
            --ink: #2e2542;
            --ink-soft: #726a86;
            --line: #ece2fb;
            --p50: #f7f2ff;
            --p100: #eee2ff;
            --p200: #ddc9fb;
            --p300: #c6a9f2;
            --p400: #a982e6;
            --p500: #8b5fd6;
            --p600: #7145bd;
            --shadow: 0 18px 45px rgba(112, 69, 189, 0.13);
        }

        * { box-sizing: border-box; }

        html, body { margin: 0; padding: 0; }

        body {
            min-height: 100vh;
            padding: 34px 20px 64px;
            font-family: 'Segoe UI', system-ui, -apple-system, 'Helvetica Neue', Arial, sans-serif;
            color: var(--ink);
            background-color: #f8f3ff;
            background-image:
                radial-gradient(1100px 520px at 6% -12%, #e6d5ff 0%, rgba(230, 213, 255, 0) 62%),
                radial-gradient(900px 470px at 102% -4%, #f4e8ff 0%, rgba(244, 232, 255, 0) 58%),
                linear-gradient(180deg, #fbf8ff 0%, #f2ebff 100%);
            background-attachment: fixed;
        }

        .app { max-width: 1100px; margin: 0 auto; }

        /* ---------- top bar ---------- */
        .topbar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 18px;
            padding: 16px 22px;
            border: 1px solid var(--line);
            border-radius: 22px;
            background: linear-gradient(120deg, #ffffff 0%, #faf6ff 100%);
            box-shadow: var(--shadow);
        }

        .brand { display: flex; align-items: center; gap: 14px; }

        .brand-logo {
            display: grid;
            place-items: center;
            width: 48px;
            height: 48px;
            border-radius: 16px;
            font-size: 24px;
            line-height: 1;
            color: #ffffff;
            background: linear-gradient(135deg, var(--p300), var(--p500));
            box-shadow: 0 10px 22px rgba(139, 95, 214, 0.34);
        }

        .brand-name { display: block; font-size: 19px; font-weight: 800; letter-spacing: -0.2px; }

        .brand-sub {
            display: block;
            font-size: 11px;
            font-weight: 600;
            letter-spacing: 0.16em;
            text-transform: uppercase;
            color: var(--ink-soft);
        }

        .user-box { display: flex; align-items: center; gap: 14px; }

        .avatar-wrap {
            position: relative;
            display: grid;
            place-items: center;
            width: 46px;
            height: 46px;
            overflow: hidden;
            border-radius: 50%;
            font-size: 17px;
            font-weight: 800;
            color: #ffffff;
            background: linear-gradient(135deg, #d9c6fb, var(--p500));
            box-shadow: 0 8px 18px rgba(112, 69, 189, 0.28);
        }

        .avatar-img {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .user-text { display: flex; flex-direction: column; line-height: 1.3; }

        .welcome {
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 0.16em;
            text-transform: uppercase;
            color: var(--ink-soft);
        }

        .user-name { font-size: 18px; font-weight: 800; color: var(--p600); letter-spacing: -0.2px; }

        .logout {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 20px;
            border-radius: 999px;
            font-size: 14px;
            font-weight: 700;
            color: #ffffff !important;
            text-decoration: none;
            background: linear-gradient(135deg, var(--p300), var(--p500));
            box-shadow: 0 10px 22px rgba(139, 95, 214, 0.32);
            transition: transform 0.18s ease, box-shadow 0.18s ease;
        }

        .logout:hover { transform: translateY(-1px); box-shadow: 0 14px 26px rgba(139, 95, 214, 0.42); }
        .logout:active { transform: translateY(0); }
        .logout svg { width: 15px; height: 15px; fill: currentColor; }

        /* ---------- panel ---------- */
        .panel {
            margin-top: 24px;
            overflow: hidden;
            border: 1px solid var(--line);
            border-radius: 24px;
            background: #ffffff;
            box-shadow: var(--shadow);
        }

        .panel-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            padding: 22px 26px 12px;
        }

        .panel-head h2 { margin: 0; font-size: 20px; font-weight: 800; letter-spacing: -0.3px; }

        .count {
            padding: 6px 13px;
            border-radius: 999px;
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 0.1em;
            text-transform: uppercase;
            color: var(--p600);
            background: var(--p100);
        }

        .table-wrap { padding: 4px 14px 20px; overflow-x: auto; }

        table.songs {
            width: 100%;
            min-width: 1000px;
            border-collapse: separate;
            border-spacing: 0 9px;
        }

        table.songs thead th {
            padding: 12px 16px;
            text-align: left;
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 0.16em;
            text-transform: uppercase;
            white-space: nowrap;
            color: var(--p600);
            background: linear-gradient(180deg, #f8f3ff, #efe4ff);
            border-top: 1px solid var(--line);
            border-bottom: 1px solid var(--line);
        }

        table.songs thead th:first-child { border-left: 1px solid var(--line); border-radius: 14px 0 0 14px; }
        table.songs thead th:last-child { border-right: 1px solid var(--line); border-radius: 0 14px 14px 0; }

        .col-id { width: 118px; }
        .col-name { width: 200px; }
        .col-plays { width: 156px; }
        .col-play { width: 380px; }

        table.songs tbody tr { background: #fdfbff; transition: background 0.18s ease; }
        table.songs tbody tr:hover { background: #f8f2ff; }

        table.songs tbody td {
            padding: 12px 16px;
            vertical-align: middle;
            border-top: 1px solid #f4edfe;
            border-bottom: 1px solid #f4edfe;
        }

        table.songs tbody tr:hover td { border-color: #e8dafc; }

        table.songs tbody td:first-child { border-left: 1px solid #f4edfe; border-radius: 14px 0 0 14px; }
        table.songs tbody td:last-child { border-right: 1px solid #f4edfe; border-radius: 0 14px 14px 0; }

        .id-badge {
            display: inline-block;
            min-width: 32px;
            padding: 5px 9px;
            border-radius: 9px;
            text-align: center;
            font-size: 13px;
            font-weight: 800;
            color: var(--p600);
            background: var(--p50);
        }

        .song-cell { display: flex; align-items: center; gap: 12px; }

        .cover {
            display: grid;
            place-items: center;
            width: 36px;
            height: 36px;
            flex: 0 0 36px;
            border-radius: 11px;
            font-size: 15px;
            color: #ffffff;
            background: linear-gradient(135deg, var(--p200), var(--p400));
            box-shadow: inset 0 0 0 1px rgba(255, 255, 255, 0.45);
        }

        .song-name { font-size: 15px; font-weight: 700; letter-spacing: -0.1px; }

        .path {
            display: inline-block;
            max-width: 320px;
            overflow: hidden;
            padding: 5px 10px;
            border-radius: 8px;
            font-family: Consolas, 'Courier New', monospace;
            font-size: 12px;
            color: var(--ink-soft);
            background: var(--p50);
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .plays {
            display: inline-block;
            min-width: 42px;
            padding: 5px 12px;
            border-radius: 999px;
            text-align: center;
            font-size: 13px;
            font-weight: 800;
            color: var(--p600);
            background: var(--p100);
        }

        /* ---------- player ---------- */
        .player {
            position: relative;
            z-index: 5;
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 7px 10px;
            border: 1px solid #ece3fb;
            border-radius: 999px;
            background: linear-gradient(180deg, #faf6ff, #f3ecff);
        }

        .player.playing {
            border-color: var(--p200);
            box-shadow: 0 8px 20px rgba(139, 95, 214, 0.18);
        }

        .icon-btn {
            display: grid;
            place-items: center;
            padding: 0;
            border: 0;
            cursor: pointer;
            background: transparent;
            color: var(--p600);
            transition: color 0.16s ease, transform 0.16s ease;
        }

        .icon-btn:hover { color: var(--p500); }

        .play-btn {
            width: 36px;
            height: 36px;
            flex: 0 0 36px;
            min-width: 36px;
            aspect-ratio: 1 / 1;
            border-radius: 50%;
            color: #ffffff;
            background: linear-gradient(135deg, var(--p300), var(--p500));
            box-shadow: 0 8px 18px rgba(139, 95, 214, 0.34);
        }

        .play-btn:hover { color: #ffffff; transform: scale(1.06); }
        .play-btn svg { width: 17px; height: 17px; fill: currentColor; }
        .play-btn .ic-pause { display: none; }
        .player.playing .play-btn .ic-play { display: none; }
        .player.playing .play-btn .ic-pause { display: block; }

        .time {
            min-width: 82px;
            white-space: nowrap;
            font-family: Consolas, 'Courier New', monospace;
            font-size: 12px;
            font-weight: 700;
            color: var(--ink-soft);
            letter-spacing: 0.02em;
        }

        .bar {
            position: relative;
            width: 78px;
            height: 6px;
            flex: 1 1 auto;
            min-width: 54px;
            overflow: hidden;
            border-radius: 999px;
            background: #e6ddf7;
            cursor: pointer;
        }

        .fill {
            width: 0;
            height: 100%;
            border-radius: 999px;
            background: linear-gradient(90deg, var(--p300), var(--p500));
            transition: width 0.1s linear;
        }

        .vol-btn, .more-btn { width: 26px; height: 26px; flex: 0 0 26px; }
        .vol-btn svg, .more-btn svg { width: 18px; height: 18px; fill: currentColor; }
        .vol-btn .ic-muted { display: none; }
        .player.muted .vol-btn .ic-vol { display: none; }
        .player.muted .vol-btn .ic-muted { display: block; }

        .menu {
            position: absolute;
            top: calc(100% + 8px);
            right: 0;
            z-index: 40;
            display: none;
            min-width: 158px;
            padding: 6px;
            border: 1px solid var(--line);
            border-radius: 14px;
            background: #ffffff;
            box-shadow: 0 18px 36px rgba(112, 69, 189, 0.2);
        }

        .menu.open { display: block; }

        /* the last row opens its menu upwards so it is not clipped by the table container */
        table.songs tbody tr:last-child .menu { top: auto; bottom: calc(100% + 8px); }

        .menu button {
            display: block;
            width: 100%;
            padding: 9px 12px;
            border: 0;
            border-radius: 9px;
            font: inherit;
            font-size: 13px;
            text-align: left;
            color: var(--ink);
            background: transparent;
            cursor: pointer;
        }

        .menu button:hover { background: var(--p50); color: var(--p600); }

        /* ---------- messages ---------- */
        .message {
            display: block;
            padding: 0 26px 24px;
            font-size: 14px;
            color: var(--p600);
        }

        .empty {
            display: block;
            padding: 28px 26px 34px;
            font-size: 14px;
            color: var(--ink-soft);
        }

        @media (max-width: 720px) {
            .topbar { flex-direction: column; align-items: flex-start; }
            .user-box { width: 100%; justify-content: space-between; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="app">

            <header class="topbar">
                <div class="brand">
                    <div class="brand-logo">&#9835;</div>
                    <div>
                        <span class="brand-name">PoliMusic</span>
                        <span class="brand-sub">Song library</span>
                    </div>
                </div>

                <div class="user-box">
                    <div class="avatar-wrap">
                        <asp:Literal ID="litInitial" runat="server" />
                        <asp:Image ID="imgUserPhoto" runat="server" CssClass="avatar-img" Visible="false" AlternateText="User" />
                    </div>
                    <div class="user-text">
                        <span class="welcome">Welcome</span>
                        <asp:Label ID="lblUserName" runat="server" CssClass="user-name" />
                    </div>
                    <asp:LinkButton ID="lnkLogout" runat="server" CssClass="logout" CausesValidation="false" OnClick="LnkLogout_Click" Text="Logout" />
                </div>
            </header>

            <section class="panel">
                <div class="panel-head">
                    <h2>Song list</h2>
                    <asp:Label ID="lblCount" runat="server" CssClass="count" />
                </div>

                <asp:Panel ID="pnlSongs" runat="server">
                    <div class="table-wrap">
                        <table class="songs">
                            <thead>
                                <tr>
                                    <th class="col-id">ID Canción</th>
                                    <th class="col-name">Nombre</th>
                                    <th>Ruta</th>
                                    <th class="col-plays">Reproducciones</th>
                                    <th class="col-play">Reproducir</th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptSongs" runat="server">
                                    <ItemTemplate>
                                        <tr data-id='<%# Eval("ID") %>'>
                                            <td class="col-id"><span class="id-badge"><%# Eval("ID") %></span></td>
                                            <td class="col-name">
                                                <div class="song-cell">
                                                    <span class="cover">&#9834;</span>
                                                    <span class="song-name"><%# Encode(Eval("Name")) %></span>
                                                </div>
                                            </td>
                                            <td><code class="path"><%# Encode(Eval("Path")) %></code></td>
                                            <td class="col-plays">
                                                <span class="plays" id='plays-<%# Eval("ID") %>'><%# Eval("Plays") %></span>
                                            </td>
                                            <td class="col-play">
                                                <div class="player">
                                                    <button type="button" class="icon-btn play-btn" title="Reproducir / Pausar">
                                                        <svg class="ic-play" viewBox="0 0 24 24" aria-hidden="true"><path d="M8 5.2v13.6L19 12z" /></svg>
                                                        <svg class="ic-pause" viewBox="0 0 24 24" aria-hidden="true"><path d="M7 5h3.4v14H7zM13.6 5H17v14h-3.4z" /></svg>
                                                    </button>
                                                    <span class="time">0:00 / 0:00</span>
                                                    <div class="bar" title="Buscar"><div class="fill"></div></div>
                                                    <button type="button" class="icon-btn vol-btn" title="Silenciar">
                                                        <svg class="ic-vol" viewBox="0 0 24 24" aria-hidden="true"><path d="M4 9v6h4l5 4.2V4.8L8 9H4z" /><path d="M16.2 8.4a5 5 0 0 1 0 7.2l1.4 1.4a7 7 0 0 0 0-10z" /></svg>
                                                        <svg class="ic-muted" viewBox="0 0 24 24" aria-hidden="true"><path d="M4 9v6h4l5 4.2V4.8L8 9H4z" /><path d="M16.3 9.1l1.4-1.4 1.8 1.8 1.8-1.8 1.4 1.4-1.8 1.8 1.8 1.8-1.4 1.4-1.8-1.8-1.8 1.8-1.4-1.4 1.8-1.8z" /></svg>
                                                    </button>
                                                    <button type="button" class="icon-btn more-btn" title="Más opciones">
                                                        <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="5" r="1.9" /><circle cx="12" cy="12" r="1.9" /><circle cx="12" cy="19" r="1.9" /></svg>
                                                    </button>
                                                    <div class="menu">
                                                        <button type="button" data-action="restart">Reiniciar</button>
                                                        <button type="button" data-action="mute">Silenciar / Activar</button>
                                                    </div>
                                                    <audio preload="metadata" src='<%# ResolveUrl(Eval("Path").ToString()) %>'></audio>
                                                </div>
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </div>
                </asp:Panel>

                <asp:Label ID="lblMessage" runat="server" CssClass="empty" />
            </section>

        </div>

        <script type="text/javascript">
            (function () {
                'use strict';

                var players = document.querySelectorAll('.player');
                if (!players.length) { return; }

                function formatTime(seconds) {
                    if (!isFinite(seconds) || seconds < 0) { seconds = 0; }
                    var m = Math.floor(seconds / 60);
                    var s = Math.floor(seconds % 60);
                    return m + ':' + (s < 10 ? '0' : '') + s;
                }

                function pauseOthers(current) {
                    Array.prototype.forEach.call(players, function (other) {
                        if (other === current) { return; }
                        var audio = other.querySelector('audio');
                        if (audio && !audio.paused) { audio.pause(); }
                    });
                }

                Array.prototype.forEach.call(players, function (player) {
                    var audio = player.querySelector('audio');
                    var playBtn = player.querySelector('.play-btn');
                    var timeLabel = player.querySelector('.time');
                    var bar = player.querySelector('.bar');
                    var fill = player.querySelector('.fill');
                    var volBtn = player.querySelector('.vol-btn');
                    var moreBtn = player.querySelector('.more-btn');
                    var menu = player.querySelector('.menu');

                    var row = player.parentNode;
                    while (row && row.tagName !== 'TR') { row = row.parentNode; }
                    var idSong = row ? row.getAttribute('data-id') : null;
                    var playsCell = idSong ? document.getElementById('plays-' + idSong) : null;
                    var counted = false;

                    function paint() {
                        var duration = audio.duration;
                        var current = audio.currentTime;
                        var total = (isFinite(duration) && duration > 0) ? formatTime(duration) : '0:00';
                        timeLabel.textContent = formatTime(current) + ' / ' + total;
                        var pct = (isFinite(duration) && duration > 0) ? (current / duration) * 100 : 0;
                        fill.style.width = pct + '%';
                    }

                    function registerPlay() {
                        if (counted) { return; }
                        counted = true;
                        if (!idSong || !window.fetch) { return; }
                        fetch('Song.aspx/RegisterPlay', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/json; charset=utf-8' },
                            credentials: 'same-origin',
                            body: JSON.stringify({ idSong: parseInt(idSong, 10) })
                        }).then(function (response) {
                            return response.ok ? response.json() : null;
                        }).then(function (result) {
                            if (result && typeof result.d === 'number' && playsCell) {
                                playsCell.textContent = result.d;
                            }
                        }).catch(function () { counted = false; });
                    }

                    playBtn.addEventListener('click', function () {
                        if (audio.paused) {
                            pauseOthers(player);
                            registerPlay();
                            var promise = audio.play();
                            if (promise && promise.catch) {
                                promise.catch(function () { player.classList.remove('playing'); });
                            }
                        } else {
                            audio.pause();
                        }
                    });

                    audio.addEventListener('play', function () { player.classList.add('playing'); });
                    audio.addEventListener('pause', function () { player.classList.remove('playing'); });
                    audio.addEventListener('timeupdate', paint);
                    audio.addEventListener('loadedmetadata', paint);
                    audio.addEventListener('durationchange', paint);
                    audio.addEventListener('ended', function () {
                        player.classList.remove('playing');
                        audio.currentTime = 0;
                        paint();
                    });
                    audio.addEventListener('error', function () { timeLabel.textContent = '0:00 / --:--'; });

                    bar.addEventListener('click', function (event) {
                        var rect = bar.getBoundingClientRect();
                        var ratio = (event.clientX - rect.left) / rect.width;
                        if (isFinite(audio.duration) && audio.duration > 0) {
                            audio.currentTime = Math.max(0, Math.min(1, ratio)) * audio.duration;
                            paint();
                        }
                    });

                    volBtn.addEventListener('click', function () {
                        audio.muted = !audio.muted;
                        player.classList.toggle('muted', audio.muted);
                    });

                    moreBtn.addEventListener('click', function (event) {
                        event.stopPropagation();
                        menu.classList.toggle('open');
                    });

                    document.addEventListener('click', function () { menu.classList.remove('open'); });

                    menu.addEventListener('click', function (event) {
                        var action = event.target.getAttribute('data-action');
                        if (action === 'restart') {
                            audio.currentTime = 0;
                            paint();
                        } else if (action === 'mute') {
                            audio.muted = !audio.muted;
                            player.classList.toggle('muted', audio.muted);
                        }
                        menu.classList.remove('open');
                    });

                    paint();
                });
            })();
        </script>
    </form>
</body>
</html>
