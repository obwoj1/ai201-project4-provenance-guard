#!/usr/bin/env bash
# Full end-to-end demo of Provenance Guard.
# Start the server first (python3 app.py), then run:  bash demo/run_demo.sh
# Uses 127.0.0.1 to avoid the macOS AirPlay-on-port-5000 issue.

set -e
BASE="http://127.0.0.1:5000"
DIR="$(dirname "$0")"

echo "=============================================="
echo " 1. SUBMIT clearly-AI text"
echo "=============================================="
curl -s -X POST "$BASE/submit" -H "Content-Type: application/json" -d @"$DIR/ai_text.json" | python3 -m json.tool

echo
echo "=============================================="
echo " 2. SUBMIT clearly-human text (capturing its content_id for the appeal)"
echo "=============================================="
RESP=$(curl -s -X POST "$BASE/submit" -H "Content-Type: application/json" -d @"$DIR/human_text.json")
echo "$RESP" | python3 -m json.tool
CID=$(echo "$RESP" | python3 -c "import sys, json; print(json.load(sys.stdin)['content_id'])")
echo
echo ">> captured content_id = $CID"

echo
echo "=============================================="
echo " 3. SUBMIT borderline formal-human text"
echo "=============================================="
curl -s -X POST "$BASE/submit" -H "Content-Type: application/json" -d @"$DIR/formal_human_text.json" | python3 -m json.tool

echo
echo "=============================================="
echo " 4. GET /log  (all decisions so far)"
echo "=============================================="
curl -s "$BASE/log" | python3 -m json.tool

echo
echo "=============================================="
echo " 5. APPEAL the human submission from step 2"
echo "=============================================="
curl -s -X POST "$BASE/appeal" -H "Content-Type: application/json" \
  -d "{\"content_id\": \"$CID\", \"creator_reasoning\": \"I wrote this myself from personal experience.\"}" | python3 -m json.tool

echo
echo "=============================================="
echo " 6. GET /log again  (that entry is now under_review)"
echo "=============================================="
curl -s "$BASE/log" | python3 -m json.tool

echo
echo "=============================================="
echo " 7. RATE LIMIT test  (limit is 10/min PER IP, counting every /submit"
echo "    above too -- so 429s appear once 10 total are used this minute)"
echo "=============================================="
for i in $(seq 1 12); do
  printf "request %2d: " "$i"
  curl -s -o /dev/null -w "%{http_code}\n" -X POST "$BASE/submit" \
    -H "Content-Type: application/json" \
    -d '{"text": "rate limit test submission", "creator_id": "rl-test"}'
done

echo
echo "Demo complete."
