extern double stopLoss = 50;
extern double takeProfit = 100;
extern double traillingPip = 100;

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