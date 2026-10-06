import os

import psycopg2

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": int(os.getenv("DB_PORT", "5432")),
    "database": os.getenv("DB_NAME", "stock_screener"),
    "user": os.getenv("DB_USER", "postgres"),
    "password": os.environ.get("DB_PASSWORD", ""),
}


def get_connection():
    if not DB_CONFIG["password"]:
        raise RuntimeError("Set DB_PASSWORD in your environment before connecting to PostgreSQL.")
    return psycopg2.connect(**DB_CONFIG)