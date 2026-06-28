# Demo requests

Ready-to-use request bodies so you never have to paste long JSON into the
terminal (which is where line breaks sneak in and break things).

Start the server first in another terminal:

```bash
python3 app.py
```

## Run everything at once

```bash
bash demo/run_demo.sh
```

This submits three texts, shows the log, files an appeal (it grabs the
content_id automatically), shows the log again, and runs the rate-limit test.

## Or send individual requests

`-d @file` reads the body from the file, so nothing gets mangled:

```bash
# Clearly AI  -> ~0.70, Likely AI-Generated
curl -s -X POST http://127.0.0.1:5000/submit -H "Content-Type: application/json" -d @demo/ai_text.json | python3 -m json.tool

# Clearly human  -> ~0.25, Likely Human-Written
curl -s -X POST http://127.0.0.1:5000/submit -H "Content-Type: application/json" -d @demo/human_text.json | python3 -m json.tool

# Borderline formal human  -> ~0.45, Uncertain Origin
curl -s -X POST http://127.0.0.1:5000/submit -H "Content-Type: application/json" -d @demo/formal_human_text.json | python3 -m json.tool

# Appeal: edit demo/appeal.json first, paste in a content_id from a submit response
curl -s -X POST http://127.0.0.1:5000/appeal -H "Content-Type: application/json" -d @demo/appeal.json | python3 -m json.tool

# View the log
curl -s http://127.0.0.1:5000/log | python3 -m json.tool
```

## Clean rate-limit demo

The limit is 10 per minute per IP and counts *every* `/submit`, so after the
full demo above you'll have already used some of the budget. For a clean
"first 10 succeed, then 429" demo, restart the server (resets the in-memory
counter) and run only this:

```bash
for i in $(seq 1 12); do curl -s -o /dev/null -w "%{http_code}\n" -X POST http://127.0.0.1:5000/submit -H "Content-Type: application/json" -d '{"text": "rate limit test", "creator_id": "rl"}'; done
```

macOS note: use `127.0.0.1`, not `localhost`, or turn off AirPlay Receiver
(it also listens on port 5000).
