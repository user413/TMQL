#property copyright "Nain"

#include <Object.mqh>
#include <Arrays\ArrayObj.mqh>
// #include <Nain\Utility\Utility.mqh>
// #include <Nain\Utility\Generic.mqh>
 #include "..\packages\Utility\Utility.mqh"
 #include "..\packages\Utility\Generic.mqh"

namespace TMQL
{

class Position : public Nain::Position{
      // // double AvgPosPrice;
};

class Order : public Nain::Order{
   //    // datetime TimeDone; //execution or cancellation
   //    // ENUM_ORDER_STATE State;

   //    double ValueToSort() const { return Time; }
};

class Deal : public Nain::Deal{
   
};

enum EnumTChartAction{
   CHART_ACTION_DRAW,
   CHART_ACTION_ERASE
};

enum EnumPriceMode{
   PRICE_MODE_BIDASK,
   PRICE_MODE_ICLOSE
};

enum EnumScheduledTransactionActionType{
   TRANS_ACTION_TYPE_MARKET_DEAL,
   TRANS_ACTION_TYPE_SLTP_DEAL,
   TRANS_ACTION_TYPE_LIMIT_ORDER,
   TRANS_ACTION_TYPE_LIMIT_DEAL,
   TRANS_ACTION_TYPE_CANCEL_ORDER
};

//----- PREDEFINED VARIABLES STRUCTURES ------

//-- PREDEFINED SYMBOL VALRIABLES
class SymbolProperties : public CObject{
   public:
      string Symbol;
      double SymbolTickValue;
      double SymbolTickSize;
      double SymbolVolumeMin;
      ulong SymbolCalcMode;
      //ENUM_ACCOUNT_MARGIN_MODE AccountMarginMode;
};

//-- PREDEFINED ACCOUNT VALRIABLES
class AccountProperties{
   public:
      ENUM_ACCOUNT_MARGIN_MODE AccountMarginMode;
};

//-- MAIN FUNCTIONALITY MEMBERS

// private:
Nain::Math m_TMQL;
Nain::ChartObj co_TMQL;

double CurrentProfit = 0;

CArrayObj PredefSymbolProperties;
AccountProperties PredefAccountProperties;

//not implemented correctly
// double ContractFee_TMQL = 0;
// double StocksFee_TMQL = 0;

EnumPriceMode PriceMode = PRICE_MODE_ICLOSE;
bool UseMarketPricesForLimitOrdersAndSLTP = false; //false to use order/sltp prices as the deal price instead of market prices
bool ShowInformationPanel = true; //automatically show and update the trade information panel
                                  //false to inprove performance but TShowInfoPanel must be manually called to show panel

bool UsePredefSymbolVariables = false;
bool UsePredefAccountProperties = false;

int LastError = 0;
ulong LastOrderTicket = 0;
ulong LastDealTicket = 0;
uint LastRequestID = 0;

Nain::List<Position> Positions; //open positions
Nain::List<Order> Orders; //open orders
Nain::List<Order> HistoryOrders; //history orders
Nain::List<Deal> Deals; //history deals

//-- UPDATED BY THistorySelect
Nain::List<Deal> SelectedHistoryDeals;
Nain::List<Order> SelectedHistoryOrders;

//-- SELECTED BY TOrderGetTicket,TOrderSelect,TPositionGetTicket,TPositionSelect
Order SelectedOrder;
Position SelectedPosition;

//-- EVENT HANDLERS
//-- OnTradeTransaction properties
class ScheduledOnTradeTransactionAction : public CObject{
   public:
      MqlTradeTransaction Trans;     // trade transaction structure
      MqlTradeRequest Request;   // request structure
      MqlTradeResult Result;    // response structure
      EnumScheduledTransactionActionType TransActionType;
};

// bool OnTradeTransactionIsScheduled = false;
CArrayObj ScheduledOnTradeTransactions;

void ScheduleOnTradeTransactionAction(MqlTradeRequest &req, MqlTradeResult &res, 
   EnumScheduledTransactionActionType transActionType){
   // OnTradeTransactionIsScheduled = true;
   ScheduledOnTradeTransactionAction* sTrans = new ScheduledOnTradeTransactionAction;
   sTrans.Request = req;
   sTrans.Result = res;
   sTrans.TransActionType = transActionType;
   ScheduledOnTradeTransactions.Add(sTrans);
}

void HandleOnTradeTransaction(){
   // if(!OnTradeTransactionIsScheduled) return;

   for (int i = ScheduledOnTradeTransactions.Total() - 1; i >= 0; i--)
   {
      ScheduledOnTradeTransactionAction* sTrans = ScheduledOnTradeTransactions.At(i);
      MqlTradeRequest EmptyReq;
      MqlTradeResult EmptyRes;

      switch (sTrans.TransActionType)
      {
         case TRANS_ACTION_TYPE_MARKET_DEAL:
            
            sTrans.Trans.type = TRADE_TRANSACTION_REQUEST;
            OnTradeTransaction(sTrans.Trans, sTrans.Request, sTrans.Result);
         
            ZeroMemory(sTrans.Trans);
            sTrans.Trans.type = TRADE_TRANSACTION_HISTORY_ADD;
            sTrans.Trans.order = sTrans.Result.order;
            sTrans.Trans.symbol = sTrans.Request.symbol;
            sTrans.Trans.order_state = ORDER_STATE_FILLED;
            OnTradeTransaction(sTrans.Trans, EmptyReq, EmptyRes);

            ZeroMemory(sTrans.Trans);
            sTrans.Trans.type = TRADE_TRANSACTION_DEAL_ADD;
            sTrans.Trans.order = sTrans.Result.order;
            sTrans.Trans.deal = sTrans.Result.deal;
            sTrans.Trans.deal_type = sTrans.Request.type == ORDER_TYPE_BUY ? DEAL_TYPE_BUY : DEAL_TYPE_SELL;
            sTrans.Trans.price = sTrans.Result.price;
            sTrans.Trans.volume = sTrans.Result.volume;
            sTrans.Trans.symbol = sTrans.Request.symbol;
            OnTradeTransaction(sTrans.Trans, EmptyReq, EmptyRes);
            
            // ZeroMemory(sTrans.Trans);
            // sTrans.Trans.type = TRADE_TRANSACTION_HISTORY_ADD;
            // sTrans.Trans.order = sTrans.Result.order;
            // OnTradeTransaction(sTrans.Trans, EmptyReq, EmptyRes);
            break;

         case TRANS_ACTION_TYPE_SLTP_DEAL:

            ZeroMemory(sTrans.Trans);
            sTrans.Trans.type = TRADE_TRANSACTION_HISTORY_ADD;
            sTrans.Trans.order = sTrans.Result.order;
            sTrans.Trans.symbol = sTrans.Request.symbol;
            OnTradeTransaction(sTrans.Trans, EmptyReq, EmptyRes);

            ZeroMemory(sTrans.Trans);
            sTrans.Trans.type = TRADE_TRANSACTION_DEAL_ADD;
            sTrans.Trans.order = sTrans.Result.order;
            sTrans.Trans.deal = sTrans.Result.deal;
            sTrans.Trans.deal_type = (sTrans.Request.type == ORDER_TYPE_BUY || sTrans.Request.type == ORDER_TYPE_BUY_LIMIT) ? 
               DEAL_TYPE_BUY : DEAL_TYPE_SELL;
            sTrans.Trans.price = sTrans.Result.price;
            sTrans.Trans.volume = sTrans.Result.volume;
            sTrans.Trans.symbol = sTrans.Request.symbol;
            OnTradeTransaction(sTrans.Trans, EmptyReq, EmptyRes);
            break;
         case TRANS_ACTION_TYPE_LIMIT_ORDER:
            //    TRADE_TRANSACTION_ORDER_ADD
            //    TRADE_TRANSACTION_ORDER_UPDATE
            //    TRADE_TRANSACTION_REQUEST
            break;

         case TRANS_ACTION_TYPE_LIMIT_DEAL:
            //    TRADE_TRANSACTION_ORDER_UPDATE
            //    TRADE_TRANSACTION_DEAL_ADD
            //    TRADE_TRANSACTION_ORDER_DELETE
            //    TRADE_TRANSACTION_HISTORY_ADD

            ZeroMemory(sTrans.Trans);
            sTrans.Trans.type = TRADE_TRANSACTION_HISTORY_ADD;
            sTrans.Trans.order = sTrans.Result.order;
            sTrans.Trans.symbol = sTrans.Request.symbol;
            sTrans.Trans.order_state = ORDER_STATE_PLACED;
            OnTradeTransaction(sTrans.Trans, EmptyReq, EmptyRes);

            ZeroMemory(sTrans.Trans);
            sTrans.Trans.type = TRADE_TRANSACTION_DEAL_ADD;
            sTrans.Trans.order = sTrans.Result.order;
            sTrans.Trans.deal = sTrans.Result.deal;
            sTrans.Trans.deal_type = (sTrans.Request.type == ORDER_TYPE_BUY || sTrans.Request.type == ORDER_TYPE_BUY_LIMIT) ? 
               DEAL_TYPE_BUY : DEAL_TYPE_SELL;
            sTrans.Trans.price = sTrans.Result.price;
            sTrans.Trans.volume = sTrans.Result.volume;
            sTrans.Trans.symbol = sTrans.Request.symbol;
            OnTradeTransaction(sTrans.Trans, EmptyReq, EmptyRes);
            break;
         case TRANS_ACTION_TYPE_CANCEL_ORDER:
            sTrans.Trans.type = TRADE_TRANSACTION_HISTORY_ADD;
            sTrans.Trans.order = sTrans.Request.order;
            sTrans.Trans.order_state = ORDER_STATE_CANCELED;
            sTrans.Trans.symbol = sTrans.Request.symbol;
            OnTradeTransaction(sTrans.Trans, EmptyReq, EmptyRes);
            break;
      }
      
      ScheduledOnTradeTransactions.Delete(i);
   }

   // OnTradeTransactionIsScheduled = false;

   // switch (req.action)
   // {
   // case TRADE_ACTION_DEAL:
   //-- DEMO
   //    TRADE_TRANSACTION_ORDER_ADD
   //    TRADE_TRANSACTION_DEAL_ADD
   //    TRADE_TRANSACTION_POSITION //only when there was a position
   //    TRADE_TRANSACTION_ORDER_DELETE
   //    TRADE_TRANSACTION_HISTORY_ADD
   //    TRADE_TRANSACTION_REQUEST
   //-- REAL
   //    TRADE_TRANSACTION_ORDER_ADD //variable
   //    TRADE_TRANSACTION_REQUEST //variable - happens twice
   //    TRADE_TRANSACTION_ORDER_UPDATE //variable
   //    TRADE_TRANSACTION_DEAL_ADD //variable
   //    TRADE_TRANSACTION_POSITION //fixed - only when there was a position
   //    TRADE_TRANSACTION_ORDER_DELETE //fixed
   //    TRADE_TRANSACTION_HISTORY_ADD //fixed most times
   //    break;
   // case TRADE_ACTION_PENDING:
   //    TRADE_TRANSACTION_ORDER_ADD
   //    TRADE_TRANSACTION_ORDER_UPDATE
   //    TRADE_TRANSACTION_REQUEST
   //    When it is executed:
   //    TRADE_TRANSACTION_ORDER_UPDATE
   //    TRADE_TRANSACTION_DEAL_ADD
   //    TRADE_TRANSACTION_ORDER_DELETE
   //    TRADE_TRANSACTION_HISTORY_ADD
   //    break;
   // case TRADE_ACTION_MODIFY:
   //    TRADE_TRANSACTION_ORDER_UPDATE
   //    TRADE_TRANSACTION_REQUEST
   //    break;
   // case TRADE_ACTION_REMOVE:
   //    TRADE_TRANSACTION_ORDER_UPDATE
   //    TRADE_TRANSACTION_ORDER_DELETE
   //    TRADE_TRANSACTION_HISTORY_ADD
   //    TRADE_TRANSACTION_REQUEST
   //    break;
   // case TRADE_ACTION_SLTP:
   //    TRADE_TRANSACTION_POSITION
   //    TRADE_TRANSACTION_REQUEST
   //    when it is triggered:
   //    TRADE_TRANSACTION_POSITION
   //    TRADE_TRANSACTION_ORDER_ADD
   //    TRADE_TRANSACTION_DEAL_ADD
   //    TRADE_TRANSACTION_ORDER_DELETE
   //    TRADE_TRANSACTION_HISTORY_ADD
   // case TRADE_ACTION_CLOSE_BY:
   //    break;
   // default:
   //    break;
   // }
}

//-- USED TO CALCULATE LIVE POSITION PROFIT
//Position OverallBuyPosition;
//Position OverallSellPosition;

MqlDateTime CurrentTimeStruct;
int CurrentDay;

// SymbolProperties *GetPredefSymbolProperties(string symbol);
// ulong CreateOrderTicket();
// bool OrderTicketIsUnique(long ticket,int ordersTotal);
// ulong CreatePositionTicket();
// bool PositionTicketIsUnique(long ticket,int positionsTotal);
// ulong CreateDealTicket();
// bool DealTicketIsUnique(long ticket,int dealsTotal);
// double CalculateProfit(string symbol,double execVolume,double avgPosPrice,double avgExecPrice,ENUM_POSITION_TYPE posType);
// double CalculatePosNewAvgPrice(double posAvgPrice,double posVolume,double execPrice,double execVolume);
// int GetFirstPositionIndexBySymbol(string symbol);
// Deal* ManagePositionDealExecution(ulong positionTicket,ENUM_DEAL_TYPE dealType,double dealPrice,double dealVolume,
//       ulong orderTicket);
// Position *CreatePosition(string symbol,ENUM_POSITION_TYPE type,double priceOpen,ulong magic,double sl,double tp,
//       double volume,ulong orderTicket);
// Deal *CreateDeal(string symbol,ENUM_DEAL_TYPE type,ulong position,double price,double profit,ulong magic,double volume,
//       ulong order,ENUM_DEAL_ENTRY entry);
// Order *CreateOrder(string symbol,ENUM_ORDER_TYPE type,double price,ulong posTicket,ulong magic,double sl,double tp,
//       double volume);
// void PrintError(string message);
// bool CheckBuyRequestType(ENUM_ORDER_TYPE orderType);
// bool CheckSellRequestType(ENUM_ORDER_TYPE orderType);
// void SetResponseAttributes(MqlTradeResult &res,ulong deal = 0,ulong order = 0,double volume = 0,double price = 0);
// void SetPositionSLTP(ulong positionTicket,double sl,double tp,ENUM_DEAL_TYPE dealType = -1);
// void RemoveFuturePendingOrders();
// ulong GetFirstPositionTicketBySymbol(string symbol);
// int GetPositionIndexByTicket(ulong ticket);
// int GetOrderIndexByTicket(ulong ticket);
// int GetSymbolBuyPositionsTotal(string symbol);
// int GetSymbolSellPositionsTotal(string symbol);
// int GetSymbolBuyOrdersTotal(string symbol);
// int GetSymbolSellOrdersTotal(string symbol);
// void DrawPositionProfit(string symbol,double livePositionProfit);
// void CalculateOverallPosAvgPrice();
// //double CalculateLivePositionProfit();
// double GetSymbolBuyPositionVolumeTotal(string symbol);
// double GetSymbolSellPositionVolumeTotal(string symbol);
// Position *ClonePosition(Position *position);
// Order *CloneOrder(Order *order);
// //Deal *CloneDeal(Deal *deal);

// //############################################### TESTER CHART OBJECTS ###############################################
// //void DrawPosition(ulong posTicket,string symbol,double avgPosPrice,double sl,double tp);
// void DrawDealArrow(string symbol,double price,datetime time,ENUM_DEAL_TYPE dealType);
// void DrawPosition(Position *position,EnumTChartAction chartAction = CHART_ACTION_DRAW);
// void DrawOrder(Order *order,EnumTChartAction chartAction = CHART_ACTION_DRAW);
// void DrawTesterPanel(string symbol,EnumTChartAction chartAction);
// void CreateTesterPanel(long chartID);

// public:
// void AddPredefSymbolProperties(string symbol,double tickValue,double tickSize,double volumeMin,ENUM_SYMBOL_CALC_MODE calcMode);
// void AddPredefAccountProperties(ENUM_ACCOUNT_MARGIN_MODE accountMarginMode);

void AddPredefSymbolProperties(string symbol,double tickValue,double tickSize,double volumeMin,
   ENUM_SYMBOL_CALC_MODE calcMode){
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

SymbolProperties* GetPredefSymbolProperties(string symbol){
   for(int c = 0; c < PredefSymbolProperties.Total(); c++){
      SymbolProperties *props = PredefSymbolProperties.At(c);
      if(props.Symbol == symbol) return props;
   }
   return NULL;
}

ulong CreateOrderTicket(){
   // ulong ticket = 1;
   // int ordersTotal = TOrdersTotal();
   // while(!OrderTicketIsUnique(ticket,ordersTotal)) ticket++;
   TMQL::LastOrderTicket++;
   // return ticket;
   return TMQL::LastOrderTicket;
}

// bool OrderTicketIsUnique(long ticket,int ordersTotal){
//    for(int c = 0; c < ordersTotal; c++){
//       Order *order = Orders.At(c);
//       if(order.Ticket == ticket) return false;
//    }
//    return true;
// }

// ulong CreatePositionTicket(){
//    ulong ticket = 1;
//    int positionsTotal = TPositionsTotal();
//    while(!PositionTicketIsUnique(ticket,positionsTotal)) ticket++;
//    return ticket;
// }

// bool PositionTicketIsUnique(long ticket,int positionsTotal){
//    for(int c = 0; c < positionsTotal; c++){
//       Position *position = Positions.At(c);
//       if(position.Ticket == ticket) return false;
//    }
//    return true;
// }

ulong CreateDealTicket(){
   // ulong ticket = 1;
   // int dealsTotal = Deals.Total();
   // while(!DealTicketIsUnique(ticket,dealsTotal)) ticket++;
   TMQL::LastDealTicket++;
   return TMQL::LastDealTicket;
}

// bool DealTicketIsUnique(long ticket,int dealsTotal){
//    for(int c = 0; c < dealsTotal; c++){
//       Deal *deal = Deals.At(c);
//       if(deal.Ticket == ticket) return false;
//    }
//    return true;
// }

double CalculateProfit(string symbol,double execVolume,double avgPosPrice,double avgExecPrice,ENUM_POSITION_TYPE posType){
   ENUM_SYMBOL_CALC_MODE calcMode = (ENUM_SYMBOL_CALC_MODE)TSymbolInfoInteger(symbol,SYMBOL_TRADE_CALC_MODE);
   double profit = 0;
   switch(calcMode){
      case SYMBOL_CALC_MODE_EXCH_STOCKS:{
         profit = (avgExecPrice * execVolume - avgPosPrice * execVolume);
         // profit -= StocksFee_TMQL;
         break;
      }
      case SYMBOL_CALC_MODE_EXCH_FUTURES:{
         profit = (avgExecPrice - avgPosPrice) * execVolume * TSymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE) / 
            TSymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);
         // profit -= ContractFee_TMQL * execVolume;
         break;
      }
      default:{
         //-- ERROR INVALID CALC MODE
      }
   }
   if(posType == POSITION_TYPE_SELL) profit = -profit;
   return profit;
}

double CalculatePosNewAvgPrice(double posAvgPrice,double posVolume,double execPrice,double execVolume){
   return (posAvgPrice * posVolume + execPrice * execVolume) / (posVolume + execVolume);
}

int GetFirstPositionIndexBySymbol(string symbol){
   for(int c = 0; c < Positions.Total(); c++){
      Position *position = Positions.At(c);
      if(position.Symbol != symbol) continue;
      return c;
   }
   return -1;
}

bool SLTPAreValid(ENUM_POSITION_TYPE posType,MqlTradeRequest& req,double bid,double ask){
   return !(
      (posType == POSITION_TYPE_BUY && ((req.sl != 0 && req.sl >= bid) || (req.tp != 0 && req.tp <= ask))) || 
      (posType == POSITION_TYPE_SELL && ((req.sl != 0 && req.sl <= ask) || (req.tp != 0 && req.tp >= bid)))
   );
}

// Position can't be 0
// Deal* ManagePositionDealExecution(ulong positionTicket,ENUM_DEAL_TYPE dealType,double dealPrice,double dealVolume,Order* order){
Deal* ManagePositionDealExecution(int positionIndex,ENUM_DEAL_TYPE dealType,double dealPrice,double dealVolume,Order* order){
   // int positionIndex;

   // if(positionTicket == 0){
   //    Order* order = Orders.At(GetOrderIndexByTicket(orderTicket)); //
   //    positionIndex = GetFirstPositionIndexBySymbol(order.Symbol);
   // }
   // else{
      // positionIndex = GetPositionIndexByTicket(positionTicket);
   // }

   bool deletePos = false;
   Position* position = Positions.At(positionIndex);
   // Position* positionClone = ClonePosition(position);
   double dealProfit = 0;
   ENUM_DEAL_ENTRY dealEntry = DEAL_ENTRY_IN;
   //string symbol = position.Symbol;
   //ulong magic = position.Magic;
   
   if(
      (position.Type == POSITION_TYPE_BUY && dealType == DEAL_TYPE_BUY) || 
      (position.Type == POSITION_TYPE_SELL && dealType == DEAL_TYPE_SELL)
   ){
      position.PriceOpen = CalculatePosNewAvgPrice(position.PriceOpen,position.Volume,dealPrice,dealVolume);
      position.Volume += dealVolume;
      TMQL::SetPositionSLTP(positionIndex,order.SL,order.TP);
      DrawPosition(position);
   }
   else{
      double newVol = position.Volume - dealVolume;
      dealProfit = CalculateProfit(position.Symbol,(newVol <= 0 ? position.Volume : dealVolume),position.PriceOpen,
         dealPrice,position.Type);
      CurrentProfit += dealProfit;
      
      if(newVol > 0){
         position.Volume = newVol;
         DrawPosition(position);
         dealEntry = DEAL_ENTRY_OUT;
      }
      else if(newVol <= 0){
         Positions.Detach(positionIndex);
         DrawPosition(position, CHART_ACTION_ERASE);

         if(newVol == 0)
            dealEntry = DEAL_ENTRY_OUT;
         else
         {
            ENUM_POSITION_TYPE newPosType = dealType == DEAL_TYPE_BUY ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;

            Position* newPos = CreatePosition(position.Symbol,newPosType,dealPrice,position.Magic,order.SL,order.TP,
               -newVol,order.PositionId); //order.Ticket
            TMQL::SetPositionSLTP(TMQL::GetPositionIndexByTicket(newPos.Ticket),order.SL,order.TP);

            dealEntry = DEAL_ENTRY_INOUT;
         }

         deletePos = true;
      }
   }

   Deal* deal = CreateDeal(position.Symbol,dealType,position.Id,dealPrice,dealProfit,position.Magic,dealVolume,
      order.Ticket,dealEntry);

   if(deletePos) delete position;
   return deal;
}

Position* CreatePosition(string symbol,ENUM_POSITION_TYPE type,double priceOpen,ulong magic,double sl,double tp,
   double volume,ulong orderTicket)
{
   Position *position = new Position;
   position.Type = type;
   position.PriceOpen = priceOpen;
   // position.AvgPosPrice = priceOpen;
   position.Symbol = symbol;
   position.Ticket = orderTicket; //CreatePositionTicket();
   position.Id = orderTicket;
   position.Magic = magic;
   position.SL = sl;
   position.TP = tp;
   position.Volume = volume;
   position.Time = TimeCurrent();
   Positions.Add(position);
   DrawPosition(position);
   return position;
   //ENUM_DEAL_TYPE dealType = type == POSITION_TYPE_BUY ? DEAL_TYPE_BUY : DEAL_TYPE_SELL;
   //CreateDeal(symbol,dealType,position.Ticket,priceOpen,0,magic,volume,orderTicket,DEAL_ENTRY_IN);
}

Deal* CreateDeal(string symbol,ENUM_DEAL_TYPE type,ulong posID,double price,double profit,ulong magic,double volume,
   ulong order,ENUM_DEAL_ENTRY entry){
   Deal *deal = new Deal;
   deal.PositionId = posID;
   deal.Price = price;
   deal.Magic = magic;
   deal.Symbol = symbol;
   deal.Order = order;
   deal.Volume = volume;
   deal.Profit = profit;
   deal.Time = TimeCurrent();
   deal.Ticket = CreateDealTicket();
   deal.Entry = entry;
   deal.Type = type;
   Deals.Add(deal);
   DrawDealArrow(symbol,price,deal.Time,type);
   return deal;
}

Order* CreateOrder(string symbol,ENUM_ORDER_TYPE type,double price,ulong posID,ulong magic,double sl,double tp,
   double volume,string comment,ENUM_TRADE_REQUEST_ACTIONS tradeAction){
   Order *order = new Order;
   order.Symbol = symbol;
   order.Ticket = CreateOrderTicket();
   order.Magic = magic;
   order.SL = sl;
   order.TP = tp;
   order.Type = type;
   order.VolumeInitial = volume;
   order.PriceOpen = price;
   order.TimeSetup = TimeCurrent();
   order.Comment = comment;
   // order.PositionTicket = posTicket;
   order.PositionId = posID == 0 ? order.Ticket : posID; //position's first order
   
   if(tradeAction == TRADE_ACTION_PENDING)
   {
      order.State = ORDER_STATE_PLACED;
      order.VolumeCurrent = volume;
      Orders.Add(order);
      DrawOrder(order);
   }
   else
   {
      order.State = ORDER_STATE_FILLED;
      HistoryOrders.Add(order);
   }

   return order;
}

void PrintError(string message){ Print("#TMQL# - Error: " + message); }

void Log(string message){ Print("#TMQL#: " + message); }

bool CheckBuyRequestType(ENUM_ORDER_TYPE orderType){
   return orderType == ORDER_TYPE_BUY || orderType == ORDER_TYPE_BUY_LIMIT || orderType == ORDER_TYPE_BUY_STOP || 
      orderType == ORDER_TYPE_BUY_STOP_LIMIT;
}

bool CheckSellRequestType(ENUM_ORDER_TYPE orderType){
   return orderType == ORDER_TYPE_SELL || orderType == ORDER_TYPE_SELL_LIMIT || orderType == ORDER_TYPE_SELL_STOP || 
      orderType == ORDER_TYPE_SELL_STOP_LIMIT;
}

void SetResponseAttributes(MqlTradeResult &res,ulong deal = 0,ulong order = 0,double volume = 0,double price = 0){
   res.deal = deal;
   res.order = order;
   res.volume = volume;
   res.price = price;
}

// void SetPositionSLTP(ulong positionTicket,double sl,double tp,ENUM_DEAL_TYPE dealType = -1){
void SetPositionSLTP(int positionIndex,double sl,double tp)
{
   // int positionIndex = GetPositionIndexByTicket(positionTicket);
   Position *position = Positions.At(positionIndex);
   
   if(position == NULL) return;
   // if(
   //    dealType == -1 ||
   //    (position.Type == POSITION_TYPE_BUY && dealType == DEAL_TYPE_BUY) || 
   //    (position.Type == POSITION_TYPE_SELL && dealType == DEAL_TYPE_SELL)
   // ){
      position.SL = sl;
      position.TP = tp;
      DrawPosition(position,CHART_ACTION_DRAW);
   // }
}

void RemoveFuturePendingOrders(){
   for(int c = Orders.Total() - 1; c >= 0; c--){
      Order *order = Orders.At(c);
      if(TSymbolInfoInteger(order.Symbol,SYMBOL_TRADE_CALC_MODE) == SYMBOL_CALC_MODE_EXCH_FUTURES){
         // Order *orderClone = CloneOrder(order);
         // Orders.Delete(c);
         Orders.Detach(c);
         // DrawOrder(orderClone,CHART_ACTION_ERASE);
         DrawOrder(order,CHART_ACTION_ERASE);
         // DrawTesterPanel(orderClone.Symbol,CHART_ACTION_DRAW);
         DrawTesterPanel(order.Symbol,CHART_ACTION_DRAW);
         // delete(orderClone);
         delete order;
      }
   }
}

ulong GetFirstPositionTicketBySymbol(string symbol){
   for(int c = 0; c < Positions.Total(); c++){
      Position *position = Positions.At(c);
      if(position.Symbol != symbol) continue;
      return position.Ticket;
   }
   return 0;
}

int GetPositionIndexByTicket(ulong ticket){
   for(int c = 0; c < Positions.Total(); c++){
      Position *position = Positions.At(c);
      if(position.Ticket == ticket) return c;
   }
   return -1;
}

int GetOrderIndexByTicket(ulong ticket){
   for(int c = 0; c < Orders.Total(); c++){
      Order *order = Orders.At(c);
      if(order.Ticket == ticket) return c;
   }
   return -1;
}

int GetSymbolBuyPositionsTotal(string symbol){
   int total = 0;
   Position *position;
   for(int c = 0; c < Positions.Total(); c++){
      position = Positions.At(c);
      if(position.Symbol == symbol && position.Type == POSITION_TYPE_BUY) total++;
   }
   return total;
}

int GetSymbolSellPositionsTotal(string symbol){
   int total = 0;
   Position *position;
   for(int c = 0; c < Positions.Total(); c++){
      position = Positions.At(c);
      if(position.Symbol == symbol && position.Type == POSITION_TYPE_SELL) total++;
   }
   return total;
}

int GetSymbolBuyOrdersTotal(string symbol){
   int total = 0;
   Order *order;
   for(int c = 0; c < Orders.Total(); c++){
      order = Orders.At(c);
      if(order.Symbol == symbol && order.Type == ORDER_TYPE_BUY_LIMIT) total++;
   }
   return total;
}

//-- HISTORY METHODS
void ClearHistoryDealList(){
   for(int c = SelectedHistoryDeals.Total() - 1; c >= 0; c--)
      SelectedHistoryDeals.Detach(c);
}

void ClearHistoryOrderList(){
   for(int c = SelectedHistoryOrders.Total() - 1; c >= 0; c--)
      SelectedHistoryOrders.Detach(c);
}

Deal* GetHistoryDealByTicket(ulong ticket){
   for(int c = SelectedHistoryDeals.Total() - 1; c >= 0; c--){
      Deal *deal = SelectedHistoryDeals.At(c);
      if(deal.Ticket == ticket) return deal;
   }
   return NULL;
}

Order* GetHistoryOrderByTicket(ulong ticket){
   for(int c = SelectedHistoryOrders.Total() - 1; c >= 0; c--){
      Order* order = SelectedHistoryOrders.At(c);
      if(order.Ticket == ticket) return order;
   }
   return NULL;
}

int GetSymbolSellOrdersTotal(string symbol){
   int total = 0;
   Order *order;
   for(int c = 0; c < Orders.Total(); c++){
      order = Orders.At(c);
      if(order.Symbol == symbol && order.Type == ORDER_TYPE_SELL_LIMIT) total++;
   }
   return total;
}

int GetSymbolDealsTotal(string symbol){
   int total = 0;
   for(int c = 0; c < Deals.Total(); c++)
      if(((Deal*)Deals.At(c)).Symbol == symbol) total++;
   
   return total;
}

void DrawPositionProfit(string symbol,double livePositionProfit){
   long currentChartID = ChartFirst();
   while(currentChartID >= 0){
      if(ChartSymbol(currentChartID) == symbol){
         if(ObjectFind(currentChartID,"PositionProfit_TMQL") < 0)
            CreateTesterPanel(currentChartID);
         else
            ObjectSetString(currentChartID,"PositionProfit_TMQL",OBJPROP_TEXT,"Position profit: "+ (string)livePositionProfit);
      }
      currentChartID = ChartNext(currentChartID);
   }
}

// void CalculateOverallPosAvgPrice(){
//    double totalBuyPosVol = 0,totalSellPosVol = 0;
//    double totalBuyPosPriceTimesVol = 0,totalSellPosPriceTimesVol = 0;
//    for(int c = 0; c < TPositionsTotal(); c++){
//       Position *position = Positions.At(c);
//       if(position.Type == POSITION_TYPE_BUY){
//          totalBuyPosVol += position.Volume;
//          totalBuyPosPriceTimesVol += position.Volume * position.PriceOpen;
//       }
//       else{
//          totalSellPosVol += position.Volume;
//          totalSellPosPriceTimesVol += position.Volume * position.PriceOpen;
//       }
//    }
// }

//double CalculateLivePositionProfit();

double GetSymbolBuyPositionVolumeTotal(string symbol){
   double totalVolume = 0;
   Position *position;
   for(int c = 0; c < Positions.Total(); c++){
      position = Positions.At(c);
      if(position.Symbol == symbol && position.Type == POSITION_TYPE_BUY) totalVolume += position.Volume;
   }
   return totalVolume;
}

double GetSymbolSellPositionVolumeTotal(string symbol){
   double totalVolume = 0;
   Position *position;
   for(int c = 0; c < Positions.Total(); c++){
      position = Positions.At(c);
      if(position.Symbol == symbol && position.Type == POSITION_TYPE_SELL) totalVolume += position.Volume;
   }
   return totalVolume;
}

// Position* ClonePosition(Position *position){
//    Position *newPos = new Position;
//    newPos.Ticket = position.Ticket;
//    newPos.Magic = position.Magic;
//    newPos.Symbol = position.Symbol;
//    newPos.Type = position.Type;
//    newPos.Volume = position.Volume;
//    newPos.Time = position.Time;
//    newPos.PriceOpen = position.PriceOpen;
//    newPos.SL = position.SL;
//    newPos.TP = position.TP;
//    newPos.AvgPosPrice = position.AvgPosPrice;
//    return newPos;
// }
// Order *CloneOrder(Order *order){
//    Order *newOrder = new Order;
//    newOrder.Ticket = order.Ticket;
//    newOrder.Magic = order.Magic;
//    newOrder.Symbol = order.Symbol;
//    newOrder.Type = order.Type;
//    newOrder.VolumeInitial = order.VolumeInitial;
//    newOrder.Time = order.Time;
//    newOrder.PriceOpen = order.PriceOpen;
//    newOrder.SL = order.SL;
//    newOrder.TP = order.TP;
//    // newOrder.PositionTicket = order.PositionTicket;
//    return newOrder;
// }
// Deal *CloneDeal(Deal *deal){
//    Deal *newDeal = new Deal;
//    newDeal.Ticket = deal.Ticket;
//    newDeal.Order = deal.Order;
//    newDeal.Magic = deal.Magic;
//    newDeal.Symbol = deal.Symbol;
//    newDeal.Volume = deal.Volume;
//    newDeal.Time = deal.Time;
//    newDeal.Price = deal.Price;
//    newDeal.Profit = deal.Profit;
//    newDeal.Position = deal.Position;
//    newDeal.Entry = deal.Entry;
//    newDeal.Type = deal.Type;
//    return newDeal;
// }

//############################################### TESTER CHART OBJECTS ###############################################

//void DrawPosition(ulong posTicket,string symbol,double avgPosPrice,double sl,double tp){
void DrawDealArrow(string symbol,double price,datetime time,ENUM_DEAL_TYPE dealType){
   long currentChartID = ChartFirst();
   //long nextChartID = ChartNext(currentChartID);
   while(currentChartID >= 0){ //!= nextChartID
      if(ChartSymbol(currentChartID) == symbol){
         if(dealType == DEAL_TYPE_BUY)
            co_TMQL.DrawBuyArrow(currentChartID,price,time,"BuyArrowObj_TMQL");
         else
            co_TMQL.DrawSellArrow(currentChartID,price,time,"SellArrowObj_TMQL");
      }
      //currentChartID = nextChartID;
      //nextChartID = ChartNext(currentChartID);
      currentChartID = ChartNext(currentChartID);
   }
}

void DrawPosition(Position *position,EnumTChartAction chartAction = CHART_ACTION_DRAW){
   long currentChartID = ChartFirst();
   while(currentChartID >= 0){
      if(ChartSymbol(currentChartID) == position.Symbol){
         string positionAvgPriceObjName = "Position" + (string)position.Ticket;
         string positionSLObjName = "Position" + (string)position.Ticket + "SL";
         string positionTPObjName = "Position" + (string)position.Ticket + "TP";
         if(chartAction == CHART_ACTION_DRAW){
            //-- DRAW POSITION
            if(ObjectFind(currentChartID,positionAvgPriceObjName) >= 0)
               ObjectSetDouble(currentChartID,positionAvgPriceObjName,OBJPROP_PRICE,position.PriceOpen);
            else
               co_TMQL.DrawHLine(currentChartID,positionAvgPriceObjName,position.PriceOpen,clrYellowGreen,STYLE_DASHDOTDOT);
            
            //-- DRAW POSITION SL
            if(position.SL != 0){
               if(ObjectFind(currentChartID,positionSLObjName) >= 0)
                  ObjectSetDouble(currentChartID,positionSLObjName,OBJPROP_PRICE,position.SL);
               else
                  co_TMQL.DrawHLine(currentChartID,positionSLObjName,position.SL,clrYellowGreen,STYLE_DOT);
            }
            else{
               ObjectDelete(currentChartID,positionSLObjName);
            }
            
            //-- DRAW POSITION TP   
            if(position.TP != 0){
               if(ObjectFind(currentChartID,positionTPObjName) >= 0)
                  ObjectSetDouble(currentChartID,positionTPObjName,OBJPROP_PRICE,position.TP);
               else
                  co_TMQL.DrawHLine(currentChartID,positionTPObjName,position.TP,clrYellowGreen,STYLE_DOT);
            }
            else{
               ObjectDelete(currentChartID,positionTPObjName);
            }         
         }
         else if(chartAction == CHART_ACTION_ERASE){
            ObjectDelete(currentChartID,positionAvgPriceObjName);
            ObjectDelete(currentChartID,positionSLObjName);            
            ObjectDelete(currentChartID,positionTPObjName);            
         }
      }
      currentChartID = ChartNext(currentChartID);
   }
}

void DrawOrder(Order* order, EnumTChartAction chartAction = CHART_ACTION_DRAW){
   long currentChartID = ChartFirst();
   while(currentChartID >= 0){
      if(ChartSymbol(currentChartID) == order.Symbol){
         string orderPriceObjName = "Order" + (string)order.Ticket;
         string orderSLObjName = "Order" + (string)order.Ticket + "SL";
         string orderTPObjName = "Order" + (string)order.Ticket + "TP";
         if(chartAction == CHART_ACTION_DRAW){
            //-- DRAW ORDER
            if(ObjectFind(currentChartID,orderPriceObjName) >= 0)
               ObjectSetDouble(currentChartID,orderPriceObjName,OBJPROP_PRICE,order.PriceOpen);
            else
               co_TMQL.DrawHLine(currentChartID,orderPriceObjName,order.PriceOpen,clrRed,STYLE_DASHDOT);
            
            //-- DRAW ORDER SL   
            if(order.SL != 0){
               if(ObjectFind(currentChartID,orderSLObjName) >= 0)
                  ObjectSetDouble(currentChartID,orderSLObjName,OBJPROP_PRICE,order.SL);
               else
                  co_TMQL.DrawHLine(currentChartID,orderSLObjName,order.SL,clrRed,STYLE_DOT);
            }
            else{
               ObjectDelete(currentChartID,orderSLObjName);
            }
            
            //-- DRAW ORDER TP
            if(order.TP != 0){
               if(ObjectFind(currentChartID,orderTPObjName) >= 0)
                  ObjectSetDouble(currentChartID,orderTPObjName,OBJPROP_PRICE,order.TP);
               else
                  co_TMQL.DrawHLine(currentChartID,orderTPObjName,order.TP,clrRed,STYLE_DOT);
            }
            else{
               ObjectDelete(currentChartID,orderTPObjName);
            }
         }
         else if(chartAction == CHART_ACTION_ERASE){
            ObjectDelete(currentChartID,orderPriceObjName);
            ObjectDelete(currentChartID,orderSLObjName);            
            ObjectDelete(currentChartID,orderTPObjName);            
         }
      }
      currentChartID = ChartNext(currentChartID);
   }
}

void DrawTesterPanel(string symbol,EnumTChartAction chartAction,bool manualCall = false){
   if(!manualCall && !ShowInformationPanel) return;
   long currentChartID = ChartFirst();
   while(currentChartID >= 0){
      if(ChartSymbol(currentChartID) == symbol){
         switch(chartAction){
            case CHART_ACTION_DRAW:{
               if(
                  ObjectFind(currentChartID,"Profit_TMQL") >= 0 && ObjectFind(currentChartID,"PositionProfit_TMQL") >= 0 && 
                  ObjectFind(currentChartID,"BuyPositions_TMQL") >= 0 && ObjectFind(currentChartID,"SellPositions_TMQL") >= 0 &&
                  ObjectFind(currentChartID,"BuyOrders_TMQL") >= 0 && ObjectFind(currentChartID,"SellOrders_TMQL") >= 0 &&
                  ObjectFind(currentChartID,"Deals_TMQL") >= 0
               ){
                  ObjectSetString(currentChartID,"Profit_TMQL",OBJPROP_TEXT,"Profit: "+ (string)CurrentProfit);
                  ObjectSetString(currentChartID,"BuyPositions_TMQL",OBJPROP_TEXT,"Buy positions: "+ (string)GetSymbolBuyPositionsTotal(ChartSymbol(currentChartID)) + " (Total Vol.: "+ (string)GetSymbolBuyPositionVolumeTotal(ChartSymbol(currentChartID))+ ")");
                  ObjectSetString(currentChartID,"SellPositions_TMQL",OBJPROP_TEXT,"Sell positions: "+ (string)GetSymbolSellPositionsTotal(ChartSymbol(currentChartID)) + " (Total Vol.: "+ (string)GetSymbolSellPositionVolumeTotal(ChartSymbol(currentChartID))+ ")");
                  ObjectSetString(currentChartID,"BuyOrders_TMQL",OBJPROP_TEXT,"Buy orders: "+ (string)GetSymbolBuyOrdersTotal(ChartSymbol(currentChartID)));
                  ObjectSetString(currentChartID,"SellOrders_TMQL",OBJPROP_TEXT,"Sell orders: "+ (string)GetSymbolSellOrdersTotal(ChartSymbol(currentChartID)));
                  ObjectSetString(currentChartID,"Deals_TMQL",OBJPROP_TEXT,"Deals: "+ (string)GetSymbolDealsTotal(ChartSymbol(currentChartID)));
               }
               else{
                  CreateTesterPanel(currentChartID);
               }
               break;
            }
            case CHART_ACTION_ERASE:{
               ObjectDelete(currentChartID,"Profit_TMQL");
               ObjectDelete(currentChartID,"PositionProfit_TMQL");
               ObjectDelete(currentChartID,"BuyPositions_TMQL");
               ObjectDelete(currentChartID,"SellPositions_TMQL");
               ObjectDelete(currentChartID,"BuyOrders_TMQL");
               ObjectDelete(currentChartID,"SellOrders_TMQL");
               ObjectDelete(currentChartID,"Deals_TMQL");
               break;
            }
         }
      }
      currentChartID = ChartNext(currentChartID);
   }
}

void CreateTesterPanel(long chartID){
   long xDistance = 4;
   long fontSize = 9;
   co_TMQL.DrawLabel(chartID,"Profit_TMQL","Profit: "+(string)CurrentProfit,xDistance,15,clrWhite,fontSize,CORNER_LEFT_UPPER);
   co_TMQL.DrawLabel(chartID,"PositionProfit_TMQL","Position profit: 0",xDistance,30,clrWhite,fontSize,CORNER_LEFT_UPPER);
   co_TMQL.DrawLabel(chartID,"BuyPositions_TMQL","Buy positions: "+(string)GetSymbolBuyPositionsTotal(ChartSymbol(chartID)) + " (Total Vol.: "+ (string)GetSymbolBuyPositionVolumeTotal(ChartSymbol(chartID))+ ")",xDistance,45,clrWhite,
      fontSize,CORNER_LEFT_UPPER);
   co_TMQL.DrawLabel(chartID,"SellPositions_TMQL","Sell positions: "+(string)GetSymbolSellPositionsTotal(ChartSymbol(chartID)) + " (Total Vol.: "+ (string)GetSymbolSellPositionVolumeTotal(ChartSymbol(chartID))+ ")",xDistance,60,clrWhite,
      fontSize,CORNER_LEFT_UPPER);
   co_TMQL.DrawLabel(chartID,"BuyOrders_TMQL","Buy orders: "+(string)GetSymbolBuyOrdersTotal(ChartSymbol(chartID)),xDistance,75,clrWhite,
      fontSize,CORNER_LEFT_UPPER);
   co_TMQL.DrawLabel(chartID,"SellOrders_TMQL","Sell orders: "+(string)GetSymbolSellOrdersTotal(ChartSymbol(chartID)),xDistance,90,clrWhite,
      fontSize,CORNER_LEFT_UPPER);
   co_TMQL.DrawLabel(chartID,"Deals_TMQL","Deals: "+(string)GetSymbolDealsTotal(ChartSymbol(chartID)),xDistance,105,clrWhite,
      fontSize,CORNER_LEFT_UPPER);
}

} // namespace TMQL