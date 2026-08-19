# Race Event Management API

## Authentication Endpoints

| Method | Endpoint | Description | Auth | Request Body | Responses |
|--------|----------|-------------|------|--------------|-----------|
| POST | `/api/auth/register` | Registers a new user account as either an Organiser or Participant | None (Public) | `{ "email": "string", "password": "string", "firstName": "string", "lastName": "string", "phoneNumber": "string", "role": "Organiser\|Participant" }` | **201 Created** - User object with JWT token<br>**400 Bad Request** - Validation failed or email already exists |
| POST | `/api/auth/login` | Authenticates user credentials and returns a JWT Bearer token | None (Public) | `{ "email": "string", "password": "string" }` | **200 OK** - Token & basic user info<br>**401 Unauthorized** - Invalid credentials |

## Profile Endpoints

| Method | Endpoint | Description | Auth | Request Body | Responses |
|--------|----------|-------------|------|--------------|-----------|
| GET | `/api/profile` | Retrieves profile details for the currently logged-in user | Any (Authenticated) | None | **200 OK** - Profile details<br>**401 Unauthorized** - Missing/invalid token |
| PUT | `/api/profile` | Updates contact details for the currently logged-in user | Any (Authenticated) | `{ "firstName": "string", "lastName": "string", "phoneNumber": "string" }` | **200 OK** - Updated profile object<br>**400 Bad Request** - Invalid fields<br>**401 Unauthorized** - Unauthorized access |

## Event Endpoints

| Method | Endpoint | Description | Auth | Request Body | Responses |
|--------|----------|-------------|------|--------------|-----------|
| GET | `/api/events` | Browses all upcoming events with optional filtering by type or date | None (Public) | None | **200 OK** - Array of Event objects with nested categories |
| GET | `/api/events/{id}` | Gets detailed information for a specific event including all distance categories | None (Public) | None | **200 OK** - Detailed Event object<br>**404 Not Found** - Event ID does not exist |
| POST | `/api/events` | Creates a new event entry in the system | Organiser | `{ "title": "string", "description": "string", "eventType": "string", "location": "string", "eventDate": "YYYY-MM-DDTHH:MM:SS" }` | **201 Created** - Newly created Event object<br>**400 Bad Request** - Validation errors<br>**403 Forbidden** - Non-organiser role |
| PUT | `/api/events/{id}` | Updates existing event details owned by the logged-in organiser | Organiser | `{ "title": "string", "description": "string", "eventType": "string", "location": "string", "eventDate": "YYYY-MM-DDTHH:MM:SS" }` | **200 OK** - Updated Event object<br>**403 Forbidden** - Not event owner<br>**404 Not Found** - Event missing |
| DELETE | `/api/events/{id}` | Removes an event and associated categories/enrolments | Organiser | None | **204 No Content** - Successfully deleted<br>**403 Forbidden** - Not event owner<br>**404 Not Found** - Event missing |

## Category Endpoints

| Method | Endpoint | Description | Auth | Request Body | Responses |
|--------|----------|-------------|------|--------------|-----------|
| POST | `/api/events/{eventId}/categories` | Adds a new distance/race category to an event | Organiser | `{ "categoryName": "string", "distanceKM": 21.1, "entryFee": 250.00, "maxCapacity": 1500 }` | **201 Created** - Created Category object<br>**400 Bad Request** - Capacity/Fee out of bounds<br>**403 Forbidden** - Forbidden access |
| DELETE | `/api/categories/{id}` | Removes a specific distance category from an event | Organiser | None | **204 No Content** - Category deleted<br>**403 Forbidden** - Not event owner<br>**404 Not Found** - Category ID missing |

## Enrollment Endpoints

| Method | Endpoint | Description | Auth | Request Body | Responses |
|--------|----------|-------------|------|--------------|-----------|
| POST | `/api/enrolments` | Registers the logged-in participant for a specific race category | Participant | `{ "categoryId": 1 }` | **201 Created** - Enrolment record with status<br>**400 Bad Request** - Event full or already enrolled<br>**403 Forbidden** - Organiser cannot enroll |
| GET | `/api/enrolments/my-enrolments` | Gets all event enrolments and statuses for the logged-in participant | Participant | None | **200 OK** - Array of participant's enrolments<br>**401 Unauthorized** - Token required |
| GET | `/api/events/{eventId}/enrolments` | Organiser views all participant enrolments for a given event | Organiser | None | **200 OK** - List of participants registered<br>**403 Forbidden** - Not event owner<br>**404 Not Found** - Event missing |

## Results Endpoints

| Method | Endpoint | Description | Auth | Request Body | Responses |
|--------|----------|-------------|------|--------------|-----------|
| POST | `/api/results` | Records or updates a participant's finish time and placement | Organiser | `{ "enrolmentId": 1, "finishTimeFormatted": "01:42:15", "finishTimeSeconds": 6135, "overallPosition": 14, "categoryPosition": 5 }` | **201 Created** - Created Result object<br>**400 Bad Request** - Invalid time format<br>**403 Forbidden** - Non-organiser role |
| GET | `/api/results/my-results` | Participant views their personal historical race results and times | Participant | None | **200 OK** - Array of personal result records<br>**401 Unauthorized** - Unauthorized access |
| GET | `/api/events/{eventId}/results` | Gets public leaderboards and category results for a completed event | None (Public) | None | **200 OK** - Ordered list of race results<br>**404 Not Found** - Event missing |