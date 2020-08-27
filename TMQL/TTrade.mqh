//#include <Nain\Utilities\Utilities.mqh>
#include <Nain\TMQL\TMQL.mqh>

//-- METHODS --
//  TBuy
//  TSell
//  TCleanReqRes
//  TCancelAllSymbolOrders
//  TCancelOrder
//  TCancelSymbolBuyOrders
//  TCanceAllSymbolSellOrders
//  TCloseAllSymbolBuyPositions
//  TCloseAllSymbolSellPositions
//  TCloseAllSymbolPositions
//  TSymbolDealProfitTotal
//  TSymbolLimitOrdersTotal
//  TSymbolMarketOrdersTotal
//  TSymbolPositionsTotal

//############################################### CUSTOMIZED METHODS ###############################################

bool TBuy(string symbol,MqlTradeRequest &req,MqlTradeResult &res,double volume,ENUM_TRADE_REQUEST_ACTIONS tradeAction = TRADE_ACTION_DEAL,
   ENUM_ORDER_TYPE_TIME orderTypeTime = ORDER_TIME_SPECIFIED,ENUM_ORDER_TYPE_FILLING orderTypeFilling = ORDER_FILLING_RETURN,
   ulong positionTicket = -1,double price = 0,double tp = 0,double sl = 0,ulong deviation = 0,long magic = -1) export{
   TCleanReqRes(req,res);
   switch(tradeAction){
    case TRADE_ACTION_DEAL:
      req.type = ORDER_TYPE_BUY;
      break; 
    case TRADE_ACTION_PENDING:
      req.type = ORDER_TYPE_BUY_LIMIT;
      req.price = price;
      req.magic = magic;
      break;
    default:
      PrintFormat("#ADVISOR#: BUY ORDER FAILURE | INVALID TRADE REQUEST ACTION");
      return false;
   }
   req.action = tradeAction;
   req.type_filling = ORDER_FILLING_RETURN;
   req.type_time = orderTypeTime;
   req.symbol = symbol;
   req.volume = volume;
   req.deviation = deviation;
   req.tp = tp;
   req.sl = sl;
   if(positionTicket != -1) req.position = positionTicket;
   
   if(!TOrderSend(req,res)){
      PrintFormat("#ADVISOR#: BUY ORDER FAILURE | TOrderSend ERROR:%d RETCODE:%d",GetLastError(), res.retcode);
   }
   else{
      PrintFormat("#ADVISOR#: BUY ORDER SUCCESS | PRICE:%g ORDER:%I64u DEAL:%I64u",res.price,res.order,res.deal);
      return true;
   }  
   return false;
}

bool TSell(string symbol,MqlTradeRequest &req,MqlTradeResult &res,double volume,ENUM_TRADE_REQUEST_ACTIONS tradeAction = TRADE_ACTION_DEAL,
   ENUM_ORDER_TYPE_TIME orderTypeTime = ORDER_TIME_SPECIFIED,ENUM_ORDER_TYPE_FILLING orderTypeFilling = ORDER_FILLING_RETURN,
   ulong positionTicket = -1,double price = 0,double tp = 0,double sl = 0,ulong deviation = 0,long magic = -1) export{
   TCleanReqRes(req,res);
   switch(tradeAction){
    case TRADE_ACTION_DEAL:
      req.type = ORDER_TYPE_SELL;
      break; 
    case TRADE_ACTION_PENDING:
      req.type = ORDER_TYPE_SELL_LIMIT;
      req.price = price;
      if(magic != -1) req.magic = magic;
      break;
    default:
      PrintFormat("#ADVISOR#: SELL ORDER FAILURE | INVALID TRADE REQUEST ACTION");
      return false;
   }
   req.action = tradeAction;
   req.type_filling = orderTypeFilling;
   req.type_time = orderTypeTime;
   req.symbol = symbol;
   req.volume = volume;
   req.deviation = deviation;
   req.tp = tp;
   req.sl = sl;
   if(positionTicket != -1) req.position = positionTicket;

   if(!TOrderSend(req,res)){
      PrintFormat("#ADVISOR#: SELL ORDER FAILURE | TOrderSend ERROR:%d RETCODE:%d",GetLastError(), res.retcode);
   }
   else{
      PrintFormat("#ADVISOR#: SELL ORDER SUCCESS | PRICE:%g ORDER:%I64u DEAL:%I64u",res.price,res.order,res.deal);
      return true;
   }  
   return false;
}

void TCleanReqRes(MqlTradeRequest &req,MqlTradeResult &res){
   ZeroMemory(req);
   ZeroMemory(res);
}

double TSymbolDealProfitTotal(datetime fromDate,datetime toDate,string symbol){
   THistorySelect(fromDate,toDate);
   double totalProfit = 0;
   for(int c = 0; c < THistoryDealsTotal(); c++){
      ulong ticket = THistoryDealGetTicket(c);
      string dealSymbol = THistoryDealGetString(ticket,DEAL_SYMBOL);
      if(dealSymbol != symbol) continue;
      totalProfit += THistoryDealGetDouble(ticket,DEAL_PROFIT);
   }
   return totalProfit;
}


// ############################################## ORDERS ##############################################

void TCancelAllSymbolOrders(MqlTradeRequest &req,MqlTradeResult &res,string symbol){
   for(int c = TOrdersTotal() - 1; c >= 0; c--){
      ulong  orderTicket = TOrderGetTicket(c);
      if(TOrderGetString(ORDER_SYMBOL) != symbol) continue;
      TCancelOrder(orderTicket,req,res);
   }
}

bool TCancelOrder(ulong orderTicket, MqlTradeRequest &req, MqlTradeResult &res){
   TCleanReqRes(req,res);
   req.action = TRADE_ACTION_REMOVE;
   req.order = orderTicket;
   if(!TOrderSend(req,res)){
      PrintFormat("#ADVISOR#: CANCEL ORDER FAILURE | TOrderSend ERROR:%d RETCODE:%d",GetLastError(), res.retcode);
      return false;
   }
   return true;
}

void TCancelSymbolBuyOrders(MqlTradeRequest &req,MqlTradeResult &res,string symbol){
   for(int c = TOrdersTotal() - 1; c >= 0; c--){
      ulong orderTicket = TOrderGetTicket(c);
      if(TOrderGetString(ORDER_SYMBOL) != symbol || TOrderGetInteger(ORDER_TYPE) != ORDER_TYPE_BUY_LIMIT) continue;
      TCancelOrder(orderTicket,req,res);
   }
}

void TCancelSymbolSellOrders(MqlTradeRequest &req,MqlTradeResult &res,string symbol){
   for(int c = TOrdersTotal() - 1; c >= 0; c--){
      ulong orderTicket = TOrderGetTicket(c);
      if(TOrderGetString(ORDER_SYMBOL) != symbol || TOrderGetInteger(ORDER_TYPE) != ORDER_TYPE_SELL_LIMIT) continue;
      TCancelOrder(orderTicket,req,res);
   }
}

int TSymbolLimitOrdersTotal(string symbol){
   int totalOrders = 0;
   for(int c = 0; c < TOrdersTotal(); c++){
      ulong  orderTicket = TOrderGetTicket(c);
      ENUM_ORDER_TYPE orderType = (ENUM_ORDER_TYPE)TOrderGetInteger(ORDER_TYPE);
      if(TOrderGetString(ORDER_SYMBOL) != symbol || !(orderType == ORDER_TYPE_BUY_LIMIT || orderType == ORDER_TYPE_SELL_LIMIT)) continue;
      totalOrders++;
   }
   return totalOrders;
}

int TSymbolMarketOrdersTotal(string symbol){
   int totalOrders = 0;
   for(int c = 0; c < TOrdersTotal(); c++){
      ulong  orderTicket = TOrderGetTicket(c);
      ENUM_ORDER_TYPE orderType = (ENUM_ORDER_TYPE)TOrderGetInteger(ORDER_TYPE);
      if(TOrderGetString(ORDER_SYMBOL) != symbol || !(orderType == ORDER_TYPE_BUY || orderType == ORDER_TYPE_SELL)) continue;
      totalOrders++;
   }
   return totalOrders;
}

// ############################################## POSITIONS ##############################################

void TCloseAllSymbolPositions(MqlTradeRequest &req,MqlTradeResult &res,string symbol){
   for(int c = 0; c < TPositionsTotal(); c++){
      ulong positionTicket = TPositionGetTicket(c);
      if(TPositionGetString(POSITION_SYMBOL) != symbol) return;
      ENUM_POSITION_TYPE positionType = (ENUM_POSITION_TYPE)TPositionGetInteger(POSITION_TYPE);
      double volume = TPositionGetDouble(POSITION_VOLUME);
      
      if(positionType == POSITION_TYPE_BUY) TSell(symbol,req,res,volume,1,2,2,positionTicket);
      else TBuy(symbol,req,res,volume,1,2,2,positionTicket);
   }
}

void TCloseAllSymbolSellPositions(MqlTradeRequest &req,MqlTradeResult &res,string symbol){
   for(int c = 0; c < TPositionsTotal(); c++){
      ulong positionTicket = TPositionGetTicket(c);
      if(TPositionGetString(POSITION_SYMBOL) != symbol || TPositionGetInteger(POSITION_TYPE) != POSITION_TYPE_SELL) return;
      TBuy(symbol,req,res,TPositionGetDouble(POSITION_VOLUME),1,2,2,positionTicket);
   }
}

void TCloseAllSymbolBuyPositions(MqlTradeRequest &req,MqlTradeResult &res,string symbol){
    for(int c = 0; c < TPositionsTotal(); c++){
      ulong positionTicket = TPositionGetTicket(c);
      if(TPositionGetString(POSITION_SYMBOL) != symbol || TPositionGetInteger(POSITION_TYPE) != POSITION_TYPE_BUY) return;
      TSell(symbol,req,res,TPositionGetDouble(POSITION_VOLUME),1,2,2,positionTicket);
   }
}

int TSymbolPositionsTotal(string symbol){
   int total = 0;
   for(int c = 0; c < TPositionsTotal(); c++){
      ulong  positionTicket = TPositionGetTicket(c);
      if(TPositionGetString(POSITION_SYMBOL) == symbol) total++;
   }
   return total;
}