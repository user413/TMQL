#property copyright "Nain"

#include "Background.mqh"

//-- IMPLEMENTED(PARTIALLY) METHODS --
// TiClose
// TiOpen
// TOrderGetDouble
// TOrderGetInteger
// TOrderGetString
// TOrderGetDouble
// TOrderGetTicket
// TOrdersTotal
// TPositionGetDouble
// TPositionGetInteger
// TPositionGetString
// TPositionGetTicket
// TPositionsTotal
// TOrderSend
// TSymbolInfoDouble
// TSymbolInfoInteger
// TAccountInfoInteger
// TOrderSelect
// TPositionSelect
// TPositionSelectByTicket
// THistorySelect
// THistoryDealSelect
// THistoryDealGetDouble
// THistoryDealGetInteger
// THistoryDealGetString
// THistoryDealGetTicket
// THistoryDealsTotal
// THistoryOrderSelect
// THistoryOrderGetDouble
// THistoryOrderGetInteger
// THistoryOrderGetString
// THistoryOrderGetTicket
// THistoryOrdersTotal
// TObjectsDeleteAll
// TGetLastError

//-- ADITIONAL NON MQL METHODS
// TShowInfoPanel

//###############################################  MQL METHODS ###############################################

double TiClose(string symbol, ENUM_TIMEFRAMES timeframe, int shift){
   if(TMQL::UsePredefSymbolVariables)
      return TMQL::m_TMQL.Round(iClose(symbol, timeframe, shift), false, true, 
         ((TMQL::SymbolProperties*)TMQL::GetPredefSymbolProperties(symbol)).SymbolTickSize);
   else
      return iClose(symbol, timeframe, shift);
}

double TiOpen(string symbol, ENUM_TIMEFRAMES timeframe, int shift){
   if(TMQL::UsePredefSymbolVariables)
      return TMQL::m_TMQL.Round(iOpen(symbol, timeframe, shift), false, true, 
         ((TMQL::SymbolProperties*)TMQL::GetPredefSymbolProperties(symbol)).SymbolTickSize);
   else
      return iOpen(symbol, timeframe, shift);
}

//-- OBJECT METHODS

//deletes all but TMQL reserved objects
int TObjectsDeleteAll(long chart_id,int sub_window=-1,int type=-1){
   int delObjsCount = 0;
   for (int i = ObjectsTotal(chart_id,sub_window,type) - 1; i >= 0; i--)
   {
      string objName = ObjectName(chart_id,i,sub_window,type);
      if(!StringFind(objName,"_TMQL") && ObjectDelete(chart_id,objName))
         delObjsCount++;
   }
   return delObjsCount;
}

int TObjectsDeleteAll(
    long chart_id,       // chart ID
    const string prefix, // prefix in object name
    int sub_window = -1, // window index
    int object_type = -1 // object type
){
   int delObjsCount = 0;
   for (int i = ObjectsTotal(chart_id,sub_window,object_type) - 1; i >= 0; i--)
   {
      string objName = ObjectName(chart_id,i,sub_window,object_type);

      if(!StringFind(objName,"_TMQL") && StringSubstr(objName,0,StringLen(prefix)) == prefix &&
         ObjectDelete(chart_id,objName))
         delObjsCount++;
   }
   return delObjsCount;
}

//-- HISTORY METHODS

bool THistorySelect(datetime fromDate, datetime toDate){
   TMQL::ClearHistoryDealList();
   TMQL::ClearHistoryOrderList();
   if(fromDate > toDate) return false;
   
   //-- SELECTING DEALS
   for(int c = 0; c < TMQL::Deals.Total(); c++){
      TMQL::Deal *deal = TMQL::Deals.At(c);
      if(deal.Time >= fromDate && deal.Time <= toDate)
         TMQL::SelectedHistoryDeals.Add(deal);
   }
   for(int c = 0; c < TMQL::HistoryOrders.Total(); c++){
     TMQL::Order* order = TMQL::HistoryOrders.At(c);
     if(order.TimeSetup >= fromDate && order.TimeSetup <= toDate)
        TMQL::SelectedHistoryOrders.Add(order);
   }
   
   // if(TMQL::SelectedHistoryDeals.Total() <= 0 && TMQL::SelectedHistoryOrders.Total() <= 0) return false;
   TMQL::SelectedHistoryOrders.Sort(TMQL::Order::PROP_TIMESETUP, Nain::SORT_MODE_ASC);

   return true;
}

//-- DEAL HISTORY

bool THistoryDealSelect(long ticket){
   TMQL::ClearHistoryDealList();
   
   for (int i = 0; i < TMQL::Deals.Total(); i++)
   {
      TMQL::Deal* d = TMQL::Deals.At(i);

      if(d.Ticket == ticket){
        TMQL::SelectedHistoryDeals.Add(d);
        return true;
      }
   }

   return false;
}

ulong THistoryDealGetTicket(int dealIndex){
   TMQL::Deal *historyDeal = TMQL::SelectedHistoryDeals.At(dealIndex);
   if(historyDeal == NULL) return 0;
   return historyDeal.Ticket;
}

int THistoryDealsTotal(){
   return TMQL::SelectedHistoryDeals.Total();
}

string THistoryDealGetString(ulong ticket,ENUM_DEAL_PROPERTY_STRING prop){
   TMQL::Deal *deal = TMQL::GetHistoryDealByTicket(ticket);
   switch(prop){
      case DEAL_SYMBOL: return deal.Symbol;
      // case DEAL_COMMENT: return deal.Comment;
      // case DEAL_EXTERNAL_ID: return deal.ExternalId;
   }
   return "";
}

ulong THistoryDealGetInteger(ulong ticket,ENUM_DEAL_PROPERTY_INTEGER prop){
   TMQL::Deal *deal = TMQL::GetHistoryDealByTicket(ticket);
   switch(prop){
      case DEAL_TICKET: return deal.Ticket;
      case DEAL_ORDER: return deal.Order;
      case DEAL_TIME: return deal.Time;
      // case DEAL_TIME_MSC: return deal.TimeMSC;
      // case DEAL_POSITION_ID: return deal.PositionId;
      case DEAL_MAGIC: return deal.Magic;
      // case DEAL_REASON: return deal.Reason;
      case DEAL_ENTRY: return deal.Entry;
      case DEAL_TYPE: return deal.Type;
   }
   return 0;
}

double THistoryDealGetDouble(ulong ticket,ENUM_DEAL_PROPERTY_DOUBLE prop){
   TMQL::Deal *deal = TMQL::GetHistoryDealByTicket(ticket);
   switch(prop){
      case DEAL_VOLUME: return deal.Volume;
      case DEAL_PRICE: return deal.Price;
      case DEAL_PROFIT: return deal.Profit;
      // case DEAL_COMMENT: return deal.Commission;
      // case DEAL_SWAP: return deal.Swap;
      // case DEAL_FEE: return deal.Fee;
      // case DEAL_SL: return deal.SL;
      // case DEAL_TP: return deal.TP;
   }
   return 0;
}

//-- ORDER HISTORY

ulong THistoryOrderGetTicket(int orderIndex){
   TMQL::Order* historyOrder = TMQL::SelectedHistoryOrders.At(orderIndex);
   if(historyOrder == NULL) return 0;
   return historyOrder.Ticket;
}

bool THistoryOrderSelect(ulong orderTicket){
   TMQL::ClearHistoryOrderList();

   for (int i = 0; i < TMQL::HistoryOrders.Total(); i++)
   {
      TMQL::Order* o = TMQL::HistoryOrders.At(i);

      if(o.Ticket == orderTicket){
        TMQL::SelectedHistoryOrders.Add(o);
        return true;
      }
   }

   return false;
}

int THistoryOrdersTotal(){
   return TMQL::SelectedHistoryOrders.Total();
}

string THistoryOrderGetString(ulong ticket,ENUM_ORDER_PROPERTY_STRING prop){
   TMQL::Order *order = TMQL::GetHistoryOrderByTicket(ticket);
   switch(prop){
      case ORDER_SYMBOL: return order.Symbol;
      // case ORDER_COMMENT: return order.Comment;
      // case ORDER_EXTERNAL_ID: return order.ExternalId;
   }
   return "";
}

ulong THistoryOrderGetInteger(ulong ticket,ENUM_ORDER_PROPERTY_INTEGER prop){
   TMQL::Order* order = TMQL::GetHistoryOrderByTicket(ticket);
   switch(prop){
      case ORDER_TICKET: return order.Ticket;
      case ORDER_MAGIC: return order.Magic;
      // case ORDER_POSITION_ID: return order.PositionId;
      case ORDER_TIME_SETUP: return order.TimeSetup;
      // case ORDER_TIME_EXPIRATION: return order.TimeExpiration;
      // case ORDER_TIME_DONE: return order.TimeDone;
      // case ORDER_TIME_DONE_MSC: return order.TimeDoneMSC;
      // case ORDER_TIME_SETUP_MSC: return order.TimeSetupMSC;
      case ORDER_TYPE: return order.Type;
      // case ORDER_STATE: return order.State;
      // case ORDER_TYPE_FILLING: return order.TypeFilling;
      // case ORDER_TYPE_TIME: return order.TypeTime;
      // case ORDER_REASON: return order.Reason;
   }
   return 0;
}

double THistoryOrderGetDouble(ulong ticket,ENUM_ORDER_PROPERTY_DOUBLE prop){
   TMQL::Order* order = TMQL::GetHistoryOrderByTicket(ticket);
   switch(prop){
      case ORDER_VOLUME_CURRENT: return order.VolumeCurrent;
      case ORDER_VOLUME_INITIAL: return order.VolumeInitial;
      case ORDER_PRICE_OPEN: return order.PriceOpen;
      // case ORDER_PRICE_STOPLIMIT: return order.PriceStopLimit;
      case ORDER_SL: return order.SL;
      case ORDER_TP: return order.TP;
      // case ORDER_PRICE_CURRENT: return order.PriceCurrent;
   }
   return 0;
}

//-- ORDER METHODS

int TOrdersTotal(){
   return TMQL::Orders.Total();
}

string TOrderGetString(ENUM_ORDER_PROPERTY_STRING prop){
   switch(prop){
      case ORDER_SYMBOL: return TMQL::SelectedOrder.Symbol;
      // case ORDER_COMMENT: return TMQL::SelectedOrder.Comment;
      // case ORDER_EXTERNAL_ID: return TMQL::SelectedOrder.ExternalId;
   }
   return "";
}
ulong TOrderGetInteger(ENUM_ORDER_PROPERTY_INTEGER prop){
   switch(prop){
      case ORDER_TICKET: return TMQL::SelectedOrder.Ticket;
      case ORDER_MAGIC: return TMQL::SelectedOrder.Magic;
      // case ORDER_POSITION_ID: return TMQL::SelectedOrder.PositionId;
      case ORDER_TIME_SETUP: return TMQL::SelectedOrder.TimeSetup;
      // case ORDER_TIME_EXPIRATION: return TMQL::SelectedOrder.TimeExpiration;
      // case ORDER_TIME_DONE: return TMQL::SelectedOrder.TimeDone;
      // case ORDER_TIME_DONE_MSC: return TMQL::SelectedOrder.TimeDoneMSC;
      // case ORDER_TIME_SETUP_MSC: return TMQL::SelectedOrder.TimeSetupMSC;
      case ORDER_TYPE: return TMQL::SelectedOrder.Type;
      // case ORDER_STATE: return TMQL::SelectedOrder.State;
      // case ORDER_TYPE_FILLING: return TMQL::SelectedOrder.TypeFilling;
      // case ORDER_TYPE_TIME: return TMQL::SelectedOrder.TypeTime;
      // case ORDER_REASON: return TMQL::SelectedOrder.Reason;
   }
   return 0;
}
double TOrderGetDouble(ENUM_ORDER_PROPERTY_DOUBLE prop){
   switch(prop){
      case ORDER_VOLUME_CURRENT: return TMQL::SelectedOrder.VolumeCurrent;
      case ORDER_VOLUME_INITIAL: return TMQL::SelectedOrder.VolumeInitial;
      case ORDER_PRICE_OPEN: return TMQL::SelectedOrder.PriceOpen;
      // case ORDER_PRICE_STOPLIMIT: return TMQL::SelectedOrder.PriceStopLimit;
      case ORDER_SL: return TMQL::SelectedOrder.SL;
      case ORDER_TP: return TMQL::SelectedOrder.TP;
      // case ORDER_PRICE_CURRENT: return TMQL::SelectedOrder.PriceCurrent;
   }
   return 0;
}

bool TOrderSelect(ulong ticket){
   int i = TMQL::GetOrderIndexByTicket(ticket);
   if(i<0) return false;
   TMQL::SelectedOrder = TMQL::Orders.At(i);
   return true;
}

ulong TOrderGetTicket(uint orderIndex){
   TMQL::Order *order = TMQL::Orders.At(orderIndex);
   if(order == NULL) return 0;
   TMQL::SelectedOrder = order;
   return TMQL::SelectedOrder.Ticket;
}

//-- POSITION METHODS

bool TPositionSelect(string symbol){
   for (int i = 0; i < TMQL::Positions.Total(); i++)
   {
      TMQL::Position *position = TMQL::Positions.At(i);
      if(position.Symbol == symbol){
         TMQL::SelectedPosition = position;
         return true;
      }
   }
   return false;
}

bool TPositionSelectByTicket(ulong ticket){
   for (int i = 0; i < TMQL::Positions.Total(); i++)
   {
      TMQL::Position *position = TMQL::Positions.At(i);
      if(position.Ticket == ticket){
         TMQL::SelectedPosition = position;
         return true;
      }
   }
   return false;
}

int TPositionsTotal(){
   return TMQL::Positions.Total();
}

string TPositionGetString(ENUM_POSITION_PROPERTY_STRING prop){
   switch(prop){
      case POSITION_SYMBOL: return TMQL::SelectedPosition.Symbol;
      // case POSITION_COMMENT: return TMQL::SelectedPosition.Comment;
      // case POSITION_EXTERNAL_ID: return TMQL::SelectedPosition.ExternalID;
   }
   return "";
}
ulong TPositionGetInteger(ENUM_POSITION_PROPERTY_INTEGER prop){
   switch(prop){
      case POSITION_TICKET: return TMQL::SelectedPosition.Ticket;
      // case POSITION_IDENTIFIER: return TMQL::SelectedPosition.Id;
      // case POSITION_MAGIC: return TMQL::SelectedPosition.Magic;
      case POSITION_TIME: return TMQL::SelectedPosition.Time;
      // case POSITION_TIME_UPDATE: return TMQL::SelectedPosition.TimeUpdate;
      // case POSITION_TIME_MSC: return TMQL::SelectedPosition.TimeMSC;
      // case POSITION_TIME_UPDATE_MSC: return TMQL::SelectedPosition.TimeUpdateMSC;
      case POSITION_TYPE: return TMQL::SelectedPosition.Type;
      // case POSITION_REASON: return TMQL::SelectedPosition.Reason;
   }
   return 0;
}
double TPositionGetDouble(ENUM_POSITION_PROPERTY_DOUBLE prop){
   switch(prop){
      case POSITION_VOLUME: return TMQL::SelectedPosition.Volume;
      case POSITION_PRICE_OPEN: return TMQL::SelectedPosition.PriceOpen;
      case POSITION_SL: return TMQL::SelectedPosition.SL;
      case POSITION_TP: return TMQL::SelectedPosition.TP;
      // case POSITION_PRICE_CURRENT: return TMQL::SelectedPosition.PriceCurrent;
      // case POSITION_SWAP: return TMQL::SelectedPosition.Swap;
      // case POSITION_PROFIT: return TMQL::SelectedPosition.Profit;
   }
   return 0;
}

ulong TPositionGetTicket(uint positionIndex){
   TMQL::Position *position = TMQL::Positions.At(positionIndex);
   if(position == NULL) return 0;
   TMQL::SelectedPosition = position;
   return TMQL::SelectedPosition.Ticket;
}

ulong TSymbolInfoInteger(string symbol,ENUM_SYMBOL_INFO_INTEGER prop){
   switch(prop){
      case SYMBOL_TRADE_CALC_MODE:{
         if(TMQL::UsePredefSymbolVariables){
            TMQL::SymbolProperties* props = TMQL::GetPredefSymbolProperties(symbol);
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
   TMQL::SymbolProperties *props;
   if(TMQL::UsePredefSymbolVariables) props = TMQL::GetPredefSymbolProperties(symbol);
   switch(prop){
      case SYMBOL_TRADE_TICK_VALUE:{
         if(TMQL::UsePredefSymbolVariables)
            return props.SymbolTickValue;
         else
            return SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE);
      }
      case SYMBOL_TRADE_TICK_SIZE:{
         if(TMQL::UsePredefSymbolVariables)
            return props.SymbolTickSize;
         else
            return SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);
      }
      case SYMBOL_VOLUME_MIN:{
         if(TMQL::UsePredefSymbolVariables)
            return props.SymbolVolumeMin;
         else
            return SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
      }
      case SYMBOL_ASK:{
         switch(TMQL::PriceMode){
            case TMQL::PRICE_MODE_BIDASK:
               return SymbolInfoDouble(symbol,SYMBOL_ASK);
            case TMQL::PRICE_MODE_ICLOSE:
               // return TMQL::m_TMQL.Round(iClose(symbol,PERIOD_CURRENT,0),true,false,
               //    TMQL::UsePredefSymbolVariables ? props.SymbolTickSize : SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE));
               return TMQL::UsePredefSymbolVariables ? 
                  TMQL::m_TMQL.Round(iClose(symbol, PERIOD_CURRENT, 0), true, false, props.SymbolTickSize) : 
                  iClose(symbol, PERIOD_CURRENT, 0);
         }
      }
      case SYMBOL_BID:{
         switch(TMQL::PriceMode){
            case TMQL::PRICE_MODE_BIDASK:
               return SymbolInfoDouble(symbol,SYMBOL_BID);
            case TMQL::PRICE_MODE_ICLOSE:
               // return TMQL::m_TMQL.Round(iClose(symbol,PERIOD_CURRENT,0),false,false,
               //    TMQL::UsePredefSymbolVariables ? props.SymbolTickSize : SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE));
               return TMQL::UsePredefSymbolVariables ? 
                  TMQL::m_TMQL.Round(iClose(symbol, PERIOD_CURRENT, 0), false, false, props.SymbolTickSize) : 
                  iClose(symbol, PERIOD_CURRENT, 0);
         }
      }
   }
   return 0;
}

ulong TAccountInfoInteger(ENUM_ACCOUNT_INFO_INTEGER prop){
   switch(prop){
      case ACCOUNT_MARGIN_MODE:{
         if(TMQL::UsePredefAccountProperties)
            return TMQL::PredefAccountProperties.AccountMarginMode;
         else
            return AccountInfoInteger(ACCOUNT_MARGIN_MODE);
      }
   }
   return 0;
}

// In hedging:
// - Limit orders always start a new position | closing/decreasing a position is always done with market orders or position close by
// - In limit orders setting existing position has no effect | setting non existing position will return TRADE_RETCODE_INVALID
// - Can't increase a position | market orders will return TRADE_RETCODE_INVALID
// - To decrease a position the market order volume can't be greater than position volume
// In netting:
// - In market orders informing non existing position ticket in requests when theres is no pos will return TRADE_RETCODE_INVALID_CLOSE_VOLUME
// - In market orders informing non existing pos when there is a pos will increase/descrease it / no error
// - In limit orders setting non existing position has no effect
bool TOrderSend(MqlTradeRequest &req,MqlTradeResult &res){

   // NETTING MARKET ORDER | NO POS | NON EXIS POS INFORMED
   // ERR_TRADE_SEND_FAILED TRADE_RETCODE_INVALID_CLOSE_VOLUME "Volume to be closed exceeds the position volume"
   // NETTING SLTP | NO POS | NON EXIS POS or 0
   // ERR_TRADE_SEND_FAILED TRADE_RETCODE_POSITION_CLOSED "Position doesn't exist"
   
   //if(req.position > 0 && TMQL::GetPositionIndexByTicket(req.position) == -1){
   //   TMQL::PrintError("Invalid position ticket");
   //   return false;
   //}
   
   TMQL::EnumScheduledTransactionActionType transActionType = -1;
   TMQL::Position* reqPosition = NULL;
   int reqPositionIndex = -1;

   if(req.position > 0){
      reqPositionIndex = TMQL::GetPositionIndexByTicket(req.position);
      reqPosition = TMQL::Positions.At(reqPositionIndex);
      // if(reqPosition == NULL || reqPosition.Symbol != req.symbol){
      if(reqPosition != NULL && reqPosition.Symbol != req.symbol){
         TMQL::PrintError("Invalid request. Wrong symbol.");
         TMQL::LastError = ERR_TRADE_SEND_FAILED;
         res.retcode = TRADE_RETCODE_INVALID;
         return false;
      }
   }

   switch(req.action){
      case TRADE_ACTION_DEAL:{
         transActionType = TMQL::TRANS_ACTION_TYPE_MARKET_DEAL;

         if(req.position > 0){
            if(TAccountInfoInteger(ACCOUNT_MARGIN_MODE) == ACCOUNT_MARGIN_MODE_RETAIL_HEDGING){
               if(reqPosition == NULL){
                  TMQL::PrintError("Invalid request. Position not found.");
                  TMQL::LastError = ERR_TRADE_SEND_FAILED;
                  res.retcode = TRADE_RETCODE_INVALID;
                  return false;
               }

               if(
                  (reqPosition.Type == POSITION_TYPE_BUY && TMQL::CheckSellRequestType(req.type)) || 
                  (reqPosition.Type == POSITION_TYPE_SELL && TMQL::CheckBuyRequestType(req.type))
               ){
                  if(reqPosition.Volume < req.volume){
                     TMQL::PrintError("Order volume greater than position volume.");
                     TMQL::LastError = ERR_TRADE_SEND_FAILED;
                     res.retcode = TRADE_RETCODE_INVALID_VOLUME;
                     return false;
                  }
               }
               else{
                  TMQL::PrintError("Invalid request. Can't increase existing position.");
                  TMQL::LastError = ERR_TRADE_SEND_FAILED;
                  res.retcode = TRADE_RETCODE_INVALID;
                  return false;
               }
            }
            else if(TAccountInfoInteger(ACCOUNT_MARGIN_MODE) == ACCOUNT_MARGIN_MODE_RETAIL_NETTING){
               if(reqPosition == NULL){
                  TMQL::PrintError("Volume to be closed exceeds the position volume");
                  TMQL::LastError = ERR_TRADE_SEND_FAILED;
                  res.retcode = TRADE_RETCODE_INVALID_CLOSE_VOLUME;
                  res.comment = "Volume to be closed exceeds the position volume";
                  return false;
               }
            }
         }

         double bidPrice = TSymbolInfoDouble(req.symbol,SYMBOL_BID);
         double askPrice = TSymbolInfoDouble(req.symbol,SYMBOL_ASK);

         if(
            // (TMQL::CheckBuyRequestType(req.type) && ((req.sl != 0 && req.sl >= bidPrice) || (req.tp != 0 && req.tp <= askPrice))) || 
            (TMQL::CheckBuyRequestType(req.type) && !TMQL::SLTPAreValid(POSITION_TYPE_BUY,req,bidPrice,askPrice)) ||
            // (TMQL::CheckSellRequestType(req.type) && ((req.sl != 0 && req.sl <= askPrice) || (req.tp != 0 && req.tp >= bidPrice)))
            (TMQL::CheckSellRequestType(req.type) && !TMQL::SLTPAreValid(POSITION_TYPE_SELL,req,bidPrice,askPrice))
         )
         {
            TMQL::PrintError("Invalid SL/TP");
            TMQL::LastError = ERR_TRADE_SEND_FAILED;
            res.retcode = TRADE_RETCODE_INVALID_STOPS;
            return false;
         }

         TMQL::Order* order;
         TMQL::Deal* deal;
         // ulong orderTicket = TMQL::CreateOrderTicket();
         ulong positionTicket = TAccountInfoInteger(ACCOUNT_MARGIN_MODE) == ACCOUNT_MARGIN_MODE_RETAIL_NETTING ?
            TMQL::GetFirstPositionTicketBySymbol(req.symbol) : req.position;

         switch(req.type){
            case ORDER_TYPE_BUY:{
               // ulong positionTicket = req.position > 0 ? req.position : TMQL::GetFirstPositionTicketBySymbol(req.symbol);
               if(positionTicket > 0){
                  if(reqPositionIndex == -1){
                     reqPositionIndex = TMQL::GetPositionIndexByTicket(positionTicket);
                     // reqPosition = TMQL::Positions.At(reqPositionIndex);
                  }
                  order = TMQL::CreateOrder(req.symbol,req.type,askPrice,positionTicket,req.magic,req.sl,req.tp,
                     req.volume,req.comment,req.action);
                  deal = TMQL::ManagePositionDealExecution(reqPositionIndex,DEAL_TYPE_BUY,askPrice,req.volume,order);
                  // TMQL::SetPositionSLTP(reqPositionIndex,req.sl,req.tp,DEAL_TYPE_BUY);
               }
               else{
                  order = TMQL::CreateOrder(req.symbol,req.type,askPrice,0,req.magic,req.sl,req.tp,
                     req.volume,req.comment,req.action);
                  TMQL::Position* position = TMQL::CreatePosition(req.symbol,POSITION_TYPE_BUY,askPrice,req.magic,req.sl,
                     req.tp,req.volume,order.Ticket);
                  deal = TMQL::CreateDeal(req.symbol,DEAL_TYPE_BUY,position.Ticket,askPrice,0,req.magic,req.volume,
                     order.Ticket,DEAL_ENTRY_IN);
               }
               break;
            }
            case ORDER_TYPE_SELL:{
               // ulong positionTicket = req.position > 0 ?  req.position : TMQL::GetFirstPositionTicketBySymbol(req.symbol);
               if(positionTicket > 0){
                  if(reqPositionIndex == -1){
                     reqPositionIndex = TMQL::GetPositionIndexByTicket(positionTicket);
                     // reqPosition = TMQL::Positions.At(reqPositionIndex);
                  }
                  order = TMQL::CreateOrder(req.symbol,req.type,bidPrice,positionTicket,req.magic,req.sl,req.tp,
                     req.volume,req.comment,req.action);
                  deal = TMQL::ManagePositionDealExecution(reqPositionIndex,DEAL_TYPE_SELL,bidPrice,req.volume,order);
                  // TMQL::SetPositionSLTP(reqPositionIndex,req.sl,req.tp,DEAL_TYPE_SELL);
               }
               else{
                  order = TMQL::CreateOrder(req.symbol,req.type,bidPrice,0,req.magic,req.sl,req.tp,
                     req.volume,req.comment,req.action);
                  TMQL::Position* position = TMQL::CreatePosition(req.symbol,POSITION_TYPE_SELL,bidPrice,req.magic,req.sl,
                     req.tp,req.volume,order.Ticket);
                  deal = TMQL::CreateDeal(req.symbol,DEAL_TYPE_SELL,position.Ticket,bidPrice,0,req.magic,req.volume,
                     order.Ticket,DEAL_ENTRY_IN);
               }
               break;
            }
            default:{
               TMQL::PrintError("Invalid order type");
               return false; //-- ERROR INVALID ORDER TYPE
            }
         }

         TMQL::SetResponseAttributes(res, deal.Ticket, order.Ticket, deal.Volume, deal.Price);
         break;
      }
      case TRADE_ACTION_PENDING:{
         transActionType = TMQL::TRANS_ACTION_TYPE_LIMIT_ORDER;

         // double bidPrice = TSymbolInfoDouble(req.symbol,SYMBOL_BID);
         // double askPrice = TSymbolInfoDouble(req.symbol,SYMBOL_ASK);

         if(TAccountInfoInteger(ACCOUNT_MARGIN_MODE) == ACCOUNT_MARGIN_MODE_RETAIL_HEDGING && req.position > 0 && 
            reqPosition == NULL)
         {
            TMQL::PrintError("Invalid request. Position not found.");
            TMQL::LastError = ERR_TRADE_SEND_FAILED;
            res.retcode = TRADE_RETCODE_INVALID;
            // res.comment = "";
            return false;
         }
         
         if(
            (TMQL::CheckBuyRequestType(req.type) && !TMQL::SLTPAreValid(POSITION_TYPE_BUY,req,req.price,req.price)) ||
            (TMQL::CheckSellRequestType(req.type) && !TMQL::SLTPAreValid(POSITION_TYPE_SELL,req,req.price,req.price))
         )
         {
            TMQL::PrintError("Invalid SL/TP");
            TMQL::LastError = ERR_TRADE_SEND_FAILED;
            res.retcode = TRADE_RETCODE_INVALID_STOPS;
            return false;
         }

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

         TMQL::Order *order = TMQL::CreateOrder(req.symbol, req.type, req.price, req.position, req.magic, req.sl, req.tp,
            req.volume, req.comment, req.action);
         TMQL::SetResponseAttributes(res, 0, order.Ticket);
         TimeToStruct(TimeCurrent(),TMQL::CurrentTimeStruct);
         TMQL::CurrentDay = TMQL::CurrentTimeStruct.day;
         break;
      }
      case TRADE_ACTION_REMOVE:{
         // transActionType = TMQL::EnumScheduledTransactionActionType.TRANS_ACTION_TYPE_CANCEL_ORDER;
         transActionType = TMQL::TRANS_ACTION_TYPE_CANCEL_ORDER;

         int orderIndex = TMQL::GetOrderIndexByTicket(req.order);
         
         if(orderIndex < 0){
            TMQL::PrintError("Order doesn't exist.");
            TMQL::LastError = ERR_TRADE_SEND_FAILED;
            res.retcode = TRADE_RETCODE_INVALID;
            return false;
         }

         TMQL::Order *order = TMQL::Orders.At(orderIndex);
         order.State = ORDER_STATE_CANCELED;
         TMQL::DrawOrder(order,TMQL::CHART_ACTION_ERASE);
         TMQL::Orders.Detach(orderIndex);
         TMQL::HistoryOrders.Add(order);

         //scheduling trade transactions
         req.symbol = order.Symbol;
         TMQL::SetResponseAttributes(res, 0, order.Ticket, 0, 0);
         // res.retcode = TRADE_RETCODE_DONE;
         // TMQL::ScheduleOnTradeTransactionAction(req, res, TMQL::EnumScheduledTransactionActionType::TRANS_ACTION_TYPE_CANCEL_ORDER);

         break;
      }
      case TRADE_ACTION_SLTP:{
            // ERR_TRADE_SEND_FAILED TRADE_RETCODE_POSITION_CLOSED "Position doesn't exist"

         if(TAccountInfoInteger(ACCOUNT_MARGIN_MODE) == ACCOUNT_MARGIN_MODE_RETAIL_HEDGING){
            if(req.position <= 0 || reqPosition == NULL){
               TMQL::PrintError("Invalid request.");
               TMQL::LastError = ERR_TRADE_SEND_FAILED;
               res.retcode = TRADE_RETCODE_INVALID;
               return false;
            }
         }
         else if(TAccountInfoInteger(ACCOUNT_MARGIN_MODE) == ACCOUNT_MARGIN_MODE_RETAIL_NETTING){
            reqPositionIndex = TMQL::GetPositionIndexByTicket(TMQL::GetFirstPositionTicketBySymbol(req.symbol));
            reqPosition = TMQL::Positions.At(reqPositionIndex);

            if(reqPositionIndex < 0){
               TMQL::PrintError("Position doesn't exist");
               TMQL::LastError = ERR_TRADE_SEND_FAILED;
               res.retcode = TRADE_RETCODE_POSITION_CLOSED;
               return false;
            }
         }

         double bidPrice = TSymbolInfoDouble(req.symbol,SYMBOL_BID);
         double askPrice = TSymbolInfoDouble(req.symbol,SYMBOL_ASK);
         
         // TMQL::Position *position = TMQL::Positions.At(TMQL::GetPositionIndexByTicket(req.position));
         // if(position == NULL){
         //    TMQL::PrintError("Invalid position ticket");
         //    return false;
         // }

         if(
            // (position.Type == POSITION_TYPE_BUY && ((req.sl != 0 && req.sl >= bid) || (req.tp != 0 && req.tp <= ask))) || 
            // (position.Type == POSITION_TYPE_SELL && ((req.sl != 0 && req.sl <= ask) || (req.tp != 0 && req.tp >= bid)))
            !TMQL::SLTPAreValid(reqPosition.Type,req,bidPrice,askPrice)
         )
         {
            TMQL::PrintError("Invalid SL/TP");
            TMQL::LastError = ERR_TRADE_SEND_FAILED;
            res.retcode = TRADE_RETCODE_INVALID_STOPS;
            return false;
         }

         TMQL::SetPositionSLTP(reqPositionIndex,req.sl,req.tp);
         break;
      }
      default:{
         TMQL::PrintError("Invalid order action");
         return false; //-- ERROR INVALID ORDER ACTION
      }
   }

   TMQL::LastRequestID++;
   res.request_id = TMQL::LastRequestID;
   res.retcode = TRADE_RETCODE_DONE;
   TMQL::ScheduleOnTradeTransactionAction(req, res, transActionType);
   TMQL::DrawTesterPanel(req.symbol, TMQL::CHART_ACTION_DRAW);
   return true;
}

//-- TO BE SET IN ONTIMER METHOD
void THandleOrderTime(){
   if(TMQL::Orders.Total() > 0){
      TimeToStruct(TimeCurrent(),TMQL::CurrentTimeStruct);
      if(TMQL::CurrentTimeStruct.day > TMQL::CurrentDay){
         TMQL::CurrentDay = TMQL::CurrentTimeStruct.day;
         TMQL::RemoveFuturePendingOrders();
      }
   }
}

//-- TO BE USED IN OnTick (MANAGES ORDERS,SL,TP)
void TManageTrade(){
   TMQL::HandleOnTradeTransaction();

   for(int c = TMQL::Orders.Total() - 1; c >= 0; c--){
      TMQL::Order* order = TMQL::Orders.At(c);
      // TMQL::Order *tempOrder = TMQL::CloneOrder(order);

      switch(order.Type){
         case ORDER_TYPE_BUY_LIMIT:{
            double currentPrice = TSymbolInfoDouble(order.Symbol,SYMBOL_ASK);
            
            if(currentPrice <= order.PriceOpen){
               TMQL::Deal* deal;

               double dealPrice = TMQL::UseMarketPricesForLimitOrdersAndSLTP ? currentPrice : order.PriceOpen;
               // ulong positionTicket = TMQL::GetFirstPositionTicketBySymbol(order.Symbol);
               ulong positionTicket = TAccountInfoInteger(ACCOUNT_MARGIN_MODE) == ACCOUNT_MARGIN_MODE_RETAIL_NETTING ? 
                  TMQL::GetFirstPositionTicketBySymbol(order.Symbol) : 0;
                  
               if(positionTicket > 0){
                  deal = TMQL::ManagePositionDealExecution(TMQL::GetPositionIndexByTicket(positionTicket),DEAL_TYPE_BUY,dealPrice,
                     order.VolumeInitial,order);
                  // TMQL::SetPositionSLTP(positionTicket,order.SL,order.TP,DEAL_TYPE_BUY);
               }
               else{
                  TMQL::Position* position = TMQL::CreatePosition(order.Symbol, POSITION_TYPE_BUY, dealPrice, order.Magic,
                     order.SL, order.TP, order.VolumeInitial, order.Ticket);
                  deal = TMQL::CreateDeal(order.Symbol, DEAL_TYPE_BUY, position.Ticket, dealPrice, 0, order.Magic, 
                     order.VolumeInitial, order.Ticket, DEAL_ENTRY_IN);
               }

               order.VolumeCurrent = 0;
               order.State = ORDER_STATE_FILLED;
               TMQL::DrawOrder(order,TMQL::CHART_ACTION_ERASE);
               TMQL::Orders.Detach(c);
               TMQL::HistoryOrders.Add(order);
               TMQL::DrawTesterPanel(order.Symbol,TMQL::CHART_ACTION_DRAW);

               //scheduling trade transaction
               MqlTradeRequest req;
               MqlTradeResult res;

               req.type = order.Type;
               req.symbol = deal.Symbol;
               TMQL::SetResponseAttributes(res, deal.Ticket, order.Ticket, deal.Volume, deal.Price);
               res.retcode = TRADE_RETCODE_DONE;
               TMQL::ScheduleOnTradeTransactionAction(req, res, TMQL::EnumScheduledTransactionActionType::TRANS_ACTION_TYPE_LIMIT_DEAL);
            }
            break;
         }
         case ORDER_TYPE_SELL_LIMIT:{
            double currentPrice = TSymbolInfoDouble(order.Symbol,SYMBOL_BID);
            if(currentPrice >= order.PriceOpen){
               TMQL::Deal* deal;

               double dealPrice = TMQL::UseMarketPricesForLimitOrdersAndSLTP ? currentPrice : order.PriceOpen;
               // ulong positionTicket = TMQL::GetFirstPositionTicketBySymbol(order.Symbol);
               ulong positionTicket = TAccountInfoInteger(ACCOUNT_MARGIN_MODE) == ACCOUNT_MARGIN_MODE_RETAIL_NETTING ? 
                  TMQL::GetFirstPositionTicketBySymbol(order.Symbol) : 0;

               if(positionTicket > 0){
                  deal = TMQL::ManagePositionDealExecution(TMQL::GetPositionIndexByTicket(positionTicket),DEAL_TYPE_SELL,dealPrice,
                     order.VolumeInitial,order);
                  // TMQL::SetPositionSLTP(positionTicket,order.SL,order.TP,DEAL_TYPE_SELL);
               }
               else{
                  TMQL::Position *position = TMQL::CreatePosition(order.Symbol, POSITION_TYPE_SELL, dealPrice, order.Magic,
                     order.SL, order.TP, order.VolumeInitial, order.Ticket);
                  deal = TMQL::CreateDeal(order.Symbol, DEAL_TYPE_SELL, position.Ticket, dealPrice, 0, order.Magic, 
                     order.VolumeInitial, order.Ticket, DEAL_ENTRY_IN);
               }

               order.VolumeCurrent = 0;
               order.State = ORDER_STATE_FILLED;
               TMQL::DrawOrder(order,TMQL::CHART_ACTION_ERASE);
               TMQL::Orders.Detach(c);
               TMQL::HistoryOrders.Add(order);
               TMQL::DrawTesterPanel(order.Symbol,TMQL::CHART_ACTION_DRAW);

               //scheduling trade transaction
               MqlTradeRequest req;
               MqlTradeResult res;

               req.type = order.Type;
               req.symbol = deal.Symbol;
               TMQL::SetResponseAttributes(res, deal.Ticket, order.Ticket, deal.Volume, deal.Price);
               res.retcode = TRADE_RETCODE_DONE;
               TMQL::ScheduleOnTradeTransactionAction(req, res, TMQL::EnumScheduledTransactionActionType::TRANS_ACTION_TYPE_LIMIT_DEAL);
            }
            break;
         }
         default:{
            //-- ORDER EXEC ERROR INVALID ORDER TYPE
         }
      }
      // delete(tempOrder);
   }
   for(int c = TMQL::Positions.Total() - 1; c >= 0; c--){
      TMQL::Position* position = TMQL::Positions.At(c);
      if(position.Type == POSITION_TYPE_BUY){
         string positionSymbol = position.Symbol;
         double currentPrice = TSymbolInfoDouble(position.Symbol,SYMBOL_BID);
         bool TPWasTriggered = position.TP > 0 && currentPrice >= position.TP;
         bool SLWasTriggered = position.SL > 0 && currentPrice <= position.SL;

         if(TPWasTriggered || SLWasTriggered){
            double dealPrice = TMQL::UseMarketPricesForLimitOrdersAndSLTP ? currentPrice : 
               (TPWasTriggered ? position.TP : position.SL);

            TMQL::Order* order = TMQL::CreateOrder(position.Symbol,ORDER_TYPE_SELL,dealPrice,position.Ticket,position.Magic,
               0,0,position.Volume,"",TRADE_ACTION_DEAL);

            TMQL::Deal* d = TMQL::ManagePositionDealExecution(c,DEAL_TYPE_SELL,dealPrice,position.Volume,order);

            if(TPWasTriggered)
               TMQL::Log("TP was triggered");
            else if(SLWasTriggered)
               TMQL::Log("SL was triggered");

            TMQL::DrawTesterPanel(positionSymbol,TMQL::CHART_ACTION_DRAW);

            MqlTradeRequest req;
            MqlTradeResult res;

            req.action = TRADE_ACTION_DEAL;
            req.type = ORDER_TYPE_SELL;
            req.symbol = d.Symbol;
            TMQL::SetResponseAttributes(res, d.Ticket, order.Ticket, d.Volume, d.Price);
            res.retcode = TRADE_RETCODE_DONE;
            TMQL::ScheduleOnTradeTransactionAction(req, res, TMQL::EnumScheduledTransactionActionType::TRANS_ACTION_TYPE_SLTP_DEAL);
         }
      }
      else{
         string positionSymbol = position.Symbol;
         double currentPrice = TSymbolInfoDouble(position.Symbol,SYMBOL_ASK);
         bool TPWasTriggered = position.TP > 0 && currentPrice <= position.TP;
         bool SLWasTriggered = position.SL > 0 && currentPrice >= position.SL;

         if(TPWasTriggered || SLWasTriggered){
            double dealPrice = TMQL::UseMarketPricesForLimitOrdersAndSLTP ? currentPrice : 
               (TPWasTriggered ? position.TP : position.SL);

            TMQL::Order* order = TMQL::CreateOrder(position.Symbol,ORDER_TYPE_BUY,dealPrice,position.Ticket,position.Magic,
               0,0,position.Volume,"",TRADE_ACTION_DEAL);

            TMQL::Deal* d = TMQL::ManagePositionDealExecution(c,DEAL_TYPE_BUY,dealPrice,position.Volume,order);

            if(TPWasTriggered)
               TMQL::Log("TP was triggered");
            else if(SLWasTriggered)
               TMQL::Log("SL was triggered");

            TMQL::DrawTesterPanel(positionSymbol,TMQL::CHART_ACTION_DRAW);

            MqlTradeRequest req;
            MqlTradeResult res;

            req.action = TRADE_ACTION_DEAL;
            req.type = ORDER_TYPE_BUY;
            req.symbol = d.Symbol;
            TMQL::SetResponseAttributes(res,d.Ticket,order.Ticket,d.Volume,d.Price);
            res.retcode = TRADE_RETCODE_DONE;
            TMQL::ScheduleOnTradeTransactionAction(req, res, TMQL::EnumScheduledTransactionActionType::TRANS_ACTION_TYPE_SLTP_DEAL);               
         }
      }
   }
}

int TGetLastError(){ return TMQL::LastError; }

//-- Manually used when ShowInformationPanel property is false
//-- Displays main info panel with updated information about positions/orders/deals in the chart
void TShowInfoPanel(string symbol){ TMQL::DrawTesterPanel(symbol,TMQL::CHART_ACTION_DRAW,true); }

void TEraseInfoPanel(string symbol) { TMQL::DrawTesterPanel(symbol,TMQL::CHART_ACTION_ERASE,true); }