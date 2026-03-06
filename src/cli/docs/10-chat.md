# Chat Commands

## chat send <message>

Send a message to the AI assistant.

**Arguments:**
- `message` - The message text to send

**Examples:**
```bash
spider chat send "Hello!"
spider chat send "What's the status of the project?"
```

**Interactive mode:**
```
SpiderApp> send Hello!
SpiderApp> send What's next?
```

## chat history

Show recent chat history for the current session.

**Examples:**
```bash
spider chat history
spider chat history --limit 20
```

**Notes:**
- History is maintained for the current chat session
- Use `/new` in interactive mode to start a fresh chat (saves current to memory)

## chat resume [job_id]

Inspect queued/running/done chat jobs and resume by job id.

**Examples:**
```bash
spider chat resume
spider chat resume job-12
```
