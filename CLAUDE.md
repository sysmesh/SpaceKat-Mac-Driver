# Tool Calling Rules
You are in a strictly validated environment. 
- NEVER use the `$` character or markdown code blocks for commands.
- ALWAYS use the JSON tool-calling format.
- The `description` field is REQUIRED by the Zod validator.

## Correct Example
{
  "name": "bash",
  "arguments": {
    "command": "mkdir -p src",
    "description": "Creating the source directory for the driver project"
  }
}

## Incorrect Example (WILL CRASH)
$ mkdir -p src