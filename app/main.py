from fastapi import FastAPI, Request
from fastapi.templating import Jinja2Templates
from pathlib import Path
import json

app = FastAPI()
templates = Jinja2Templates(directory="templates")

# Define file paths for 4 terminals
TERMINALS = {
    "Terminal 1": "C:/path/to/Files/Terminal_1.json",
    "Terminal 2": "C:/path/to/Files/Terminal_2.json",
    "Terminal 3": "C:/path/to/Files/Terminal_3.json",
    "Terminal 4": "C:/path/to/Files/Terminal_4.json",
}

@app.get("/")
async def read_dashboard(request: Request):
    terminal_data = {}

    for terminal, filepath in TERMINALS.items():
        file = Path(filepath)
        if file.exists():
            with open(file) as f:
                data = json.load(f)
            terminal_data[terminal] = data.get("data", {})
        else:
            terminal_data[terminal] = {}  # Empty if file not present yet

    return templates.TemplateResponse("dashboard.html", {
        "request": request,
        "terminal_data": terminal_data,
    })
