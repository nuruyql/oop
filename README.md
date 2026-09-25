# Operating Systems Practical Works

This repository contains practical works for the Operating Systems course.

---

# PR01 — Linux Users, Groups and Permissions

## Goal

Study Linux user and group management, file and directory permissions, the `su` and `sudo` commands, and basic Bash configuration.

## Users and Groups

A group named `developers` was created.

A user named `student2` was created and added to the `developers` group.

The main user was also added to the `developers` group.

## Shared Directory

A shared directory was created:

```bash
/srv/shared
```

The owner of the directory is `root` and the group is `developers`.

The following permissions were set:

```text
2775 (drwxrwsr-x)
```

Members of the `developers` group can create and delete files in the directory.

Other users have read and execute permissions but cannot modify the contents.

The `setgid` bit (`2`) ensures that new files and directories created inside `/srv/shared` inherit the `developers` group.

A file named `student2.txt` was created by `student2`.

The main user, who is also a member of the `developers` group, was able to delete this file.

This is possible because deleting a file depends primarily on the permissions of its parent directory. The `developers` group has write and execute permissions on `/srv/shared`.

## su and sudo

`su` (switch user) is used to switch to another user account. It normally requires the password of the target user.

`sudo` allows an authorized user to execute individual commands with elevated privileges.

In Ubuntu, direct password login to the `root` account is normally disabled by default. Administrative tasks are usually performed using `sudo`.

This reduces the need to work permanently with root privileges and lowers the risk of accidentally modifying important system files.

## Bash Configuration

The following aliases were added to `~/.bashrc`:

```bash
alias ll='ls -lah'
alias cshared='cd /srv/shared'
```

The following environment variable was also added:

```bash
export COURSE_NAME="Operating Systems"
```

After starting a new Bash session, the aliases and environment variable work correctly.

## PR01 Conclusion

During this practical work, Linux users and groups were created and configured.

Permissions for a shared directory were configured using group permissions and the `setgid` bit.

The difference between `su` and `sudo` was studied, and basic Bash configuration using aliases and environment variables was completed.

---

# PR02 — Bash Scripts and System Calls

## Goal

Create a Bash script for analyzing log files and study Linux system calls using `strace`.

The number of system calls made by a Python program is also compared with the `cat` utility.

## report.sh

The `report.sh` script analyzes log files in a specified directory.

Usage:

```bash
./report.sh <directory> <ERROR|WARN> [--top N]
```

The script:

- checks that the required arguments are provided;
- prints help and returns exit code `1` when arguments are missing;
- checks whether the specified directory exists;
- accepts the `ERROR` or `WARN` log level;
- counts messages for each module;
- sorts modules by the number of messages in descending order;
- supports the `--top N` option.

Example:

```bash
./report.sh logs ERROR
```

Example with `--top`:

```bash
./report.sh logs WARN --top 2
```

The script has a shebang and executable permissions.

It can be checked with:

```bash
shellcheck report.sh
```

## hello.py

The `hello.py` program reads a specified file and prints its size in bytes.

Usage:

```bash
python3 hello.py logs/app.log
```

For the test file used in this work, the result was:

```text
File size: 182 bytes
```

The script also contains a shebang:

```python
#!/usr/bin/env python3
```

and has executable permissions.

## strace Analysis

The Python program was analyzed using:

```bash
strace -f -o trace.txt python3 hello.py logs/app.log
```

The resulting trace was saved in:

```text
trace.txt
```

The trace contained **561 system-call records**.

The test file was opened with a system call similar to:

```text
openat(AT_FDCWD, "logs/app.log", O_RDONLY|O_CLOEXEC) = 3
```

The returned file descriptor was `3`.

The relevant reads of the test file included:

```text
read(3, ..., 183) = 182
read(3, "", 1) = 0
```

The first call read **182 bytes** from the file.

The second call returned `0`, which indicates the end of the file (EOF).

The file is then closed after it is no longer needed.

Many other system calls in `trace.txt` are not directly related to reading `app.log`.

They are overhead caused by starting the Python interpreter, loading libraries and modules, allocating and mapping memory, initializing the runtime, and executing the Python script.

## Comparison: cat vs Python

Both programs were tested using the same file:

```text
logs/app.log
```

The Python trace was created with:

```bash
strace -f -o trace.txt python3 hello.py logs/app.log
```

The `cat` trace was created with:

```bash
strace -f -o cat_trace.txt cat logs/app.log > /dev/null
```

The number of trace records was counted using:

```bash
wc -l trace.txt
wc -l cat_trace.txt
```

Results:

| Program | Trace records |
|---|---:|
| `python3 hello.py logs/app.log` | 561 |
| `cat logs/app.log` | 120 |

In this experiment, Python produced approximately:

```text
561 / 120 ≈ 4.68
```

times as many trace records as `cat`.

## Why Python Uses More System Calls

`cat` is a compiled utility designed for a relatively simple task: reading files and writing their contents.

Running `hello.py` requires starting the Python interpreter first.

Before the actual Python code is executed, the interpreter performs additional operations such as:

- loading shared libraries;
- searching for and loading Python modules;
- accessing configuration and environment information;
- allocating and mapping memory;
- initializing the Python runtime.

Therefore, Python has significantly more startup overhead for this simple task.

## PR02 Conclusion

The `report.sh` script was created to analyze `ERROR` and `WARN` messages and count them by module.

The `hello.py` program was analyzed using `strace`.

The Python execution produced **561 trace records**, while `cat` produced **120 trace records** on the same test file.

The experiment demonstrates that a Python program has additional interpreter startup overhead, while `cat` performs the same basic file-reading task with fewer system calls.