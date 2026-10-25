        </div><!-- /content -->
    </main>

    <!-- ================= PLAYER ================= -->
    <footer class="player" id="player" aria-label="Reproductor">
        <div class="now">
            <img id="player-cover" src="SongFilesAndImages_resources/PlaylistImages/default.jpg" alt="Portada">
            <div>
                <div class="t" id="player-title">Selecciona una canci&oacute;n</div>
                <div class="s" id="player-artist">PoliMusic</div>
            </div>
        </div>
        <div class="controls">
            <div class="ctrl-row">
                <button type="button" class="ctrl" id="btn-shuffle" title="Aleatorio" aria-label="Aleatorio"><%= Ico("shuffle", "") %></button>
                <button type="button" class="ctrl" id="btn-prev" title="Anterior" aria-label="Anterior"><%= Ico("prev", "") %></button>
                <button type="button" class="ctrl-main" id="btn-play" title="Reproducir" aria-label="Reproducir">
                    <svg class="icon" id="play-icon" aria-hidden="true"><use href="#i-play"></use></svg>
                </button>
                <button type="button" class="ctrl" id="btn-next" title="Siguiente" aria-label="Siguiente"><%= Ico("next", "") %></button>
                <button type="button" class="ctrl" id="btn-repeat" title="Repetir" aria-label="Repetir">
                    <svg class="icon" id="repeat-icon" aria-hidden="true"><use href="#i-repeat"></use></svg>
                </button>
            </div>
            <div class="progress-row">
                <span class="time" id="time-current">0:00</span>
                <input type="range" class="range" id="seek" min="0" max="1000" value="0" step="1" aria-label="Progreso">
                <span class="time" id="time-total">0:00</span>
            </div>
        </div>
        <div class="vol">
            <button type="button" class="ctrl" id="btn-mute" title="Silenciar" aria-label="Silenciar">
                <svg class="icon" id="vol-icon" aria-hidden="true"><use href="#i-volume"></use></svg>
            </button>
            <input type="range" class="range" id="volume" min="0" max="100" value="80" aria-label="Volumen">
        </div>
        <audio id="audio" preload="metadata"></audio>
    </footer>
</div>

<!-- Modal de confirmacion -->
<div class="modal-backdrop" id="confirm-modal" hidden>
    <div class="modal" role="dialog" aria-modal="true" aria-labelledby="confirm-title">
        <div class="modal-icon"><%= Ico("trash", "icon-lg") %></div>
        <h3 id="confirm-title">&iquest;Est&aacute;s seguro?</h3>
        <p id="confirm-text">Esta acci&oacute;n no se puede deshacer.</p>
        <div class="modal-actions">
            <button type="button" class="btn btn-ghost" id="confirm-cancel">Cancelar</button>
            <button type="button" class="btn btn-danger" id="confirm-ok">Eliminar</button>
        </div>
    </div>
</div>

<script src="js/app.js?v=3"></script>
</body>
</html>
<% DbClose %>
