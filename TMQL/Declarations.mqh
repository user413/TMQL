#include <Object.mqh>
#include <Arrays\ArrayObj.mqh>

class Position : public CObject{
   public:
      ulong Ticket;
      ulong Magic;
      string Symbol;
      ENUM_POSITION_TYPE Type;
      double Volume;
      datetime Time;
      double PriceOpen;
      double SL;
      double TP;
      double AvgPosPrice;
};

class Order : public CObject{
   public:
      ulong Ticket;
      ulong Magic;
      string Symbol;
      ENUM_ORDER_TYPE Type;
      double Volume;
      datetime Time;
      double Price;
      double SL;
      double TP;
      ulong PositionTicket;
};

class Deal : public CObject{
   public:
      ulong Ticket;
      ulong Order;
      ulong Magic;
      string Symbol;
      double Volume;
      datetime Time;
      double Price;
      double Profit;
      ulong Position;
      ENUM_DEAL_ENTRY Entry;
      ENUM_DEAL_TYPE Type;
};

enum EnumTChartAction{
   CHART_ACTION_DRAW,
   CHART_ACTION_ERASE
};

//enum EnumPositionTradeMode{
//   POSITION_MODE_SINGLE, //-- ONLY 1 POSITION CAN EXIST, SAME DIRECTION ORDER ADDS TO THE POSITION
//   POSITION_MODE_MULTIPLE //-- MULTIPLE POSITIONS CAN EXIST AT ONCE, SAME DIRECTION ORDER CREATE A NEW POSITION
//};

CArrayObj Positions;
CArrayObj Orders;
CArrayObj Deals;

//-- UPDATED BY THistorySelect
CArrayObj SelectedHistoryDeals;

//-- SELECTED BY TOrderGetTicket,TOrderSelect,TPositionGetTicket,TPositionSelect
Order SelectedOrder;
Position SelectedPosition;
//Deal SelectedHistoryDeal;

//-- USED TO CALCULATE LIVE POSITION PROFIT
//Position OverallBuyPosition;
//Position OverallSellPosition;

double CurrentProfit = 0;

enum EnumPriceMode{
   PRICE_MODE_BIDASK,
   PRICE_MODE_ICLOSE
};

//----- ONINIT VARIABLES ------

class SymbolProperties : public CObject{
   public:
      string Symbol;
      double SymbolTickValue;
      double SymbolTickSize;
      double SymbolVolumeMin;
      ulong SymbolCalcMode;
      //ENUM_ACCOUNT_MARGIN_MODE AccountMarginMode;
};

class AccountProperties{
   public:
      ENUM_ACCOUNT_MARGIN_MODE AccountMarginMode;
};

CArrayObj PredefSymbolProperties;
AccountProperties PredefAccountProperties;

void AddPredefSymbolProperties(string symbol,double tickValue,double tickSize,double volumeMin,ENUM_SYMBOL_CALC_MODE calcMode){
   SymbolProperties *symbolProps = new SymbolProperties;
   symbolProps.Symbol = symbol;
   symbolProps.SymbolTickValue = tickValue;
   symbolProps.SymbolTickSize = tickSize;
   symbolProps.SymbolVolumeMin = volumeMin;
   symbolProps.SymbolCalcMode = calcMode;
   PredefSymbolProperties.Add(symbolProps);
   UsePredefSymbolVariables = true;
}

void AddPredefAccountProperties(ENUM_ACCOUNT_MARGIN_MODE accountMarginMode){
   PredefAccountProperties.AccountMarginMode = accountMarginMode;
   UsePredefAccountProperties = true;
}

SymbolProperties *GetPredefSymbolProperties(string symbol){
   for(int c = 0; c < PredefSymbolProperties.Total(); c++){
      SymbolProperties *props = PredefSymbolProperties.At(c);
      if(props.Symbol != symbol) continue;
      return props;
   }
   return NULL;
}

double ContractFee_TMQL = 0;
double StocksFee_TMQL = 0;
EnumPriceMode PriceMode = PRICE_MODE_BIDASK;

bool UsePredefSymbolVariables = false;
bool UsePredefAccountProperties = false;
//-- PREDEFINED SYMBOL VALRIABLES
//double SymbolTickValue_TMQL = 1;
//double SymbolTickSize_TMQL = 5;
//double SymbolVolumeMin_TMQL = 1;
//ulong SymbolCalcMode_TMQL = SYMBOL_CALC_MODE_EXCH_FUTURES;
//EnumPositionTradeMode PositionTradeMode = POSITION_MODE_SINGLE;

MqlDateTime CurrentTimeStruct;
int CurrentDay;