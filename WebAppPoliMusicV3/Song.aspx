<%@ Page Title="Canciones" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Song.aspx.cs" Inherits="WebAppPoliMusicV3.SongPage" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <style type="text/css">
        :root {
            --pm-ink: #2e2542;
            --pm-ink-soft: #726a86;
            --pm-line: #ece2fb;
            --pm-p50: #f7f2ff;
            --pm-p100: #eee2ff;
            --pm-p200: #ddc9fb;
            --pm-p300: #c6a9f2;
            --pm-p400: #a982e6;
            --pm-p500: #8b5fd6;
            --pm-p600: #7145bd;
            --pm-shadow: 0 18px 45px rgba(112, 69, 189, 0.13);
        }

        .pm-body {
            padding: 28px 0 48px;
            font-family: 'Segoe UI', system-ui, -apple-system, 'Helvetica Neue', Arial, sans-serif;
            color: var(--pm-ink);
        }

        .pm-container {
            max-width: 1100px;
            margin: 0 auto;
            padding: 0 20px;
        }

        /* ---------- header card ---------- */
        .pm-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 18px;
            padding: 18px 24px;
            border: 1px solid var(--pm-line);
            border-radius: 22px;
            background: linear-gradient(120deg, #ffffff 0%, #faf6ff 100%);
            box-shadow: var(--pm-shadow);
        }

        .pm-brand { display: flex; align-items: center; gap: 14px; }

        .pm-brand-logo {
            display: grid;
            place-items: center;
            width: 50px;
            height: 50px;
            border-radius: 16px;
            font-size: 26px;
            line-height: 1;
            color: #ffffff;
            background: linear-gradient(135deg, var(--pm-p300), var(--pm-p500));
            box-shadow: 0 10px 22px rgba(139, 95, 214, 0.34);
        }

        .pm-brand-name {
            display: block;
            font-size: 20px;
            font-weight: 800;
            letter-spacing: -0.2px;
        }

        .pm-brand-sub {
            display: block;
            font-size: 11px;
            font-weight: 600;
            letter-spacing: 0.16em;
            text-transform: uppercase;
            color: var(--pm-ink-soft);
        }

        .pm-user-box { display: flex; align-items: center; gap: 14px; }

        .pm-avatar {
            display: grid;
            place-items: center;
            width: 46px;
            height: 46px;
            border-radius: 50%;
            font-size: 17px;
            font-weight: 800;
            color: #ffffff;
            background: linear-gradient(135deg, #d9c6fb, var(--pm-p500));
            box-shadow: 0 8px 18px rgba(112, 69, 189, 0.28);
            overflow: hidden;
            position: relative;
        }

        .pm-avatar img {
            position: absolute;
            top: 0; left: 0;
            width: 100%; height: 100%;
            object-fit: cover;
        }

        .pm-user-text { display: flex; flex-direction: column; line-height: 1.3; }

        .pm-welcome {
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 0.16em;
            text-transform: uppercase;
            color: var(--pm-ink-soft);
        }

        .pm-user-name {
            font-size: 18px;
            font-weight: 800;
            color: var(--pm-p600);
            letter-spacing: -0.2px;
        }

        /* ---------- main panel ---------- */
        .pm-panel {
            margin-top: 22px;
            overflow: hidden;
            border: 1px solid var(--pm-line);
            border-radius: 24px;
            background: #ffffff;
            box-shadow: var(--pm-shadow);
        }

        .pm-panel-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            padding: 22px 26px 10px;
        }

        .pm-panel-head h2 {
            margin: 0;
            font-size: 22px;
            font-weight: 800;
            letter-spacing: -0.3px;
        }

        .pm-count {
            padding: 6px 14px;
            border-radius: 999px;
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 0.1em;
            text-transform: uppercase;
            color: var(--pm-p600);
            background: var(--pm-p100);
        }

        /* ---------- table ---------- */
        .pm-table-wrap {
            padding: 4px 14px 20px;
            overflow-x: auto;
        }

        table.pm-songs {
            width: 100%;
            min-width: 880px;
            border-collapse: separate;
            border-spacing: 0 9px;
        }

        table.pm-songs thead th {
            padding: 12px 16px;
            text-align: left;
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 0.16em;
            text-transform: uppercase;
            white-space: nowrap;
            color: var(--pm-p600);
            background: linear-gradient(180deg, #f8f3ff, #efe4ff);
            border-top: 1px solid var(--pm-line);
            border-bottom: 1px solid var(--pm-line);
        }

        table.pm-songs thead th:first-child {
            border-left: 1px solid var(--pm-line);
            border-radius: 14px 0 0 14px;
        }
        table.pm-songs thead th:last-child {
            border-right: 1px solid var(--pm-line);
            border-radius: 0 14px 14px 0;
        }

        .pm-col-id { width: 110px; }
        .pm-col-name { width: 220px; }
        .pm-col-plays { width: 140px; }
        .pm-col-play { width: auto; }

        table.pm-songs tbody tr {
            background: #fdfbff;
            transition: background 0.18s ease;
        }
        table.pm-songs tbody tr:hover { background: #f8f2ff; }

        table.pm-songs tbody td {
            padding: 12px 16px;
            vertical-align: middle;
            border-top: 1px solid #f4edfe;
            border-bottom: 1px solid #f4edfe;
        }

        table.pm-songs tbody tr:hover td { border-color: #e8dafc; }

        table.pm-songs tbody td:first-child {
            border-left: 1px solid #f4edfe;
            border-radius: 14px 0 0 14px;
        }
        table.pm-songs tbody td:last-child {
            border-right: 1px solid #f4edfe;
            border-radius: 0 14px 14px 0;
        }

        .pm-id-badge {
            display: inline-block;
            min-width: 32px;
            padding: 5px 9px;
            border-radius: 9px;
            text-align: center;
            font-size: 13px;
            font-weight: 800;
            color: var(--pm-p600);
            background: var(--pm-p50);
        }

        .pm-song-cell { display: flex; align-items: center; gap: 12px; }

        .pm-cover {
            display: grid;
            place-items: center;
            width: 36px;
            height: 36px;
            flex: 0 0 36px;
            border-radius: 11px;
            font-size: 15px;
            color: #ffffff;
            background: linear-gradient(135deg, var(--pm-p200), var(--pm-p400));
            box-shadow: inset 0 0 0 1px rgba(255, 255, 255, 0.45);
        }

        .pm-song-name { font-size: 15px; font-weight: 700; letter-spacing: -0.1px; }

        .pm-path {
            display: inline-block;
            max-width: 280px;
            overflow: hidden;
            padding: 5px 10px;
            border-radius: 8px;
            font-family: Consolas, 'Courier New', monospace;
            font-size: 12px;
            color: var(--pm-ink-soft);
            background: var(--pm-p50);
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .pm-plays {
            display: inline-block;
            min-width: 42px;
            padding: 5px 12px;
            border-radius: 999px;
            text-align: center;
            font-size: 13px;
            font-weight: 800;
            color: var(--pm-p600);
            background: var(--pm-p100);
        }

        /* ---------- player ---------- */
        .pm-player {
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

        .pm-player.playing {
            border-color: var(--pm-p200);
            box-shadow: 0 8px 20px rgba(139, 95, 214, 0.18);
        }

        .pm-icon-btn {
            display: grid;
            place-items: center;
            padding: 0;
            border: 0;
            cursor: pointer;
            background: transparent;
            color: var(--pm-p600);
            transition: color 0.16s ease, transform 0.16s ease;
        }

        .pm-icon-btn:hover { color: var(--pm-p500); }

        .pm-play-btn {
            width: 36px;
            height: 36px;
            flex: 0 0 36px;
            min-width: 36px;
            border-radius: 50%;
            color: #ffffff;
            background: linear-gradient(135deg, var(--pm-p300), var(--pm-p500));
            box-shadow: 0 8px 18px rgba(139, 95, 214, 0.34);
        }

        .pm-play-btn:hover { color: #ffffff; transform: scale(1.06); }
        .pm-play-btn svg { width: 17px; height: 17px; fill: currentColor; }
        .pm-play-btn .ic-pause { display: none; }
        .pm-player.playing .pm-play-btn .ic-play { display: none; }
        .pm-player.playing .pm-play-btn .ic-pause { display: block; }

        .pm-time {
            min-width: 78px;
            white-space: nowrap;
            font-family: Consolas, 'Courier New', monospace;
            font-size: 12px;
            font-weight: 700;
            color: var(--pm-ink-soft);
        }

        .pm-bar {
            position: relative;
            width: 78px;
            height: 6px;
            flex: 1 1 auto;
            min-width: 50px;
            overflow: hidden;
            border-radius: 999px;
            background: #e6ddf7;
            cursor: pointer;
        }

        .pm-fill {
            width: 0;
            height: 100%;
            border-radius: 999px;
            background: linear-gradient(90deg, var(--pm-p300), var(--pm-p500));
            transition: width 0.1s linear;
        }

        .pm-vol-btn { width: 26px; height: 26px; flex: 0 0 26px; }
        .pm-vol-btn svg { width: 18px; height: 18px; fill: currentColor; }
        .pm-vol-btn .ic-muted { display: none; }
        .pm-player.muted .pm-vol-btn .ic-vol { display: none; }
        .pm-player.muted .pm-vol-btn .ic-muted { display: block; }

        .pm-more-btn { width: 26px; height: 26px; flex: 0 0 26px; }
        .pm-more-btn svg { width: 18px; height: 18px; fill: currentColor; }

        .pm-menu {
            position: absolute;
            top: calc(100% + 8px);
            right: 0;
            z-index: 40;
            display: none;
            min-width: 158px;
            padding: 6px;
            border: 1px solid var(--pm-line);
            border-radius: 14px;
            background: #ffffff;
            box-shadow: 0 18px 36px rgba(112, 69, 189, 0.2);
        }

        .pm-menu.open { display: block; }

        table.pm-songs tbody tr:last-child .pm-menu {
            top: auto;
            bottom: calc(100% + 8px);
        }

        .pm-menu button {
            display: block;
            width: 100%;
            padding: 9px 12px;
            border: 0;
            border-radius: 9px;
            font: inherit;
            font-size: 13px;
            text-align: left;
            color: var(--pm-ink);
            background: transparent;
            cursor: pointer;
        }

        .pm-menu button:hover { background: var(--pm-p50); color: var(--pm-p600); }

        /* ---------- messages ---------- */
        .pm-message {
            display: block;
            padding: 0 26px 24px;
            font-size: 14px;
            color: var(--pm-p600);
        }

        .pm-empty {
            display: block;
            padding: 28px 26px 34px;
            font-size: 14px;
            color: var(--pm-ink-soft);
        }

        @media (max-width: 720px) {
            .pm-header { flex-direction: column; align-items: flex-start; }
            .pm-user-box { width: 100%; justify-content: space-between; }
        }
    </style>

    <div class="pm-body">
        <div class="pm-container">

            <header class="pm-header">
                <div class="pm-brand">
                    <div class="pm-brand-logo">&#9835;</div>
                    <div>
                        <span class="pm-brand-name">PoliMusic</span>
                        <span class="pm-brand-sub">Canciones</span>
                    </div>
                </div>

                <div class="pm-user-box">
                    <div class="pm-avatar">
                        <asp:Literal ID="litInitial" runat="server" />
                        <asp:Image ID="imgUserPhoto" runat="server" CssClass="pm-avatar-img" Visible="false" AlternateText="Usuario" />
                    </div>
                    <div class="pm-user-text">
                        <span class="pm-welcome">Bienvenido</span>
                        <asp:Label ID="lblUserName" runat="server" CssClass="pm-user-name" />
                    </div>
                </div>
            </header>

            <section class="pm-panel">
                <div class="pm-panel-head">
                    <h2>Lista de Canciones</h2>
                    <asp:Label ID="lblCount" runat="server" CssClass="pm-count" />
                </div>

                <asp:Panel ID="pnlSongs" runat="server">
                    <div class="pm-table-wrap">
                        <table class="pm-songs">
                            <thead>
                                <tr>
                                    <th class="pm-col-id">ID Canci&oacute;n</th>
                                    <th class="pm-col-name">Nombre</th>
                                    <th>Ruta</th>
                                    <th class="pm-col-plays">Reproducciones</th>
                                    <th class="pm-col-play">Reproducir</th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptSongs" runat="server">
                                    <ItemTemplate>
                                        <tr data-id='<%# Eval("ID") %>'>
                                            <td class="pm-col-id"><span class="pm-id-badge"><%# Eval("ID") %></span></td>
                                            <td class="pm-col-name">
                                                <div class="pm-song-cell">
                                                    <span class="pm-cover">&#9834;</span>
                                                    <span class="pm-song-name"><%# Encode(Eval("Name")) %></span>
                                                </div>
                                            </td>
                                            <td><code class="pm-path"><%# Encode(Eval("Path")) %></code></td>
                                            <td class="pm-col-plays">
                                                <span class="pm-plays" id='plays-<%# Eval("ID") %>'><%# Eval("Plays") %></span>
                                            </td>
                                            <td class="pm-col-play">
                                                <div class="pm-player">
                                                    <button type="button" class="pm-icon-btn pm-play-btn" title="Reproducir / Pausar">
                                                        <svg class="ic-play" viewBox="0 0 24 24" aria-hidden="true"><path d="M8 5.2v13.6L19 12z" /></svg>
                                                        <svg class="ic-pause" viewBox="0 0 24 24" aria-hidden="true"><path d="M7 5h3.4v14H7zM13.6 5H17v14h-3.4z" /></svg>
                                                    </button>
                                                    <span class="pm-time">0:00 / 0:00</span>
                                                    <div class="pm-bar" title="Buscar"><div class="pm-fill"></div></div>
                                                    <button type="button" class="pm-icon-btn pm-vol-btn" title="Silenciar">
                                                        <svg class="ic-vol" viewBox="0 0 24 24" aria-hidden="true"><path d="M4 9v6h4l5 4.2V4.8L8 9H4z" /><path d="M16.2 8.4a5 5 0 0 1 0 7.2l1.4 1.4a7 7 0 0 0 0-10z" /></svg>
                                                        <svg class="ic-muted" viewBox="0 0 24 24" aria-hidden="true"><path d="M4 9v6h4l5 4.2V4.8L8 9H4z" /><path d="M16.3 9.1l1.4-1.4 1.8 1.8 1.8-1.8 1.4 1.4-1.8 1.8 1.8 1.8-1.4 1.4-1.8-1.8-1.8 1.8-1.4-1.4 1.8-1.8z" /></svg>
                                                    </button>
                                                    <button type="button" class="pm-icon-btn pm-more-btn" title="M&aacute;s opciones">
                                                        <svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="5" r="1.9" /><circle cx="12" cy="12" r="1.9" /><circle cx="12" cy="19" r="1.9" /></svg>
                                                    </button>
                                                    <div class="pm-menu">
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

                <asp:Label ID="lblMessage" runat="server" CssClass="pm-empty" />
            </section>

        </div>
    </div>

    <script type="text/javascript">
        (function () {
            'use strict';

            var players = document.querySelectorAll('.pm-player');
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
                var playBtn = player.querySelector('.pm-play-btn');
                var timeLabel = player.querySelector('.pm-time');
                var bar = player.querySelector('.pm-bar');
                var fill = player.querySelector('.pm-fill');
                var volBtn = player.querySelector('.pm-vol-btn');
                var moreBtn = player.querySelector('.pm-more-btn');
                var menu = player.querySelector('.pm-menu');

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

</asp:Content>
