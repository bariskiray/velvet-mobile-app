# Velvet — AI-Powered Valet Management System

> A full-stack valet parking management platform powered by computer vision and machine learning. Velvet automates vehicle identification using AI — detecting license plates, car brands, and colors from a single photo — while providing a complete operational workflow for businesses and valet attendants.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Backend Setup](#backend-setup)
  - [Frontend Setup](#frontend-setup)
- [Environment Variables](#environment-variables)
- [API Reference](#api-reference)
- [AI Pipeline](#ai-pipeline)
- [Screenshots](#screenshots)
- [Contributing](#contributing)

---

## Overview

Velvet is a two-sided mobile platform that connects **valet businesses** (restaurant owners, hotel managers, etc.) with their **valet attendants**. When a customer hands over their car, the valet simply takes a photo — the AI pipeline automatically identifies the vehicle's license plate, brand, and color in seconds. The business owner monitors everything in real time through their own dashboard with statistics, payment tracking, and device management.

---

## Features

### Business Panel
- **Dashboard** — Real-time overview of active valets and open tickets
- **Ticket Management** — Filter and view all parking tickets by date, status, and valet
- **AI-Assisted Check-In** — Automatic vehicle identification (plate, brand, color) via photo
- **Smart Checkout** — Automatically assigns the nearest available valet via FCM push notification
- **Payment Tracking** — Record cash or card payments with tip support
- **Parking Lot Management** — Add, edit, and delete parking spots with GPS coordinates on a map
- **Device Management** — Assign/unassign handheld devices to valets with full audit logs
- **Statistics & Analytics** — Daily visit counts, peak hours, peak days, and revenue charts

### Valet Panel
- **Open Tickets** — See and act on assigned tickets in real time
- **AI Camera** — Capture vehicle photo to auto-fill plate, brand, and color
- **Map Navigation** — Get directions to the nearest available parking spot (Haversine algorithm)
- **QR Code Support** — QR scanning for ticket identification
- **FCM Push Notifications** — Instant alerts when a customer requests their car

---

## Architecture

```
┌──────────────────────────────────────────────────┐
│              Flutter Mobile App (GetX)            │
│   Business Panel          Valet Panel             │
└─────────────────┬────────────────────────────────┘
                  │  HTTP/REST (Dio + JWT Bearer)
                  ▼
┌──────────────────────────────────────────────────┐
│            FastAPI Backend (/api/...)             │
├──────────────┬───────────────────────────────────┤
│  SQLAlchemy  │  Firebase Admin SDK               │
│  ORM (MySQL) │  (FCM Push Notifications)         │
├──────────────┴───────────────────────────────────┤
│                   AI Pipeline                     │
│  OWL-ViT (vehicle & plate detection)              │
│  + Custom YOLO (brand detection)                  │
│  + Keras H5 (color classification)                │
│  + PaddleOCR (license plate reading)              │
└──────────────────────────────────────────────────┘
```

**Authentication:** Scope-based JWT (`business` / `valet`) via OAuth2 Password Grant.  
**Notifications:** Firebase Cloud Messaging — push notification sent to valet on checkout.  
**Location:** Haversine formula to find nearest parking spot from valet's GPS position.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile Frontend | Flutter 3.x, GetX (state management + routing), Dio |
| Backend Framework | FastAPI 0.115, Python 3.11+ |
| Database | MySQL + SQLAlchemy ORM 2.0 |
| Authentication | JWT (python-jose), bcrypt/passlib |
| Push Notifications | Firebase Admin SDK + FCM |
| Maps | Google Maps Flutter |
| AI — Vehicle Detection | OWL-ViT (`google/owlvit-base-patch32`) |
| AI — Brand Detection | Custom YOLOv8 (Ultralytics) |
| AI — Color Detection | Custom Keras H5 / Caffe model |
| AI — License Plate OCR | PaddleOCR 2.9 |
| Image Processing | OpenCV 4.10 |
| Charts | fl_chart |

---

## Project Structure

```
Valet/
├── backend/                          # Python FastAPI backend
│   ├── .env.example                  # Environment variable template
│   ├── requirements.txt              # Python dependencies
│   └── app/
│       ├── main.py                   # App entry point + model warm-up
│       ├── routers.py                # All API endpoints (~987 lines)
│       ├── firebase_config.py        # Firebase Admin SDK init
│       ├── AI/
│       │   ├── pipeline_feature.py   # Main AI pipeline
│       │   ├── model_loader.py       # Model warm-up on startup
│       │   ├── ml_config.yml         # Model configuration
│       │   └── PreTrained_models/    # Model implementations
│       │       ├── OwlWit.py         # OWL-ViT vehicle/plate detection
│       │       ├── PaddleOcr.py      # OCR for license plates
│       │       ├── Brand_detect.py   # YOLO brand detection
│       │       └── ColorDetect.py    # Color classification
│       ├── Database/
│       │   ├── auth.py               # JWT authentication
│       │   ├── crud.py               # Database operations
│       │   ├── database.py           # SQLAlchemy engine + session
│       │   └── schemas.py            # Pydantic request/response schemas
│       ├── models/                   # SQLAlchemy ORM models
│       │   ├── Business.py
│       │   ├── Valet.py
│       │   ├── Ticket.py
│       │   ├── Car.py
│       │   ├── Payment.py
│       │   ├── Device.py
│       │   ├── DeviceLog.py
│       │   └── ParkingLocation.py
│       └── utils/
│           └── geo.py                # Haversine distance calculation
│
└── frontend/
    └── valet_mobile_app/             # Flutter application
        ├── pubspec.yaml
        └── lib/
            ├── main.dart             # App entry + Firebase + routing
            ├── api_service/
            │   └── api_service.dart  # All API calls (Dio-based)
            ├── auth/
            │   ├── auth_controller.dart
            │   └── auth_models.dart
            ├── components/           # Shared UI components
            └── views/
                ├── mainPage.dart     # Role selection screen
                ├── business/         # Business owner screens
                │   ├── business_home/
                │   ├── business_login/
                │   ├── business_tickets/
                │   ├── checkout/
                │   ├── devices/
                │   ├── parking_spots/
                │   ├── payment/
                │   └── statistics/
                └── valet/            # Valet attendant screens
                    ├── valet_home/
                    ├── valet_login/
                    ├── valet_create_ticket/
                    └── valet_complete_ticket/
```

---

## Getting Started

### Prerequisites

- Python 3.11+
- Flutter 3.x SDK
- MySQL 8.0+
- Firebase project (for FCM)
- Google Maps API key (for maps in Flutter)

---

### Backend Setup

**1. Clone the repository and navigate to the backend:**
```bash
cd backend
```

**2. Create and activate a virtual environment:**
```bash
python -m venv venv
source venv/bin/activate  # macOS/Linux
venv\Scripts\activate     # Windows
```

**3. Install dependencies:**
```bash
pip install -r requirements.txt
```

> **Note:** The `requirements.txt` includes TensorFlow, PyTorch, PaddleOCR, and Ultralytics. Installation may take several minutes and requires ~10GB of disk space for all AI model weights.

**4. Configure environment variables:**
```bash
cp .env.example .env
```
Edit `.env` with your actual values (see [Environment Variables](#environment-variables)).

**5. Configure the database:**

Create `app/Database/database_config.yaml` (not committed — keep it secret):
```yaml
host: localhost
port: 3306
user: your_db_user
password: your_db_password
database: velvet_db
```

**6. Add Firebase credentials:**

Place your Firebase Admin SDK JSON file at:
```
backend/config/firebase-adminsdk.json
```
Download this from Firebase Console → Project Settings → Service Accounts → Generate new private key.

**7. Add AI model weights:**

Place model files in:
```
backend/app/AI/PreTrained_models/weights/brand/   # YOLO .pt + Keras .keras files
backend/app/AI/PreTrained_models/weights/color/   # .h5 + .caffemodel files
```

**8. Run the server:**
```bash
cd backend
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at `http://localhost:8000`.  
Interactive docs: `http://localhost:8000/docs`

---

### Frontend Setup

**1. Navigate to the Flutter project:**
```bash
cd frontend/valet_mobile_app
```

**2. Install Flutter dependencies:**
```bash
flutter pub get
```

**3. Configure Firebase:**

- Add `google-services.json` to `android/app/`
- Add `GoogleService-Info.plist` to `ios/Runner/`
- Update `firebase.json` with your project details

**4. Configure the backend URL:**

In `lib/api_service/api_service.dart`, update `getBaseUrl()` for your environment:
```dart
static String getBaseUrl() {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8000/';   // Android emulator
    // return 'http://YOUR_LOCAL_IP:8000/';  // Physical device
  } else {
    return 'http://localhost:8000/';   // iOS simulator
  }
}
```

**5. Run the app:**
```bash
flutter run
```

---

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `JWT_SECRET_KEY` | Secret key for signing JWT tokens | `NjSM...` (generate a random 256-bit key) |
| `JWT_ALGORITHM` | JWT signing algorithm | `HS256` |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | Token expiry in minutes | `60` |

> Generate a secure secret key:
> ```bash
> python -c "import secrets; print(secrets.token_urlsafe(32))"
> ```

**Additional config files (not committed to git):**

| File | Purpose |
|------|---------|
| `backend/app/Database/database_config.yaml` | MySQL connection config |
| `backend/config/firebase-adminsdk.json` | Firebase Admin SDK credentials |

---

## API Reference

All endpoints are prefixed with `/api`. Authentication uses `Authorization: Bearer <token>` header.

### Authentication
| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| POST | `/api/token` | Public | Login (Business or Valet), returns JWT |

### Business
| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| POST | `/api/businesses/register` | Public | Register a new business |

### Valets
| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| POST | `/api/valets/register` | Business | Add a new valet |
| GET | `/api/valets` | Business | List all valets (paginated) |
| GET | `/api/valets/{id}` | Business | Get valet details |
| POST | `/api/valets/logout` | Valet | Valet logout + clear FCM token |

### Tickets
| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| POST | `/api/tickets/create` | Valet | Create a new parking ticket |
| PUT | `/api/tickets/update` | Valet | Fill in vehicle details |
| PUT | `/api/tickets/checkout` | Business | Checkout + auto-assign valet via FCM |
| PUT | `/api/tickets/deliver_car` | Valet | Mark car as delivered |
| GET | `/api/tickets/open` | Valet | List open tickets |
| GET | `/api/tickets/closed` | Valet | List closed tickets |
| GET | `/api/tickets` | Business | Filter tickets by date/status |
| GET | `/api/tickets/{id}` | Business | Get single ticket |

### Parking Locations
| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| GET/POST | `/api/parking-locations` | Business | List or create parking spots |
| GET/PUT/DELETE | `/api/parking-locations/{id}` | Business | Get, update, or delete a spot |
| GET | `/api/parking-spots` | Valet | List available spots |
| GET | `/api/parking-spots/closest` | Valet | Find nearest empty spot by GPS |

### Devices
| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| POST | `/api/devices` | Business | Register a device |
| GET | `/api/devices` | Business | List all devices |
| PUT | `/api/devices/assign` | Business | Assign device to valet |
| PUT | `/api/devices/unassign` | Business | Unassign device |
| GET | `/api/devices/{id}/logs` | Business | Device assignment history |

### Payments
| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| POST | `/api/payments` | Business | Create a payment record |
| GET | `/api/payments/{ticket_id}` | Business | Get payment for a ticket |

### AI
| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| POST | `/api/AI` | Valet | Upload vehicle photo, returns plate + brand + color |

### Statistics
| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| GET | `/api/statistics/daily-visits` | Business | Visit count for a given date |
| GET | `/api/statistics/visit-count-by-hours` | Business | Hourly visit distribution |
| GET | `/api/statistics/peak-hours` | Business | Top busiest hours |
| GET | `/api/statistics/peak-days` | Business | Top busiest days of the week |
| GET | `/api/statistics/money-gained` | Business | Total revenue for a date range |

---

## AI Pipeline

When a valet uploads a vehicle photo via `/api/AI`, the following pipeline runs:

```
Input Photo
    │
    ▼
OWL-ViT (google/owlvit-base-patch32)
    ├── Vehicle Detection → Crop vehicle region
    └── License Plate Detection → Crop plate region
              │
              ▼
    ┌─────────────────────────────────┐
    │  Parallel Processing            │
    ├── Brand Detection (YOLOv8)      │
    │   → e.g. "Toyota", "BMW"        │
    ├── Color Detection (Keras H5)    │
    │   → e.g. "Silver", "Black"      │
    └── License Plate OCR (PaddleOCR) │
        Preprocessing: Otsu threshold │
        → e.g. "34 ABC 123"          │
    └─────────────────────────────────┘
              │
              ▼
    JSON Response: { plate, brand, color }
```

All models are **warmed up on server startup** to minimize first-request latency.

---

## Database Schema

```
Business ──< Valet ──< Ticket >── Car
    │              │
    │              └──< DeviceLog >── Device
    │
    ├──< ParkingLocation
    ├──< Device
    └──< Payment >── Ticket
```

**Ticket Status Flow:**
```
OPEN (1) → FILLED (2) → CLOSED (3) → DELIVERED (4)
```

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

This project is for educational and portfolio purposes.
