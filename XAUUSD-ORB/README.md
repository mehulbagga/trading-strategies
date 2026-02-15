# XAUUSD Opening Range Breakout Strategy

An automated intraday trading system for Gold (XAUUSD) based on opening range breakout methodology.

![Strategy Type](https://img.shields.io/badge/Strategy-Breakout-blue)
![Timeframe](https://img.shields.io/badge/Timeframe-3min-green)
![Risk-Reward](https://img.shields.io/badge/R:R-3:1-orange)

## 📋 Strategy Overview

The Opening Range Breakout (ORB) strategy identifies the high and low during the first 15 minutes of the trading session (18:03-18:18 EST) and enters positions when price breaks out of this range.

### Key Features

- **Opening Range**: 15-minute range from 18:03 to 18:18 EST
- **Entry Logic**: First breakout above/below the opening range
- **Stop Loss**: Placed at the breakout candle's low (long) or high (short)
- **Take Profit**: 3x the stop loss distance
- **Trade Frequency**: Maximum one trade per day
- **Position Management**: Automatic SL/TP execution

## 🎯 Entry Rules

### Long Entry (Buy)
- Wait for opening range formation (18:03-18:18 EST)
- Enter when any 3-minute candle closes **above** the opening range high
- Only if no trade has been taken today

### Short Entry (Sell)
- Wait for opening range formation (18:03-18:18 EST)
- Enter when any 3-minute candle closes **below** the opening range low
- Only if no trade has been taken today

## 🛡️ Risk Management

- **Stop Loss**: Breakout candle's low (buy) or high (sell)
- **Take Profit**: 3x the stop loss points
- **Risk-Reward Ratio**: 1:3
- **Position Limit**: One trade per day maximum

## 💻 Implementation

This strategy is implemented in two platforms:

### TradingView (Pine Script)
```
File: strategy.pine
Use on: 3-minute XAUUSD chart
```

### MetaTrader 5 (MQL5)
```
File: XAUUSD_ORB.mq5
Use on: 3-minute XAUUSD chart
```

## 📊 Backtesting Results

*Note: Add your backtesting results here once completed*

| Metric | Value |
|--------|-------|
| Total Trades | - |
| Win Rate | - |
| Average Win | - |
| Average Loss | - |
| Profit Factor | - |
| Max Drawdown | - |

## 🚀 How to Use

### TradingView Setup
1. Open TradingView and load XAUUSD chart
2. Set timeframe to **3 minutes**
3. Open Pine Editor (bottom panel)
4. Copy the code from `strategy.pine`
5. Click "Add to Chart"
6. Strategy will start tracking opening ranges

### MetaTrader 5 Setup
1. Copy `XAUUSD_ORB.mq5` to `MQL5/Experts/` folder
2. Compile in MetaEditor (F7)
3. Drag EA onto 3-minute XAUUSD chart
4. Configure lot size and parameters
5. Enable AutoTrading (Ctrl+E)

## ⚙️ Parameters

### TradingView
- `Show Opening Range Box`: Display visual range
- `OR Box Color`: Customize range box color

### MetaTrader 5
- `LotSize`: Position size (default: 0.01)
- `MagicNumber`: Unique identifier (default: 123456)
- `ShowOpeningRange`: Display range box on chart

## 📈 Strategy Logic Flow

```
1. Wait for 18:03 EST
2. Capture high/low for 15 minutes (until 18:18)
3. After 18:18, monitor for breakouts
4. On breakout:
   - Enter position (if no trade today)
   - Set SL at breakout candle low/high
   - Set TP at 3x SL distance
5. Hold until SL or TP hit
6. Reset for next day
```

## 🔧 Technical Details

**Timezone Handling**
- All times are in New York timezone (EST)
- Automatic conversion from broker time to EST
- Daily reset at midnight EST

**One Trade Per Day Logic**
- Boolean flag `trade_taken_today`
- Resets on new trading day
- Prevents multiple entries

**Visual Indicators**
- Opening range box (green/red)
- Entry signal arrows
- Stop loss and take profit lines
- Real-time position information

## 📝 Code Structure

### Pine Script
- Time functions (EST conversion)
- Opening range capture logic
- Entry signal detection
- Position management
- Visual plotting

### MQL5
- New bar detection
- Timezone conversion
- Range capture and formation
- Trade execution functions
- Position monitoring

## ⚠️ Important Notes

- **Must use 3-minute timeframe** - Strategy designed specifically for M3
- **Timezone critical** - Ensure correct EST time conversion
- **One trade limit** - Only first breakout is traded each day
- **Risk management** - Always use proper position sizing

## 🔮 Future Enhancements

- [ ] Add volatility filter (ATR-based)
- [ ] Implement volume confirmation
- [ ] Add time-of-day exit rules
- [ ] Multi-timeframe validation
- [ ] Trailing stop functionality
- [ ] Performance analytics dashboard

## 📚 References

- Opening Range Breakout methodology
- Intraday trading strategies
- Price action analysis
- Risk management principles

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

---

## 📞 Questions or Suggestions?

Feel free to open an issue or reach out if you have questions or suggestions for improvements!

**Author**: Mehul Bagga 
**Date**: February 2025  
**Version**: 1.0
