---
title: "Lesson in Error Management"
subtitle: Why Golang's "Boring" Code is a Feature
date: 2025-11-21
tags: ["Story: Outage", "Tech: Go", "Tech: Rust", "Topic: Resilience", "Format: Analysis"]
---

![Partitioned JSON data](/img/20251118_cloudflare_outage.jpeg)


A lot of developers complains about Golang.

> *"Why do I have to type `if err != nil` every single time?"*
>
> *"It is too much typing. It is boring."*

But the recent Cloudflare outage shows why this "boring" code is actually a **critical safety feature**. Sometimes, the fastest path is the most dangerous.

-----

### 1\. The Breakdown: What Really Happened on November 18, 2025
[A large part of the internet went down](https://blog.cloudflare.com/18-november-2025-outage/). It was not a hacker. It was a mistake in the code.

Cloudflare’s **FL2 proxy engine** (written in Rust) tried to read a configuration file that got too big due to a routine update. Instead of rejecting the file, the whole system crashed.

This exposed the simple, brutal truth about shortcuts.

-----

### 2\. The Code Philosophy: Convenience vs. Safeguard

#### 🦀 The Rust Way: The Convenience Trap

Rust provides the **`.unwrap()`** shortcut. It’s designed to save typing, but it eliminates all safety checks.

It basically tells the computer: *"I am sure this works. If I am wrong, crash the program immediately."*

It is very fast to write:

```rust
// Easy to write, but dangerous
let config = load_file().unwrap();
```

If `load_file` has an error, the server dies. This is the code that caused the global panic.

----
#### 🐹 The Golang Way: Friction as a Guardrail

Go does not have a magic "crash button" like `.unwrap()`. To force a crash, a developer must explicitly choose to destroy the process:

```go
// You must choose to crash
val, err := loadFile()
if err != nil {
    panic(err) // This feels wrong to write.
}
```

This code will not pass most serious code reviews, and linters will shout at you. Go forces you to handle the error, meaning the **"lazy" path is actually the safe path.**

Most Go developers will just log the error and continue:

```go
if err != nil {
    logger.Error("File too big, skipping")
    return // The server stays ONLINE.
}
```

**Rust makes crashing easy. Go makes crashing hard.**

-----

### 3\. The Deeper Lesson: Survival Over Perfection

The argument is not just about the code shortcut. The outage highlighted two core engineering failures that must be avoided:

  * **The Design Flaw:** The deepest problem was the **hard-coded size limit** for the config file. The system was too **brittle** (easily broken) by unexpected data.
  * **The Missing Protocol:** The system failed to have a **graceful failure protocol**. It should have rejected the bad configuration and reverted to the last known good file.

#### How to Survive the Error

When a new config cannot be loaded, the operations team must be woken up, even if the user is not impacted. The system must "scream for help" without crashing:

  * **Log Loudly:** Immediately write a **`FATAL`** log message, detailing *why* the configuration failed.
  * **Trigger an Alert:** Increment a specific metric (e.g., `config_load_failure_total`) to trigger an immediate **Pager Alert** for the on-call engineer.
  * **Stay Alive:** Keep the server running using the last known good config.

When you build systems for the entire internet, having to type a few extra lines of code is not boring—it’s **system insurance**.