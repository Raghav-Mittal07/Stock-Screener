
import re

from backend.db import get_connection



METRIC_COLUMNS = {
    # Valuation
    "pe": "r.pe_ratio",
    "p/e": "r.pe_ratio",
    "pb": "r.pb_ratio",
    "p/b": "r.pb_ratio",
    "peg": "r.peg_ratio",
    "ev/ebitda": "r.ev_to_ebitda",
    "ev to ebitda": "r.ev_to_ebitda",
    "ev/sales": "r.ev_to_sales",
    "ev to sales": "r.ev_to_sales",
    "price/sales": "r.price_to_sales",
    "price to sales": "r.price_to_sales",
    "p/s": "r.price_to_sales",
    "dividend yield": "r.dividend_yield",
    "dividend_yield": "r.dividend_yield",

    # Profitability
    "roe": "r.roe",
    "roce": "r.roce",
    "roa": "r.roa",
    "opm": "r.opm",
    "npm": "r.npm",
    "net profit margin": "r.npm",
    "gross margin": "r.gross_margin",
    "ebitda margin": "r.ebitda_margin",

    # Growth
    "revenue growth": "r.revenue_growth",
    "sales growth": "r.revenue_growth",
    "profit growth": "r.profit_growth",
    "pat growth": "r.profit_growth",
    "eps growth": "r.eps_growth",

    # Financial strength
    "debt/equity": "r.debt_to_equity",
    "d/e": "r.debt_to_equity",
    "interest coverage": "r.interest_coverage",
    "current ratio": "r.current_ratio",
    "quick ratio": "r.quick_ratio",
    "debt/ebitda": "r.debt_to_ebitda",

    # Cash flow
    "cfo/pat": "r.cfo_to_pat",
    "cfo/revenue": "r.cfo_to_revenue",
    "fcf margin": "r.fcf_margin",
    "capex/revenue": "r.capex_to_revenue",

    # Quality
    "altman z": "r.altman_z",
    "piotroski": "r.piotroski_score",
    "piotroski score": "r.piotroski_score",
}

def parse_screen_query(query):
    """
    Converts a user query such as:

        ROE > 15 AND P/E < 20
        ROE > 30 OR P/E < 20

    into SQL conditions and parameters.
    """

    if not query or not query.strip():
        raise ValueError("Query cannot be empty.")

    # Split into OR groups first.
    or_groups = re.split(
        r"\s+OR\s+",
        query.strip(),
        flags=re.IGNORECASE
    )

    sql_groups = []
    params = []

    for group in or_groups:

        # Each OR group can contain multiple AND conditions.
        and_parts = re.split(
            r"\s+AND\s+",
            group.strip(),
            flags=re.IGNORECASE
        )

        conditions = []

        for part in and_parts:

            match = re.match(
                r"^\s*(.+?)\s*(>=|<=|>|<|=)\s*(-?\d+(?:\.\d+)?)\s*%?\s*$",
                part,
                flags=re.IGNORECASE
            )

            if not match:
                raise ValueError(
                    f"Could not understand condition: '{part}'. "
                    "Use format like: ROE > 15"
                )

            metric = match.group(1).strip().lower()
            operator = match.group(2)
            value = float(match.group(3))

            if metric not in METRIC_COLUMNS:
                raise ValueError(
                    f"Unsupported metric: '{metric}'"
                )

            column = METRIC_COLUMNS[metric]

            conditions.append(
                f"{column} {operator} %s"
            )

            params.append(value)

        sql_groups.append(
            "(" + " AND ".join(conditions) + ")"
        )

    return " OR ".join(sql_groups), params


def screen_stocks(
    max_pe=None,
    max_peg=None,
    min_revenue_growth=None,
    min_profit_growth=None,
    min_eps_growth=None,
    min_opm=None,
    min_roce=None,
    min_roe=None,
    max_debt_to_equity=None
):
    conn = get_connection()
    cursor = conn.cursor()

    query = """
        SELECT
            c.symbol,
            c.name,
            r.pe_ratio,
            r.peg_ratio,
            r.revenue_growth,
            r.profit_growth,
            r.eps_growth,
            r.opm,
            r.roce,
            r.roe,
            r.debt_to_equity
        FROM companies c
        JOIN financial_ratios r
            ON c.id = r.company_id
        JOIN financial_periods p
            ON r.period_id = p.id
        WHERE p.period_type = 'annual'
          AND p.fiscal_year = 2026
    """

    params = []

    if max_pe is not None:
        query += " AND r.pe_ratio <= %s"
        params.append(max_pe)

    if max_peg is not None:
        query += " AND r.peg_ratio <= %s"
        params.append(max_peg)

    if min_revenue_growth is not None:
        query += " AND r.revenue_growth >= %s"
        params.append(min_revenue_growth)

    if min_profit_growth is not None:
        query += " AND r.profit_growth >= %s"
        params.append(min_profit_growth)

    if min_eps_growth is not None:
        query += " AND r.eps_growth >= %s"
        params.append(min_eps_growth)

    if min_opm is not None:
        query += " AND r.opm >= %s"
        params.append(min_opm)

    if min_roce is not None:
        query += " AND r.roce >= %s"
        params.append(min_roce)

    if min_roe is not None:
        query += " AND r.roe >= %s"
        params.append(min_roe)

    if max_debt_to_equity is not None:
        query += " AND r.debt_to_equity <= %s"
        params.append(max_debt_to_equity)

    query += " ORDER BY c.symbol"

    cursor.execute(query, params)
    rows = cursor.fetchall()

    cursor.close()
    conn.close()

    return [
        {
            "symbol": row[0],
            "name": row[1],
            "pe": row[2],
            "peg": row[3],
            "revenue_growth": row[4],
            "profit_growth": row[5],
            "eps_growth": row[6],
            "opm": row[7],
            "roce": row[8],
            "roe": row[9],
            "debt_to_equity": row[10]
        }
        for row in rows
    ]

def screen_stocks_by_query(query_text):
    sql_condition, params = parse_screen_query(query_text)
    conn = get_connection()
    cursor = conn.cursor()

    query = """
        SELECT
    c.symbol,
    c.name,

    -- Valuation
    r.pe_ratio,
    r.pb_ratio,
    r.peg_ratio,
    r.ev_to_ebitda,
    r.ev_to_sales,
    r.price_to_sales,
    r.dividend_yield,

    -- Profitability
    r.roe,
    r.roce,
    r.roa,
    r.opm,
    r.npm,
    r.gross_margin,
    r.ebitda_margin,

    -- Growth
    r.revenue_growth,
    r.profit_growth,
    r.eps_growth,

    -- Financial strength
    r.debt_to_equity,
    r.interest_coverage,
    r.current_ratio,
    r.quick_ratio,
    r.debt_to_ebitda,

    -- Cash flow
    r.cfo_to_pat,
    r.cfo_to_revenue,
    r.fcf_margin,
    r.capex_to_revenue,

    -- Quality
    r.altman_z,
    r.piotroski_score

        FROM companies c
        JOIN financial_ratios r
            ON c.id = r.company_id
        JOIN financial_periods p
            ON r.period_id = p.id
        WHERE p.period_type = 'annual'
          AND p.fiscal_year = 2026
    """

    query += " AND (" + sql_condition + ")"

    query += " ORDER BY c.symbol"

    cursor.execute(query, params)
    rows = cursor.fetchall()

    cursor.close()
    conn.close()

    return [
    {
        "symbol": row[0],
        "name": row[1],

        # Valuation
        "pe": row[2],
        "pb": row[3],
        "peg": row[4],
        "ev_to_ebitda": row[5],
        "ev_to_sales": row[6],
        "price_to_sales": row[7],
        "dividend_yield": row[8],

        # Profitability
        "roe": row[9],
        "roce": row[10],
        "roa": row[11],
        "opm": row[12],
        "npm": row[13],
        "gross_margin": row[14],
        "ebitda_margin": row[15],

        # Growth
        "revenue_growth": row[16],
        "profit_growth": row[17],
        "eps_growth": row[18],

        # Financial strength
        "debt_to_equity": row[19],
        "interest_coverage": row[20],
        "current_ratio": row[21],
        "quick_ratio": row[22],
        "debt_to_ebitda": row[23],

        # Cash flow
        "cfo_to_pat": row[24],
        "cfo_to_revenue": row[25],
        "fcf_margin": row[26],
        "capex_to_revenue": row[27],

        # Quality
        "altman_z": row[28],
        "piotroski_score": row[29],
    }
    for row in rows
]