from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine
import os
from dotenv import load_dotenv
from .'.venv'.src.models.products import Products


load_dotenv()

engine = create_engine(os.getenv('DB_URL'), echo=True)

session_factory = sessionmaker(engine=engine)

with session_factory() as session:
    #raws = session.execute('SELECT * FROM products')
    raws = session.SELECT(Products).where(Products.products_id == 1)