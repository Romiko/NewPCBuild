# Fan Curves & Hubs (Generic)

- **PWM (4-pin)** fans can be precisely controlled by duty cycle; **DC (3-pin)** fans by voltage.
- Use **PWM headers for PWM fans**; set header mode in BIOS accordingly (PWM vs DC).
- **Hubs vs Splitters:**
  - **Splitter**: just duplicates the header; only **one tach (RPM) wire** should be passed to the motherboard.
  - **Powered PWM Hub**: takes SATA power + one PWM signal; drives many fans from a single header. Board sees **one fan** RPM only.
- **Where to plug what:**
  - Front intakes → a powered PWM hub is fine; control by **Motherboard/CPU sensor**.
  - Top/Rear exhaust → individual headers if possible for finer control.
- **Positive pressure**: Slightly more intake CFM than exhaust. Keep dust filters on intakes.
- **AIO orientation**: If front-mounted, put **tubes down** so the pump isn't the highest point. Prefer **top-mount radiator** as exhaust when possible.
- **GPU airflow**: Leave 3–4 slots of clearance under large GPUs; avoid front panel obstructions.
