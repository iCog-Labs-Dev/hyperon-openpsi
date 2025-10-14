from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List

# ----- Schemas -----
class Item(BaseModel):
    id: int
    name: str
    description: str | None = None

# Fake in-memory database
items_db: List[Item] = []


app = FastAPI(title="Simple FastAPI App")

@app.get("/")
def root():
    return {"message": "Welcome to the FastAPI skeleton!"}

@app.get("/items", response_model=List[Item])
def list_items():
    return items_db

@app.get("/items/{item_id}", response_model=Item)
def get_item(item_id: int):
    for item in items_db:
        if item.id == item_id:
            return item
    raise HTTPException(status_code=404, detail="Item not found")

@app.post("/items", response_model=Item)
def create_item(item: Item):
    items_db.append(item)
    return item

@app.delete("/items/{item_id}")
def delete_item(item_id: int):
    for i, item in enumerate(items_db):
        if item.id == item_id:
            del items_db[i]
            return {"message": f"Item {item_id} deleted"}
    raise HTTPException(status_code=404, detail="Item not found")