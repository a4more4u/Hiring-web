# WhatsApp Integration Guide

This project now supports sending WhatsApp Job Alerts to eligible candidates.

## 1. Setup

### Backend
1.  Sign up for **Twilio**.
2.  Enable **WhatsApp Sandbox** in Twilio Console.
3.  Get your **Account SID** and **Auth Token**.
4.  Create a `.env` file in `server/` (copy `.env.example`) and add:
    ```env
    TWILIO_ACCOUNT_SID=your_sid_here
    TWILIO_AUTH_TOKEN=your_token_here
    TWILIO_WHATSAPP_NUMBER=whatsapp:+14155238886
    ```

### Database
The database schema has been updated to include:
- `skills` field for Users.
- `skillsRequired` field for Jobs.
- `Notification` model to track sent messages.

Run: `cd server && npx prisma db push` (Already done setup step).

## 2. Usage

### Employer Dashboard
1.  Go to the **Employer Dashboard**.
2.  In the **My Jobs** list, you will see a **Bell Icon** (Notify) next to each job.
3.  Click it to broadcast the job to all Workers who match the job requirements (or all workers if no specific requirements are set).

### Matching Logic
- The system matches Jobs to Workers based on **Skills**.
- If a Job has `skillsRequired` (comma-separated), it checks if the Worker has any of those skills.
- If no skills are required, it sends to all Workers.
- Candidates must have a valid phone number.

## 3. Testing
- Use the Twilio Sandbox.
- Candidates' phone numbers must join the Sandbox (send "join <code >" to the sandbox number) to receive messages in dev mode.
