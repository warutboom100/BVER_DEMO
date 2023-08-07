const map = document.getElementById('map');
const userMarker1 = document.getElementById('user-marker-1');
const userMarker2 = document.getElementById('user-marker-2');
const userMarker3 = document.getElementById('user-marker-3');
const userMarker4 = document.getElementById('user-marker-4');
const httpsserver = "https://a1b62c0da8b2.ngrok.app";
var x1 = 0;
function updateUserMarkerPosition(marker,x1,y1,status) {
  const x = x1/100.0 * map.offsetWidth;
  const y = ((y1*0.42)+28)/100.0 * map.offsetHeight;
  marker.style.top = y + 'px';
  marker.style.left = x + 'px';

  const mapContainer = document.getElementById('map-container');
  
  const markerSize = Math.min(mapContainer.offsetWidth, mapContainer.offsetHeight) * 0.06;
  marker.style.width = markerSize + 'px';
  marker.style.height = markerSize + 'px';
  if (status === 'Online') {
    marker.style.boxShadow = "rgba(0, 255, 0, 0.8) 0px 0px 3px 1.5px inset, rgba(0, 255, 0, 0.8) 0px 0px 3px 1.5px";
  } else if (status === 'Booking') {
    marker.style.boxShadow = "rgb(234, 200, 27) 0px 0px 3px 1.5px inset, rgb(234, 200, 27) 0px 0px 3px 1.5px";
  } else if (status === 'Offline') {
    marker.style.boxShadow = "rgb(167, 164, 164) 0px 0px 1px 1.5px inset, rgb(167, 164, 164) 0px 0px 1px 1.5px";
  }
  
}
async function getUserLocation() {
  const response = await fetch(httpsserver+'/users/location');
  const data = await response.json();
  const dataArray = JSON.parse(data);

  const deviceListBody = document.getElementById('device-list-body');
  const usersDiv = document.querySelector('.users');
  deviceListBody.innerHTML = ''; // เคลียร์ข้อมูลเก่าทั้งหมด
  usersDiv.innerHTML = ''; 
  dataArray.forEach((item, index) => {
    const { deviceID, location , lastupdate, status,origin,achievement,name,imgee} = item;
    const { x, y } = location;
    updatescore_users(achievement,name,imgee);
    const tr = document.createElement('tr');

    const deviceIDCell = document.createElement('td');
    deviceIDCell.textContent = deviceID;
    tr.appendChild(deviceIDCell);

    const placeCell = document.createElement('td');
    placeCell.textContent = origin;
    tr.appendChild(placeCell);

    const dateCell = document.createElement('td');
    dateCell.textContent = lastupdate;
    tr.appendChild(dateCell);

    const statusCell = document.createElement('td');
    statusCell.textContent = status;
    tr.appendChild(statusCell);

    deviceListBody.appendChild(tr);

    // deviceListBody.appendChild(tr);


    const marker = getMarkerByDeviceID(deviceID); // แก้ไขตรงนี้โดยเรียกใช้ฟังก์ชันหรือวิธีที่ใช้งานกับตัวแทนผู้ใช้
    if (marker) {
      updateUserMarkerPosition(marker, x, y,status);
    }
  });
}
async function updatescore_users(achievement,name,imgee) {
  const usersDiv = document.querySelector('.users');
  
  const { complete, score } = achievement;

  const cardDiv = document.createElement('div');
  cardDiv.classList.add('card');

  const img = document.createElement('img');
  img.src = imgee; // Replace with the correct image source
  cardDiv.appendChild(img);

  const nameHeader = document.createElement('h4');
  nameHeader.textContent = name;
  cardDiv.appendChild(nameHeader);

  const roleParagraph = document.createElement('p');
  roleParagraph.textContent = 'Porter';
  cardDiv.appendChild(roleParagraph);

  const perDiv = document.createElement('div');
  perDiv.classList.add('per');

  const table = document.createElement('table');

  const tr1 = document.createElement('tr');
  const td11 = document.createElement('td');
  const span11 = document.createElement('span');
  span11.textContent = complete; // Update with the actual data
  td11.appendChild(span11);
  tr1.appendChild(td11);

  const td12 = document.createElement('td');
  const span12 = document.createElement('span');
  span12.textContent = score; // Update with the actual data
  td12.appendChild(span12);
  tr1.appendChild(td12);

  const tr2 = document.createElement('tr');
  const td21 = document.createElement('td');
  td21.textContent = 'Complete';
  tr2.appendChild(td21);

  const td22 = document.createElement('td');
  td22.textContent = 'Score';
  tr2.appendChild(td22);

  table.appendChild(tr1);
  table.appendChild(tr2);

  perDiv.appendChild(table);
  cardDiv.appendChild(perDiv);

  const profileButton = document.createElement('button');
  profileButton.textContent = 'Profile';
  cardDiv.appendChild(profileButton);

  usersDiv.appendChild(cardDiv);
  
}

async function getUserAttendance() {
  const response = await fetch(httpsserver+'/users/attendance');
  const data = await response.json();
  const dataArray = JSON.parse(data);

  const attendanceBody = document.getElementById('Attendance-list-body');
  attendanceBody.innerHTML = ''; // Clear old data

  dataArray.forEach((item, index) => {
    const { ID, CommitBy, Date, StartTime, FinishTime ,Status,EquipmentRequired,JobsInformation,Note} = item;
    // const { Infusionpump, Oxygentank,Stretcher,Walker,Wheelchair } = EquipmentRequired;
    // const { Destination, PatientName,Priority,Service,} = JobsInformation;

    const tr = document.createElement('tr');

    const userid = document.createElement('td');
    userid.textContent = ID;
    tr.appendChild(userid);

    const name = document.createElement('td');
    name.textContent = CommitBy;
    tr.appendChild(name);

    const type = document.createElement('td');
    type.textContent = 'Porter';
    tr.appendChild(type);

    const date = document.createElement('td');
    date.textContent = Date;
    tr.appendChild(date);

    const starttime = document.createElement('td');
    starttime.textContent = StartTime;
    tr.appendChild(starttime);

    const finishtime = document.createElement('td');
    finishtime.textContent = FinishTime;
    tr.appendChild(finishtime);

    const viewButtonCell = document.createElement('td');
    const viewButton = document.createElement('button');
    viewButton.textContent = 'View';
    viewButton.addEventListener('click', () => {
      openModal(ID, CommitBy, Date, StartTime, FinishTime ,Status,EquipmentRequired,JobsInformation,Note);
    });
    viewButtonCell.appendChild(viewButton);
    tr.appendChild(viewButtonCell);

    attendanceBody.appendChild(tr);
  });
  
}


function getMarkerByDeviceID(deviceID) {
  // แก้ไขฟังก์ชันนี้ให้ตรงกับโครงสร้าง HTML ของตัวแทนผู้ใช้
  if (deviceID === 'panuwat') {
    return userMarker3;
  } else if (deviceID === 'aimpitha') {
    return userMarker2;
  } else if (deviceID === 'warut') {
    return userMarker1;
  }else if (deviceID === 'ratcha') {
    return userMarker4;
  }
  return null; // หรือคืนค่าที่เหมาะสมในกรณีที่ไม่พบตัวแทนผู้ใช้
}

function submitBookingForm(event) {
  event.preventDefault(); // ป้องกันการรีเฟรชหน้าเมื่อกดปุ่ม Submit
  const timestamp = new Date().toLocaleDateString('en-GB');
  // ดึงค่าจากฟิลด์ในฟอร์ม
  const patientName = document.getElementById('patientName').value;
  const destination = document.getElementById('destination').value;
  const priority = document.getElementById('jobe-priority').value;
  const service = document.getElementById('service-time').value;
  const stretcher = document.getElementById('stretcher').value;
  const wheelchair = document.getElementById('wheelchair').value;
  const walker = document.getElementById('walker').value;
  const oxygentank = document.getElementById('oxygentank').value;
  const infusionpump = document.getElementById('infusionpump').value;
  const note = document.getElementById('note').value;
  const id  = Math.floor(Math.random() * 100) + 1;
  // สร้างออบเจกต์ข้อมูลที่จะส่งไปยัง FastAPI
  const data = {
    "JobsInformation": {"PatientName":patientName,
                        "Destination": destination,
                        "Priority": priority,
                        "Service": service,},
    "EquipmentRequired":{"Stretcher":parseInt(stretcher),
                        "Wheelchair": parseInt(wheelchair),
                        "Walker": parseInt(walker),
                        "Oxygentank": parseInt(oxygentank),
                        "Infusionpump": parseInt(infusionpump)},
    "Note":note,
    "Status":"notcomplete",
    "CommitBy":"-",
    "StartTime":"-",
    "FinishTime":"-",
    "Date":timestamp,
    "ID":parseInt(id),

    
  };

  fetch(httpsserver+'/create_collection/tasks', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(data)
  })
    .then(response => response.json())
    .then(result => {
      console.log(result);
      // ดำเนินการต่อหลังจากได้รับการตอบกลับจาก FastAPI
      document.getElementById("booking-info").style.display = "none";
      document.getElementById("map-container").style.display = "block";
      document.getElementById("Porter").style.display = "none";
    })
    .catch(error => {
      console.error(error);
      // การจัดการข้อผิดพลาด
    });
    document.getElementById("bookingForm").reset();
}

// // รับอินพุตแบบฟอร์มเมื่อกดปุ่ม Submit
// const form = document.getElementById('bookingForm');
// form.addEventListener('submit', submitBookingForm);


function toggleActive(event) {
  var navLinks = document.getElementsByClassName("nav-link");
  for (var i = 0; i < navLinks.length; i++) {
    navLinks[i].classList.remove("active");
  }
  event.target.classList.add("active");

  var middleDiv = document.getElementById("middle");
  var bookingInfoDiv = document.getElementById("booking-info");
  var mapContainerDiv = document.getElementById("map-container");
  var portermonitor = document.getElementById("Porter");
  if (event.target.textContent === "Dashboard") {
    bookingInfoDiv.style.display = "none";
    mapContainerDiv.style.display = "block";
    portermonitor.style.display = "none";
  } else if (event.target.textContent === "Booking") {
    mapContainerDiv.style.display = "none";
    bookingInfoDiv.style.display = "block";
    portermonitor.style.display = "none";
  }
  else if (event.target.textContent === "Porter") {
    mapContainerDiv.style.display = "none";
    portermonitor.style.display = "block";
    bookingInfoDiv.style.display = "none";
    
  }

}

// Function to create the modal dynamically
function createModal() {
  const modalDiv = document.createElement('div');
  modalDiv.id = 'my-modal';
  modalDiv.classList.add('modal');

  const modalContentDiv = document.createElement('div');
  modalContentDiv.classList.add('modal-content');

  const modalHeaderDiv = document.createElement('div');
  modalHeaderDiv.classList.add('modal-header');

  const closeButton = document.createElement('span');
  closeButton.classList.add('close');
  closeButton.innerHTML = '&times;';
  closeButton.addEventListener('click', closeModal);
  modalHeaderDiv.appendChild(closeButton);

  const modalTitle = document.createElement('h2');
  modalTitle.textContent = 'Modal Header';
  modalHeaderDiv.appendChild(modalTitle);

  const modalBodyDiv = document.createElement('div');
  modalBodyDiv.classList.add('modal-body');
  modalBodyDiv.innerHTML = `
    <p>This is my modal</p>
    <p>Lorem ipsum dolor sit amet consectetur adipisicing elit. Nulla repellendus nisi, sunt consectetur ipsa velit
      repudiandae aperiam modi quisquam nihil nam asperiores doloremque mollitia dolor deleniti quibusdam nemo
      commodi ab.</p>
  `;

  

  modalContentDiv.appendChild(modalHeaderDiv);
  modalContentDiv.appendChild(modalBodyDiv);


  modalDiv.appendChild(modalContentDiv);

  // Append the modal to the document body
  document.body.appendChild(modalDiv);

  // Create a <style> element and add CSS styles
  const styleElement = document.createElement('style');
  styleElement.textContent = `
    :root {
      --modal-duration: 1s;
      --modal-color: #29BA91;
    }

    .button {
      background: #428bca;
      padding: 1em 2em;
      color: #fff;
      border: 0;
      border-radius: 5px;
      cursor: pointer;
    }

    .button:hover {
      background: #3876ac;
    }

    .modal {
      font-family: Arial, Helvetica, sans-serif;
      background: #f4f4f4;
      font-size: 17px;
      line-height: 1.6;
      display: flex;
      height: 100vh;
      align-items: center;
      justify-content: center;
      display: none;
      position: fixed;
      z-index: 1;
      left: 0;
      top: 0;
      height: 100%;
      width: 100%;
      overflow: auto;
      background-color: rgba(0, 0, 0, 0.5);
    }

    .modal-content {
      margin: 10% auto;
      width: 60%;
      box-shadow: 0 5px 8px 0 rgba(0, 0, 0, 0.2), 0 7px 20px 0 rgba(0, 0, 0, 0.17);
      animation-name: modalopen;
      animation-duration: var(--modal-duration);
    }

    .modal-header h2,
    .modal-footer h3 {
      margin: 0;
    }

    .modal-header {
      background: var(--modal-color);
      padding: 15px;
      color: #fff;
      border-top-left-radius: 5px;
      border-top-right-radius: 5px;
    }

    .modal-body {
      padding: 10px 20px;
      background: #fff;
    }


    .close {
      color: #ccc;
      float: right;
      font-size: 30px;
      color: #fff;
    }
    #text{
      margin-left: 20px;
    }
    #bold{
      font-weight: bold;
    }

    .close:hover,
    .close:focus {
      color: #000;
      text-decoration: none;
      cursor: pointer;
    }

    @keyframes modalopen {
      from {
        opacity: 0;
      }
      to {
        opacity: 1;
      }
    }
  `;

  // Append the <style> element to the document's <head>
  document.head.appendChild(styleElement);
}


// Function to open the modal
function openModal(jobID, CommitBy, Date, StartTime, FinishTime ,Status,EquipmentRequired,JobsInformation,Note) {
  const modal = document.getElementById('my-modal');
  const modalHeader = modal.querySelector('.modal-header h2');
  const modalBody = modal.querySelector('.modal-body');
  const { Infusionpump, Oxygentank,Stretcher,Walker,Wheelchair } = EquipmentRequired;
  const { Destination, PatientName,Priority,Service,} = JobsInformation;
  // Set the modal content based on the selected user ID
  modalHeader.textContent = `Job details - ID: ${jobID} ,Time:${Date}     ${StartTime}-${FinishTime}`;
  modalBody.innerHTML = `
    <div id="head">
      <p id="bold">Job done by ${CommitBy} (${Status})</p>
      <div id="text">
      </div>
    </div>
    <div id="head">
      <p id="bold">JobsInformation</p>
      <div id="text">
        <p>- PatientName: ${PatientName}</p>
        <p>- Destination: ${Destination}</p>
        <p>- Priority:    ${Priority}</p>
        <p>- Service:     ${Service}</p>
      </div>
    </div>
    <div id="head">
      <p id="bold">EquipmentRequired</p>
      <div id="text">
        <p>- Infusionpump: ${Infusionpump}, Oxygentank: ${Oxygentank}, Stretcher: ${Stretcher}</p>
        <p>- Walker: ${Walker}, Wheelchair: ${Wheelchair}, Other: .....</p>
      </div>
    </div>
    <div id="head">
      <p id="bold">Note</p>
      <div id="text">
        <p>${Note}</p>
        
      </div>
    </div>
    
    
  `;

  modal.style.display = 'block';
}

// Function to close the modal
function closeModal() {
  const modal = document.getElementById('my-modal');
  modal.style.display = 'none';
}

// Add event listener to the modal close button
document.addEventListener('DOMContentLoaded', createModal);




setInterval(getUserLocation, 2500);
// setInterval(getUserAttendance, 10000);
getUserAttendance();
getUserLocation();