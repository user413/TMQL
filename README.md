# TMQL

*This project was built according to my own demands therefore most features are partially implemented. It contains the most common MQL5 features that could 
be useful for most clients.*

Library to provide EA testing for symbols that lack reliable historic market data.\
It simulates real trade in MetaTrader platform including the display of orders and positions on a chart.

### Usage: ###
Include the TMQL.mqh file. Location may differ.
```mql5
#include <TMQL/TMQL/TMQL.mqh>
```
Add these methods to the beginning of OnInit of the EA in case the account or symbol properties need to be specified (example):
```mql5
AddPredefSymbolProperties(Symbol(),1,5,1,SYMBOL_CALC_MODE_EXCH_FUTURES);
AddPredefAccountProperties(ACCOUNT_MARGIN_MODE_RETAIL_NETTING);

//-- Additional configuration variables:

//-- How the program retrieves price values (ask and bid values can be innacurate for some faulty data)
PriceMode = PRICE_MODE_ICLOSE; //or PRICE_MODE_BIDASK

//-- To use order/sltp prices as the deal price (false) instead of market prices (true)
UseMarketPricesForLimitOrdersAndSLTP = false;

//-- Automatically show and update the trade information panel. Set false to improve performance but TShowInfoPanel must be manually called to show panel
ShowInformationPanel = true;
```
Add this method to the beginning of OnTick method:
```mql5
//-- Manages order executions, SL, TP
TManageTrade();
```
Add this method in the beginning of OnTimer. Necessary in order to cancel ORDER_TIME_DAY orders before the trade session of the next day (Note: currently implemented only for symbols with SYMBOL_CALC_MODE_EXCH_FUTURES mode):
```mql5
//-- Note: In order to work properly it is recommended to have a < 1 minute timer set up
THandleOrderTime();
```
The client code must contain the OnTradeTransaction method defined. If this event won't be used declare an empty method:
```mql5
void OnTradeTransaction(const MqlTradeTransaction& trans, const MqlTradeRequest& request, const MqlTradeResult& result) { }
```
Normal MQL5 sample of code:
```mql5
ulong  position_ticket = PositionGetTicket(i);
string position_symbol = PositionGetString(POSITION_SYMBOL);
int    digits = (int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS);
ulong  magic = PositionGetInteger(POSITION_MAGIC);
double volume = PositionGetDouble(POSITION_VOLUME);
double sl = PositionGetDouble(POSITION_SL);
double tp = PositionGetDouble(POSITION_TP);
ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
```
TMQL version of the sample to be simulated (a T is added behind the normal MQL5 methods):
```mql5
ulong  position_ticket = TPositionGetTicket(i);
string position_symbol = TPositionGetString(POSITION_SYMBOL);
int    digits = (int)TSymbolInfoInteger(position_symbol,SYMBOL_DIGITS);
ulong  magic = TPositionGetInteger(POSITION_MAGIC);
double volume = TPositionGetDouble(POSITION_VOLUME);
double sl = TPositionGetDouble(POSITION_SL);
double tp = TPositionGetDouble(POSITION_TP);
ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)TPositionGetInteger(POSITION_TYPE);
```

#### List of currently implemented methods (equivalent to MQ5): ####

TiClose\
TiOpen\
TOrderGetDouble\
TOrderGetInteger\
TOrderGetString\
TOrderGetDouble\
TOrderGetTicket\
TOrdersTotal\
TPositionGetDouble\
TPositionGetInteger\
TPositionGetString\
TPositionGetTicket\
TPositionsTotal\
TOrderSend\
TSymbolInfoDouble\
TSymbolInfoInteger\
TAccountInfoInteger\
TOrderSelect\
TPositionSelect\
TPositionSelectByTicket\
THistorySelect\
THistoryDealGetDouble\
THistoryDealGetInteger\
THistoryDealGetString\
THistoryDealGetTicket\
THistoryDealsTotal\
THistoryOrderSelect\
THistoryOrderGetDouble\
THistoryOrderGetInteger\
THistoryOrderGetString\
THistoryOrderGetTicket\
THistoryOrdersTotal\
TObjectsDeleteAll\
TGetLastError
