from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from backend.db import get_connection
from backend.screening import screen_stocks, screen_stocks_by_query

app = FastAPI(title="Stock Screener API")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "https://stock-screener-rouge.vercel.app"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def root():
    return {
        "message": "Stock Screener API is running"
    }


@app.get("/companies")
def get_companies():
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id, symbol, name, exchange, sector, industry
        FROM companies
        ORDER BY symbol;
    """)

    rows = cursor.fetchall()

    cursor.close()
    conn.close()

    return [
        {
            "id": row[0],
            "symbol": row[1],
            "name": row[2],
            "exchange": row[3],
            "sector": row[4],
            "industry": row[5]
        }
        for row in rows
    ]


@app.get("/screen")
def screen(
    max_pe: float | None = None,
    max_peg: float | None = None,
    min_revenue_growth: float | None = None,
    min_profit_growth: float | None = None,
    min_eps_growth: float | None = None,
    min_opm: float | None = None,
    min_roce: float | None = None,
    min_roe: float | None = None,
    max_debt_to_equity: float | None = None
):
    return screen_stocks(
        max_pe=max_pe,
        max_peg=max_peg,
        min_revenue_growth=min_revenue_growth,
        min_profit_growth=min_profit_growth,
        min_eps_growth=min_eps_growth,
        min_opm=min_opm,
        min_roce=min_roce,
        min_roe=min_roe,
        max_debt_to_equity=max_debt_to_equity
    )

@app.get("/screen-query")
def screen_query(query: str):
    try:
        return screen_stocks_by_query(query)
    except ValueError as e:
        return {
            "error": str(e)
        }

@app.get("/companies/{symbol}")
def get_company(symbol: str):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT
            c.id,
            c.symbol,
            c.name,
            c.isin,
            c.exchange,
            c.sector,
            c.industry,

            i.revenue,
            i.operating_profit,
            i.ebit,
            i.profit_before_tax,
            i.net_profit,
            i.eps,

            b.total_assets,
            b.total_equity,
            b.total_debt,
            b.cash_and_equivalents,

            cf.operating_cash_flow,
            cf.investing_cash_flow,
            cf.financing_cash_flow,
            cf.capital_expenditure,
            cf.free_cash_flow,

            r.pe_ratio,
            r.pb_ratio,
            r.peg_ratio,
            r.roe,
            r.roce,
            r.opm,
            r.npm,
            r.debt_to_equity,
            r.revenue_growth,
            r.profit_growth,
            r.eps_growth,
            r.altman_z,
            r.piotroski_score,

            m.last_price,
            m.previous_close,
            m.volume,
            m.market_cap,
            m.week_52_high,
            m.week_52_low

        FROM companies c

        LEFT JOIN financial_periods p
            ON c.id = p.company_id
            AND p.period_type = 'annual'
            AND p.fiscal_year = 2026

        LEFT JOIN income_statements i
            ON c.id = i.company_id
            AND i.period_id = p.id

        LEFT JOIN balance_sheets b
            ON c.id = b.company_id
            AND b.period_id = p.id

        LEFT JOIN cash_flows cf
            ON c.id = cf.company_id
            AND cf.period_id = p.id

        LEFT JOIN financial_ratios r
            ON c.id = r.company_id
            AND r.period_id = p.id

        LEFT JOIN market_data m
            ON c.id = m.company_id

        WHERE UPPER(c.symbol) = UPPER(%s)
    """, (symbol,))

    row = cursor.fetchone()

    cursor.close()
    conn.close()

    if row is None:
        return {"error": "Company not found"}

    return {
        "company": {
            "id": row[0],
            "symbol": row[1],
            "name": row[2],
            "isin": row[3],
            "exchange": row[4],
            "sector": row[5],
            "industry": row[6]
        },
        "income_statement": {
            "revenue": row[7],
            "operating_profit": row[8],
            "ebit": row[9],
            "profit_before_tax": row[10],
            "net_profit": row[11],
            "eps": row[12]
        },
        "balance_sheet": {
            "total_assets": row[13],
            "total_equity": row[14],
            "total_debt": row[15],
            "cash": row[16]
        },
        "cash_flow": {
            "operating_cash_flow": row[17],
            "investing_cash_flow": row[18],
            "financing_cash_flow": row[19],
            "capital_expenditure": row[20],
            "free_cash_flow": row[21]
        },
        "ratios": {
            "pe": row[22],
            "pb": row[23],
            "peg": row[24],
            "roe": row[25],
            "roce": row[26],
            "opm": row[27],
            "npm": row[28],
            "debt_to_equity": row[29],
            "revenue_growth": row[30],
            "profit_growth": row[31],
            "eps_growth": row[32],
            "altman_z": row[33],
            "piotroski_score": row[34]
        },
        "market_data": {
            "last_price": row[35],
            "previous_close": row[36],
            "volume": row[37],
            "market_cap": row[38],
            "week_52_high": row[39],
            "week_52_low": row[40]
        }
    }
