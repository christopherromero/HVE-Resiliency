---
description: Run Prompt 7 logging and transaction state validation for resiliency research
agent: Task Researcher
---

# HVE Resiliency Researcher 7 — Logging

Use [Resiliency Research Platform Context](../../../instructions/hve-resiliency-platform-context.instructions.md).

```text
# HVE Task Researcher Prompt — Logging & Transaction State Validation

You are acting as a Senior Cloud Application Architect performing an observability/logging validation for a microservice.

## OBJECTIVE
Validate whether this microservice logs *vital operational and transactional state* needed to:
1) Assess microservice health/state during normal operations and during failures/failover,
2) Diagnose transaction flow issues end-to-end (without leaking secrets or sensitive data),
3) Correlate events across calls/dependencies using consistent correlation IDs,
4) Support incident triage when pods appear "healthy" but transactions silently fail.
5) All logging and telemetry findings should be treated as a Priority P2 or P3 in the research output.

## SCOPE
Analyze the repository for logging/telemetry behaviors in:
- Application code (controllers, services, clients, workflow/orchestration handlers)
- Middleware/interceptors/filters (request/response, correlation IDs, auth)
- Async workers / schedulers / message handlers (if present)
- Error handling and retry logic
- Health/readiness endpoints and dependency checks (and their logging)
- Config that affects logging level/format/sinks
- Telemetry integrations (OpenTelemetry, App Insights, Micrometer, tracing libraries)

## EVIDENCE RULES (MANDATORY)
- Base findings ONLY on verifiable evidence.
- For every claim: cite exact **file path + line number(s)**.
- If you cannot find evidence, state "NOT FOUND (no evidence)" and list where you looked.
- Do NOT infer behavior. Do NOT assume framework defaults unless shown in code/config.

## WHAT TO VALIDATE (LOGGING REQUIREMENTS)

### Microservice Operational State (Service Health & Readiness)
Verify the code logs the following events with sufficient detail:
1. Service startup readiness transitions:
   - Startup begin/end, config loaded, dependency initialization success/failure
2. Readiness/liveness/health endpoint behavior:
   - Whether health endpoints reflect dependency readiness (DB, external services, messaging, secrets store)
   - Whether unhealthy dependency causes readiness to fail (and if logged)
3. Background health monitors / dependency probes (if present):
   - Periodic checks and state changes logged (healthy -> degraded -> unhealthy)
4. Capacity/scaling signals (if present):
   - HPA/scaling related events (queue lag, thread pool saturation, backpressure indicators)

For each item, answer:
- Where is it implemented?
- What exactly is logged (message + fields)?
- Is it structured logging (JSON/fields) or unstructured text?
- Are log levels appropriate (INFO/WARN/ERROR)?
- Is there risk of "healthy pod" while app is functionally down due to missing dependency state logging?

### Transaction Flow State (Critical)
Verify the service logs transaction state transitions and decision points:
1. Transaction lifecycle events (at minimum):
   - start / validation / authorization / capture / void / refund / completion / failure
2. Idempotency and dedup logic:
   - Idempotency key presence/usage, dedup decisions, replay handling
3. External dependency calls:
   - Outbound calls to downstream services
   - What request metadata is logged (NON-SENSITIVE only)
   - What response metadata is logged (status codes, reason categories, latency)
4. Retry/circuit breaker outcomes:
   - retry attempt number, backoff, final failure reason, circuit open/half-open transitions
5. Error categorization:
   - Distinguish transient vs permanent failures (HTTP 429/5xx vs validation/business errors)
6. "Silent failure" risks:
   - Identify areas where exceptions are swallowed, errors are logged without context, or failures do not emit ERROR logs/metrics.

For each transaction logging point, validate:
- What is being captured in the logs
- Correlation/Trace ID propagation (incoming -> downstream calls)
- Whether logs include a "state" field or consistent event names
- Whether logs include timing/latency at key steps
- Whether failures produce a clear root-cause breadcrumb trail across logs

### Correlation & Traceability (REQUIRED)
Validate end-to-end correlation across logs:
- Is there a correlation ID / trace ID extracted from inbound request headers?
- Is it injected into log context (MDC) and propagated to outbound requests/messages?
- Are logs consistent across controllers/services/clients/async handlers?
- Are structured fields consistent (e.g., traceId, spanId, correlationId, transactionId, orderId)?

Provide evidence for:
- header parsing
- MDC/log context injection
- outbound propagation (HTTP headers, message metadata)
- log formatter configuration

### Structured Logging, Log Hygiene, and Security (REQUIRED)
Validate the repository prevents leaking secrets/sensitive data:
- Are sensitive details, tokens, secrets, auth headers, PII masked or excluded?
- Do logs avoid full payload dumps for sensitive requests/responses?
- Are exception logs safe (stack traces ok, but no sensitive values)?
- Are there explicit filters/redactors?
- Are logging levels configurable via environment and not hardcoded?

### Telemetry Complements (Metrics/Tracing) — If Present
If the repo contains telemetry:
- Validate key metrics emitted for transaction success/failure counts, latency, dependency errors
- Validate traces/spans exist for key steps and outbound calls
- Ensure metric names/tags do not leak sensitive data
- Cite where metrics/spans are created and what tags are included

## REQUIRED OUTPUT FORMAT

### SECTION 1 — CURRENT LOGGING INVENTORY (EVIDENCE CONFIRMED)
Provide a concise inventory table:
- Component/Module
- What it logs (events/states)
- Fields present (transactionId, traceId, dependency, status, latency)
- Log level
- Evidence (file:line)
- Priority P2 or P3 for all logging and telemetry findings to be followed up and remediated.

### SECTION 2 — GAPS & RISKS (PRIORITIZED)
List findings as F-### with:
- Title
- Risk (impact on diagnosing failures / failover events)
- Evidence of missing/insufficient logging (file:line) or "NOT FOUND"
- Why this is risky (e.g., silent outage, cannot correlate, missing state transitions)
- Impact if not addressed (e.g., inability to detect or diagnose outages, delayed incident response)

Use priorities:
- P2 — Improvement/Best Practice (Non-Blocking)
- P3 — Non-Blocking Code Consistency (Best Practices / Maintainability)

### SECTION 3 — PRESCRIPTIVE RECOMMENDATIONS (CODE-LEVEL)
For each finding (no new findings beyond Section 2):
- Recommended logging pattern (structured fields + event naming)
- Where to implement (exact layer: filter/interceptor/service/client)
- Minimal code change intent (what to add, what to avoid)
- Acceptance criteria (testable), including:
  - When dependency X is unhealthy, logs show state transition + readiness change
  - When transaction fails, logs contain transactionId + traceId + failure category + dependency info
  - Correlation IDs present across inbound/outbound logs for a single transaction

## FINAL CHECK
Include a short "Can we diagnose a silent outage?" walkthrough:
- If the service stops processing transactions but pods are alive, what logs/metrics/traces would prove it?
- If you cannot answer based on evidence, state what is missing.
```
