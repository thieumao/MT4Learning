#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input int      Magic             = 137;
input double   volume            = 0.01;
double         newVolume         = 0.01;
input int      slPoint           = 200;
input int      tpPoint           = 600;
bool           enterSell         = false;
bool           enterBuy          = false;   
input int      MA1_period        = 10;
input int      MA2_period        = 29;
input int      MA3_period        = 51;
input int      MA50_period       = 50;

int OnInit() { return(INIT_SUCCEEDED); }

void OnDeinit(const int reason) {}

void OnTick() {
   int signal = -1; // no signal
   double MA1 = iMA(Symbol(),Period(),MA1_period,0,MODE_EMA,PRICE_CLOSE,0);
   double MA2 = iMA(Symbol(),Period(),MA2_period,0,MODE_EMA,PRICE_CLOSE,0);
   double MA3 = iMA(Symbol(),Period(),MA3_period,0,MODE_EMA,PRICE_CLOSE,0);
   double MA1_1 = iMA(Symbol(),Period(),MA1_period,0,MODE_EMA,PRICE_CLOSE,1);
   double MA2_1 = iMA(Symbol(),Period(),MA2_period,0,MODE_EMA,PRICE_CLOSE,1);
   double MA3_1 = iMA(Symbol(),Period(),MA3_period,0,MODE_EMA,PRICE_CLOSE,1);
   
   double MA50_1 = iMA(Symbol(),Period(),MA50_period,0,MODE_SMA,PRICE_CLOSE,1);
   double RSI_1  = iRSI(Symbol(),0,0,PRICE_CLOSE,1);
   double MA50_2 = iMA(Symbol(),Period(),MA50_period,0,MODE_SMA,PRICE_CLOSE,2);
   double RSI_2  = iRSI(Symbol(),0,0,PRICE_CLOSE,2);

   //if(MA1_1 > MA2_1 && MA1 < MA2 && MA1 < MA3 && MA2 < MA3 && MA3_1 > MA3) signal = OP_SELL;
   //if(MA1_1 < MA2_1 && MA1 > MA2 && MA1 > MA3 && MA2 > MA3 && MA3_1 < MA3) signal = OP_BUY;
   if (MA50_1 > 50 && RSI_1 > 50 && MA50_2 < MA50_1 && RSI_2 < RSI_1) signal = OP_BUY;
   if (MA50_1 < 50 && RSI_1 < 50 && MA50_2 > MA50_1 && RSI_2 > RSI_1) signal = OP_SELL;

   double lastProfit = getLastCommand(Symbol());
   if (lastProfit > 0) {
      newVolume = 0.01;
   } else {
      newVolume = lastLotSize * 2;
      //commandType = (lastType + 1) % 2;
   } 
  
  if (signal == OP_SELL) {
     if(CountOrders(OP_SELL,Magic)== 0 && enterSell == false) enterSell = true;
     if(enterSell == true){
       OrderSend(Symbol(),OP_SELL,newVolume,Bid,0,Bid + slPoint*Point,Bid - tpPoint*Point,NULL,Magic,0,clrRed);
       enterSell = false;
     }
  } else if (signal == OP_BUY) {
     if(CountOrders(OP_BUY,Magic)== 0 && enterBuy == false) enterBuy = true;
     if(enterBuy == true){
       OrderSend(Symbol(),OP_BUY,newVolume,Ask,0,Ask - slPoint*Point,Ask + tpPoint*Point,NULL,Magic,0,clrBlue);
       enterBuy = false;
     }
  }
}

int CountOrders(int type, int magic) {
   int count = 0;
   for (int i = OrdersTotal() - 1; i >= 0; i--) {
      RefreshRates();	
      if (OrderSelect(i, SELECT_BY_POS) == False) {
         continue;
      }
      if (OrderMagicNumber() != magic) {
         continue;
      }
      if (type == OP_BUY) {
         count++;
      } else if (type == OP_SELL) {
         count++;
      }
      continue;
   }
   return count;
}

double lastLotSize = 0.01;
int lastType = OP_BUY;
double getLastCommand(string symbol) {
   double lastProfit;
   datetime lastTime = 0;
   for (int i = 0; i <= OrdersHistoryTotal() - 1; i++) {
      //if (OrderSelect(i, SELECT_BY_POS) == False) { continue; }
      if (OrderSymbol() != symbol) { continue; }
      if (OrderMagicNumber() != Magic) { continue; }
      if (OrderType() > 1) { continue; }
      if (OrderCloseTime() > lastTime) {
         lastTime = OrderCloseTime();
         lastProfit = OrderProfit();
         lastLotSize = OrderLots();
         lastType = OrderType();
      }
   }
   return lastProfit;
}