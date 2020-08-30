# TMQL

Library to provide EA testing for symbols that lack proper market data.__
It simulates real trade in MetaTrader platform including the display of orders and positions on a chart.

## Usage: ##

Add these methods to the OnInit of the EA in case the account or symbol properties need to be specified:

```mql5
AddPredefSymbolProperties(Symbol(),1,5,1,SYMBOL_CALC_MODE_EXCH_FUTURES);
AddPredefAccountProperties(ACCOUNT_MARGIN_MODE_RETAIL_NETTING);
```

Add this to specify how it retrieves price values (ask and bid values can be innacurate for some faulty data):

```mql5
PriceMode = PRICE_MODE_ICLOSE; //or PRICE_MODE_BIDASK
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
TMQL version of the sample to be simulated (a single T is added behind the normal MQL5 methods):

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

### List of current implemented methods (equivalent to MQ5): ###

  THistoryDealGetDouble__
  THistoryDealGetInteger__
  THistoryDealGetString__
  THistoryDealGetTicket__
  THistoryDealsTotal__
  THistorySelect__
  TOrderGetDouble__
  TOrderGetInteger__
  TOrderGetString__
  TOrderGetDouble__
  TOrderGetTicket__
  TPositionGetDouble__
  TPositionGetInteger__
  TPositionGetString__
  TPositionGetTicket__
  TPositionsTotal__
  TOrderSend__
  TSymbolInfoDouble__
  TSymbolInfoInteger__
