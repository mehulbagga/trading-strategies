# NQ E-mini Futures — 3-Minute Opening Range Breakout (Fib Entry)

**Asset**: NASDAQ 100 E-mini Futures (NQ1!)  
**Timeframe**: 1-minute chart  
**Strategy Type**: Opening Range Breakout, Intraday  
**Platform**: TradingView (Pine Script v5)

---

## 📌 Strategy Overview

Captures the first directional move after the NASDAQ market opens by:
1. Building a 3-minute reference range from the first 3 candles of the session
2. Waiting for a confirmed breakout (1-min close above/below the range)
3. Entering at a 0.25 Fibonacci pullback level of the breakout candle
4. Managing risk with a fixed stop and 1.5R target

---

## ⏰ Timing

| Timezone | Range Window       | Entry From |
|----------|--------------------|------------|
| IST      | 20:00 – 20:03      | 20:03+     |
| NY (EST) | 09:30 – 09:33 AM   | 09:33+     |

---

## 📐 Entry & Exit Rules

### BUY Setup
- **Condition**: 1-min candle closes **above** the 3-min range high
- **Entry**: `High of trigger candle − 0.25 × (High − Low)` → limit order (25% Fib pullback)
- **Stop Loss**: Low of the trigger candle
- **Target**: `Entry + 1.5 × (Entry − Stop)`

### SELL Setup
- **Condition**: 1-min candle closes **below** the 3-min range low
- **Entry**: `Low of trigger candle + 0.25 × (High − Low)` → limit order (25% Fib retrace)
- **Stop Loss**: High of the trigger candle
- **Target**: `Entry − 1.5 × (Stop − Entry)`

---

## 🔒 Risk Management

- ✅ **One trade per day** — no re-entry after the first setup is triggered
- ✅ **Limit order entry** — avoids chasing, gets a better fill via Fib pullback
- ✅ **Fixed 1.5R target** — clear and pre-defined reward-to-risk
- ✅ **Hard stop** on trigger candle extreme

---

## 📊 Visual Indicators on Chart

| Element | Color | Description |
|---------|-------|-------------|
| Background | Yellow | 3-min range building window |
| Horizontal line | Yellow | Range High & Range Low levels |
| Label | Green | BUY entry price |
| Label | Orange | SELL entry price |
| Label | Red | Stop Loss level |
| Label | Blue | Take Profit level |

---

## 🚀 How to Use

1. Open TradingView and load **NQ1!** on a **1-minute chart**
2. Set chart timezone to **UTC+5:30 (IST)** or leave as exchange default
3. Go to **Pine Script Editor** → paste `strategy.pine` → click **Add to chart**
4. The strategy will automatically:
   - Highlight the 20:00–20:03 IST range window
   - Draw range High/Low levels
   - Place entry, SL, and TP labels on the first breakout candle

---

## ⚠️ Disclaimer

This strategy is for educational and research purposes only. Past performance does not guarantee future results. Always conduct your own due diligence before trading with real capital.
