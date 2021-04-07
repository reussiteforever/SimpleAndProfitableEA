#property copyright "Abdel-Khafid ATOKOU"
#property version   "1.00"

// STRATEGY INSPIRED FROM RENE BALK STRATEGY

#include<Trade/Trade.mqh>

//H1 variables
int handleTrendMaFast;
int handleTrendMaSlow;

//M5 variables
int handleMaFast;
int handleMaSlow;
int handleMaMiddle;

CTrade trade;
int eaMagic = 2;

int OnInit()
  {
   trade.SetExpertMagicNumber(eaMagic);
   
   handleTrendMaFast = iMA(_Symbol,PERIOD_H2,8,0,MODE_EMA,PRICE_CLOSE);
   handleTrendMaSlow = iMA(_Symbol,PERIOD_H2,21,0,MODE_EMA,PRICE_CLOSE);
   
   handleMaFast = iMA(_Symbol,PERIOD_M5,8,0,MODE_EMA,PRICE_CLOSE);
   handleMaMiddle = iMA(_Symbol,PERIOD_M5,13,0,MODE_EMA,PRICE_CLOSE);
   handleMaSlow = iMA(_Symbol,PERIOD_M5,21,0,MODE_EMA,PRICE_CLOSE);
   
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {

  }

void OnTick()
  {
   double maTrendFast[], maTrendSlow[];
   CopyBuffer(handleTrendMaFast,0,0,1,maTrendFast);
   CopyBuffer(handleTrendMaSlow,0,0,1,maTrendSlow);
   
   double maFast[], maMiddle[], maSlow[];
   CopyBuffer(handleMaFast,0,0,1,maFast);
   CopyBuffer(handleMaMiddle,0,0,1,maMiddle);
   CopyBuffer(handleMaSlow,0,0,1,maSlow);
   
   double bid = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID),_Digits);
   static double lastBid = bid;
   
   int trendDirection = 0;
   if(maTrendFast[0] > maTrendSlow[0] && bid > maTrendFast[0])
     {
      trendDirection = 1;
     }else if(maTrendFast[0] < maTrendSlow[0] && bid < maTrendFast[0])
        {
         trendDirection = -1;
        }   
        
    // COMPTER LE NOMBRE DE POSITIONS OUVERT
    int positions = nombrePositions();
    
    //COMPTER LE NOMBRE D'ORDRES OUVERTS
    int orders = ordersNumber();
        
    if(trendDirection == 1)
      {
       if(maFast[0] > maMiddle[0] && maMiddle[0] > maSlow[0])
         {
          if(bid <= maFast[0] && lastBid > maFast[0])
            {
             if(positions + orders <=0)
               {
                int indexHighest = iHighest(_Symbol,PERIOD_M5,MODE_HIGH,5,1);
                double highPrice = iHigh(_Symbol,PERIOD_M5,indexHighest);
                highPrice = NormalizeDouble(highPrice,_Digits);
                
                double sl = iLow(_Symbol,PERIOD_M5,0) - 3000;
                sl = NormalizeDouble(sl,_Digits);
                
                int indexLowest = iLowest(_Symbol,PERIOD_M5,MODE_LOW,5,1);
                double lowPrice = iLow(_Symbol,PERIOD_M5,indexLowest);
                lowPrice = NormalizeDouble(lowPrice,_Digits);
                
                double tp = highPrice + (highPrice-lowPrice);
                tp = NormalizeDouble(tp,_Digits);
                //trade.BuyStop(0.001,highPrice,_Symbol,lowPrice,tp);
                trade.BuyStop(0.002,highPrice,_Symbol,lowPrice,tp);
               }
            }
         }
      }else if(trendDirection == -1){
       if(maFast[0] < maMiddle[0] && maMiddle[0] < maSlow[0])
         {
          if(bid>=maFast[0] && lastBid < maFast[0])
            {
             if(positions + orders <=0)
               {
                int indexHighest = iHighest(_Symbol,PERIOD_M5,MODE_HIGH,5,1);
                double highPrice = iHigh(_Symbol,PERIOD_M5,indexHighest);
                highPrice = NormalizeDouble(highPrice,_Digits);
                
                //REAL SL
                double sl = iHigh(_Symbol,PERIOD_M5,0) + 3000;
                sl = NormalizeDouble(sl,_Digits);
                  
                //SETUP OF INITIAL SL
                int indexLowest = iLowest(_Symbol,PERIOD_M5,MODE_LOW,5,1);
                double lowPrice = iLow(_Symbol,PERIOD_M5,indexLowest);
                lowPrice = NormalizeDouble(lowPrice,_Digits);
                
                double tp = lowPrice - (highPrice-lowPrice);
                tp = NormalizeDouble(tp,_Digits);
                trade.SellStop(0.001,lowPrice,_Symbol,highPrice,tp);
                //trade.SellStop(0.001,lowPrice,_Symbol,highPrice,tp);
               }
            }
         }
      }
      
   
   lastBid = bid;
   Comment(maTrendFast[0],"\n",maTrendSlow[0],"\n Trend Direction ", trendDirection);
  }
  
  
  // FONCTION POUR COMPTER LE NOMBRE DE POSITIONS OUVERT
  int nombrePositions(){
   int positions = 0;
   for(int i=0;i<PositionsTotal()-1;i++)
     {
     ulong posTicket = PositionGetTicket(i);
      if(PositionSelectByTicket(posTicket))
        {
         if(PositionGetString(POSITION_SYMBOL)==_Symbol && PositionGetInteger(POSITION_MAGIC)==eaMagic)
           {
            positions++;
           }
        }
     }
     return positions;
  }
  
  //FONCTION POUR COMPTER LE NOMBRE D'ORDRES OUVERTS
  int ordersNumber(){
   int orders = 0;
   for(int i=0;i<OrdersTotal()-1;i++)
     {
     ulong orderTicket = OrderGetTicket(i);
      if(OrderSelect(orderTicket))
        {
         if(OrderGetString(ORDER_SYMBOL)==_Symbol && OrderGetInteger(ORDER_MAGIC)==eaMagic)
           {
            orders++;
           }
        }
     }
     return orders;
  }
