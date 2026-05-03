# Project Research: "Just My Cycle" - A Practical, Private Period App

## Goal
Build a period app tailored for everyday use by a friend. It must be practical, intuitive, and genuinely helpful, while strictly avoiding the common pitfalls of the industry: no fertility/pregnancy bloat, no "shrink it and pink it" aesthetics, and no machine learning. The app should feel like a safe, calm digital space—a reliable companion rather than a clinical or infantilizing tool.

## Core Product Principles
1. **Zero Fertility Bloat**: The app assumes the user just wants to track their period and symptoms. No "fertile window" predictions, no ovulation tests, and no pregnancy modes.
2. **Local-First Privacy**: Sensitive health data must be handled with absolute security. All data lives locally on the device (SQLite). No cloud accounts, no third-party data selling.
3. **No "Shrink it and Pink it"**: The UI must be sleek, modern, and discreet. No forced pink flowers or infantalizing graphics. Users shouldn't feel embarrassed opening it in public.
4. **Transparent, Rule-Based Logic (No ML)**: Predictions use simple, deterministic math (e.g., averages). Users must be able to understand *why* a prediction was made.
5. **User Control over Data**: The app must allow users to exclude anomalous months (due to stress, Plan B, medication) from their prediction averages to prevent "waterfall" inaccuracies.
6. **Low Effort UX**: Logging a period or symptom should take seconds, not minutes. 1-tap logging is the gold standard.

---

## Key User Needs & Frustrations Solved
- **Frustration:** Apps assume a perfect 28-day cycle and get confused by irregularities.
  - **Solution:** Provide prediction *windows* (not single days) and allow users to manually exclude an irregular cycle from the average calculation.
- **Frustration:** Apps are overly gendered and visually loud.
  - **Solution:** Offer neutral, elegant, customizable color themes (e.g., dark mode, slate, sage) with clean infographics instead of illustrations.
- **Frustration:** Fear of data being subpoenaed or sold.
  - **Solution:** 100% local storage. "Your data never leaves your phone."
- **Frustration:** App interfaces are cluttered with articles, community forums, and TTC (Trying to Conceive) features.
  - **Solution:** A focused dashboard that only shows the calendar, logging tools, and personal insights.

---

## UX/UI Design & Aesthetic Strategy

### Vibe & Tone of Voice
- **Tone:** The "soothing sound of a reliable friend"—compassionate, considerate, but practical. Not overly clinical, not overly enthusiastic.
- **Aesthetic:** A calming, modern, data-first aesthetic. Think of a premium digital journal or elevated infographic rather than a stereotypical wellness app. 
- **Shapes:** Rounded corners, soft UI elements, and comfortable spacing to create a sense of safety and ease. 

### Color Themes (Customizable Options)
Avoid bright pinks and aggressive reds. Offer a palette of calming, sophisticated themes:
1. **"Slate & Sage" (Default):** Muted grey-blues mixed with soft, earthy greens. Professional, calming, and highly discreet.
2. **"Midnight" (Dark Mode):** A true dark mode with deep OLED blacks and subtle muted violet/amber accents for data points. Essential for late-night logging without eye strain.
3. **"Paper & Ink":** A minimalist light theme using off-white (creamy) backgrounds with dark charcoal typography, mimicking a physical journal.
4. **"Terracotta":** Warm, earthy clay tones (ochre, muted rust) for users who prefer warmer colors without resorting to Barbie pink.

### Page Structure & Layout (MVP)
1. **The Dashboard (Home):**
   - **Primary Focus:** The current status (e.g., "Day 14", "Period expected in 2-4 days").
   - **Visual Options:** Let users choose how they want to see their cycle—either a **Circular Overview** (showing the whole cycle at a glance) or a **Horizontal Timeline** (chronological).
   - **Quick Log:** A prominent, 1-tap FAB (Floating Action Button) or inline card to quickly log today's flow/symptoms without navigating away.
2. **The Calendar View:**
   - A traditional monthly view to spot historical trends. Color-coded dots (using the chosen theme's accent colors) denote flow days and logged symptoms.
3. **The Log Screen (Overlay/Modal):**
   - Pops up quickly over the dashboard.
   - Uses simple chips/icons for 1-tap logging of Flow (Light/Medium/Heavy) and core symptoms (Cramps, Headache, Mood). 
   - A text field for custom notes.
4. **Insights & Trends:**
   - Simple data visualizations (bar charts, scatter plots) showing average cycle length, variance, and symptom frequency. 
   - Button to "Export for Doctor" (generates PDF/CSV).
5. **Settings & Privacy:**
   - Toggle for "Ignore this cycle in predictions".
   - Theme selector.
   - App lock (Biometric/PIN).
   - "Delete all my data" button.

---

## Recommended Feature Set

### MVP (Build First)
1. **Quick Log Screen & Dashboard**
   - Period start/end, Flow intensity, Core symptoms.
   - Customizable dashboard view (Circle vs Timeline).

2. **Rule-Based Cycle Prediction (No ML)**
   - Moving average cycle estimate (last 3-6 months).
   - Predicted window (e.g., "Expected between Oct 12 - Oct 15").
   - "Ignore this cycle" toggle for outlier months.

3. **Discreet Reminder System**
   - Vague, customizable push notifications.

4. **Insights & Doctor Export**
   - Average cycle length and variation trend.
   - Clean PDF/CSV export.

5. **Privacy Basics**
   - Local-only storage.
   - Optional App lock (PIN/biometric).

### V2 (After MVP Stability)
1. **Customizable Symptom Tags**: Let the user define exactly what they want to track.
2. **Symptom Correlation**: Simple graphs showing which days of the cycle certain symptoms usually peak.

---

## Non-ML Prediction Approach (Deterministic)

### Inputs
- Last N cycle lengths (excluding user-ignored cycles).
- Recent period start dates.

### Logic
1. Compute cycle length stats (Mean, min/max).
2. Predict next period as a **window**:
   - Earliest likely date: mean - historical variability.
   - Latest likely date: mean + historical variability.
3. If a user flags a month as "Irregular/Ignore", skip it in the mean calculation.

### UX Output
- “Expected in 3–6 days” instead of “Arrives on Tuesday.”
- Transparent explanation: "Based on your average cycle of 29 days."

---

## What to Build Now (Priority Order)
1. Local Database setup (SQLite/Drift).
2. Quick Log UI + Dashboard View (implementing the Slate & Sage theme default).
3. The deterministic prediction engine (averaging logic + the "Ignore" toggle).
4. The Calendar View for historical tracking.
5. Export for doctor visits.
