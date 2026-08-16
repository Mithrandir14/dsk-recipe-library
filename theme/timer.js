/**
 * Click-to-start timers for recipe step timer badges.
 *
 * `cook build web`'s static export renders ⏱️ badges as inert text — the
 * interactive timer only exists in the dynamic `cook server` app, which
 * this static site doesn't ship. This appends the missing behavior onto
 * the generator's own keyboard-shortcuts.js bundle (loaded on every page)
 * rather than editing any generated HTML.
 */
(function() {
    'use strict';

    function parseDurationSeconds(text) {
        // Matches "6 minutes" and ranges like "20-25 minutes" (uses the
        // upper bound of a range as the timer length).
        const match = text.match(/([\d.]+)(?:\s*-\s*([\d.]+))?\s*(second|minute|hour)/i);
        if (!match) return null;
        const value = parseFloat(match[2] || match[1]);
        const unit = match[3].toLowerCase();
        const perUnit = unit === 'second' ? 1 : unit === 'minute' ? 60 : 3600;
        const seconds = Math.round(value * perUnit);
        return seconds > 0 ? seconds : null;
    }

    function formatRemaining(seconds) {
        const m = Math.floor(seconds / 60);
        const s = seconds % 60;
        return m + ':' + String(s).padStart(2, '0');
    }

    function playChime() {
        try {
            const Ctx = window.AudioContext || window.webkitAudioContext;
            const ctx = new Ctx();
            [880, 1320].forEach(function(freq, i) {
                const osc = ctx.createOscillator();
                const gain = ctx.createGain();
                osc.frequency.value = freq;
                osc.connect(gain);
                gain.connect(ctx.destination);
                const start = ctx.currentTime + i * 0.18;
                gain.gain.setValueAtTime(0.0001, start);
                gain.gain.exponentialRampToValueAtTime(0.2, start + 0.02);
                gain.gain.exponentialRampToValueAtTime(0.0001, start + 0.35);
                osc.start(start);
                osc.stop(start + 0.4);
            });
        } catch (e) {
            // Audio unavailable (autoplay policy, unsupported browser) —
            // the visual "Done!" state still shows either way.
        }
    }

    function initTimerBadge(el) {
        if (el.dataset.timerInit) return;
        el.dataset.timerInit = 'true';

        const originalText = el.textContent;
        const totalSeconds = parseDurationSeconds(originalText);
        if (totalSeconds === null) return;

        el.classList.add('timer-badge-clickable');
        el.setAttribute('role', 'button');
        el.setAttribute('tabindex', '0');
        el.title = 'Click to start timer';

        let remaining = totalSeconds;
        let intervalId = null;

        function stop() {
            if (intervalId) {
                clearInterval(intervalId);
                intervalId = null;
            }
        }

        function tick() {
            remaining -= 1;
            if (remaining <= 0) {
                stop();
                el.textContent = '⏰ Done!';
                el.classList.remove('timer-running');
                el.classList.add('timer-done');
                playChime();
                return;
            }
            el.textContent = '⏱️ ' + formatRemaining(remaining);
        }

        function start() {
            remaining = totalSeconds;
            el.classList.remove('timer-done');
            el.classList.add('timer-running');
            el.textContent = '⏱️ ' + formatRemaining(remaining);
            intervalId = setInterval(tick, 1000);
        }

        function reset() {
            stop();
            el.classList.remove('timer-running', 'timer-done');
            el.textContent = originalText;
        }

        el.addEventListener('click', function() {
            if (intervalId || el.classList.contains('timer-done')) {
                reset();
            } else {
                start();
            }
        });

        el.addEventListener('keydown', function(e) {
            if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                el.click();
            }
        });
    }

    function init() {
        document.querySelectorAll('.timer-badge').forEach(initTimerBadge);
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
})();
