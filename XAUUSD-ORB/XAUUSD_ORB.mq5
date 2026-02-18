//+------------------------------------------------------------------+
//|                                                   XAUUSD_ORB.mq5 |
//|                                  XAUUSD Opening Range Breakout   |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Opening Range Breakout Strategy"
#property link      ""
#property version   "1.00"
#property description "Opening Range Breakout Strategy for XAUUSD"
#property description "Opening Range: 18:03 - 18:18 New York Time"

//--- Input Parameters
input double   LotSize = 0.01;              // Lot Size
input int      MagicNumber = 123456;        // Magic Number
input bool     ShowOpeningRange = true;     // Show Opening Range Box
input color    RangeBoxColor = clrDodgerBlue; // Opening Range Box Color

//--- Global Variables
datetime g_lastBarTime = 0;
bool g_tradeTakenToday = false;
bool g_rangeFormed = false;
double g_rangeHigh = 0;
double g_rangeLow = 0;
datetime g_rangeStartTime = 0;
datetime g_rangeEndTime = 0;
datetime g_currentDay = 0;

//--- Rectangle object for OR visualization
string g_rangeBoxName = "OR_Box";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Check if symbol is XAUUSD
   string symbol = _Symbol;
   
   //--- Check timeframe is 3 minutes
   if(_Period != PERIOD_M3)
   {
      Alert("This EA works on 3-minute chart only!");
      return(INIT_FAILED);
   }
   
   Print("XAUUSD Opening Range Breakout EA Initialized");
   Print("Opening Range: 18:03 - 18:18 New York Time");
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //--- Delete rectangle object
   ObjectDelete(0, g_rangeBoxName);
   Comment("");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   //--- Check for new bar
   if(!IsNewBar())
      return;
   
   //--- Get current time in New York timezone
   MqlDateTime currentTime;
   datetime serverTime = TimeCurrent();
   TimeToStruct(serverTime, currentTime);
   
   //--- Convert to New York time (EST/EDT)
   datetime nyTime = GetNewYorkTime();
   MqlDateTime nyStruct;
   TimeToStruct(nyTime, nyStruct);
   
   //--- Check if new day
   datetime today = StringToTime(IntegerToString(nyStruct.year) + "." + 
                                  IntegerToString(nyStruct.mon) + "." + 
                                  IntegerToString(nyStruct.day));
   
   if(today != g_currentDay)
   {
      ResetDailyVariables();
      g_currentDay = today;
   }
   
   //--- Check if we're in opening range period (18:03 - 18:18 NY time)
   if(IsInOpeningRange(nyStruct))
   {
      CaptureOpeningRange();
   }
   
   //--- Mark range as formed after 18:18
   if(!g_rangeFormed && g_rangeHigh > 0 && g_rangeLow > 0)
   {
      if(nyStruct.hour >= 18 && nyStruct.min >= 18)
      {
         g_rangeFormed = true;
         
         //--- Draw opening range box
         if(ShowOpeningRange)
            DrawOpeningRangeBox();
         
         Print("Opening Range Formed - High: ", g_rangeHigh, " Low: ", g_rangeLow);
      }
   }
   
   //--- Check for entry signals after range is formed
   if(g_rangeFormed && !g_tradeTakenToday)
   {
      CheckForEntrySignals();
   }
   
   //--- Update chart comment
   UpdateChartComment();
}

//+------------------------------------------------------------------+
//| Check if new bar has formed                                      |
//+------------------------------------------------------------------+
bool IsNewBar()
{
   datetime currentBarTime = iTime(_Symbol, _Period, 0);
   
   if(currentBarTime != g_lastBarTime)
   {
      g_lastBarTime = currentBarTime;
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Get New York time                                                |
//+------------------------------------------------------------------+
datetime GetNewYorkTime()
{
   //--- Get server time
   datetime serverTime = TimeCurrent();
   
   //--- Get GMT offset
   MqlDateTime tm;
   TimeToStruct(serverTime, tm);
   
   //--- New York is GMT-5 (EST) or GMT-4 (EDT)
   //--- Simplified: using EST (GMT-5)
   int nyOffset = -5;
   
   //--- Calculate NY time
   datetime nyTime = serverTime + (nyOffset * 3600);
   
   return nyTime;
}

//+------------------------------------------------------------------+
//| Check if current time is in opening range                        |
//+------------------------------------------------------------------+
bool IsInOpeningRange(MqlDateTime &timeStruct)
{
   if(timeStruct.hour == 18)
   {
      if(timeStruct.min >= 3 && timeStruct.min <= 18)
         return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Capture opening range high and low                               |
//+------------------------------------------------------------------+
void CaptureOpeningRange()
{
   double high = iHigh(_Symbol, _Period, 1);
   double low = iLow(_Symbol, _Period, 1);
   
   if(g_rangeHigh == 0 || g_rangeLow == 0)
   {
      g_rangeHigh = high;
      g_rangeLow = low;
      g_rangeStartTime = iTime(_Symbol, _Period, 1);
   }
   else
   {
      if(high > g_rangeHigh)
         g_rangeHigh = high;
      if(low < g_rangeLow)
         g_rangeLow = low;
   }
   
   g_rangeEndTime = iTime(_Symbol, _Period, 0);
}

//+------------------------------------------------------------------+
//| Draw opening range box                                           |
//+------------------------------------------------------------------+
void DrawOpeningRangeBox()
{
   //--- Delete existing box
   ObjectDelete(0, g_rangeBoxName);
   
   //--- Create rectangle
   if(ObjectCreate(0, g_rangeBoxName, OBJ_RECTANGLE, 0, g_rangeStartTime, g_rangeHigh, 
                   TimeCurrent() + PeriodSeconds(PERIOD_H1) * 24, g_rangeLow))
   {
      ObjectSetInteger(0, g_rangeBoxName, OBJPROP_COLOR, RangeBoxColor);
      ObjectSetInteger(0, g_rangeBoxName, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, g_rangeBoxName, OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, g_rangeBoxName, OBJPROP_FILL, false);
      ObjectSetInteger(0, g_rangeBoxName, OBJPROP_BACK, false);
      ObjectSetInteger(0, g_rangeBoxName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, g_rangeBoxName, OBJPROP_SELECTED, false);
   }
}

//+------------------------------------------------------------------+
//| Check for entry signals                                          |
//+------------------------------------------------------------------+
void CheckForEntrySignals()
{
   //--- Check if already in position
   if(PositionSelect(_Symbol))
      return;
   
   double close1 = iClose(_Symbol, _Period, 1);
   double close2 = iClose(_Symbol, _Period, 2);
   double low1 = iLow(_Symbol, _Period, 1);
   double high1 = iHigh(_Symbol, _Period, 1);
   
   //--- Buy signal: previous candle closed above OR high
   if(close1 > g_rangeHigh && close2 <= g_rangeHigh)
   {
      double stopLoss = low1;
      double slPoints = close1 - stopLoss;
      double takeProfit = close1 + (slPoints * 3);
      
      OpenBuyOrder(stopLoss, takeProfit);
   }
   
   //--- Sell signal: previous candle closed below OR low
   if(close1 < g_rangeLow && close2 >= g_rangeLow)
   {
      double stopLoss = high1;
      double slPoints = stopLoss - close1;
      double takeProfit = close1 - (slPoints * 3);
      
      OpenSellOrder(stopLoss, takeProfit);
   }
}

//+------------------------------------------------------------------+
//| Open Buy Order                                                    |
//+------------------------------------------------------------------+
void OpenBuyOrder(double sl, double tp)
{
   MqlTradeRequest request;
   MqlTradeResult result;
   ZeroMemory(request);
   ZeroMemory(result);
   
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   
   //--- Normalize prices
   sl = NormalizeDouble(sl, _Digits);
   tp = NormalizeDouble(tp, _Digits);
   
   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = LotSize;
   request.type = ORDER_TYPE_BUY;
   request.price = ask;
   request.sl = sl;
   request.tp = tp;
   request.deviation = 10;
   request.magic = MagicNumber;
   request.comment = "ORB Buy";
   
   if(OrderSend(request, result))
   {
      if(result.retcode == TRADE_RETCODE_DONE)
      {
         Print("Buy order placed successfully. Ticket: ", result.order);
         g_tradeTakenToday = true;
      }
      else
      {
         Print("Buy order failed. Error: ", result.retcode);
      }
   }
}

//+------------------------------------------------------------------+
//| Open Sell Order                                                   |
//+------------------------------------------------------------------+
void OpenSellOrder(double sl, double tp)
{
   MqlTradeRequest request;
   MqlTradeResult result;
   ZeroMemory(request);
   ZeroMemory(result);
   
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   //--- Normalize prices
   sl = NormalizeDouble(sl, _Digits);
   tp = NormalizeDouble(tp, _Digits);
   
   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = LotSize;
   request.type = ORDER_TYPE_SELL;
   request.price = bid;
   request.sl = sl;
   request.tp = tp;
   request.deviation = 10;
   request.magic = MagicNumber;
   request.comment = "ORB Sell";
   
   if(OrderSend(request, result))
   {
      if(result.retcode == TRADE_RETCODE_DONE)
      {
         Print("Sell order placed successfully. Ticket: ", result.order);
         g_tradeTakenToday = true;
      }
      else
      {
         Print("Sell order failed. Error: ", result.retcode);
      }
   }
}

//+------------------------------------------------------------------+
//| Reset daily variables                                            |
//+------------------------------------------------------------------+
void ResetDailyVariables()
{
   g_tradeTakenToday = false;
   g_rangeFormed = false;
   g_rangeHigh = 0;
   g_rangeLow = 0;
   g_rangeStartTime = 0;
   g_rangeEndTime = 0;
   
   //--- Delete rectangle
   ObjectDelete(0, g_rangeBoxName);
   
   Print("New Day - Variables Reset");
}

//+------------------------------------------------------------------+
//| Update chart comment                                             |
//+------------------------------------------------------------------+
void UpdateChartComment()
{
   string comment = "";
   comment += "==== XAUUSD Opening Range Breakout ====\n";
   comment += "Opening Range: 18:03 - 18:18 NY Time\n";
   comment += "=========================================\n";
   
   if(g_rangeFormed)
   {
      comment += "Range High: " + DoubleToString(g_rangeHigh, _Digits) + "\n";
      comment += "Range Low: " + DoubleToString(g_rangeLow, _Digits) + "\n";
   }
   else
   {
      comment += "Waiting for Opening Range...\n";
   }
   
   comment += "Trade Taken Today: " + (g_tradeTakenToday ? "YES" : "NO") + "\n";
   
   if(PositionSelect(_Symbol))
   {
      comment += "=========================================\n";
      comment += "Current Position: " + EnumToString((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)) + "\n";
      comment += "Entry: " + DoubleToString(PositionGetDouble(POSITION_PRICE_OPEN), _Digits) + "\n";
      comment += "SL: " + DoubleToString(PositionGetDouble(POSITION_SL), _Digits) + "\n";
      comment += "TP: " + DoubleToString(PositionGetDouble(POSITION_TP), _Digits) + "\n";
      comment += "Profit: " + DoubleToString(PositionGetDouble(POSITION_PROFIT), 2) + " USD\n";
   }
   
   Comment(comment);
}
//+------------------------------------------------------------------+
