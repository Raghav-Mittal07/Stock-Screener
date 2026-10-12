import { useState } from "react";
import "./App.css";
const API_URL = import.meta.env.VITE_API_URL || "http://127.0.0.1:8000";
const availableMetrics = {
  "Valuation": [
    ["P/E", "P/E < 20"],
    ["P/B", "P/B < 3"],
    ["PEG", "PEG < 1.5"],
    ["EV/EBITDA", "EV/EBITDA < 15"],
    ["EV/Sales", "EV/Sales < 5"],
    ["P/S", "P/S < 5"],
    ["Dividend Yield", "Dividend Yield > 2"],
  ],

  "Profitability": [
    ["ROE", "ROE > 15"],
    ["ROCE", "ROCE > 20"],
    ["ROA", "ROA > 10"],
    ["OPM", "OPM > 15"],
    ["NPM", "NPM > 10"],
    ["Gross Margin", "Gross Margin > 30"],
    ["EBITDA Margin", "EBITDA Margin > 20"],
  ],

  "Growth": [
    ["Revenue Growth", "Revenue Growth > 10"],
    ["Profit Growth", "Profit Growth > 15"],
    ["EPS Growth", "EPS Growth > 15"],
  ],

  "Financial Strength": [
    ["Debt/Equity", "Debt/Equity < 0.3"],
    ["Interest Coverage", "Interest Coverage > 5"],
    ["Current Ratio", "Current Ratio > 1.5"],
    ["Quick Ratio", "Quick Ratio > 1"],
    ["Debt/EBITDA", "Debt/EBITDA < 1"],
  ],

  "Cash Flow": [
    ["CFO/PAT", "CFO/PAT > 1"],
    ["CFO/Revenue", "CFO/Revenue > 10"],
    ["FCF Margin", "FCF Margin > 10"],
    ["Capex/Revenue", "Capex/Revenue < 10"],
  ],

  "Quality": [
    ["Altman Z", "Altman Z > 1.8"],
    ["Piotroski Score", "Piotroski Score > 7"],
  ],
};

function App() {
  

const [query, setQuery] = useState("");
  const [results, setResults] = useState([]);
  const [companyData, setCompanyData] = useState(null);
  const [loading, setLoading] = useState(false);
  const [companyLoading, setCompanyLoading] = useState(false);

  


const runQuery = async () => {
  if (!query.trim()) {
    return;
  }

  setLoading(true);
  setCompanyData(null);

  try {
    const response = await fetch(
      `${API_URL}/screen-query?query=${encodeURIComponent(query)}`
    );

    const data = await response.json();

    if (data.error) {
      alert(data.error);
      setResults([]);
    } else {
      setResults(data);
    }
  } catch (error) {
    console.error("Query screening error:", error);
    alert("Could not connect to the Stock Screener API.");
  }

  setLoading(false);
};

  const viewCompany = async (symbol) => {
    setCompanyLoading(true);

    try {
      const response = await fetch(
        `${API_URL}/companies/${symbol}`
      );

      const data = await response.json();
      setCompanyData(data);
    } catch (error) {
      console.error("Company data error:", error);
    }

    setCompanyLoading(false);
  };

  return (
    <div className="app">

      <header className="header">
        <h1>Stock Screener</h1>
        <p>Indian Equity Research & Screening Platform</p>
      </header>

      <main className="container">

        <section className="card">
  <h2>Screen Stocks</h2>

  <div className="query-section">
    <label>Custom Screening Query</label>

    <input
      type="text"
      className="query-input"
      placeholder="e.g. ROE > 15 AND P/E < 30"
      value={query}
      onChange={(event) => setQuery(event.target.value)}
    />

    <div className="query-actions">
  <button
    className="run-button"
    onClick={runQuery}
  >
    {loading ? "Screening..." : "Run Query"}
  </button>

  <details className="metrics-dropdown">
    <summary>Available Metrics</summary>

    <div className="metrics-menu">
      {Object.entries(availableMetrics).map(
        ([category, metrics]) => (
          <div
            className="metric-category"
            key={category}
          >
            <div className="metric-category-title">
              {category}
            </div>

            {metrics.map(([name, example]) => (
              <div
                className="metric-item"
                key={name}
              >
                <span>{name}</span>
                <code>{example}</code>
              </div>
            ))}
          </div>
        )
      )}
    </div>
  </details>
</div>
</div>


  

          

        </section>

        <section className="card">

          <h2>Screening Results</h2>

          {!loading && results.length === 0 && (
            <p>No companies match the selected criteria.</p>
          )}

          {results.length > 0 && (
  <div className="table-container">
    <table>
      <thead>
        <tr>
          <th>Symbol</th>
          <th>Company</th>

          <th>P/E</th>
          <th>P/B</th>
          <th>PEG</th>
          <th>EV/EBITDA</th>
          <th>EV/Sales</th>
          <th>P/S</th>
          <th>Div. Yield</th>

          <th>ROE</th>
          <th>ROCE</th>
          <th>ROA</th>
          <th>OPM</th>
          <th>NPM</th>
          <th>Gross Margin</th>
          <th>EBITDA Margin</th>

          <th>Revenue Growth</th>
          <th>Profit Growth</th>
          <th>EPS Growth</th>

          <th>D/E</th>
          <th>Interest Coverage</th>
          <th>Current Ratio</th>
          <th>Quick Ratio</th>
          <th>Debt/EBITDA</th>

          <th>CFO/PAT</th>
          <th>CFO/Revenue</th>
          <th>FCF Margin</th>
          <th>Capex/Revenue</th>

          <th>Altman Z</th>
          <th>Piotroski</th>
        </tr>
      </thead>

      <tbody>
        {results.map((stock) => (
          <tr key={stock.symbol}>

            <td>
              <button
                className="company-button"
                onClick={() => viewCompany(stock.symbol)}
              >
                {stock.symbol}
              </button>
            </td>

            <td>{stock.name}</td>

            {/* Valuation */}
            <td>{stock.pe?.toFixed(2) ?? "-"}</td>
            <td>{stock.pb?.toFixed(2) ?? "-"}</td>
            <td>{stock.peg?.toFixed(2) ?? "-"}</td>
            <td>{stock.ev_to_ebitda?.toFixed(2) ?? "-"}</td>
            <td>{stock.ev_to_sales?.toFixed(2) ?? "-"}</td>
            <td>{stock.price_to_sales?.toFixed(2) ?? "-"}</td>
            <td>
              {stock.dividend_yield != null
                ? `${stock.dividend_yield.toFixed(2)}%`
                : "-"}
            </td>

            {/* Profitability */}
            <td>
              {stock.roe != null ? `${stock.roe.toFixed(2)}%` : "-"}
            </td>
            <td>
              {stock.roce != null ? `${stock.roce.toFixed(2)}%` : "-"}
            </td>
            <td>
              {stock.roa != null ? `${stock.roa.toFixed(2)}%` : "-"}
            </td>
            <td>
              {stock.opm != null ? `${stock.opm.toFixed(2)}%` : "-"}
            </td>
            <td>
              {stock.npm != null ? `${stock.npm.toFixed(2)}%` : "-"}
            </td>
            <td>
              {stock.gross_margin != null
                ? `${stock.gross_margin.toFixed(2)}%`
                : "-"}
            </td>
            <td>
              {stock.ebitda_margin != null
                ? `${stock.ebitda_margin.toFixed(2)}%`
                : "-"}
            </td>

            {/* Growth */}
            <td>
              {stock.revenue_growth != null
                ? `${stock.revenue_growth.toFixed(2)}%`
                : "-"}
            </td>
            <td>
              {stock.profit_growth != null
                ? `${stock.profit_growth.toFixed(2)}%`
                : "-"}
            </td>
            <td>
              {stock.eps_growth != null
                ? `${stock.eps_growth.toFixed(2)}%`
                : "-"}
            </td>

            {/* Financial strength */}
            <td>
              {stock.debt_to_equity != null
                ? stock.debt_to_equity.toFixed(2)
                : "-"}
            </td>
            <td>
              {stock.interest_coverage != null
                ? stock.interest_coverage.toFixed(2)
                : "-"}
            </td>
            <td>
              {stock.current_ratio != null
                ? stock.current_ratio.toFixed(2)
                : "-"}
            </td>
            <td>
              {stock.quick_ratio != null
                ? stock.quick_ratio.toFixed(2)
                : "-"}
            </td>
            <td>
              {stock.debt_to_ebitda != null
                ? stock.debt_to_ebitda.toFixed(2)
                : "-"}
            </td>

            {/* Cash flow */}
            <td>
              {stock.cfo_to_pat != null
                ? stock.cfo_to_pat.toFixed(2)
                : "-"}
            </td>
            <td>
              {stock.cfo_to_revenue != null
                ? `${stock.cfo_to_revenue.toFixed(2)}%`
                : "-"}
            </td>
            <td>
              {stock.fcf_margin != null
                ? `${stock.fcf_margin.toFixed(2)}%`
                : "-"}
            </td>
            <td>
              {stock.capex_to_revenue != null
                ? `${stock.capex_to_revenue.toFixed(2)}%`
                : "-"}
            </td>

            {/* Quality */}
            <td>
              {stock.altman_z != null
                ? stock.altman_z.toFixed(2)
                : "-"}
            </td>
            <td>
              {stock.piotroski_score != null
                ? stock.piotroski_score
                : "-"}
            </td>

          </tr>
        ))}
      </tbody>
    </table>
  </div>
)}

        </section>

        {companyLoading && (
          <section className="card">
            <p>Loading company research...</p>
          </section>
        )}

        {companyData && (
          <section className="card">

            <h2>
              {companyData.company.name} (
              {companyData.company.symbol}
              )
            </h2>

            <p>
              {companyData.company.sector} ·{" "}
              {companyData.company.industry}
            </p>

            <h3>Income Statement</h3>

            <div className="research-grid">

              <div className="metric">
                <div className="metric-title">
                  Revenue
                </div>

                <div className="metric-value">
                  {companyData.income_statement.revenue}
                </div>
              </div>

              <div className="metric">
                <div className="metric-title">
                  Operating Profit
                </div>

                <div className="metric-value">
                  {companyData.income_statement.operating_profit}
                </div>
              </div>

              <div className="metric">
                <div className="metric-title">
                  Net Profit
                </div>

                <div className="metric-value">
                  {companyData.income_statement.net_profit}
                </div>
              </div>

              <div className="metric">
                <div className="metric-title">
                  EPS
                </div>

                <div className="metric-value">
                  {companyData.income_statement.eps}
                </div>
              </div>

            </div>

            <h3>Balance Sheet</h3>

            <div className="research-grid">

              <div className="metric">
                <div className="metric-title">
                  Total Assets
                </div>

                <div className="metric-value">
                  {companyData.balance_sheet.total_assets}
                </div>
              </div>

              <div className="metric">
                <div className="metric-title">
                  Total Equity
                </div>

                <div className="metric-value">
                  {companyData.balance_sheet.total_equity}
                </div>
              </div>

              <div className="metric">
                <div className="metric-title">
                  Total Debt
                </div>

                <div className="metric-value">
                  {companyData.balance_sheet.total_debt}
                </div>
              </div>

              <div className="metric">
                <div className="metric-title">
                  Cash
                </div>

                <div className="metric-value">
                  {companyData.balance_sheet.cash}
                </div>
              </div>

            </div>

            <h3>Cash Flow</h3>

            <div className="research-grid">

              <div className="metric">
                <div className="metric-title">
                  Operating Cash Flow
                </div>

                <div className="metric-value">
                  {companyData.cash_flow.operating_cash_flow}
                </div>
              </div>

              <div className="metric">
                <div className="metric-title">
                  Free Cash Flow
                </div>

                <div className="metric-value">
                  {companyData.cash_flow.free_cash_flow}
                </div>
              </div>

            </div>

            <h3>Key Ratios</h3>

            <div className="research-grid">

              <div className="metric">
                <div className="metric-title">
                  P/E
                </div>

                <div className="metric-value">
                  {companyData.ratios.pe}
                </div>
              </div>

              <div className="metric">
                <div className="metric-title">
                  PEG
                </div>

                <div className="metric-value">
                  {companyData.ratios.peg}
                </div>
              </div>

              <div className="metric">
                <div className="metric-title">
                  ROE
                </div>

                <div className="metric-value">
                  {companyData.ratios.roe}%
                </div>
              </div>

              <div className="metric">
                <div className="metric-title">
                  ROCE
                </div>

                <div className="metric-value">
                  {companyData.ratios.roce}%
                </div>
              </div>

              <div className="metric">
                <div className="metric-title">
                  OPM
                </div>

                <div className="metric-value">
                  {companyData.ratios.opm}%
                </div>
              </div>

              <div className="metric">
                <div className="metric-title">
                  Debt/Equity
                </div>

                <div className="metric-value">
                  {companyData.ratios.debt_to_equity}
                </div>
              </div>

            </div>

            <h3>Market Data</h3>

            <div className="research-grid">

              <div className="metric">
                <div className="metric-title">
                  Last Price
                </div>

                <div className="metric-value">
                  {companyData.market_data.last_price}
                </div>
              </div>

              <div className="metric">
                <div className="metric-title">
                  Market Cap
                </div>

                <div className="metric-value">
                  {companyData.market_data.market_cap}
                </div>
              </div>

              <div className="metric">
                <div className="metric-title">
                  52 Week High
                </div>

                <div className="metric-value">
                  {companyData.market_data.week_52_high}
                </div>
              </div>

              <div className="metric">
                <div className="metric-title">
                  52 Week Low
                </div>

                <div className="metric-value">
                  {companyData.market_data.week_52_low}
                </div>
              </div>

            </div>

          </section>
        )}

      </main>

    </div>
  );
}

export default App;