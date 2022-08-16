#include <Nain\TMQL\TMQL\TMQL.mqh>

namespace Nain { namespace TUtility
{
   //moving SL properties
   struct MovingSLProperties
   {
      double Price;
      double SLPriceDistance;
      ENUM_POSITION_TYPE PositionType;
      long ChartID;
      string ObjName;
   };
   
   class Format
   {
   private:
      /* data */
   public:
      string BoolToString(bool value){
         return value == 0 ? "false" : "true";
      }
   };

   class Time
   {
   private:
      /* data */
   public:
      //Returns a datetime with hours,minutes and seconds only
      datetime DateToTime(datetime date){
         MqlDateTime inp;
         TimeToStruct(date, inp);
         inp.year = 1970;
         inp.mon = 0;
         inp.day = 0;
         //inp.day_of_week = 0;
         //inp.day_of_year = 0;
         return (datetime)StructToTime(inp);
      }
   };
   
   
   class Math
   {   
   private:
   public:
      Math(/* args */){};

      double Round(double value,bool roundUp,bool autoRound,double tickSize){
         //-- roundUp: rounds up or down in case remainder equals middleValue / if autoRound is false, it rounds manually
         //-- autoRound: whether the value is rounded automatically or based entirely on roundUp variable
         bool valueIsNegative = value < 0;
         if(valueIsNegative) value = -value;
         double remainder = MathMod(value,tickSize);
         double middleValue = tickSize/2;
         
         if(remainder == 0){
            //return value;
         }
         else if(autoRound){
            if((remainder >= middleValue && roundUp) || (remainder > middleValue && !roundUp)){
               value = value - remainder + tickSize;
            }
            else if((remainder < middleValue && roundUp) || (remainder <= middleValue && !roundUp)){
               value = value - remainder;
            }
         }
         else{
            if(roundUp) value = value - remainder + tickSize;
            else value = value - remainder;
         }
         if(valueIsNegative) value = -value;
         return value;
      }

      bool NumberIsOdd(double value){
         if(MathMod(value,2) > 0) return true;
         return false;
      }

      bool NumberIsInteger(double number){
         return MathFloor(number/1) == number/1 && (number >= 1 || number <= -1);
      }

      bool NumberIsMultiple(double number,double multipleOf){
         if(!MathMod(number,multipleOf) > 0) return true;
         return false;
      }
   };

   class ChartObj
   {
   private:
      MovingSLProperties MovingSLProps;
   public:
      ChartObj(/* args */){};

      //########################################### CHART OBJECTS ########################################### 

      void DrawLabel(long chartID,string labelName,string labelText,long xDistance,long yDistance,
         color labelColor = clrWhite,long fontSize = 10,ENUM_BASE_CORNER labelCorner = CORNER_LEFT_UPPER){
         if(ObjectFind(chartID,labelName) < 0) ObjectCreate(chartID,labelName,OBJ_LABEL,0,0,0);
         ObjectSetString(chartID,labelName,OBJPROP_TEXT,labelText);
         ObjectSetInteger(chartID,labelName,OBJPROP_COLOR,labelColor);
         ObjectSetInteger(chartID,labelName,OBJPROP_CORNER,labelCorner);
         ObjectSetInteger(chartID,labelName,OBJPROP_XDISTANCE,xDistance);
         ObjectSetInteger(chartID,labelName,OBJPROP_YDISTANCE,yDistance);
         ObjectSetInteger(chartID,labelName,OBJPROP_FONTSIZE,fontSize);
      }

      //extern ENUM_OBJ inpHigherPeriod=PERIOD_W1;
      void DrawHLine(long chartID,string objName,double price,color objColor = clrRed,ENUM_LINE_STYLE objStyle = STYLE_SOLID,
         bool objBack = false,ENUM_OBJECT_PROPERTY_INTEGER lineWidth = 1){
         if(ObjectFind(chartID,objName) < 0) ObjectCreate(chartID,objName,OBJ_HLINE,0,0,price);
         else ObjectSetDouble(chartID,objName,OBJPROP_PRICE,price);
         ObjectSetInteger(chartID,objName,OBJPROP_COLOR,objColor);
         ObjectSetInteger(chartID,objName,OBJPROP_STYLE,objStyle);
         ObjectSetInteger(chartID,objName,OBJPROP_BACK,objBack);
         ObjectSetInteger(chartID,objName,OBJPROP_WIDTH,lineWidth);//3
      }

      int BuyArrowObjCounter;
      void DrawBuyArrow(long chartID,double price,datetime time,color objColor = 4278411180,bool objBack = false){
         ObjectCreate(chartID,"BuyArrowObj"+(string)BuyArrowObjCounter,OBJ_ARROW_BUY,0,time,price);
         ObjectSetInteger(chartID,"BuyArrowObj"+(string)BuyArrowObjCounter,OBJPROP_COLOR,objColor);
         ObjectSetInteger(chartID,"BuyArrowObj"+(string)BuyArrowObjCounter,OBJPROP_BACK,objBack);
         BuyArrowObjCounter++;
      }

      int SellArrowObjCounter;
      void DrawSellArrow(long chartID,double price,datetime time,color objColor = 4292953117,bool objBack = false){
         ObjectCreate(chartID,"SellArrowObj"+(string)SellArrowObjCounter,OBJ_ARROW_SELL,0,time,price);
         ObjectSetInteger(chartID,"SellArrowObj"+(string)SellArrowObjCounter,OBJPROP_COLOR,objColor);
         ObjectSetInteger(chartID,"SellArrowObj"+(string)SellArrowObjCounter,OBJPROP_BACK,objBack);
         SellArrowObjCounter++;
      }

      int ArrowUpObjCounter;
      void DrawArrowUp(long chartID,double price,datetime time,bool objBack = false){
         ObjectCreate(chartID,"ArrowUpObj"+(string)ArrowUpObjCounter,OBJ_ARROW_UP,0,time,price);
         ObjectSetInteger(chartID,"ArrowUpObj"+(string)ArrowUpObjCounter,OBJPROP_BACK,objBack);
         ArrowUpObjCounter++;
      }

      int ArrowDownObjCounter;
      void DrawArrowDown(long chartID,double price,datetime time,bool objBack = false){
         ObjectCreate(chartID,"ArrowDownObj"+(string)ArrowDownObjCounter,OBJ_ARROW_DOWN,0,time,price);
         ObjectSetInteger(chartID,"ArrowUpObj"+(string)ArrowUpObjCounter,OBJPROP_BACK,objBack);
         ArrowDownObjCounter++;
      }

      //########################################### MOVING SL ########################################### 

      void SetMovingSL(double initialSLPrice,double SLPriceDistance,ENUM_POSITION_TYPE positionType, 
      long chartID,color objColor = clrRed,ENUM_LINE_STYLE objStyle = STYLE_SOLID,bool objBack = false,
         ENUM_OBJECT_PROPERTY_INTEGER lineWidth = 1,string objName="MovingSL"){
         MovingSLProps.Price = initialSLPrice;
         MovingSLProps.SLPriceDistance = SLPriceDistance;
         MovingSLProps.PositionType = positionType;
         MovingSLProps.ChartID = chartID;
         MovingSLProps.ObjName = objName;
         DrawHLine(chartID,objName,initialSLPrice,objColor,objStyle,objBack,lineWidth);
      }

      //-- Used in OnTick / returns if SL price was reached
      bool HandleMovingSL(){
         double distFromSL;
         double currPrice;

         if(MovingSLProps.PositionType == POSITION_TYPE_BUY){
            currPrice = TSymbolInfoDouble(ChartSymbol(MovingSLProps.ChartID), SYMBOL_ASK);
            distFromSL = currPrice - MovingSLProps.Price;
            if(distFromSL > MovingSLProps.SLPriceDistance){
               MovingSLProps.Price = currPrice - MovingSLProps.SLPriceDistance;
               DrawHLine(MovingSLProps.ChartID,MovingSLProps.ObjName,MovingSLProps.Price);
            }
         }
         else{
            currPrice = TSymbolInfoDouble(ChartSymbol(MovingSLProps.ChartID), SYMBOL_BID);
            distFromSL = MovingSLProps.Price - currPrice;
            if(distFromSL > MovingSLProps.SLPriceDistance){
               MovingSLProps.Price = currPrice + MovingSLProps.SLPriceDistance;
               DrawHLine(MovingSLProps.ChartID,MovingSLProps.ObjName,MovingSLProps.Price);
            }
         }

         if(distFromSL <= 0){
            ClearMovingSL();
            return true;
         }

         return false;
      }

      void ClearMovingSL(){
         ObjectDelete(MovingSLProps.ChartID, MovingSLProps.ObjName);
      }
   };
} }