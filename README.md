# 📱 MiniSprint – Offline Sprint & Task Manager

## 🧾 Overview
MiniSprint is a lightweight, offline-first mobile app designed to manage projects, sprints, and tasks using a simple Agile workflow. It provides a clean and fast alternative to complex DevOps tools like Jira.

---

# 🎯 Goals
- Simple project management
- Offline usage (no internet required)
- Fast and lightweight
- Agile-style workflow (Sprint + Tasks)
- Easy for individuals and small teams

---

# 👥 User Type
- Single user (local usage)
- Optional future: team sync

---

# 🧱 Core Features

## 📁 1. Projects
- Create project
- Edit/Delete project
- View all projects

**Fields:**
- id
- name
- description

---

## 🏁 2. Sprints
- Create multiple sprints per project
- Track duration and status

**Fields:**
- id
- project_id
- name (Sprint 1, Sprint 2...)
- start_date
- end_date
- status (Active / Completed)

---

## ✅ 3. Tasks
- Add tasks to a sprint
- Update status
- Set priority

**Fields:**
- id
- sprint_id
- title
- description
- status (To Do / In Progress / Done)
- priority (High / Medium / Low)

---

## 📊 4. Kanban Board (Main Feature 🔥)

### Columns:
- 🟡 To Do  
- 🔵 In Progress  
- 🟢 Done  

### Features:
- Drag & Drop tasks between columns
- Instant status update
- Visual workflow

---

## ⏱️ 5. Sprint Progress
- Completion percentage
- Tasks count per status
- Visual progress bar

---

## 🧠 6. Smart Feature (Optional)
**Generate Tasks Button**
- Auto-create tasks from a goal

---

# 📱 Screens

1. **Dashboard**
   - List of projects
   - Create new project

2. **Project Details**
   - List of sprints

3. **Sprint List**
   - Create / manage sprints

4. **Kanban Board**
   - Task management

5. **Add/Edit Task**
   - Create or update task

---

# 🗄️ Database Schema

## Project Table
| Field        | Type   |
|--------------|--------|
| id           | int    |
| name         | string |
| description  | string |

---

## Sprint Table
| Field        | Type   |
|--------------|--------|
| id           | int    |
| project_id   | int    |
| name         | string |
| start_date   | date   |
| end_date     | date   |
| status       | string |

---

## Task Table
| Field        | Type   |
|--------------|--------|
| id           | int    |
| sprint_id    | int    |
| title        | string |
| description  | string |
| status       | string |
| priority     | string |

---

# ⚙️ Tech Stack

- **Frontend:** Flutter
- **Database:** SQLite (sqflite)
- **State Management:** Provider / Riverpod

---

# 🚀 Future Enhancements

- 🔔 Local notifications
- ☁️ Cloud sync
- 👥 Team collaboration
- 📄 Export to PDF
- 📊 Advanced analytics

---

# 🎨 UI Design Principles

- Minimal and clean
- Fast navigation
- No heavy graphics
- Smooth drag & drop

---

# 💡 App Name Ideas

- MiniSprint
- SprintLite
- TaskFlow
- DevTrack

---

# ✅ Summary

MiniSprint is:
- ⚡ Fast
- 🪶 Lightweight
- 📴 Offline-first
- 🧠 Agile-inspired

A perfect starter app for developers who want a practical, real-world project without complexity.



keytool -genkey -v -keystore D:\Flutter\unit_test\minisprint\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
