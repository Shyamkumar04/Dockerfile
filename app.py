import requests
import time
import threading
from fastapi import FastAPI
import uvicorn

app = FastAPI()
count = 0

URL = "https://camo.githubusercontent.com/9a741155737ca89ba8f2d524024dec836ae35d49653c89af435b0d6d4be3adff/68747470733a2f2f6b6f6d617265762e636f6d2f67687076632f3f757365726e616d653d6d6f68616e69736837373737373737267374796c653d666f722d7468652d6261646765"

@app.get("/")
def read_count():
    return {"ping_count": count}

def ping_loop():
    global count
    while True:
        try:
            response = requests.get(URL)
            count += 1
            print(f"[INFO] Ping #{count} - Status Code: {response.status_code}")
        except Exception as e:
            print(f"[ERROR] {e}")
        time.sleep(20)  # Delay between requests

if __name__ == "__main__":
    # Start ping loop in background thread
    thread = threading.Thread(target=ping_loop, daemon=True)
    thread.start()

    # Start FastAPI server
    uvicorn.run(app, host="0.0.0.0", port=8000)
