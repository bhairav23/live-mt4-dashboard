//+------------------------------------------------------------------+
//| WriteAccountDataToFile.mq4                                       |
//+------------------------------------------------------------------+
#property strict

// Define symbols to track
string symbols[] = {"EURUSD", "GBPUSD", "USDJPY", "USDCHF", "NZDUSD", "USDCAD", "AUDUSD"};

int OnInit()
{
   EventSetTimer(1); // Run every 1 second
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer();
}

void OnTimer()
{
   string json = "{\n";
   json += "\"terminal\": \"" + IntegerToString(AccountNumber()) + "\",\n";
   json += "\"timestamp\": \"" + TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) + "\",\n";
   json += "\"data\": {\n";

   // Totals for 'All' row
   double all_pnl = 0;
   double all_buy_lots = 0;
   double all_sell_lots = 0;
   int all_buy_pos = 0;
   int all_sell_pos = 0;
   int all_total_pos = 0;

   for (int i = -1; i < ArraySize(symbols); i++)
   {
      string sym = (i == -1) ? "All" : symbols[i];
      double pnl = 0;
      double buy_lots = 0;
      double sell_lots = 0;
      int buy_pos = 0;
      int sell_pos = 0;
      int total_pos = 0;
      double weighted_buy_price = 0;
      double weighted_sell_price = 0;

      for (int j = 0; j < OrdersTotal(); j++)
      {
         if (OrderSelect(j, SELECT_BY_POS, MODE_TRADES))
         {
            string ord_sym = OrderSymbol();
            int type = OrderType();
            if ((i == -1) || (ord_sym == sym))
            {
               double lots = OrderLots();
               double price = OrderOpenPrice();

               // ✅ New correct net PnL calculation:
               double order_pnl = OrderProfit() + OrderCommission() + OrderSwap();

               pnl += order_pnl;

               if (type == OP_BUY)
               {
                  buy_lots += lots;
                  buy_pos++;
                  weighted_buy_price += price * lots;
               }
               else if (type == OP_SELL)
               {
                  sell_lots += lots;
                  sell_pos++;
                  weighted_sell_price += price * lots;
               }
               total_pos++;
            }
         }
      }

      double total_lots = buy_lots + sell_lots;

      string be_price_str = "\"N/A\"";
      if (sym != "All" && total_lots > 0)
      {
         double net_lots = buy_lots - sell_lots;

         if (MathAbs(net_lots) > 0.00001)
         {
            double avg_buy_price = (buy_lots > 0) ? (weighted_buy_price / buy_lots) : 0;
            double avg_sell_price = (sell_lots > 0) ? (weighted_sell_price / sell_lots) : 0;

            double be_price = (buy_lots * avg_buy_price + sell_lots * avg_sell_price) / total_lots;
            be_price_str = DoubleToString(be_price, MarketInfo(sym, MODE_DIGITS));
         }
      }

      if (sym == "All")
      {
         pnl = all_pnl;
         buy_lots = all_buy_lots;
         sell_lots = all_sell_lots;
         total_lots = buy_lots + sell_lots;
         buy_pos = all_buy_pos;
         sell_pos = all_sell_pos;
         total_pos = all_total_pos;
         be_price_str = "\"N/A\"";
      }
      else
      {
         all_pnl += pnl;
         all_buy_lots += buy_lots;
         all_sell_lots += sell_lots;
         all_buy_pos += buy_pos;
         all_sell_pos += sell_pos;
         all_total_pos += total_pos;
      }

      json += "\"" + sym + "\": {";
      json += "\"pnl\": " + DoubleToString(pnl, 2) + ",";
      json += "\"be_price\": " + be_price_str + ",";
      json += "\"buy_lots\": " + DoubleToString(buy_lots, 2) + ",";
      json += "\"sell_lots\": " + DoubleToString(sell_lots, 2) + ",";
      json += "\"total_lots\": " + DoubleToString(total_lots, 2) + ",";
      json += "\"buy_pos\": " + buy_pos + ",";
      json += "\"sell_pos\": " + sell_pos + ",";
      json += "\"total_pos\": " + total_pos;
      json += "}";

      if (i < ArraySize(symbols) - 1)
         json += ",";
      json += "\n";
   }

   json += "}\n";
   json += "}";

   string filename = "Terminal_" + IntegerToString(AccountNumber()) + ".json";
   int handle = FileOpen(filename, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if (handle != INVALID_HANDLE)
   {
      FileWrite(handle, json);
      FileClose(handle);
   }
}

//+------------------------------------------------------------------+
