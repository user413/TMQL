#property copyright "Nain"

#include "Declarations.mqh"
//#include "..\Utilities\Utilities.mqh"

//-- IMPLEMENTED METHODS --
// THistoryDealGetDouble
// THistoryDealGetInteger
// THistoryDealGetString
// THistoryDealGetTicket
// THistoryDealsTotal
// THistorySelect
// TOrderGetDouble
// TOrderGetInteger
// TOrderGetString
// TOrderGetDouble
// TOrderGetTicket
// TPositionGetDouble
// TPositionGetInteger
// TPositionGetString
// TPositionGetTicket
// TPositionsTotal
// TOrderSend
// TSymbolInfoDouble
// TSymbolInfoInteger
// TOrderSelect
// TPositionSelect

//-- SUMMARY --
// int TPositionsTotal();
// int TOrdersTotal();
// string TOrderGetString(ENUM_ORDER_PROPERTY_STRING prop);
// ulong TOrderGetInteger(ENUM_ORDER_PROPERTY_INTEGER prop);
// double TOrderGetDouble(ENUM_ORDER_PROPERTY_DOUBLE prop);
// string TPositionGetString(ENUM_POSITION_PROPERTY_STRING prop);
// ulong TPositionGetInteger(ENUM_POSITION_PROPERTY_INTEGER prop);
// double TPositionGetDouble(ENUM_POSITION_PROPERTY_DOUBLE prop);
// ulong TOrderGetTicket(uint orderIndex);
// ulong TPositionGetTicket(uint positionIndex);
// bool TOrderSend(MqlTradeRequest &request,MqlTradeResult &result);
// void TManageTrade();

//###############################################  MQL METHODS ###############################################

//-- HISTORY METHODS
void ClearHistoryDealList(){
   for(int c = SelectedHistoryDeals.Total() - 1; c >= 0; c--)
      SelectedHistoryDeals.Detach(c);
}

bool THistorySelect(datetime fromDate, datetime toDate){
   ClearHistoryDealList();
   if(fromDate > toDate) return false;
   
   //-- SELECTING DEALS
   for(int c = Deals.Total() - 1; c >= 0; c--){
      Deal *deal = Deals.At(c);
      if(deal.Time >= fromDate && deal.Time <= toDate)
         SelectedHistoryDeals.Add(deal);
   }
   
   //for(int c = Orders.Total() - 1; c >= 0; c--){
   //   Deal *deal = Deals.At(c);
   //   if(deal.Time >= fromDate && deal.Time <= toDate)
   //      SelectedHistoryOrders.Add(deal);
   //}
   
   if(SelectedHistoryDeals.Total() <= 0) return false;
   return true;
}

ulong THistoryDealGetTicket(int dealIndex){
   Deal *historyDeal = SelectedHistoryDeals.At(dealIndex);
   if(historyDeal == NULL) return 0;
   return historyDeal.Ticket;
}

Deal *GetHistoryDealByTicket(ulong ticket){
   for(int c = SelectedHistoryDeals.Total() - 1; c >= 0; c--){
      Deal *deal = SelectedHistoryDeals.At(c);
      if(deal.Ticket == ticket) return deal;
   }
   return NULL;
}

int THistoryDealsTotal(){
   return SelectedHistoryDeals.Total();
}

string THistoryDealGetString(ulong ticket,ENUM_DEAL_PROPERTY_STRING prop){
   Deal *deal = GetHistoryDealByTicket(ticket);
   switch(prop){
      case DEAL_SYMBOL:
         return deal.Symbol;
   }
   return "";
}

ulong THistoryDealGetInteger(ulong ticket,ENUM_DEAL_PROPERTY_INTEGER prop){
   Deal *deal = GetHistoryDealByTicket(ticket);
   switch(prop){
      case DEAL_TICKET:
         return deal.Ticket;
      case DEAL_ORDER:
         return deal.Order;
      case DEAL_MAGIC:
         return deal.Magic;
      case DEAL_POSITION_ID:
         return deal.Position;
      case DEAL_TIME:
         return deal.Time;
      case DEAL_ENTRY:
         return deal.Entry;
   }
   return 0;
}

double THistoryDealGetDouble(ulong ticket,ENUM_DEAL_PROPERTY_DOUBLE prop){
   Deal *deal = GetHistoryDealByTicket(ticket);
   switch(prop){
      case DEAL_VOLUME:
         return deal.Volume;
      case DEAL_PRICE:
         return deal.Price;
      case DEAL_PROFIT:
         return deal.Profit;
   }
   return 0;
}


//-- ORDER METHODS

int TOrdersTotal() export{
   return Orders.Total();
}

string TOrderGetString(ENUM_ORDER_PROPERTY_STRING prop) export{
   switch(prop){
      case ORDER_SYMBOL:
         return SelectedOrder.Symbol;
   }
   return "";
}
ulong TOrderGetInteger(ENUM_ORDER_PROPERTY_INTEGER prop) export{
   switch(prop){
      case ORDER_TICKET:
         return SelectedOrder.Ticket;
      case ORDER_TIME_SETUP:
         return SelectedOrder.Time;
      case ORDER_TYPE:
         return SelectedOrder.Type;
      case ORDER_MAGIC:
         return SelectedOrder.Magic;
      case ORDER_POSITION_ID:
         return SelectedOrder.PositionTicket;
   }
   return 0;
}
double TOrderGetDouble(ENUM_ORDER_PROPERTY_DOUBLE prop) export{
   switch(prop){
      case ORDER_PRICE_OPEN:
         return SelectedOrder.Price;
      case ORDER_TP:
         return SelectedOrder.TP;
      case ORDER_SL:
         return SelectedOrder.SL;
      case ORDER_VOLUME_CURRENT:
         return SelectedOrder.Volume;
   }
   return 0;
}

bool TOrderSelect(ulong ticket){
   int i = GetOrderIndexByTicket(ticket);
   if(i<0) return false;
   SelectedOrder = Orders.At(i);
   return true;
}

ulong TOrderGetTicket(uint orderIndex) export{
   Order *order = Orders.At(orderIndex);
   if(order == NULL) return 0;
   SelectedOrder = order;
   return SelectedOrder.Ticket;
}

ulong CreateOrderTicket(){
   ulong ticket = 1;
   int ordersTotal = TOrdersTotal();
   while(!OrderTicketIsUnique(ticket,ordersTotal)) ticket++;
   return ticket;
}

bool OrderTicketIsUnique(long ticket,int ordersTotal){
   for(int c = 0; c < ordersTotal; c++){
      Order *order = Orders.At(c);
      if(order.Ticket == ticket) return false;
   }
   return true;
}



//-- POSITION METHODS

bool TPositionSelect(string symbol){
   for (int i = 0; i < Positions.Total(); i++)
   {
      Position *position = Positions.At(i);
      if(position.Symbol == symbol){
         SelectedPosition = position;
         return true;
      }
   }
   return false;
}

int TPositionsTotal() export{
   return Positions.Total();
}

string TPositionGetString(ENUM_POSITION_PROPERTY_STRING prop) export{
   switch(prop){
      case POSITION_SYMBOL:
         return SelectedPosition.Symbol;
   }
   return "";
}
ulong TPositionGetInteger(ENUM_POSITION_PROPERTY_INTEGER prop) export{
   switch(prop){
      case POSITION_TICKET:
         return SelectedPosition.Ticket;
      case POSITION_TIME: //-- open time
         return SelectedPosition.Time;
      case POSITION_TYPE:
         return SelectedPosition.Type;
   }
   return 0;
}
double TPositionGetDouble(ENUM_POSITION_PROPERTY_DOUBLE prop) export{
   switch(prop){
      case POSITION_PRICE_OPEN:
         return SelectedPosition.PriceOpen;
      case POSITION_TP:
         return SelectedPosition.TP;
      case POSITION_SL:
         return SelectedPosition.SL;
      case POSITION_VOLUME:
         return SelectedPosition.Volume;
   }
   return 0;
}

ulong TPositionGetTicket(uint positionIndex) export{
   Position *position = Positions.At(positionIndex);
   if(position == NULL) return 0;
   SelectedPosition = position;
   return SelectedPosition.Ticket;
}

ulong CreatePositionTicket(){
   ulong ticket = 1;
   int positionsTotal = TPositionsTotal();
   while(!PositionTicketIsUnique(ticket,positionsTotal)) ticket++;
   return ticket;
}

bool PositionTicketIsUnique(long ticket,int positionsTotal){
   for(int c = 0; c < positionsTotal; c++){
      Position *position = Positions.At(c);
      if(position.Ticket == ticket) return false;
   }
   return true;
}


ulong CreateDealTicket(){
   ulong ticket = 1;
   int dealsTotal = Deals.Total();
   while(!DealTicketIsUnique(ticket,dealsTotal)) ticket++;
   return ticket;
}

bool DealTicketIsUnique(long ticket,int dealsTotal){
   for(int c = 0; c < dealsTotal; c++){
      Deal *deal = Deals.At(c);
      if(deal.Ticket == ticket) return false;
   }
   return true;
}

ulong TSymbolInfoInteger(string symbol,ENUM_SYMBOL_INFO_INTEGER prop){
   switch(prop){
      case SYMBOL_TRADE_CALC_MODE:{
         if(UsePredefSymbolVariables){
            SymbolProperties *props = GetPredefSymbolProperties(symbol);
            return props.SymbolCalcMode;
         }
         else{
            return SymbolInfoInteger(symbol,SYMBOL_TRADE_CALC_MODE);
         }
      }
   }
   return 0;
}

double TSymbolInfoDouble(string symbol,ENUM_SYMBOL_INFO_DOUBLE prop){
   SymbolProperties *props;
   if(UsePredefSymbolVariables) props = GetPredefSymbolProperties(symbol);
   switch(prop){
      case SYMBOL_TRADE_TICK_VALUE:{
         if(UsePredefSymbolVariables)
            return props.SymbolTickValue;
         else
            return SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE);
      }
      case SYMBOL_TRADE_TICK_SIZE:{
         if(UsePredefSymbolVariables)
            return props.SymbolTickSize;
         else
            return SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);
      }
      case SYMBOL_VOLUME_MIN:{
         if(UsePredefSymbolVariables)
            return props.SymbolVolumeMin;
         else
            return SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
      }
      case SYMBOL_ASK:{
         switch(PriceMode){
            case PRICE_MODE_BIDASK:
               return SymbolInfoDouble(symbol,SYMBOL_ASK);
            case PRICE_MODE_ICLOSE:
               return m_TMQL.Round(iClose(symbol,PERIOD_CURRENT,0),true,true,UsePredefSymbolVariables ? props.SymbolTickSize : SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE));
         }
      }
      case SYMBOL_BID:{
         switch(PriceMode){
            case PRICE_MODE_BIDASK:
               return SymbolInfoDouble(symbol,SYMBOL_BID);
            case PRICE_MODE_ICLOSE:
               return m_TMQL.Round(iClose(symbol,PERIOD_CURRENT,0),true,false,UsePredefSymbolVariables ? props.SymbolTickSize : SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE));
         }
      }
   }
   return 0;
}

ulong TAccountInfoInteger(ENUM_ACCOUNT_INFO_INTEGER prop){
   switch(prop){
      case ACCOUNT_MARGIN_MODE:{
         if(UsePredefAccountProperties)
            return PredefAccountProperties.AccountMarginMode;
         else
            return AccountInfoInteger(ACCOUNT_MARGIN_MODE);
      }
   }
   return 0;
}

double CalculateProfit(string symbol,double execVolume,double avgPosPrice,double avgExecPrice,ENUM_POSITION_TYPE posType){
   ENUM_SYMBOL_CALC_MODE calcMode = (ENUM_SYMBOL_CALC_MODE)TSymbolInfoInteger(symbol,SYMBOL_TRADE_CALC_MODE);
   double profit = 0;
   switch(calcMode){
      case SYMBOL_CALC_MODE_EXCH_STOCKS:{
         profit = (avgExecPrice * execVolume - avgPosPrice * execVolume);
         profit -= StocksFee_TMQL;
         break;
      }
      case SYMBOL_CALC_MODE_EXCH_FUTURES:{
         profit = (avgExecPrice - avgPosPrice) * execVolume * TSymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE) / TSymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);
         profit -= ContractFee_TMQL * execVolume;
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

Deal* ManagePositionDealExecution(ulong positionTicket,ENUM_DEAL_TYPE dealType,double dealPrice,double dealVolume,ulong orderTicket){
   int positionIndex;
   if(positionTicket == 0){
      Order *order = Orders.At(GetOrderIndexByTicket(orderTicket));
      positionIndex = GetFirstPositionIndexBySymbol(order.Symbol);
   }
   else{
      positionIndex = GetPositionIndexByTicket(positionTicket);
   }
   Position *position = Positions.At(positionIndex);
   Position *positionClone = ClonePosition(position);
   double dealProfit = 0;
   ENUM_DEAL_ENTRY dealEntry = DEAL_ENTRY_IN;
   //string symbol = position.Symbol;
   //ulong magic = position.Magic;
   
   if((position.Type == POSITION_TYPE_BUY && dealType == DEAL_TYPE_BUY) || (position.Type == POSITION_TYPE_SELL && dealType == DEAL_TYPE_SELL)){
      position.AvgPosPrice = CalculatePosNewAvgPrice(position.AvgPosPrice,position.Volume,dealPrice,dealVolume);
      position.Volume = dealVolume + position.Volume;
      DrawPosition(position);
   }
   else{
      double newVol = position.Volume - dealVolume;
      dealProfit = CalculateProfit(position.Symbol,(newVol <= 0 ? position.Volume : dealVolume),position.AvgPosPrice,dealPrice,position.Type);
      CurrentProfit += dealProfit;
      if(newVol > 0){
         position.Volume = newVol;
         DrawPosition(position);
         dealEntry = DEAL_ENTRY_OUT;
      }
      else if(newVol < 0){
         position.Volume = -newVol;
         if(dealType == DEAL_TYPE_BUY) position.Type = POSITION_TYPE_BUY;
         else position.Type = POSITION_TYPE_SELL;
         position.PriceOpen = dealPrice;
         position.AvgPosPrice = dealPrice;
         position.Time = TimeCurrent();
         DrawPosition(position);
         dealEntry = DEAL_ENTRY_INOUT;
      }
      else{
         Positions.Delete(positionIndex);
         DrawPosition(positionClone,CHART_ACTION_ERASE);
         dealEntry = DEAL_ENTRY_OUT;
      }
   }
   Deal *deal = CreateDeal(positionClone.Symbol,dealType,positionTicket,dealPrice,dealProfit,positionClone.Magic,dealVolume,orderTicket,dealEntry);
   delete(positionClone);
   return deal;
}

Position *CreatePosition(string symbol,ENUM_POSITION_TYPE type,double priceOpen,ulong magic,double sl,double tp,double volume,ulong orderTicket){
   Position *position = new Position;
   position.Type = type;
   position.PriceOpen = priceOpen;
   position.AvgPosPrice = priceOpen;
   position.Symbol = symbol;
   position.Ticket = CreatePositionTicket();
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

Deal *CreateDeal(string symbol,ENUM_DEAL_TYPE type,ulong position,double price,double profit,ulong magic,double volume,ulong order,ENUM_DEAL_ENTRY entry){
   Deal *deal = new Deal;
   deal.Position = position;
   deal.Price = price;
   deal.Magic = magic;
   deal.Symbol = symbol;
   deal.Order = order;
   deal.Volume = volume;
   deal.Profit = profit;
   deal.Time = TimeCurrent();
   deal.Ticket = CreateDealTicket();
   deal.Entry = entry;
   Deals.Add(deal);
   DrawDealArrow(symbol,price,deal.Time,type);
   return deal;
}

Order *CreateOrder(string symbol,ENUM_ORDER_TYPE type,double price,ulong posTicket,ulong magic,double sl,double tp,double volume){
   Order *order = new Order;
   order.Symbol = symbol;
   order.Ticket = CreateOrderTicket();
   order.Magic = magic;
   order.SL = sl;
   order.TP = tp;
   order.Type = type;
   order.Volume = volume;
   order.Price = price;
   order.Time = TimeCurrent();
   order.PositionTicket = posTicket;
   Orders.Add(order);
   DrawOrder(order);
   return order;
}

void PrintError(string message){
   Print("#TMQL# - Error: " + message); 
}

bool CheckBuyRequestType(ENUM_ORDER_TYPE orderType){
   return orderType == ORDER_TYPE_BUY || orderType == ORDER_TYPE_BUY_LIMIT || orderType == ORDER_TYPE_BUY_STOP || orderType == ORDER_TYPE_BUY_STOP_LIMIT;
}

bool CheckSellRequestType(ENUM_ORDER_TYPE orderType){
   return orderType == ORDER_TYPE_SELL || orderType == ORDER_TYPE_SELL_LIMIT || orderType == ORDER_TYPE_SELL_STOP || orderType == ORDER_TYPE_SELL_STOP_LIMIT;
}

bool TOrderSend(MqlTradeRequest &req,MqlTradeResult &res) export{
   
   double bid = TSymbolInfoDouble(req.symbol,SYMBOL_BID);
   double ask = TSymbolInfoDouble(req.symbol,SYMBOL_ASK);
   
   //if(req.position > 0 && GetPositionIndexByTicket(req.position) == -1){
   //   PrintError("Invalid position ticket");
   //   return false;
   //}
   
   if(
      (CheckBuyRequestType(req.type) && ((req.sl != 0 && req.sl >= bid) || (req.tp != 0 && req.tp <= ask))) || 
      (CheckSellRequestType(req.type) && ((req.sl != 0 && req.sl <= ask) || (req.tp != 0 && req.tp >= bid)))
     )
   {
      PrintError("Invalid SL/TP");
      return false;
   }

   switch(req.action){
      case TRADE_ACTION_DEAL:{
         if(TAccountInfoInteger(ACCOUNT_MARGIN_MODE) == ACCOUNT_MARGIN_MODE_RETAIL_NETTING && req.position > 0){
            Position *position = Positions.At(GetFirstPositionIndexBySymbol(req.symbol));
            if(
               position == NULL ||
               (
                ((position.Type == POSITION_TYPE_BUY && CheckSellRequestType(req.type)) || (position.Type == POSITION_TYPE_SELL && CheckBuyRequestType(req.type)))
                && position.Volume < req.volume
               )
              )
            {
               PrintError("Order volume greater than position volume");
               return false;
            }
         }
         Deal *deal;
         ulong orderTicket = CreateOrderTicket();
         switch(req.type){
            case ORDER_TYPE_BUY:{
               double currentPrice = TSymbolInfoDouble(req.symbol,SYMBOL_ASK);
               ulong positionTicket = req.position > 0 ?  req.position : GetFirstPositionTicketBySymbol(req.symbol);
               if(TAccountInfoInteger(ACCOUNT_MARGIN_MODE) == ACCOUNT_MARGIN_MODE_RETAIL_NETTING && positionTicket > 0){
                  deal = ManagePositionDealExecution(positionTicket,DEAL_TYPE_BUY,currentPrice,req.volume,orderTicket);
                  SetPositionSLTP(positionTicket,req.sl,req.tp,DEAL_TYPE_BUY);
               }
               else{
                  Position *position = CreatePosition(req.symbol,POSITION_TYPE_BUY,currentPrice,req.magic,req.sl,req.tp,req.volume,orderTicket);
                  deal = CreateDeal(req.symbol,DEAL_TYPE_BUY,position.Ticket,currentPrice,0,req.magic,req.volume,orderTicket,DEAL_ENTRY_IN);
               }
               break;
            }
            case ORDER_TYPE_SELL:{
               double currentPrice = TSymbolInfoDouble(req.symbol,SYMBOL_BID);
               ulong positionTicket = req.position > 0 ?  req.position : GetFirstPositionTicketBySymbol(req.symbol);
               if(TAccountInfoInteger(ACCOUNT_MARGIN_MODE) == ACCOUNT_MARGIN_MODE_RETAIL_NETTING && positionTicket > 0){
                  deal = ManagePositionDealExecution(positionTicket,DEAL_TYPE_SELL,currentPrice,req.volume,orderTicket);
                  SetPositionSLTP(positionTicket,req.sl,req.tp,DEAL_TYPE_SELL);
               }
               else{
                  Position *position = CreatePosition(req.symbol,POSITION_TYPE_SELL,currentPrice,req.magic,req.sl,req.tp,req.volume,orderTicket);
                  deal = CreateDeal(req.symbol,DEAL_TYPE_SELL,position.Ticket,currentPrice,0,req.magic,req.volume,orderTicket,DEAL_ENTRY_IN);
               }
               break;
            }
            default:{
               PrintError("Invalid order type");
               return false; //-- ERROR INVALID ORDER TYPE
            }
         }
         SetResponseAttributes(res,deal.Ticket,orderTicket,deal.Volume,deal.Price);
         break;
      }
      case TRADE_ACTION_PENDING:{
         switch(req.type){
            case ORDER_TYPE_BUY_LIMIT:{
               //if(req.price <= SymbolInfoDouble(req.symbol,SYMBOL_ASK){
               break;
            }
            case ORDER_TYPE_SELL_LIMIT:{
               //if(req.price >= SymbolInfoDouble(req.symbol,SYMBOL_BID){
               break;
            }
            default:{
               return false; //-- ERROR INVALID ORDER TYPE
            }
         }
         Order *order = CreateOrder(req.symbol,req.type,req.price,req.position,req.magic,req.sl,req.tp,req.volume);
         SetResponseAttributes(res,0,order.Ticket);
         TimeToStruct(TimeCurrent(),CurrentTimeStruct);
         CurrentDay = CurrentTimeStruct.day;
         break;
      }
      case TRADE_ACTION_REMOVE:{
         int orderIndex = GetOrderIndexByTicket(req.order);
         Order *order = Orders.At(orderIndex);
         DrawOrder(order,CHART_ACTION_ERASE);
         Orders.Delete(orderIndex);
         break;
      }
      case TRADE_ACTION_SLTP:{
         Position *position = Positions.At(GetPositionIndexByTicket(req.position));
         if(position == NULL){
            PrintError("Invalid position ticket");
            return false;
         }
         if(
            (position.Type == POSITION_TYPE_BUY && ((req.sl != 0 && req.sl >= bid) || (req.tp != 0 && req.tp <= ask))) || 
            (position.Type == POSITION_TYPE_SELL && ((req.sl != 0 && req.sl <= ask) || (req.tp != 0 && req.tp >= bid)))
         )
         {
            PrintError("Invalid SL/TP");
            return false;
         }
         SetPositionSLTP(req.position,req.sl,req.tp);
         break;
      }
      default:{
         PrintError("Invalid order action");
         return false; //-- ERROR INVALID ORDER ACTION
      }
   }
   
   DrawTesterPanel(req.symbol,CHART_ACTION_DRAW);
   return true;
}

void SetResponseAttributes(MqlTradeResult &res,ulong deal = 0,ulong order = 0,double volume = 0,double price = 0){
   res.deal = deal;
   res.order = order;
   res.volume = volume;
   res.price = price;
}

void SetPositionSLTP(ulong positionTicket,double sl,double tp,ENUM_DEAL_TYPE dealType = -1){
   int positionIndex = GetPositionIndexByTicket(positionTicket);
   Position *position = Positions.At(positionIndex);
   if(position == NULL) return;
   if((position.Type == POSITION_TYPE_BUY && dealType == DEAL_TYPE_BUY) || (position.Type == POSITION_TYPE_SELL && dealType == DEAL_TYPE_SELL) || dealType == -1){
      position.SL = sl;
      position.TP = tp;
      DrawPosition(position,CHART_ACTION_DRAW);
   }
}

//-- TO BE SET IN ONTIMER METHOD
void HandleOrderTime(){
   if(Orders.Total() > 0){
      TimeToStruct(TimeCurrent(),CurrentTimeStruct);
      if(CurrentTimeStruct.day > CurrentDay){
         CurrentDay = CurrentTimeStruct.day;
         RemoveFuturePendingOrders();
      }
   }
}

void RemoveFuturePendingOrders(){
   for(int c = Orders.Total() - 1; c >= 0; c--){
      Order *order = Orders.At(c);
      if(TSymbolInfoInteger(order.Symbol,SYMBOL_TRADE_CALC_MODE) == SYMBOL_CALC_MODE_EXCH_FUTURES){
         Order *orderClone = CloneOrder(order);
         Orders.Delete(c);
         DrawOrder(orderClone,CHART_ACTION_ERASE);
         DrawTesterPanel(orderClone.Symbol,CHART_ACTION_DRAW);
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

//-- MANAGING ORDERS,SL,TP
void TManageTrade() export{
   for(int c = Orders.Total() - 1; c >= 0; c--){
      Order *order = Orders.At(c);
      Order *tempOrder = CloneOrder(order);
      switch(order.Type){
         case ORDER_TYPE_BUY_LIMIT:{
            double currentPrice = TSymbolInfoDouble(order.Symbol,SYMBOL_ASK);
            if(currentPrice <= order.Price){
               ulong positionTicket = GetFirstPositionTicketBySymbol(order.Symbol);
               if(TAccountInfoInteger(ACCOUNT_MARGIN_MODE) == ACCOUNT_MARGIN_MODE_RETAIL_NETTING && positionTicket != 0){
                  ManagePositionDealExecution(positionTicket,DEAL_TYPE_BUY,currentPrice,order.Volume,order.Ticket);
                  SetPositionSLTP(positionTicket,order.SL,order.TP,DEAL_TYPE_BUY);
               }
               else{
                  Position *position = CreatePosition(order.Symbol,POSITION_TYPE_BUY,currentPrice,order.Magic,order.SL,order.TP,order.Volume,order.Ticket);
                  CreateDeal(order.Symbol,DEAL_TYPE_BUY,position.Ticket,currentPrice,0,order.Magic,order.Volume,order.Ticket,DEAL_ENTRY_IN);
               }
               Orders.Delete(c);
               DrawOrder(tempOrder,CHART_ACTION_ERASE);
               DrawTesterPanel(tempOrder.Symbol,CHART_ACTION_DRAW);
            }
            break;
         }
         case ORDER_TYPE_SELL_LIMIT:{
            double currentPrice = TSymbolInfoDouble(order.Symbol,SYMBOL_BID);
            if(currentPrice >= order.Price){
               ulong positionTicket = GetFirstPositionTicketBySymbol(order.Symbol);
               if(TAccountInfoInteger(ACCOUNT_MARGIN_MODE) == ACCOUNT_MARGIN_MODE_RETAIL_NETTING && positionTicket != 0){
                  ManagePositionDealExecution(positionTicket,DEAL_TYPE_SELL,currentPrice,order.Volume,order.Ticket);
                  SetPositionSLTP(positionTicket,order.SL,order.TP,DEAL_TYPE_SELL);
               }
               else{
                  Position *position = CreatePosition(order.Symbol,POSITION_TYPE_SELL,currentPrice,order.Magic,order.SL,order.TP,order.Volume,order.Ticket);
                  CreateDeal(order.Symbol,DEAL_TYPE_SELL,position.Ticket,currentPrice,0,order.Magic,order.Volume,order.Ticket,DEAL_ENTRY_IN);
               }
               Orders.Delete(c);
               DrawOrder(tempOrder,CHART_ACTION_ERASE);
               DrawTesterPanel(tempOrder.Symbol,CHART_ACTION_DRAW);
            }
            break;
         }
         default:{
            //-- ORDER EXEC ERROR INVALID ORDER TYPE
         }
      }
      delete(tempOrder);
   }
   for(int c = Positions.Total() - 1; c >= 0; c--){
      Position *position = Positions.At(c);
      string potitionSymbol = position.Symbol;
      if(position.Type == POSITION_TYPE_BUY){
         double currentPrice = TSymbolInfoDouble(position.Symbol,SYMBOL_BID);
         bool TPWasTriggered = position.TP > 0 && currentPrice >= position.TP;
         bool SLWasTriggered = position.SL > 0 && currentPrice <= position.SL;
         if(TPWasTriggered || SLWasTriggered){
            ManagePositionDealExecution(position.Ticket,DEAL_TYPE_SELL,currentPrice,position.Volume,CreateOrderTicket());
            if(TPWasTriggered){}
               //-- TP TRIGGER MESSAGE
            else if(SLWasTriggered){}
               //-- SL TRIGGER MESSAGE
            DrawTesterPanel(potitionSymbol,CHART_ACTION_DRAW);
         }
      }
      else{
         double currentPrice = TSymbolInfoDouble(position.Symbol,SYMBOL_ASK);
         bool TPWasTriggered = position.TP > 0 && currentPrice <= position.TP;
         bool SLWasTriggered = position.SL > 0 && currentPrice >= position.SL;
         if(TPWasTriggered || SLWasTriggered){
            ManagePositionDealExecution(position.Ticket,DEAL_TYPE_BUY,currentPrice,position.Volume,CreateOrderTicket());
            if(TPWasTriggered){}
               //-- TP TRIGGER MESSAGE
            else if(SLWasTriggered){}
               //-- SL TRIGGER MESSAGE
            DrawTesterPanel(potitionSymbol,CHART_ACTION_DRAW);
         }
      }
   }
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

int GetSymbolSellOrdersTotal(string symbol){
   int total = 0;
   Order *order;
   for(int c = 0; c < Orders.Total(); c++){
      order = Orders.At(c);
      if(order.Symbol == symbol && order.Type == ORDER_TYPE_SELL_LIMIT) total++;
   }
   return total;
}

//############################################### TESTER CHART OBJECTS ###############################################

//void DrawPosition(ulong posTicket,string symbol,double avgPosPrice,double sl,double tp){
void DrawDealArrow(string symbol,double price,datetime time,ENUM_DEAL_TYPE dealType){
   long currentChartID = ChartFirst();
   //long nextChartID = ChartNext(currentChartID);
   while(currentChartID >= 0){ //!= nextChartID
      if(ChartSymbol(currentChartID) == symbol){
         if(dealType == DEAL_TYPE_BUY)
            co_TMQL.DrawBuyArrow(currentChartID,price,time);
         else
            co_TMQL.DrawSellArrow(currentChartID,price,time);
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
               ObjectSetDouble(currentChartID,positionAvgPriceObjName,OBJPROP_PRICE,position.AvgPosPrice);
            else
               co_TMQL.DrawHLine(currentChartID,positionAvgPriceObjName,position.AvgPosPrice,clrGreen,STYLE_DASHDOTDOT);
            
            //-- DRAW POSITION SL
            if(position.SL != 0){
               if(ObjectFind(currentChartID,positionSLObjName) >= 0)
                  ObjectSetDouble(currentChartID,positionSLObjName,OBJPROP_PRICE,position.SL);
               else
                  co_TMQL.DrawHLine(currentChartID,positionSLObjName,position.SL,clrGreen,STYLE_DOT);
            }
            else{
               ObjectDelete(currentChartID,positionSLObjName);
            }
            
            //-- DRAW POSITION TP   
            if(position.TP != 0){
               if(ObjectFind(currentChartID,positionTPObjName) >= 0)
                  ObjectSetDouble(currentChartID,positionTPObjName,OBJPROP_PRICE,position.TP);
               else
                  co_TMQL.DrawHLine(currentChartID,positionTPObjName,position.TP,clrGreen,STYLE_DOT);
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

void DrawOrder(Order *order,EnumTChartAction chartAction = CHART_ACTION_DRAW){
   long currentChartID = ChartFirst();
   while(currentChartID >= 0){
      if(ChartSymbol(currentChartID) == order.Symbol){
         string orderPriceObjName = "Order" + (string)order.Ticket;
         string orderSLObjName = "Order" + (string)order.Ticket + "SL";
         string orderTPObjName = "Order" + (string)order.Ticket + "TP";
         if(chartAction == CHART_ACTION_DRAW){
            //-- DRAW ORDER
            if(ObjectFind(currentChartID,orderPriceObjName) >= 0)
               ObjectSetDouble(currentChartID,orderPriceObjName,OBJPROP_PRICE,order.Price);
            else
               co_TMQL.DrawHLine(currentChartID,orderPriceObjName,order.Price,clrRed,STYLE_DASHDOT);
            
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

void DrawTesterPanel(string symbol,EnumTChartAction chartAction){
   long currentChartID = ChartFirst();
   while(currentChartID >= 0){
      if(ChartSymbol(currentChartID) == symbol){
         switch(chartAction){
            case CHART_ACTION_DRAW:{
               if(
                  ObjectFind(currentChartID,"Profit_TMQL") >= 0 && ObjectFind(currentChartID,"PositionProfit_TMQL") >= 0 && 
                  ObjectFind(currentChartID,"BuyPositions_TMQL") >= 0 && ObjectFind(currentChartID,"SellPositions_TMQL") >= 0 &&
                  ObjectFind(currentChartID,"BuyOrders_TMQL") >= 0 && ObjectFind(currentChartID,"SellOrders_TMQL") >= 0
               ){
                  ObjectSetString(currentChartID,"Profit_TMQL",OBJPROP_TEXT,"Profit: "+ (string)CurrentProfit);
                  ObjectSetString(currentChartID,"BuyPositions_TMQL",OBJPROP_TEXT,"Buy positions: "+ (string)GetSymbolBuyPositionsTotal(ChartSymbol(currentChartID)) + " (Total Vol.: "+ (string)GetSymbolBuyPositionVolumeTotal(ChartSymbol(currentChartID))+ ")");
                  ObjectSetString(currentChartID,"SellPositions_TMQL",OBJPROP_TEXT,"Sell positions: "+ (string)GetSymbolSellPositionsTotal(ChartSymbol(currentChartID)) + " (Total Vol.: "+ (string)GetSymbolSellPositionVolumeTotal(ChartSymbol(currentChartID))+ ")");
                  ObjectSetString(currentChartID,"BuyOrders_TMQL",OBJPROP_TEXT,"Buy orders: "+ (string)GetSymbolBuyOrdersTotal(ChartSymbol(currentChartID)));
                  ObjectSetString(currentChartID,"SellOrders_TMQL",OBJPROP_TEXT,"Sell orders: "+ (string)GetSymbolSellOrdersTotal(ChartSymbol(currentChartID)));
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

void CalculateOverallPosAvgPrice(){
   double totalBuyPosVol = 0,totalSellPosVol = 0;
   double totalBuyPosPriceTimesVol = 0,totalSellPosPriceTimesVol = 0;
   for(int c = 0; c < TPositionsTotal(); c++){
      Position *position = Positions.At(c);
      if(position.Type == POSITION_TYPE_BUY){
         totalBuyPosVol += position.Volume;
         totalBuyPosPriceTimesVol += position.Volume * position.AvgPosPrice;
      }
      else{
         totalSellPosVol += position.Volume;
         totalSellPosPriceTimesVol += position.Volume * position.AvgPosPrice;
      }
   }
   //OverallBuyPosition.AvgPosPrice = totalBuyPosPriceTimesVol / totalBuyPosVol;
   //OverallBuyPosition.Volume = totalBuyPosVol;
   //OverallSellPosition.AvgPosPrice = totalSellPosPriceTimesVol / totalSellPosVol;
   //OverallSellPosition.Volume = totalSellPosVol;
}

//double CalculateLivePositionProfit();

Position *ClonePosition(Position *position){
   Position *newPos = new Position;
   newPos.Ticket = position.Ticket;
   newPos.Magic = position.Magic;
   newPos.Symbol = position.Symbol;
   newPos.Type = position.Type;
   newPos.Volume = position.Volume;
   newPos.Time = position.Time;
   newPos.PriceOpen = position.PriceOpen;
   newPos.SL = position.SL;
   newPos.TP = position.TP;
   newPos.AvgPosPrice = position.AvgPosPrice;
   return newPos;
}
Order *CloneOrder(Order *order){
   Order *newOrder = new Order;
   newOrder.Ticket = order.Ticket;
   newOrder.Magic = order.Magic;
   newOrder.Symbol = order.Symbol;
   newOrder.Type = order.Type;
   newOrder.Volume = order.Volume;
   newOrder.Time = order.Time;
   newOrder.Price = order.Price;
   newOrder.SL = order.SL;
   newOrder.TP = order.TP;
   newOrder.PositionTicket = order.PositionTicket;
   return newOrder;
}
Deal *CloneDeal(Deal *deal){
   Deal *newDeal = new Deal;
   newDeal.Ticket = deal.Ticket;
   newDeal.Order = deal.Order;
   newDeal.Magic = deal.Magic;
   newDeal.Symbol = deal.Symbol;
   newDeal.Volume = deal.Volume;
   newDeal.Time = deal.Time;
   newDeal.Price = deal.Price;
   newDeal.Profit = deal.Profit;
   newDeal.Position = deal.Position;
   newDeal.Entry = deal.Entry;
   newDeal.Type = deal.Type;
   return newDeal;
}