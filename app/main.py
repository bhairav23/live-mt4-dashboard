from fastapi import FastAPI, Request
from fastapi.templating import Jinja2Templates
from pathlib import Path
import json

app = FastAPI()
templates = Jinja2Templates(directory="templates")

TERMINALS = {
    "Basic": "C:/Users/3112923-2/AppData/Roaming/MetaQuotes/Terminal/5D49F47D1EA1ECFC0DDC965B6D100AC5/MQL4/Files/Terminal_60044391.json",
    "Surge": "C:/Users/3112923-2/AppData/Roaming/MetaQuotes/Terminal/76F5A6AB6C9C072B94A014923F71D84B/MQL4/Files/Terminal_700000034.json",
    "HNW":   "C:/Users/3112923-2/AppData/Roaming/MetaQuotes/Terminal/6D8ED79B81D9D70041DDDF6786110ECE/MQL4/Files/Terminal_50055879.json",
    "VT30":  "C:/Users/3112923-2/AppData/Roaming/MetaQuotes/Terminal/704444BB97FFEAFF0FAD48FB79A73215/MQL4/Files/Terminal_700000032.json",
}

@app.get("/")
async def read_dashboard(request: Request):
    return templates.TemplateResponse("dashboard.html", {"request": request})

@app.get("/data")
async def get_data():
    terminal_data = {}
    for terminal, filepath in TERMINALS.items():
        file = Path(filepath)
        if file.exists():
            try:
                with open(file) as f:
                    data = json.load(f)
                terminal_data[terminal] = data.get("data", {})
            except Exception as e:
                print(f"Error reading {filepath}: {e}")
                terminal_data[terminal] = {}
        else:
            terminal_data[terminal] = {}
    return terminal_data
