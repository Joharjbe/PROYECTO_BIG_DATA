#este archivo debe estar dentro de la carpeta review_sentiment_pred para que funcione y ponga todos los parquet a mongo
import os
import pandas as pd
import pyarrow.parquet as pq
from pymongo import MongoClient

client = MongoClient("mongodb://localhost:27017")
db = client["proyectoBD"]
coleccion = db["reviews_sentiment"]
carpeta = os.path.dirname(os.path.abspath(__file__))
parquet_files = [
    os.path.join(carpeta, f)
    for f in os.listdir(carpeta)
    if f.endswith(".parquet")
]

for parquet in parquet_files:
    df = pq.read_table(parquet).to_pandas()
    records = df.to_dict(orient="records")
    if records:
        coleccion.insert_many(records)
