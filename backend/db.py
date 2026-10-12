import os

import pymysql

DB_CONFIG = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": int(os.getenv("DB_PORT", "3306")),
    "database": os.getenv("DB_NAME", "stock_screener"),
    "user": os.getenv("DB_USER", "root"),
    "password": os.environ.get("DB_PASSWORD", ""),
    "ssl_ca": os.getenv("DB_SSL_CA", None),
}


def get_connection():
    if not DB_CONFIG["password"]:
        raise RuntimeError("Set DB_PASSWORD in your environment before connecting MySQL.")
    return pymysql.connect(**DB_CONFIG)
