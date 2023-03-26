#property copyright "Nain"

#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayDouble.mqh>
#include <Arrays\ArrayString.mqh>
// #include <Nain\Utility\Common.mqh>
// #include <Nain\Utility\Trade.mqh>
// #include <Nain\Utility\Format.mqh>
// #include "Generic.mqh"
// #include <Nain\Utility\CustomBars.mqh>

namespace Nain
{
   class Math
   {
   public:
      static double Round(double value,bool roundUp,bool autoRound,double tickSize){
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

      static bool NumberIsOdd(double value){
         if(MathMod(value,2) > 0) return true;
         return false;
      }

      static bool NumberIsInteger(double number){
         return MathFloor(number/1) == number/1 && (number >= 1 || number <= -1);
      }

      static bool NumberIsMultiple(double number,double multipleOf){
         if(!MathMod(number,multipleOf) > 0) return true;
         return false;
      }

      static ulong GenerateExpertMagic(){
         string text = MQLInfoString(MQL_PROGRAM_NAME) + Symbol();
         char a[];
         StringToCharArray(text, a);
         ulong result = 0;
         for (int i = 0; i < ArraySize(a); i++)
            result += a[i];
         return result;
      }

      static int HandleNumericComparison(double nodePropValue, double propValue, const int mode = 0){
         if(mode <= 0) return 0;
         if(propValue == nodePropValue) return 0;
         int result = (propValue > nodePropValue) * 2 - 1;
         if(mode == 2) result *= -1;
         return result;
      }

      static double MoneyToPoints(double money,double volume,double symbolTickValue,double symbolTickSize){
         if(money == 0) return 0;
         return Math::Round((money / symbolTickValue) * symbolTickSize / volume,true,false,symbolTickSize);
         // double tickValue = symbolTickValue * volume;
         // return m.Round(money / tickValue,true,false,1) * symbolTickSize;
      }

      static double PointsToMoney(double points,double volume,double symbolTickValue,double symbolTickSize ){
         return (Math::Round(points,false,false,symbolTickSize) / symbolTickSize) * symbolTickValue * volume;
      }

      //-- Generated a compact id based on the position of the current chart
      static int GenerateChartId(){
         long currentChartID = ChartFirst();
         int newId = 1;

         while(currentChartID >= 0){
            if(ChartID() == currentChartID) break;
            newId++;
            currentChartID = ChartNext(currentChartID);
         }

         return newId;
      }
   };

   class ChartObj
   {
   private:
      static bool Constructor()
      {
         SetObjCounter(BuyArrowObjCounter, OBJ_ARROW_BUY, BaseObjName + "_BA");
         SetObjCounter(SellArrowObjCounter, OBJ_ARROW_SELL, BaseObjName + "_SA");
         SetObjCounter(ArrowUpObjCounter, OBJ_ARROW_UP, BaseObjName + "_AU");
         SetObjCounter(ArrowDownObjCounter, OBJ_ARROW_DOWN, BaseObjName + "_AD");
         return true;
      }

      static const bool Constr;
      static const string BaseObjName; //added to the names of all objects
      static int BuyArrowObjCounter,SellArrowObjCounter,ArrowUpObjCounter,ArrowDownObjCounter;
      // Initiates counter variable with the max amount of objects of the informed type found from each chart available
      static void SetObjCounter(int& objCounter,ENUM_OBJECT objType,string baseName);
   public:
      static void EraseAllObjects(long chartId);

      static void DrawLabel(long chartID,string labelName,string labelText,long xDistance,long yDistance,
         color labelColor = clrWhite,long fontSize = 10,ENUM_BASE_CORNER labelCorner = CORNER_LEFT_UPPER){
         if(ObjectFind(chartID,labelName) < 0) ObjectCreate(chartID,labelName,OBJ_LABEL,0,0,0);
         ObjectSetString(chartID,labelName,OBJPROP_TEXT,labelText);
         ObjectSetInteger(chartID,labelName,OBJPROP_COLOR,labelColor);
         ObjectSetInteger(chartID,labelName,OBJPROP_CORNER,labelCorner);
         ObjectSetInteger(chartID,labelName,OBJPROP_XDISTANCE,xDistance);
         ObjectSetInteger(chartID,labelName,OBJPROP_YDISTANCE,yDistance);
         ObjectSetInteger(chartID,labelName,OBJPROP_FONTSIZE,fontSize);
      }

      static void DrawHLine(long chartID,string objName,double price,color objColor = clrRed,ENUM_LINE_STYLE objStyle = STYLE_SOLID,
         bool objBack = false,ENUM_OBJECT_PROPERTY_INTEGER lineWidth = 1){ //,string label=""
         if(ObjectFind(chartID,objName) < 0) ObjectCreate(chartID,objName,OBJ_HLINE,0,0,price);
         else ObjectSetDouble(chartID,objName,OBJPROP_PRICE,price);
         ObjectSetInteger(chartID,objName,OBJPROP_COLOR,objColor);
         ObjectSetInteger(chartID,objName,OBJPROP_STYLE,objStyle);
         ObjectSetInteger(chartID,objName,OBJPROP_BACK,objBack);
         ObjectSetInteger(chartID,objName,OBJPROP_WIDTH,lineWidth);
         // ObjectSetString(chartID,objName,OBJPROP_TEXT,label);
      }

      static void DrawBuyArrow(long chartID,double price,datetime time,string baseObjName = "BuyArrowObj",
         color objColor = clrBlue,bool objBack = false){
         // SetObjCounter(BuyArrowObjCounter, OBJ_ARROW_BUY, BaseObjName + "_BA");
         string objName = baseObjName + BaseObjName + "_BA" + (string)BuyArrowObjCounter;
         ObjectCreate(chartID,objName,OBJ_ARROW_BUY,0,time,price);
         ObjectSetInteger(chartID,objName,OBJPROP_COLOR,objColor);
         ObjectSetInteger(chartID,objName,OBJPROP_BACK,objBack);
         BuyArrowObjCounter++;
      }

      static void DrawSellArrow(long chartID,double price,datetime time,string baseObjName = "SellArrowObj",
         color objColor = clrRed,bool objBack = false){
         // SetObjCounter(SellArrowObjCounter, OBJ_ARROW_SELL, BaseObjName + "_SA");
         string objName = baseObjName + BaseObjName + "_SA" + (string)SellArrowObjCounter;
         ObjectCreate(chartID,objName,OBJ_ARROW_SELL,0,time,price);
         ObjectSetInteger(chartID,objName,OBJPROP_COLOR,objColor);
         ObjectSetInteger(chartID,objName,OBJPROP_BACK,objBack);
         SellArrowObjCounter++;
      }

      static void DrawArrowUp(long chartID,double price,datetime time,string baseObjName = "ArrowUpObj",
         color objColor=clrRed,bool objBack = false,ENUM_ARROW_ANCHOR anchor = ANCHOR_TOP){
         // SetObjCounter(ArrowUpObjCounter, OBJ_ARROW_UP, BaseObjName + "_AU");
         string objName = baseObjName + BaseObjName + "_AU" + (string)ArrowUpObjCounter;
         ObjectCreate(chartID,objName,OBJ_ARROW_UP,0,time,price);
         ObjectSetInteger(chartID,objName,OBJPROP_BACK,objBack);
         ObjectSetInteger(chartID,objName,OBJPROP_ANCHOR,anchor);
         ObjectSetInteger(chartID,objName,OBJPROP_COLOR,objColor);
         ArrowUpObjCounter++;
      }

      static void DrawArrowDown(long chartID,double price,datetime time,string baseObjName = "ArrowDownObj",
         color objColor=clrRed,bool objBack = false,ENUM_ARROW_ANCHOR anchor = ANCHOR_BOTTOM){
         // SetObjCounter(ArrowDownObjCounter, OBJ_ARROW_DOWN, BaseObjName + "_AD");
         string objName = baseObjName + BaseObjName + "_AD" + (string)ArrowDownObjCounter;
         ObjectCreate(chartID,objName,OBJ_ARROW_DOWN,0,time,price);
         ObjectSetInteger(chartID,objName,OBJPROP_BACK,objBack);
         ObjectSetInteger(chartID,objName,OBJPROP_ANCHOR,anchor);
         ObjectSetInteger(chartID,objName,OBJPROP_COLOR,objColor);
         ArrowDownObjCounter++;
      }
   };

   const bool ChartObj::Constr = ChartObj::Constructor();
   const string ChartObj::BaseObjName = "_ChartObjUtil";
   //static variables
   int ChartObj::BuyArrowObjCounter = 0;
   int ChartObj::SellArrowObjCounter = 0;
   int ChartObj::ArrowUpObjCounter = 0;
   int ChartObj::ArrowDownObjCounter = 0;

   // Initiates counter variable with the max number found in the name of objects containing the informed base name
   // in all charts
   void ChartObj::SetObjCounter(int& objCounter,ENUM_OBJECT objType,string baseName){
      if(objCounter > 0) return;
      long currentChartID = ChartFirst();
      string objName;
      int baseNamePos;
      int objNumber;

      //retrieving obj name with highest number
      while(currentChartID >= 0){
         // int chartObjCount = 0;
         for (int i = 0; i < ObjectsTotal(currentChartID, -1, objType); i++)
         {
            // if (StringFind(ObjectName(currentChartID, i, -1, objType), baseName) >= 0)
            //    chartObjCount++;

            objName = ObjectName(currentChartID, i, -1, objType);
            baseNamePos = StringFind(objName, baseName);
            if(baseNamePos < 0) continue;
            objNumber = (int)StringSubstr(objName, baseNamePos + StringLen(baseName));
            if(objNumber > objCounter) objCounter = objNumber;
         }
         // if(objCounter < chartObjCount) objCounter = chartObjCount;
         currentChartID = ChartNext(currentChartID);
      }
      objCounter++;
   }

   //-- Removes all objects created by the class
   void ChartObj::EraseAllObjects(long chartId){
      for (int i = 0; i < ObjectsTotal(chartId); i++){
         string objName = ObjectName(chartId, i);
         if(StringFind(objName,BaseObjName))
            ObjectDelete(chartId, objName);
      }
   }
}