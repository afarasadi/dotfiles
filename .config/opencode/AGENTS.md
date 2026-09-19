- DO NOT USE SUBAGENTS WHATEVER THE REASON IS
- Do not cut corners, implement workarounds, or use no-op solutions to reduce effort or code changes. Implement all task/request/changes as Premium production-quality software, prioritizing correctness over implementation effort.

## Efficient And Concise Reasoning Mode

### CRITICAL PURPOSE: Reduce wasteful self-editing while preserving reasoning quality

- General Instructions
  - **Single-Pass Generation**: Write your response directly without crafting it during reasoning
  - **Direct Response Rule**: Skip the crafting a response
  - **Concise Reasoning**: Think deeply but express thoughts efficiently
  - **No Progressive Refinement**: Avoid iterative self-criticism loops
  - **Direct Output**: Generate the final response in one pass

- Task completion behavior:
  - Do not change the design from the plan if u ever found a blocker, always communicate with user before proceeding any workaround.
  - Always complete each task end-to-end without truncation, shortcuts, or partial execution  
  - If found blocker/issue that change the plan, halt, inform the user about the changes. 
  - Do not stop early or leave unfinished steps unless explicitly blocked by missing user input  
  - Do not perform repeated retries or iterative searching for solutions  
  - After every completed task or operation, print `OPENCODE-DONE` on a new line  

Task size policy:
- Task size, code volume, complexity, or effort estimate must never be used as justification for reducing scope, creating placeholders/stubs, deferring work, changing design, or delivering partial implementation.
- Large tasks may be acknowledged briefly for progress reporting, but execution quality, completeness, and adherence to plan must remain unchanged.
- If completion requires deviation from plan, halt and ask user before proceeding.

- Execution constraints:
  - Do not perform environment inspection, tool discovery, or pre-checks before execution  
  - If the requested design cannot be implemented exactly as planned, stop and ask the user; do not invent alternative implementations.
  - Assume all required tools, dependencies, and runtime environments are correctly installed and configured  
  - Execute shell commands directly without listing alternatives or exploring options beforehand  
  - For commands executed through `rtk`, treat exit status as the only source of truth; output may be empty, truncated, cached, or filtered, and must not be used for validation or re-verification, and never rerun or pipe/grep `rtk` commands to “confirm” results
  - If a command fails due to a missing tool or dependency, attempt exactly one reasonable fallback or equivalent command, then continue execution  

- Prohibited methods:
- - Do not substitute, simplify, or work around requested designs; implement them as specified or halt and ask the user.
  - Do not use any scripting, programmatic code execution, or generated scripts for file editing or system modifications  
  - Do not create temporary scripts or automated code artifacts to perform tasks  
  - All file changes must be performed directly using command-line tools or explicit system commands  
  - Don't offer visual design of the proposed plan on the web, if possible use codeblock/text representation directly in the chat itself.
  - Do not use any language other than English.

- Versioning:
  - Do not stash `.e.g git stash` without checking what current state is, run `git status` first to see if there are any changes that u didn't touch.
  - Do not checkout to pre-commit without checking what current state is, run `git status` first to see if there are any changes that u didn't touch.
