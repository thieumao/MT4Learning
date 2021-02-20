#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input int      Magic             = 0;
input double   khoiluong         = 0.01;
input int      sodiemSL          = 100;
input int      sodiemTP          = 200;
bool           vaolenhSELL       = false;
bool           vaolenhBUY        = false;
input int      epsilon_inp       = 20; //epsilon Point    
input double    tile_doji        = 5.5;// Ti Le DoJi  
input double   tile_pinbar       = 3;    
input int      MA1_period        = 9;
input int      MA2_period        = 17;
input int      MA3_period        = 51;

int OnInit() { return(INIT_SUCCEEDED); }

void OnDeinit(const int reason) {}

void OnTick() {
  string Signal = "";
  double MA1 = iMA(Symbol(),Period(),MA1_period,0,MODE_EMA,PRICE_CLOSE,0);
  double MA2 = iMA(Symbol(),Period(),MA2_period,0,MODE_EMA,PRICE_CLOSE,0);
  double MA3 = iMA(Symbol(),Period(),MA3_period,0,MODE_EMA,PRICE_CLOSE,0);
  double MA1_1 = iMA(Symbol(),Period(),MA1_period,0,MODE_EMA,PRICE_CLOSE,1);
  double MA2_1 = iMA(Symbol(),Period(),MA2_period,0,MODE_EMA,PRICE_CLOSE,1);
  double MA3_1 = iMA(Symbol(),Period(),MA3_period,0,MODE_EMA,PRICE_CLOSE,1);

  if(MA1_1 > MA2_1 && MA1 < MA2 && MA1 < MA3 && MA2 < MA3 && MA3_1 > MA3) Signal = "OP_SELL";
  if(MA1_1 < MA2_1 && MA1 > MA2 && MA1 > MA3 && MA2 > MA3 && MA3_1 < MA3) Signal = "OP_BUY";

  // --- VAO LENH      
  if(CountOrders("OP_SELL",Magic)== 0 && vaolenhSELL == false) vaolenhSELL = true;
  if(Signal == "OP_SELL" && vaolenhSELL == true){
    int Go = OrderSend(Symbol(),OP_SELL,khoiluong,Bid,0,Bid + sodiemSL*Point,Bid - sodiemTP*Point,NULL,Magic,0,clrRed);
    vaolenhSELL = false;
  }

  if(CountOrders("OP_BUY",Magic)== 0 && vaolenhBUY == false) vaolenhBUY = true;
  if(Signal == "OP_BUY" && vaolenhBUY == true){
    int Go = OrderSend(Symbol(),OP_BUY,khoiluong,Ask,0,Ask - sodiemSL*Point,Ask + sodiemTP*Point,NULL,Magic,0,clrBlue);
    vaolenhBUY = false;
  }
}

string Nen (int thutunen){
  if(Open[thutunen]<Close[thutunen]) return "Nen_Tang";
  else return "Nen_Giam";
}

int CountOrders(string type, int magic) {
  int count = 0;
  for (int i = OrdersTotal() - 1; i >= 0; i--){
	  RefreshRates();	 	
	  if(OrderSelect(i,SELECT_BY_POS)){
	    if(OrderMagicNumber() == magic && OrderSymbol() == Symbol()){
	         if(type=="All")
	            count ++;
	         if(type=="AllLimitStop" && OrderType()>1)
	            count ++;
	         if(type=="OP_BUY" && OrderType()==0)
	            count ++;
	         if(type=="OP_SELL" && OrderType()==1)
	            count ++;
	         if(type=="OP_BUYLIMIT" && OrderType()==2)
	            count ++;
	         if(type=="OP_SELLLIMIT" && OrderType()==3)
	            count ++;
	         if(type=="OP_BUYSTOP" && OrderType()==4)
	            count ++;
	         if(type=="OP_SELLSTOP" && OrderType()==5)
	            count ++;
	    }
	    if(OrderSymbol() == Symbol()){
	         if(type=="AllAllOneSymbol")
	            count ++;
	         if(type=="AllLimitStopOneSymbol" && OrderType()>1)
	            count ++;
	         if(type=="OP_BUYOneSymbol" && OrderType()==0)
	            count ++;
	         if(type=="OP_SELLOneSymbol" && OrderType()==1)
	            count ++;
	         if(type=="OP_BUYLIMITOneSymbol" && OrderType()==2)
	            count ++;
	         if(type=="OP_SELLLIMITOneSymbol" && OrderType()==3)
	            count ++;
	         if(type=="OP_BUYSTOPOneSymbol" && OrderType()==4)
	            count ++;
	         if(type=="OP_SELLSTOPOneSymbol" && OrderType()==5)
	            count ++;
	    }
	    if(type=="AllAllAll")
	      count ++;
	  }	
	}   
  return count;
}

bool NewCandle() {
  static datetime NewBar=0; bool re=false;
  if(Time[0]!=NewBar) {
    NewBar=Time[0]; re=true;
  }
  return re;
}