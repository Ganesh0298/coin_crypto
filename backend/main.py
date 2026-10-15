import os

import httpx
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException, Query

load_dotenv(os.path.join(os.path.dirname(__file__), ".env"))

app = FastAPI(title="Coin Pilot API")

BASE_URL = "https://api.coingecko.com/api/v3"
API_KEY = os.getenv("COINGECKO_API_KEY")


async def fetch_data(path, params=None):
    if not API_KEY:
        raise HTTPException(500, "API key is missing")

    try:
        async with httpx.AsyncClient(timeout=20) as client:
            response = await client.get(
                f"{BASE_URL}{path}",
                params=params or {},
                headers={"x-cg-demo-api-key": API_KEY},
            )

        if response.status_code == 429:
            raise HTTPException(429, "API rate limit reached")

        response.raise_for_status()
        return response.json()

    except httpx.HTTPStatusError as exc:
        raise HTTPException(
            502, "Crypto data provider returned an error"
        ) from exc
    except httpx.RequestError as exc:
        raise HTTPException(
            502, "Cannot connect to crypto data provider"
        ) from exc


@app.get("/")
async def health():
    return {"status": "ok", "app": "Coin Pilot"}


@app.get("/api/coins")
async def get_coins(
    per_page: int = Query(50, ge=1, le=100),
    page: int = Query(1, ge=1),
):
    return await fetch_data(
        "/coins/markets",
        {
            "vs_currency": "usd",
            "order": "market_cap_desc",
            "per_page": per_page,
            "page": page,
            "sparkline": "false",
            "price_change_percentage": "24h",
        },
    )


@app.get("/api/coins/{coin_id}")
async def get_coin(coin_id: str):
    return await fetch_data(
        f"/coins/{coin_id}",
        {
            "localization": "false",
            "tickers": "false",
            "market_data": "true",
        },
    )


@app.get("/api/coins/{coin_id}/chart")
async def get_chart(
    coin_id: str,
    days: int = Query(7, ge=1, le=365),
):
    return await fetch_data(
        f"/coins/{coin_id}/market_chart",
        {"vs_currency": "usd", "days": days},
    )


@app.get("/api/market/global")
async def get_global_market():
    return await fetch_data("/global")
