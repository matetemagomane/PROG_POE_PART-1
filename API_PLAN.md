# Event Management API

| HTTP Method | Route | Description | Role Required | Request Body |
|---|---|---|---|---|
| POST | /api/auth/register | Registers a new user account as either an Organiser or Participant. | None (Public) | `{ "email": "string", "password": "string", "firstName": "string", "lastName": "string", "phoneNumber": "string", "role": "Organiser\|Participant" }` |
| POST | /api/auth/login | Authenticates user credentials and returns a JWT Bearer token. | None (Public) | `{ "email": "string", "password": "string" }` |
| GET | /api/profile | Retrieves profile details for the currently logged-in user. | Any (Authenticated) | None |
| PUT | /api/profile | Updates contact details for the currently logged-in user. | Any (Authenticated) | `{ "firstName": "string", "lastName": "string", "phoneNumber": "string" }` |
| GET | /api/events | Browses all upcoming events with optional filtering by type or date. | None (Public) | None |
| GET | /api/events/{id} | Gets detailed information for a specific event including all distance categories. | None (Public) | None |
| POST | /api/events | Creates a new event entry in the system. | Organiser | `{ "title": "string", "description": "string", "eventType": "string", "location": "string", "eventDate": "YYYY-MM-DDTHH:MM:SS" }` |
| PUT | /api/events/{id} | Updates existing event details owned by the logged-in organiser. | Organiser | `{ "title": "string", "description": "string", "eventType": "string", "location": "string", "eventDate": "YYYY-MM-DDTHH:MM:SS" }` |
| DELETE | /api/events/{id} | Removes an event and associated categories/enrolments. | Organiser | None |
| POST | /api/events/{eventId}/categories | Adds a new distance/race category to an event. | Organiser | `{ "categoryName": "string", "distanceKM": 21.1, "entryFee": 250.00, "maxCapacity": 1500 }` |
| DELETE | /api/categories/{id} | Removes a specific distance category from an event. | Organiser | None |
| POST | /api/enrolments | Registers the logged-in participant for a specific race category. | Participant | `{ "categoryId": 1 }` |
| GET | /api/enrolments/my-enrolments | Gets all event enrolments and statuses for the logged-in participant. | Participant | None |
| GET | /api/events/{eventId}/enrolments | Organiser views all participant enrolments for a given event. | Organiser | None |
| POST | /api/results | Records or updates a participant's finish time and placement. | Organiser | `{ "enrolmentId": 1, "finishTimeFormatted": "01:42:15", "finishTimeSeconds": 6135, "overallPosition": 14, "categoryPosition": 5 }` |
| GET | /api/results/my-results | Participant views their personal historical race results and times. | Participant | None |
| GET | /api/events/{eventId}/results | Gets public leaderboards and category results for a completed event. | None (Public) | None |