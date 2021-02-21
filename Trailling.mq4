extern double stopLoss = 50;
extern double takeProfit = 100;
extern double traillingPip = 100;
int Magic = 137;

void OnTick() {
    Trailling(traillingPip);
}

void Trailling(double trail) {
    double newSL; trail *= 10 * Point;
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) { continue; }
        if (OrderSymbol() != Symbol()) { continue; }
        if (OrderMagicNumber() != Magic) { continue; }

        if (OrderType() == OP_BUY) { newSL = Ask - trail; }
        else if (OrderType() == OP_SELL) { newSL = Bid + trail; }

        if (OrderType() == OP_BUY && OrderStopLoss() >= newSL) { continue; }
        if (OrderType() == OP_SELL && OrderStopLoss() <= newSL) { continue; }

        OrderModify(OrderTicket(), OrdderOpenPrice(), newSL, OrderTakeProfit(), 0, CLR_NONE);

        if (GetLastError() != 0 && GetLastError != 1) {
            Print("Error Trailling: " + GetLastError(););
        }
    }
}

void TrailingStopbyPoint(int PointStart, int PointTrailing, int PointStep, int magic) {
    for (int i = 0; i <= OrdersTotal() - 1; i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if ((OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)) // || (OrderSymbol()==Symbol() && bool_TrailingOrderHand))
            {
                if (OrderType() == OP_BUY) {
                    if (Bid > OrderOpenPrice() + PointStart * Point // + MathAbs((OrderSwap() + OrderCommission())/OrderLots())*Point
                        && Bid > OrderStopLoss() + (Pointtrailing + PointStep) * Point)
                    {
                        bool tam = OrderModify(OrderTicket(), OrderOpenPrice(), Bid - PointTrailing * Point, OrderTakeProfit(), OrderExpiration(), Blue);
                        //double M_min_to_Point = (OrderSwap() + OrderCommission())/OrderLots(); 
                        //TextCreateCoToaDo_2(0,"da trailing","trailing"+ " : " + DoubleToStr(((OrderSwap() + OrderCommission())/OrderLots()),Digits) ,"Arial",17,1,5,155,Blue);
                    }
                }

                if (OrderType() == OP_SELL) {
                    double CreateSL = NormalizeDouble(Ask + 100 * PointStart * Point, Digits);
                    if (OrderStopLoss() == 0) {
                        if (!OrderModify(OrderTicket(), OrderOpenPrice(), CreateSL, OrderTakeProfit(), OrderExpiration(), clrGreenYellow))
	                        Print("OrderModify - Buy has been ended with an error #",GetLastError());} 
                        if (Ask < OrderOpenPrice() - PointStart * Point // - MathAbs((OrderSwap() + OrderCommission())/OrderLots())*Point
                            && Ask<OrderStopLoss() - (Pointtrailing) * Point)
                        {
                            sl = NormalizeDouble(Ask + Pointtrailing * Point(), Digits);
                            bool tam = OrderModify(OrderTicket(), OrderOpenPrice(), sl, OrderTakeProfit(), OrderExpiration(), clrGreenYellow);
                            //TextCreateCoToaDo_2(0,"SL","trailingSL"+ " : " + DoubleToStr(sl,Digits) ,"Arial",17,1,5,125,Blue);
                        }
                }
            }
        }
    }
}