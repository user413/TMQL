
bool Buy(string symbol,MqlTradeRequest &req,MqlTradeResult &res,double volume,ENUM_TRADE_REQUEST_ACTIONS tradeAction = TRADE_ACTION_DEAL,
   ENUM_ORDER_TYPE_TIME orderTypeTime = ORDER_TIME_DAY,ENUM_ORDER_TYPE_FILLING orderTypeFilling = ORDER_FILLING_RETURN,
   ulong positionTicket = 0,double price = 0,double tp = 0,double sl = 0,ulong deviation = 0,long magic = 0){
   CleanReqRes(req,res);
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
   if(positionTicket != 0) req.position = positionTicket;
   
   if(!OrderSend(req,res)){
      PrintFormat("#ADVISOR#: BUY ORDER FAILURE | ORDERSEND ERROR:%d RETCODE:%d",GetLastError(), res.retcode);
   }
   else{
      PrintFormat("#ADVISOR#: BUY ORDER SUCCESS | PRICE:%g ORDER:%I64u DEAL:%I64u",res.price,res.order,res.deal);
      return true;
   }  
   return false;
}

bool Sell(string symbol,MqlTradeRequest &req,MqlTradeResult &res,double volume,ENUM_TRADE_REQUEST_ACTIONS tradeAction = TRADE_ACTION_DEAL,
   ENUM_ORDER_TYPE_TIME orderTypeTime = ORDER_TIME_DAY,ENUM_ORDER_TYPE_FILLING orderTypeFilling = ORDER_FILLING_RETURN,
   ulong positionTicket = 0,double price = 0,double tp = 0,double sl = 0,ulong deviation = 0,long magic = 0){
   CleanReqRes(req,res);
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
   if(positionTicket != 0) req.position = positionTicket;

   if(!OrderSend(req,res)){
      PrintFormat("#ADVISOR#: SELL ORDER FAILURE | ORDERSEND ERROR:%d RETCODE:%d",GetLastError(), res.retcode);
   }
   else{
      PrintFormat("#ADVISOR#: SELL ORDER SUCCESS | PRICE:%g ORDER:%I64u DEAL:%I64u",res.price,res.order,res.deal);
      return true;
   }  
   return false;
}

void CleanReqRes(MqlTradeRequest &req,MqlTradeResult &res){
   ZeroMemory(req);
   ZeroMemory(res);
}

double SymbolDealProfitTotal(datetime fromDate,datetime toDate,string symbol){
   HistorySelect(fromDate,toDate);
   double totalProfit = 0;
   for(int c = 0; c < HistoryDealsTotal(); c++){
      ulong ticket = HistoryDealGetTicket(c);
      string dealSymbol = HistoryDealGetString(ticket,DEAL_SYMBOL);
      if(dealSymbol != symbol) continue;
      totalProfit += HistoryDealGetDouble(ticket,DEAL_PROFIT);
   }
   return totalProfit;
}

// ############################################## ORDERS ##############################################

void CancelAllSymbolOrders(MqlTradeRequest &req,MqlTradeResult &res,string symbol){
   for(int c = OrdersTotal() - 1; c >= 0; c--){
      ulong  orderTicket = OrderGetTicket(c);
      if(OrderGetString(ORDER_SYMBOL) != symbol) continue;
      CancelOrder(orderTicket,req,res);
   }
}

bool CancelOrder(ulong orderTicket, MqlTradeRequest &req, MqlTradeResult &res){
   CleanReqRes(req,res);
   req.action = TRADE_ACTION_REMOVE;
   req.order = orderTicket;
   if(!OrderSend(req,res)){
      PrintFormat("#ADVISOR#: CANCEL ORDER FAILURE | ORDERSEND ERROR:%d RETCODE:%d",GetLastError(), res.retcode);
      return false;
   }
   return true;
}

void CancelSymbolBuyOrders(MqlTradeRequest &req,MqlTradeResult &res,string symbol){
   for(int c = OrdersTotal() - 1; c >= 0; c--){
      ulong  orderTicket = OrderGetTicket(c);
      if(OrderGetString(ORDER_SYMBOL) != Symbol() || OrderGetInteger(ORDER_TYPE) != ORDER_TYPE_BUY_LIMIT) continue;
      CancelOrder(orderTicket,req,res);
   }
}

void CancelSymbolSellOrders(MqlTradeRequest &req,MqlTradeResult &res,string symbol){
   for(int c = OrdersTotal() - 1; c >= 0; c--){
      ulong  orderTicket = OrderGetTicket(c);
      if(OrderGetString(ORDER_SYMBOL) != Symbol() || OrderGetInteger(ORDER_TYPE) != ORDER_TYPE_SELL_LIMIT) continue;
      CancelOrder(orderTicket,req,res);
   }
}

int SymbolLimitOrdersTotal(string symbol){
   int totalOrders = 0;
   for(int c = 0; c < OrdersTotal(); c++){
      ulong  orderTicket = OrderGetTicket(c);
      ENUM_ORDER_TYPE orderType = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
      if(OrderGetString(ORDER_SYMBOL) != symbol || !(orderType == ORDER_TYPE_BUY_LIMIT || orderType == ORDER_TYPE_SELL_LIMIT)) continue;
      totalOrders++;
   }
   return totalOrders;
}

int SymbolMarketOrdersTotal(string symbol){
   int totalOrders = 0;
   for(int c = 0; c < OrdersTotal(); c++){
      ulong  orderTicket = OrderGetTicket(c);
      ENUM_ORDER_TYPE orderType = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
      if(OrderGetString(ORDER_SYMBOL) != symbol || !(orderType == ORDER_TYPE_BUY || orderType == ORDER_TYPE_SELL)) continue;
      totalOrders++;
   }
   return totalOrders;
}


// ############################################## POSITIONS ##############################################

void CloseAllSymbolPositions(MqlTradeRequest &req,MqlTradeResult &res,string symbol){
   for(int c = 0; c < PositionsTotal(); c++){
      ulong positionTicket = PositionGetTicket(c);
      if(PositionGetString(POSITION_SYMBOL) != symbol) return;
      ENUM_POSITION_TYPE positionType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      double volume = PositionGetDouble(POSITION_VOLUME);
      
      if(positionType == POSITION_TYPE_BUY) Sell(symbol,req,res,volume,1,2,2,positionTicket);
      else Buy(symbol,req,res,volume,1,2,2,positionTicket);
   }
}

void CloseAllSymbolSellPositions(MqlTradeRequest &req,MqlTradeResult &res,string symbol){
   for(int c = 0; c < PositionsTotal(); c++){
      ulong positionTicket = PositionGetTicket(c);
      if(PositionGetString(POSITION_SYMBOL) != symbol || PositionGetInteger(POSITION_TYPE) != POSITION_TYPE_SELL) return;
      Buy(symbol,req,res,PositionGetDouble(POSITION_VOLUME),1,2,2,positionTicket);
   }
}

void CloseAllSymbolBuyPositions(MqlTradeRequest &req,MqlTradeResult &res,string symbol){
    for(int c = 0; c < PositionsTotal(); c++){
      ulong positionTicket = PositionGetTicket(c);
      if(PositionGetString(POSITION_SYMBOL) != symbol || PositionGetInteger(POSITION_TYPE) != POSITION_TYPE_BUY) return;
      Sell(symbol,req,res,PositionGetDouble(POSITION_VOLUME),1,2,2,positionTicket);
   }
}

int SymbolPositionsTotal(string symbol){
   int total = 0;
   for(int c = 0; c < PositionsTotal(); c++){
      ulong  positionTicket = PositionGetTicket(c);
      if(PositionGetString(POSITION_SYMBOL) == symbol) total++;
   }
   return total;
}