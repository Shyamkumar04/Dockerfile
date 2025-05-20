import requests
import time

URL = "https://camo.githubusercontent.com/9a741155737ca89ba8f2d524024dec836ae35d49653c89af435b0d6d4be3adff/68747470733a2f2f6b6f6d617265762e636f6d2f67687076632f3f757365726e616d653d6d6f68616e69736837373737373737267374796c653d666f722d7468652d6261646765"

# Infinite loop (Koyeb will manage process lifetime)
def main():
    while True:
        try:
            response = requests.get(URL)
            print(f"[INFO] Status Code: {response.status_code}")
        except Exception as e:
            print(f"[ERROR] {e}")
        time.sleep(60)  # Delay between requests (60 seconds)

if __name__ == "__main__":
    main()
