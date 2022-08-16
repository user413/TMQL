#include <Nain\TMQL\TMQL\TMQL.mqh>

namespace Nain { namespace TUtility
{
   class Trade
   {
   private:
      MqlTradeRequest Req;
      MqlTradeResult Res;
      void CleanReqRes(){ CleanReqRes(Req,Res); }
   public:
      Trade(){};
      
      //ENUM_TRADE_REQUEST_ACTIONS
      // ENUM_ORDER_TYPE_TIME
      // ENUM_ORDER_TYPE_FILLING
      bool Buy(string symbol,MqlTradeRequest &req,MqlTradeResult &res,double volume,ENUM_TRADE_REQUEST_ACTIONS tradeAction = TRADE_ACTION_DEAL,
         ENUM_ORDER_TYPE_TIME orderTypeTime = ORDER_TIME_DAY,ENUM_ORDER_TYPE_FILLING orderTypeFilling = ORDER_FILLING_RETURN,
         double price = 0,double tp = 0,double sl = 0,ulong deviation = 0,ulong positionTicket = 0,long magic = 0){
         CleanReqRes(req,res);
         string orderTypeStr;
         switch(tradeAction){
         case TRADE_ACTION_DEAL:
            req.type = ORDER_TYPE_BUY;
            orderTypeStr = "MARKET";
            break; 
         case TRADE_ACTION_PENDING:
            req.type = ORDER_TYPE_BUY_LIMIT;
            req.price = price;
            req.magic = magic;
            orderTypeStr = "PENDING";
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
         
         if(!TOrderSend(req,res))
            PrintFormat("#ADVISOR#: %s BUY ORDER FAILURE | ORDERSEND ERROR:%d RETCODE:%d",orderTypeStr,GetLastError(),
               res.retcode);
         else{
            PrintFormat("#ADVISOR#: %s BUY ORDER SUCCESS | PRICE:%g ORDER:%I64u DEAL:%I64u",orderTypeStr,res.price,res.order,
               res.deal);
            return true;
         }  
         return false;
      }

      bool Sell(string symbol,MqlTradeRequest &req,MqlTradeResult &res,double volume,ENUM_TRADE_REQUEST_ACTIONS tradeAction = TRADE_ACTION_DEAL,
         ENUM_ORDER_TYPE_TIME orderTypeTime = ORDER_TIME_DAY,ENUM_ORDER_TYPE_FILLING orderTypeFilling = ORDER_FILLING_RETURN,
         double price = 0,double tp = 0,double sl = 0,ulong deviation = 0,ulong positionTicket = 0,long magic = 0){
         CleanReqRes(req,res);
         string orderTypeStr;
         switch(tradeAction){
         case TRADE_ACTION_DEAL:
            req.type = ORDER_TYPE_SELL;
            orderTypeStr = "MARKET";
            break; 
         case TRADE_ACTION_PENDING:
            req.type = ORDER_TYPE_SELL_LIMIT;
            req.price = price;
            if(magic != -1) req.magic = magic;
            orderTypeStr = "PENDING";
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

         if(!TOrderSend(req,res))
            PrintFormat("#ADVISOR#: %s SELL ORDER FAILURE | ORDERSEND ERROR:%d RETCODE:%d",orderTypeStr,GetLastError(),
               res.retcode);
         else{
            PrintFormat("#ADVISOR#: %s SELL ORDER SUCCESS | PRICE:%g ORDER:%I64u DEAL:%I64u",orderTypeStr,res.price,res.order,
               res.deal);
            return true;
         }  
         return false;
      }

      void CleanReqRes(MqlTradeRequest &req,MqlTradeResult &res){
         ZeroMemory(req);
         ZeroMemory(res);
      }

      double SymbolDealProfitTotal(string symbol,datetime fromDate,datetime toDate){
         double totalProfit = 0;
         if(THistorySelect(fromDate,toDate)){
            for(int c = 0; c < THistoryDealsTotal(); c++){
               ulong ticket = THistoryDealGetTicket(c);
               string dealSymbol = THistoryDealGetString(ticket,DEAL_SYMBOL);
               if(dealSymbol != symbol) continue;
               totalProfit += THistoryDealGetDouble(ticket,DEAL_PROFIT);
            }
         }
         return totalProfit;
      }

      // ############################################## ORDERS ##############################################

      bool CancelAllSymbolOrders(string symbol){
         bool errorHasOcurred = false;
         for(int c = TOrdersTotal() - 1; c >= 0; c--){
            ulong orderTicket = TOrderGetTicket(c);
            if(TOrderGetString(ORDER_SYMBOL) != symbol) continue;
            if(!CancelOrder(orderTicket,Req,Res)) errorHasOcurred = true;
         }
         CleanReqRes();
         return !errorHasOcurred;
      }

      bool CancelOrder(ulong orderTicket, MqlTradeRequest &req, MqlTradeResult &res){
         CleanReqRes(req,res);
         req.action = TRADE_ACTION_REMOVE;
         req.order = orderTicket;
         if(!TOrderSend(req,res)){
            PrintFormat("#ADVISOR#: CANCEL ORDER FAILURE | ORDERSEND ERROR:%d RETCODE:%d",GetLastError(), res.retcode);
            return false;
         }
         return true;
      }

      bool CancelSymbolBuyOrders(string symbol){
         bool errorHasOcurred = false;
         for(int c = TOrdersTotal() - 1; c >= 0; c--){
            ulong  orderTicket = TOrderGetTicket(c);
            if(TOrderGetString(ORDER_SYMBOL) != symbol || TOrderGetInteger(ORDER_TYPE) != ORDER_TYPE_BUY_LIMIT) continue;
            if(!CancelOrder(orderTicket,Req,Res)) errorHasOcurred = true;
         }
         CleanReqRes();
         return !errorHasOcurred;
      }

      bool CancelSymbolSellOrders(string symbol){
         bool errorHasOcurred = false;
         for(int c = TOrdersTotal() - 1; c >= 0; c--){
            ulong  orderTicket = TOrderGetTicket(c);
            if(TOrderGetString(ORDER_SYMBOL) != symbol || TOrderGetInteger(ORDER_TYPE) != ORDER_TYPE_SELL_LIMIT) continue;
            if(!CancelOrder(orderTicket,Req,Res)) errorHasOcurred = true;
         }
         CleanReqRes();
         return !errorHasOcurred;
      }

      int SymbolLimitOrdersTotal(string symbol){
         int totalOrders = 0;
         for(int c = 0; c < TOrdersTotal(); c++){
            ulong  orderTicket = TOrderGetTicket(c);
            ENUM_ORDER_TYPE orderType = (ENUM_ORDER_TYPE)TOrderGetInteger(ORDER_TYPE);
            if(TOrderGetString(ORDER_SYMBOL) != symbol || !(orderType == ORDER_TYPE_BUY_LIMIT || orderType == ORDER_TYPE_SELL_LIMIT)) continue;
            totalOrders++;
         }
         return totalOrders;
      }

      int SymbolMarketOrdersTotal(string symbol){
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

      bool CloseAllSymbolPositions(string symbol){
         bool errorHasOcurred = false;
         for(int c = 0; c < TPositionsTotal(); c++){
            ulong positionTicket = TPositionGetTicket(c);
            if(TPositionGetString(POSITION_SYMBOL) != symbol) continue;
            ENUM_POSITION_TYPE positionType = (ENUM_POSITION_TYPE)TPositionGetInteger(POSITION_TYPE);
            double volume = TPositionGetDouble(POSITION_VOLUME);

            if(
               (positionType == POSITION_TYPE_BUY && 
                  !Sell(symbol,Req,Res,volume,TRADE_ACTION_DEAL,ORDER_TIME_DAY,ORDER_FILLING_RETURN,positionTicket)) ||
               (positionType == POSITION_TYPE_SELL &&
                  !Buy(symbol,Req,Res,volume,TRADE_ACTION_DEAL,ORDER_TIME_DAY,ORDER_FILLING_RETURN,positionTicket))
            )
               errorHasOcurred = true;
         }
         CleanReqRes();
         return !errorHasOcurred;
      }

      bool CloseAllSymbolSellPositions(string symbol){
         bool errorHasOcurred = false;
         for(int c = 0; c < TPositionsTotal(); c++){
            ulong positionTicket = TPositionGetTicket(c);
            if(TPositionGetString(POSITION_SYMBOL) != symbol || TPositionGetInteger(POSITION_TYPE) != POSITION_TYPE_SELL) continue;
            if(!Buy(symbol,Req,Res,TPositionGetDouble(POSITION_VOLUME),TRADE_ACTION_DEAL,ORDER_TIME_DAY,ORDER_FILLING_RETURN,
               positionTicket))
               errorHasOcurred = true;
         }
         CleanReqRes();
         return !errorHasOcurred;
      }

      bool CloseAllSymbolBuyPositions(string symbol){
         bool errorHasOcurred = false;
         for(int c = 0; c < TPositionsTotal(); c++){
            ulong positionTicket = TPositionGetTicket(c);
            if(TPositionGetString(POSITION_SYMBOL) != symbol || TPositionGetInteger(POSITION_TYPE) != POSITION_TYPE_BUY) continue;
            if(!Sell(symbol,Req,Res,TPositionGetDouble(POSITION_VOLUME),TRADE_ACTION_DEAL,ORDER_TIME_DAY,ORDER_FILLING_RETURN,
               positionTicket))
               errorHasOcurred = false;
         }
         CleanReqRes();
         return !errorHasOcurred;
      }

      int SymbolPositionsTotal(string symbol){
         int total = 0;
         for(int c = 0; c < TPositionsTotal(); c++){
            TPositionGetTicket(c);
            if(TPositionGetString(POSITION_SYMBOL) == symbol) total++;
         }
         return total;
      }

      //-- Used when working with a single position
      ENUM_POSITION_TYPE GetCurrentPositionType(string symbol){
         for(int c = 0; c < TPositionsTotal(); c++){
            TPositionGetTicket(c);
            if(TPositionGetString(POSITION_SYMBOL) != symbol) continue;
            return TPositionGetInteger(POSITION_TYPE);
         }
         return -1;
      }

      //-- Used when working with a single position
      double GetCurrentPositionVolume(string symbol){
         for(int c = 0; c < TPositionsTotal(); c++){
            TPositionGetTicket(c);
            if(TPositionGetString(POSITION_SYMBOL) != symbol) continue;
            return TPositionGetDouble(POSITION_VOLUME);
         }
         return -1;
      }
   };
} }