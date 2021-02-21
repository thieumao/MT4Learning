#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
// only for GBPUSD H1
input int      Magic             = 137;
input double   volume            = 0.01;
double         newVolume         = 0.01;
input int      slPoint           = 200;
input int      tpPoint           = 600;

input int      pointStart        = 290;
input int      pointTrailing     = 290; 
input int      pointStep         = 290;

bool           enterSell         = false;
bool           enterBuy          = false;   
input int      MA1_period        = 10;
input int      MA2_period        = 29;
input int      MA3_period        = 51;

datetime tradeTime;

int OnInit() { return(INIT_SUCCEEDED); }

void OnDeinit(const int reason) {}

void OnTick() {
/*
   if (iTime(Symbol(), 0, 0) == tradeTime) {
      return;
   }
   tradeTime = iTime(Symbol(), 0, 0);
   */

   int signal = -1; // no signal
   double MA1 = iMA(Symbol(),Period(),MA1_period,0,MODE_EMA,PRICE_CLOSE,0);
   double MA2 = iMA(Symbol(),Period(),MA2_period,0,MODE_EMA,PRICE_CLOSE,0);
   double MA3 = iMA(Symbol(),Period(),MA3_period,0,MODE_EMA,PRICE_CLOSE,0);
   double MA1_1 = iMA(Symbol(),Period(),MA1_period,0,MODE_EMA,PRICE_CLOSE,1);
   double MA2_1 = iMA(Symbol(),Period(),MA2_period,0,MODE_EMA,PRICE_CLOSE,1);
   double MA3_1 = iMA(Symbol(),Period(),MA3_period,0,MODE_EMA,PRICE_CLOSE,1);

   if(MA1_1 > MA2_1 && MA1 < MA2 && MA1 < MA3 && MA2 < MA3 && MA3_1 > MA3) signal = OP_SELL;
   if(MA1_1 < MA2_1 && MA1 > MA2 && MA1 > MA3 && MA2 > MA3 && MA3_1 < MA3) signal = OP_BUY;

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
  } else {
     //Trailling();
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

void Trailling() {
    double newSL, trail = pointTrailing * Point;
    
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) { continue; }
        if (OrderSymbol() != Symbol()) { continue; }
        if (OrderMagicNumber() != Magic) { continue; }

        if (OrderType() == OP_BUY) { newSL = Bid - trail; }
        else if (OrderType() == OP_SELL) { newSL = Ask + trail; }

        if (OrderType() == OP_BUY && OrderStopLoss() >= newSL) { continue; }
        if (OrderType() == OP_SELL && OrderStopLoss() <= newSL) { continue; }
       
        if (OrderType() == OP_BUY) {
           if (Bid > OrderOpenPrice() + pointStart * Point && Bid > OrderStopLoss() + (pointTrailing + pointStep) * Point)
            {
               OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), OrderExpiration(), Blue);
            }
        }
        
        if (OrderType() == OP_SELL) {
           if (Ask < OrderOpenPrice() + pointStart * Point && Ask < OrderStopLoss() + (pointTrailing + pointStep) * Point)
            {
               OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), OrderExpiration(), Blue);
            }
        }
        
        //OrderModify(OrderTicket(), OrdderOpenPrice(), newSL, OrderTakeProfit(), 0, CLR_NONE);

        if (GetLastError() != 0 && GetLastError() != 1) {
            Print("Error Trailling: " + GetLastError());
        }
    }
}
