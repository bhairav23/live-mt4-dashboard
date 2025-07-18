from fastapi import FastAPI, Request
from fastapi.templating import Jinja2Templates
from pathlib import Path
import json

app = FastAPI()
templates = Jinja2Templates(directory="templates")

# Define file paths for 4 terminals
TERMINALS = {
    "Terminal 1": "C:/Users/3112923-2/AppData/Roaming/MetaQuotes/Terminal/5D49F47D1EA1ECFC0DDC965B6D100AC5/MQL4/Files/Terminal_60044391.json",
    "Terminal 2": "C:/Users/3112923-2/AppData/Roaming/MetaQuotes/Terminal/6D8ED79B81D9D70041DDDF6786110ECE/MQL4/Files/Terminal_50055879.json",
    "Terminal 3": "C:/Users/3112923-2/AppData/Roaming/MetaQuotes/Terminal/704444BB97FFEAFF0FAD48FB79A73215/MQL4/Files/Terminal_700000032.json",
    "Terminal 4": "C:/Users/3112923-2/AppData/Roaming/MetaQuotes/Terminal/76F5A6AB6C9C072B94A014923F71D84B/MQL4/Files/Terminal_700000034.json",
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
