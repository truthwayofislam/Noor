#!/bin/bash
echo "Testing Prayer Times API..."
curl -s "https://api.aladhan.com/v1/timings?latitude=24.8607&longitude=67.0011&method=2" | python3 -c "
import sys, json
data = json.load(sys.stdin)
if 'data' in data and 'timings' in data['data']:
    timings = data['data']['timings']
    print('✅ API Working!')
    print(f\"Fajr: {timings['Fajr']}\")
    print(f\"Dhuhr: {timings['Dhuhr']}\")
    print(f\"Asr: {timings['Asr']}\")
    print(f\"Maghrib: {timings['Maghrib']}\")
    print(f\"Isha: {timings['Isha']}\")
else:
    print('❌ API Failed!')
    print(data)
"
