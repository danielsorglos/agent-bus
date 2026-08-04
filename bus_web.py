#!/usr/bin/env python3
"""
bus_web — Weboberflaeche fuer den agent-bus im sorgl.OS-Look.

Zeigt den gemeinsamen Kanal aller Claude-Accounts als Chat, die Aufgaben als
Board und das geteilte Wissen als Notizen. Du selbst trittst als Mensch auf und
kannst mitreden, Auftraege verteilen und Ergebnisse abnehmen.

Start:
    python bus_web.py                     # http://127.0.0.1:8787
    python bus_web.py --port 9000 --ich mensch-edgar

Nutzt denselben Kern wie der MCP-Server (agent_bus.py) — was hier passiert,
sehen die Agenten, und umgekehrt.
"""

import argparse
import json
import os
import sys
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

HIER = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HIER)

# Identitaet vor dem Import festlegen, damit der Kern nicht ueber eine fehlende
# Agent-ID stolpert; der echte Wert wird nach dem Parsen der Argumente gesetzt.
os.environ.setdefault("BUS_AGENT_ID", "mensch")
import agent_bus as bus  # noqa: E402

# Git vertraegt keine parallelen Schreibzugriffe im selben Arbeitsverzeichnis.
# Jeder Bus-Zugriff — Hintergrund-Sync wie Web-Request — laeuft durch dieses Schloss.
SCHLOSS = threading.RLock()

ZUSTAND = {"letzter_sync": None, "sync_status": "noch nicht gelaufen", "fehler": None}


def kuerze(zeile, laenge=60):
    """Betreff aus dem Text ableiten, aber an der Wortgrenze — sonst steht in der
    Inbox der Agenten ein mitten im Wort abgeschnittener Fetzen."""
    zeile = zeile.strip()
    if len(zeile) <= laenge:
        return zeile
    schnitt = zeile[:laenge].rsplit(" ", 1)[0]
    return (schnitt or zeile[:laenge]) + "…"


def mensch_default():
    ident = bus.lies_json(os.path.join(bus.REPO, "identity.json"), {}) or {}
    if ident.get("mensch_id"):
        return ident["mensch_id"]
    if ident.get("mensch"):
        return f"mensch-{ident['mensch']}"
    return "mensch-daniel"


# ------------------------------------------------------------------ Hintergrund

def sync_schleife(intervall):
    while True:
        try:
            with SCHLOSS:
                p = bus.pull()
                bus.melde_praesenz(rolle="mensch")
                bus.commit_push(f"praesenz {bus.AGENT}")
            ZUSTAND["letzter_sync"] = bus.jetzt()
            ZUSTAND["sync_status"] = p
            ZUSTAND["fehler"] = None if p in ("ok", "lokal (kein Remote)") else p
        except Exception as e:
            ZUSTAND["fehler"] = f"{type(e).__name__}: {e}"
        time.sleep(intervall)


# ------------------------------------------------------------------------- API

def baue_zustand():
    with SCHLOSS:
        reg = bus.registry().get("agents", [])
        p = bus.praesenz()
        nachrichten = bus.alle_json("msgs")[-300:]
        aufgaben = [z for z in (bus.task_zustand(t) for t in bus.alle_task_ids()) if z]
        freigaben = [z for z in (bus.vorschlag_zustand(v) for v in bus.alle_vorschlag_ids()) if z]
        notizen_wurzel = bus.pfad("notes")
        notizen = (sorted(f[:-3] for f in os.listdir(notizen_wurzel) if f.endswith(".md"))
                   if os.path.isdir(notizen_wurzel) else [])

    teilnehmer = []
    for a in reg:
        e = p.get(a.get("id")) or {}
        teilnehmer.append({
            "id": a.get("id"), "typ": a.get("typ", "agent"),
            "name": a.get("name", ""), "rolle": a.get("rolle", ""),
            "zuletzt": e.get("ts"), "zuletzt_text": bus.alter_text(e.get("ts")),
            "aktiv": bool(e.get("ts")) and bus.alter_text(e.get("ts")) in ("gerade eben",),
        })

    return {
        "ich": bus.AGENT,
        "repo": bus.REPO,
        "hat_remote": bus.hat_remote(),
        "teilnehmer": teilnehmer,
        "nachrichten": nachrichten,
        "aufgaben": aufgaben,
        "freigaben": freigaben,
        "notizen": notizen,
        "sync": dict(ZUSTAND),
    }


def api(pfad, koerper):
    """Gibt (status, daten) zurueck."""
    if pfad == "/api/state":
        return 200, baue_zustand()

    if pfad == "/api/message":
        an = koerper.get("to") or ["*"]
        text = (koerper.get("body") or "").strip()
        if not text:
            return 400, {"fehler": "Leere Nachricht."}
        betreff = (koerper.get("subject") or "").strip() or kuerze(text.split("\n")[0])
        with SCHLOSS:
            info = bus.t_send({"to": an, "subject": betreff, "body": text,
                               "thread": koerper.get("thread")})
        return 200, {"ok": True, "info": info}

    if pfad == "/api/task":
        titel = (koerper.get("title") or "").strip()
        if not titel:
            return 400, {"fehler": "Kein Titel."}
        with SCHLOSS:
            info = bus.t_task_create({"title": titel, "body": koerper.get("body"),
                                      "assign_to": koerper.get("assign_to") or None})
        return 200, {"ok": True, "info": info}

    if pfad == "/api/auftrag":
        titel = (koerper.get("title") or "").strip()
        if not titel:
            return 400, {"fehler": "Kein Titel."}
        with SCHLOSS:
            info = bus.t_auftrag_create({"title": titel, "body": koerper.get("body"),
                                         "an": koerper.get("an")})
        return 200, {"ok": True, "info": info}

    if pfad == "/api/task/update":
        with SCHLOSS:
            info = bus.t_task_update({"id": koerper.get("id"),
                                      "status": koerper.get("status") or None,
                                      "note": koerper.get("note") or None})
        return 200, {"ok": True, "info": info}

    if pfad == "/api/note":
        with SCHLOSS:
            info = bus.t_note_write({"key": koerper.get("key"),
                                     "content": koerper.get("content"),
                                     "append": bool(koerper.get("append"))})
        return 200, {"ok": True, "info": info}

    if pfad == "/api/note/read":
        # Direkt aus der Datei, nicht ueber t_note_read: der Daten-Hinweis ist eine
        # Leitplanke fuer Agenten und waere hier bloss Rauschen vor den Augen
        # des Menschen, dem die Notiz ohnehin gehoert.
        key = (koerper.get("key") or "").strip().lower()
        if not bus.ID_RE.match(key or ""):
            return 400, {"fehler": "Ungueltiger Schluessel."}
        ziel = bus.pfad("notes", f"{key}.md")
        if not os.path.isfile(ziel):
            return 404, {"fehler": "Notiz existiert nicht."}
        with open(ziel, encoding="utf-8") as f:
            return 200, {"ok": True, "text": f.read()}

    if pfad == "/api/entscheidung":
        # Entscheiden koennen nur Menschen — und hier sitzt der Mensch. Der
        # MCP-Server der Agenten hat dieses Werkzeug mit Absicht nicht.
        with SCHLOSS:
            info = bus.entscheide_vorschlag(
                (koerper.get("id") or "").strip(),
                (koerper.get("entscheidung") or "").strip(),
                koerper.get("kommentar"),
            )
        return 200, {"ok": True, "info": info}

    if pfad == "/api/sync":
        with SCHLOSS:
            info = bus.t_sync({})
        return 200, {"ok": True, "info": info}

    return 404, {"fehler": "Unbekannter Endpunkt."}


# ---------------------------------------------------------------------- Server

class Handler(BaseHTTPRequestHandler):
    server_version = "agent-bus"

    def log_message(self, *_a):
        pass  # Konsole bleibt ruhig; Fehler kommen ueber die Oberflaeche

    def _sende(self, status, daten=None, roh=None, typ="application/json"):
        if roh is None:
            roh = json.dumps(daten, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", f"{typ}; charset=utf-8")
        self.send_header("Content-Length", str(len(roh)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(roh)

    def do_GET(self):
        pfad = self.path.split("?")[0]
        if pfad.startswith("/api/"):
            try:
                status, daten = api(pfad, {})
            except Exception as e:
                status, daten = 500, {"fehler": f"{type(e).__name__}: {e}"}
            return self._sende(status, daten)

        datei = "index.html" if pfad in ("/", "/index.html") else os.path.basename(pfad)
        ziel = os.path.join(HIER, "web", datei)
        if not os.path.isfile(ziel):
            return self._sende(404, {"fehler": "nicht gefunden"})
        typ = {"html": "text/html", "css": "text/css", "js": "text/javascript",
               "svg": "image/svg+xml"}.get(datei.rsplit(".", 1)[-1], "text/plain")
        with open(ziel, "rb") as f:
            return self._sende(200, roh=f.read(), typ=typ)

    def do_POST(self):
        laenge = int(self.headers.get("Content-Length") or 0)
        try:
            koerper = json.loads(self.rfile.read(laenge) or b"{}")
        except json.JSONDecodeError:
            return self._sende(400, {"fehler": "Ungueltiges JSON."})
        try:
            status, daten = api(self.path.split("?")[0], koerper)
        except Exception as e:
            status, daten = 500, {"fehler": f"{type(e).__name__}: {e}"}
        self._sende(status, daten)


def main():
    p = argparse.ArgumentParser(description="Weboberflaeche fuer den agent-bus")
    p.add_argument("--port", type=int, default=8787)
    p.add_argument("--ich", default=None, help="Eigene Mensch-ID, z.B. mensch-edgar")
    p.add_argument("--intervall", type=int, default=20, help="Sync-Takt in Sekunden")
    p.add_argument("--kein-browser", action="store_true")
    args = p.parse_args()

    bus.setze_agent(args.ich or mensch_default())
    if not bus.ID_RE.match(bus.AGENT):
        print(f"Ungueltige Mensch-ID '{bus.AGENT}'.")
        return 1

    print(f"agent-bus Weboberflaeche")
    print(f"  du bist:  {bus.AGENT}")
    print(f"  repo:     {bus.REPO}")
    print(f"  remote:   {'ja' if bus.hat_remote() else 'NEIN — nur lokal'}")
    print(f"  adresse:  http://127.0.0.1:{args.port}")
    print("  (Strg+C beendet)")

    threading.Thread(target=sync_schleife, args=(args.intervall,), daemon=True).start()

    if not args.kein_browser:
        try:
            import webbrowser
            threading.Timer(1.0, webbrowser.open,
                            (f"http://127.0.0.1:{args.port}",)).start()
        except Exception:
            pass

    # Nur an die Loopback-Adresse binden: der Bus gehoert nicht ins Netz.
    srv = ThreadingHTTPServer(("127.0.0.1", args.port), Handler)
    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        print("\nbeendet")
    return 0


if __name__ == "__main__":
    sys.exit(main())
