import firebase_admin
from firebase_admin import credentials, firestore,storage
import json
from datetime import datetime
from fastapi import FastAPI, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
import xlsxwriter
import pandas as pd
app = FastAPI()
allow_all = ['*']
app.add_middleware(
   CORSMiddleware,
   allow_origins=allow_all,
   allow_credentials=True,
   allow_methods=["*"],
   allow_headers=["*"],
)
app.mount("/static", StaticFiles(directory="static"), name="static")

#html
templates = Jinja2Templates(directory="templates")


@app.get("/index/", response_class=HTMLResponse)
def index(request : Request):
    context = {"request": request}
    return templates.TemplateResponse("index.html", context)


cred = credentials.Certificate("nosql-poc1-firebase-adminsdk-vhj7y-78fbf8e4e6.json")
# กำหนดข้อมูลรับรองให้กับ Firebase Admin SDK
firebase_admin.initialize_app(cred)

# รับส่วนของ Firestore
db = firestore.client()
# สร้าง Storage client



@app.get("/users/{command}")
async def get_users_data(command: str):
    # timestamp = datetime.now().strftime("%Y-%m-%d")
    # สร้างรายการเก็บข้อมูลเอกสาร
    users_data = []
    if command == 'location':
        users_ref = db.collection('users')

        # ดึงข้อมูลในเอกสารในคอลเลกชัน "users"
        users_docs = users_ref.get()
        for doc in users_docs:
            user_data = doc.to_dict()
            device_id = user_data.get("deviceID")
            location = user_data.get("location")
            status = user_data.get("status")
            origin = user_data.get("origin")
            lastupdate = user_data.get("lastupdate")
            achievement = user_data.get("achievement")
            name = user_data.get("name")
            imgref = "/static/img/"+device_id+".jpg"
            if device_id and location:
                
                user_item = {
                    "deviceID": device_id,
                    "location": location,
                    "status": status,
                    "lastupdate": lastupdate,
                    "origin":origin,
                    "achievement":achievement,
                    "name": name,
                    "imgee":imgref
                    
                }
                users_data.append(user_item)
    if command == 'attendance':
         # อ้างอิงคอลเลกชัน "users"
        users_ref = db.collection('tasks')
        users_docs = users_ref.get()
        for doc in users_docs:
            user_data = doc.to_dict()
            _id = user_data.get("ID")
            commitname = user_data.get("CommitBy")
            date = user_data.get("Date")
            starttime = user_data.get("StartTime")
            finishtime = user_data.get("FinishTime")
            status = user_data.get("Status")
            equip = user_data.get("EquipmentRequired")
            jobinfo = user_data.get("JobsInformation")
            note = user_data.get("Note")
            if status == "completed" or status == "cancelled":
                user_item = {
                    "ID":_id,
                    "CommitBy":commitname,
                    "Date":date,
                    "StartTime":starttime,
                    "FinishTime":finishtime,
                    "Status":status,
                    "EquipmentRequired":equip,
                    "JobsInformation":jobinfo,
                    "FinishTime":finishtime,
                    "Note":note
                }
                users_data.append(user_item)
       
    users_json = json.dumps(users_data)
    # print(users_json)
    return users_json


@app.post("/create_collection/{collection_name}")
async def create_collection(collection_name: str, data: dict):
    try:
        # สร้างคอลเลกชันใหม่
        collection_ref = db.collection(collection_name)
        doc_ref = collection_ref.document()

        # เพิ่มข้อมูลในเอกสารใหม่
        doc_ref.set(data)
        return {"message": "Collection created successfully and document added"}
    except Exception as e:
        return {"error": str(e)}
    
@app.put("/users/{device_id}")
async def update_user_location(device_id: str, x: int, y: int):
    try:
        # อ้างอิงถึงคอลเลกชัน 'users' ใน Firestore
        collection_ref = db.collection('users')

        # สร้าง Query เพื่อเลือกเอกสารที่ต้องการแก้ไขโดยใช้ฟิลด์ 'deviceID'
        query = collection_ref.where('deviceID', '==', device_id)

        # ดึงข้อมูลเอกสารจาก Query
        docs = query.get()

        # อัปเดตฟิลด์ 'location' ในเอกสารที่ต้องการ
        for doc in docs:
            doc.reference.update({
                'location': {
                    'x': x,
                    'y': y
                }
            })

        return {"message": "Location updated successfully"}
    except Exception as e:
        return {"error": str(e)}
    
data = []
timedata = []  # เก็บค่า last_place
n_data = 50

@app.post("/postexcel")
async def post_excel(request_body: dict):
    # ทำตามต้องการกับข้อมูลที่รับเข้ามาใน request_body
    # ในกรณีนี้เป็นการพิมพ์ข้อมูลที่รับเข้ามาออกทาง console
    last_place = request_body.get("lastplace")
    timestamp = request_body.get("timestamp")
    
    workbook = xlsxwriter.Workbook('data.xlsx')
    worksheet = workbook.add_worksheet()
    
    if len(data) < n_data:
        data.append(last_place)
        timedata.append(timestamp)
    
    if len(data) == n_data:
        row = 0  # กำหนดค่าเริ่มต้นของตัวแปร row เป็น 0
        for item in data:
            # write operation perform
            worksheet.write(row, 0, item)
            
            # incrementing the value of row by one
            # with each iterations.
            row += 1
        row = 0 
        for item in timedata:
            # write operation perform
            worksheet.write(row, 1, item)
            
            # incrementing the value of row by one
            # with each iterations.
            row += 1
        print("done writing")
        workbook.close()
        
    return {"message": "Data received successfully"}

