/* =========================================================
   PoliMusic – app.js
   Reproductor global, filtros, modal de confirmacion,
   conteo de reproducciones (AJAX), preview de assets
   ========================================================= */
'use strict';

(function () {

    /* -------------------------------------------------------
       Utilidades
    ------------------------------------------------------- */
    function qs(sel, ctx) { return (ctx || document).querySelector(sel); }
    function qsa(sel, ctx) { return Array.from((ctx || document).querySelectorAll(sel)); }
    function fmtTime(sec) {
        if (!isFinite(sec)) return '--:--';
        var m = Math.floor(sec / 60), s = Math.floor(sec % 60);
        return m + ':' + (s < 10 ? '0' : '') + s;
    }
    function setRange(el, val) {
        el.value = val;
        el.style.setProperty('--val', (val / el.max * 100).toFixed(2) + '%');
    }

    /* -------------------------------------------------------
       Estado del reproductor
    ------------------------------------------------------- */
    var audio      = qs('#audio');
    var playlist   = [];   // [{id, src, title, artist, cover}]
    var queueIndex = -1;
    var shuffle    = false;
    var repeatMode = 0;    // 0=off 1=all 2=one
    var historyStack = [];

    /* -------------------------------------------------------
       Referencias al DOM del reproductor
    ------------------------------------------------------- */
    var btnPlay      = qs('#btn-play');
    var playIcon     = qs('#play-icon');
    var btnPrev      = qs('#btn-prev');
    var btnNext      = qs('#btn-next');
    var btnShuffle   = qs('#btn-shuffle');
    var btnRepeat    = qs('#btn-repeat');
    var repeatIcon   = qs('#repeat-icon');
    var btnMute      = qs('#btn-mute');
    var volIcon      = qs('#vol-icon');
    var seekEl       = qs('#seek');
    var volEl        = qs('#volume');
    var timeCur      = qs('#time-current');
    var timeTot      = qs('#time-total');
    var playerCover  = qs('#player-cover');
    var playerTitle  = qs('#player-title');
    var playerArtist = qs('#player-artist');

    if (!audio) return;

    /* -------------------------------------------------------
       Carga de canciones desde la pagina
    ------------------------------------------------------- */
    function refreshPlaylist() {
        playlist = [];
        qsa('[data-songlist] .song-row').forEach(function (row) {
            var t = row.dataset;
            if (t.src) playlist.push({ id: t.id, src: t.src, title: t.title, artist: t.artist, cover: t.cover });
        });
    }

    /* -------------------------------------------------------
       Reproducir un item (por indice dentro de playlist[])
    ------------------------------------------------------- */
    function playByIndex(idx) {
        if (idx < 0 || idx >= playlist.length) return;
        var item = playlist[idx];
        queueIndex = idx;

        audio.src = item.src;
        audio.load();
        audio.play().catch(function () {});

        playerTitle.textContent  = item.title;
        playerArtist.textContent = item.artist;
        if (playerCover) playerCover.src = item.cover;

        // Marca la fila activa
        qsa('.song-row.playing').forEach(function (r) { r.classList.remove('playing'); });
        qsa('.song-row[data-id="' + item.id + '"]').forEach(function (r) { r.classList.add('playing'); });

        document.title = item.title + ' – PoliMusic';
        incrementPlays(item.id);
        historyStack.push(idx);
    }

    /* -------------------------------------------------------
       Reproducir por datos externos (play-single / play-all)
    ------------------------------------------------------- */
    function playItem(item) {
        // Busca en la playlist actual
        var idx = playlist.findIndex(function (p) { return p.id === item.id; });
        if (idx >= 0) { playByIndex(idx); return; }
        // Si no esta en la lista activa, agrega como lista temporal
        playlist = [item];
        queueIndex = 0;
        playByIndex(0);
    }

    /* -------------------------------------------------------
       Siguiente / Anterior
    ------------------------------------------------------- */
    function nextTrack() {
        if (!playlist.length) return;
        if (repeatMode === 2) { playByIndex(queueIndex); return; }
        var next;
        if (shuffle) {
            next = Math.floor(Math.random() * playlist.length);
        } else {
            next = queueIndex + 1;
            if (next >= playlist.length) {
                if (repeatMode === 1) { next = 0; } else { return; }
            }
        }
        playByIndex(next);
    }

    function prevTrack() {
        if (!playlist.length) return;
        if (audio.currentTime > 3) { audio.currentTime = 0; return; }
        var prev;
        if (historyStack.length > 1) {
            historyStack.pop(); // saca el actual
            prev = historyStack[historyStack.length - 1];
            historyStack.pop(); // se volvera a agregar en playByIndex
        } else {
            prev = queueIndex > 0 ? queueIndex - 1 : 0;
        }
        playByIndex(prev);
    }

    /* -------------------------------------------------------
       Eventos del reproductor
    ------------------------------------------------------- */
    audio.addEventListener('timeupdate', function () {
        if (!audio.duration) return;
        var pct = (audio.currentTime / audio.duration) * 1000;
        setRange(seekEl, Math.floor(pct));
        timeCur.textContent = fmtTime(audio.currentTime);
    });

    audio.addEventListener('loadedmetadata', function () {
        timeTot.textContent = fmtTime(audio.duration);
        // Rellena las columnas de duracion en la tabla de canciones
        var src = audio.src;
        qsa('.song-row').forEach(function (row) {
            if (row.dataset.src === src || decodeURIComponent(row.dataset.src) === decodeURIComponent(src)) {
                var d = row.querySelector('[data-dur]');
                if (d) d.textContent = fmtTime(audio.duration);
            }
        });
    });

    audio.addEventListener('play', function () {
        playIcon.href.baseVal = '#i-pause';
        document.body.classList.add('is-playing');
        document.body.classList.remove('paused');
    });

    audio.addEventListener('pause', function () {
        playIcon.href.baseVal = '#i-play';
        document.body.classList.remove('is-playing');
        document.body.classList.add('paused');
    });

    audio.addEventListener('ended', function () { nextTrack(); });

    audio.addEventListener('volumechange', function () {
        var href = audio.muted || audio.volume === 0 ? '#i-mute' : '#i-volume';
        volIcon.href.baseVal = href;
    });

    audio.addEventListener('error', function () {
        console.warn('[PoliMusic] Error al cargar el audio:', audio.src);
        // Intenta el siguiente automaticamente
        setTimeout(nextTrack, 1200);
    });

    btnPlay.addEventListener('click', function () {
        if (!audio.src && playlist.length) { playByIndex(0); return; }
        if (audio.paused) audio.play().catch(function () {});
        else audio.pause();
    });

    btnNext.addEventListener('click', nextTrack);
    btnPrev.addEventListener('click', prevTrack);

    btnShuffle.addEventListener('click', function () {
        shuffle = !shuffle;
        btnShuffle.classList.toggle('on', shuffle);
    });

    btnRepeat.addEventListener('click', function () {
        repeatMode = (repeatMode + 1) % 3;
        btnRepeat.classList.toggle('on', repeatMode > 0);
        var icons = ['#i-repeat', '#i-repeat', '#i-repeat-one'];
        repeatIcon.href.baseVal = icons[repeatMode];
        btnRepeat.title = ['Repetir', 'Repetir todo', 'Repetir una'].split(',')[repeatMode] || 'Repetir';
    });

    btnMute.addEventListener('click', function () { audio.muted = !audio.muted; });

    seekEl.addEventListener('input', function () {
        if (audio.duration) audio.currentTime = (seekEl.value / 1000) * audio.duration;
        seekEl.style.setProperty('--val', (seekEl.value / seekEl.max * 100).toFixed(2) + '%');
    });

    volEl.addEventListener('input', function () {
        audio.volume = volEl.value / 100;
        audio.muted = false;
        volEl.style.setProperty('--val', (volEl.value / volEl.max * 100).toFixed(2) + '%');
    });
    // Inicializa posicion del rango de volumen
    volEl.style.setProperty('--val', '80%');
    audio.volume = 0.8;

    /* -------------------------------------------------------
       Delegacion de clics en filas de canciones
    ------------------------------------------------------- */
    document.addEventListener('click', function (e) {
        // Clic en fila (o hijo de fila)
        var row = e.target.closest('.song-row');
        if (row && !e.target.closest('a[href]')) {
            refreshPlaylist();
            var idx = playlist.findIndex(function (p) { return p.id === row.dataset.id; });
            if (idx >= 0) {
                if (idx === queueIndex && !audio.paused) { audio.pause(); return; }
                playByIndex(idx);
            }
            return;
        }

        // Boton play-single (admin / listados)
        var ps = e.target.closest('[data-play-single]');
        if (ps) {
            e.preventDefault();
            refreshPlaylist();
            playItem({ id: ps.dataset.id, src: ps.dataset.src, title: ps.dataset.title, artist: ps.dataset.artist, cover: ps.dataset.cover });
            return;
        }

        // play-fab con data-play-all -> reproduce toda la lista visible
        var pa = e.target.closest('[data-play-all]');
        if (pa) {
            e.preventDefault();
            var tableId = pa.dataset.playAll;
            var rows = qsa('#' + tableId + ' .song-row');
            if (!rows.length) return;
            playlist = rows.map(function (r) {
                return { id: r.dataset.id, src: r.dataset.src, title: r.dataset.title, artist: r.dataset.artist, cover: r.dataset.cover };
            });
            queueIndex = -1;
            playByIndex(shuffle ? Math.floor(Math.random() * playlist.length) : 0);
            return;
        }

        // play-fab con data-href -> navega a esa URL
        var ph = e.target.closest('.play-fab[data-href]');
        if (ph) {
            e.preventDefault();
            window.location.href = ph.dataset.href;
            return;
        }
    });

    /* -------------------------------------------------------
       Incremento de reproducciones via AJAX (fetch)
    ------------------------------------------------------- */
    function incrementPlays(songId) {
        if (!songId) return;
        fetch('api_plays.asp?id=' + encodeURIComponent(songId), { method: 'POST', headers: { 'X-Requested-With': 'XMLHttpRequest' } })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (data && data.plays !== undefined) {
                    qsa('.song-row[data-id="' + songId + '"] [data-plays]').forEach(function (el) {
                        el.textContent = Number(data.plays).toLocaleString();
                    });
                }
            })
            .catch(function (err) { console.warn('[PoliMusic] plays API error:', err); });
    }

    /* -------------------------------------------------------
       Topbar: sombra al hacer scroll en el main
    ------------------------------------------------------- */
    var main    = qs('#main');
    var topbar  = qs('#topbar');
    if (main && topbar) {
        main.addEventListener('scroll', function () {
            topbar.classList.toggle('scrolled', main.scrollTop > 10);
        });
    }

    /* -------------------------------------------------------
       Historial navegador (atras / adelante)
    ------------------------------------------------------- */
    var btnBack    = qs('#btn-back');
    var btnForward = qs('#btn-forward');
    if (btnBack)    btnBack.addEventListener('click', function () { window.history.back(); });
    if (btnForward) btnForward.addEventListener('click', function () { window.history.forward(); });

    /* -------------------------------------------------------
       Filtro de busqueda en la lista de canciones
    ------------------------------------------------------- */
    document.addEventListener('input', function (e) {
        var inp = e.target;
        var tableId = inp.dataset.filter;
        if (!tableId) return;
        var q = inp.value.trim().toLowerCase();
        var rows = qsa('#' + tableId + ' .song-row, [id="' + tableId + '"] [data-row]');
        var noResults = qs('#' + tableId + '-noresults');
        var visible = 0;
        rows.forEach(function (row) {
            var text = row.textContent.toLowerCase();
            var show = q === '' || text.indexOf(q) >= 0;
            row.style.display = show ? '' : 'none';
            if (show) visible++;
        });
        if (noResults) noResults.hidden = (visible > 0 || q === '');
    });

    /* -------------------------------------------------------
       Modal de confirmacion para formularios de eliminacion
    ------------------------------------------------------- */
    var modal      = qs('#confirm-modal');
    var modalText  = qs('#confirm-text');
    var btnOk      = qs('#confirm-ok');
    var btnCancel  = qs('#confirm-cancel');
    var pendingForm = null;

    if (modal) {
        document.addEventListener('submit', function (e) {
            var form = e.target;
            if (!form.dataset.confirm) return;
            e.preventDefault();
            pendingForm = form;
            if (modalText) modalText.textContent = form.dataset.confirm;
            modal.hidden = false;
            modal.focus();
        });

        btnOk.addEventListener('click', function () {
            modal.hidden = true;
            if (pendingForm) { pendingForm.removeAttribute('data-confirm'); pendingForm.submit(); }
        });

        btnCancel.addEventListener('click', function () {
            modal.hidden = true;
            pendingForm = null;
        });

        modal.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') { modal.hidden = true; pendingForm = null; }
        });

        modal.addEventListener('click', function (e) {
            if (e.target === modal) { modal.hidden = true; pendingForm = null; }
        });
    }

    /* -------------------------------------------------------
       Cierre de mensajes flash
    ------------------------------------------------------- */
    document.addEventListener('click', function (e) {
        var btn = e.target.closest('[data-dismiss]');
        if (btn) {
            var flash = btn.closest('.flash');
            if (flash) flash.remove();
        }
    });

    /* -------------------------------------------------------
       Preview de assets (selects en formularios admin)
    ------------------------------------------------------- */
    document.addEventListener('change', function (e) {
        var sel = e.target;
        if (!sel.dataset.preview) return;
        var opt = sel.options[sel.selectedIndex];
        var url = opt ? opt.dataset.url : '';
        var kind = sel.dataset.preview;
        var previewId = sel.id + '-preview';
        var preview = qs('#' + previewId);

        if (kind === 'audio') {
            if (preview) {
                preview.src = url || '';
                if (url) preview.load();
            }
        } else {
            if (preview) {
                if (url) { preview.src = url; preview.style.display = ''; }
                else { preview.src = ''; preview.style.display = 'none'; }
            }
        }
    });

    /* -------------------------------------------------------
       Toggle de visibilidad de contrasena (login)
    ------------------------------------------------------- */
    var togglePass = qs('#toggle-pass');
    if (togglePass) {
        togglePass.addEventListener('click', function () {
            var inp = qs('#password');
            if (inp) inp.type = inp.type === 'password' ? 'text' : 'password';
        });
    }

    /* -------------------------------------------------------
       Auto-play si la URL tiene ?autoplay=1
    ------------------------------------------------------- */
    if (window.location.search.indexOf('autoplay=1') >= 0) {
        window.addEventListener('load', function () {
            refreshPlaylist();
            if (playlist.length) setTimeout(function () { playByIndex(0); }, 600);
        });
    }

    /* -------------------------------------------------------
       Keyboard shortcuts globales
    ------------------------------------------------------- */
    document.addEventListener('keydown', function (e) {
        var tag = document.activeElement ? document.activeElement.tagName : '';
        if (tag === 'INPUT' || tag === 'TEXTAREA' || tag === 'SELECT') return;
        switch (e.code) {
            case 'Space':
                e.preventDefault();
                if (!audio.src && playlist.length) { playByIndex(0); break; }
                if (audio.paused) audio.play().catch(function () {});
                else audio.pause();
                break;
            case 'ArrowRight': e.preventDefault(); nextTrack(); break;
            case 'ArrowLeft': e.preventDefault(); prevTrack(); break;
            case 'KeyM': audio.muted = !audio.muted; break;
            case 'KeyS': btnShuffle.click(); break;
        }
    });

    /* -------------------------------------------------------
       Inicializacion
    ------------------------------------------------------- */
    refreshPlaylist();

})();
