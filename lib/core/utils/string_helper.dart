import 'package:flutter/material.dart';

class S {
  final BuildContext context;
  S(this.context);

  bool get isAr => Localizations.localeOf(context).languageCode == 'ar';

  String get projects => isAr ? 'المشاريع' : 'Projects';
  String get recentProjects => isAr ? 'المشاريع الأخيرة' : 'Recent Projects';
  String get manageSprints => isAr ? 'إدارة الدورات والمهام الخاصة بك' : 'Manage your sprints and tasks';
  String get noProjects => isAr ? 'لا توجد مشاريع بعد' : 'No projects yet';
  String get createFirstProject => isAr ? 'قم بإنشاء مشروعك الأول للبدء' : 'Create your first project to start';
  String get addProject => isAr ? 'إضافة مشروع' : 'Add Project';
  String get retry => isAr ? 'إعادة المحاولة' : 'Retry';
  String get deleteProject => isAr ? 'حذف المشروع' : 'Delete Project';
  String get deleteConfirm => isAr 
      ? 'هل أنت متأكد من حذف المشروع؟ سيتم حذف جميع الدورات والمهام أيضاً.' 
      : 'Are you sure you want to delete this project? This will also delete all sprints and tasks.';
  String get cancel => isAr ? 'إلغاء' : 'Cancel';
  String get delete => isAr ? 'حذف' : 'Delete';
  String get edit => isAr ? 'تعديل' : 'Edit';
  String get projectDetails => isAr ? 'تفاصيل المشروع' : 'Project Details';
  String get fillInfo => isAr 
      ? 'املأ المعلومات أدناه لإنشاء أو تحديث مشروعك.' 
      : 'Fill in the information below to create or update your project.';
  String get projectName => isAr ? 'اسم المشروع' : 'Project Name';
  String get description => isAr ? 'الوصف' : 'Description';
  String get save => isAr ? 'حفظ' : 'Save';
  String get statsTotal => isAr ? 'إجمالي المشاريع' : 'Total Projects';
  String get statsActive => isAr ? 'المشاريع النشطة' : 'Active Projects';

  // Sprints
  String get projectSprints => isAr ? 'دورات المشروع' : 'Project Sprints';
  String get trackMilestones => isAr ? 'تتبع وإدارة معالم المشروع.' : 'Track and manage project milestones.';
  String get noSprints => isAr ? 'لا توجد دورات بعد' : 'No sprints yet';
  String get createFirstSprint => isAr ? 'قم بإنشاء دورتك الأولى للبدء' : 'Create your first sprint to get started';
  String get addSprint => isAr ? 'إضافة دورة' : 'Add Sprint';
  String get editSprint => isAr ? 'تعديل الدورة' : 'Edit Sprint';
  String get deleteSprint => isAr ? 'حذف الدورة' : 'Delete Sprint';
  String get deleteSprintConfirm => isAr 
      ? 'هل أنت متأكد من حذف هذه الدورة؟ سيتم حذف جميع المهام أيضاً.' 
      : 'Are you sure you want to delete this sprint? This will also delete all tasks.';
  String get sprintDetails => isAr ? 'تفاصيل الدورة' : 'Sprint Details';
  String get sprintGoal => isAr ? 'حدد الإطار الزمني والهدف لهذه الدورة.' : 'Define the timeframe and goal for this sprint.';
  String get sprintName => isAr ? 'اسم الدورة (مثلاً: الدورة 1)' : 'Sprint Name (e.g., Sprint 1)';
  String get startDate => isAr ? 'تاريخ البدء' : 'Start Date';
  String get endDate => isAr ? 'تاريخ الانتهاء' : 'End Date';
  String get status => isAr ? 'الحالة' : 'Status';
  String get active => isAr ? 'نشط' : 'Active';
  String get completed => isAr ? 'مكتمل' : 'Completed';
  String get updateSprint => isAr ? 'تحديث الدورة' : 'Update Sprint';
  String get createSprint => isAr ? 'إنشاء دورة' : 'Create Sprint';
  String get pleaseEnterSprintName => isAr ? 'يرجى إدخال اسم الدورة' : 'Please enter a sprint name';
  String sprintCountLabel(int count) => isAr ? '$count دورات' : '$count Sprints';
  String taskCountLabel(int count) => isAr ? '$count مهام' : '$count Tasks';

  // Tasks
  String get board => isAr ? 'لوحة المهام' : 'Board View';
  String get toDo => isAr ? 'قيد الانتظار' : 'To Do';
  String get inProgress => isAr ? 'قيد التنفيذ' : 'In Progress';
  String get done => isAr ? 'مكتمل' : 'Done';
  String get addTask => isAr ? 'إضافة مهمة' : 'Add Task';
  String get editTask => isAr ? 'تعديل المهمة' : 'Edit Task';
  String get taskTitle => isAr ? 'عنوان المهمة' : 'Task Title';
  String get priority => isAr ? 'الأولوية' : 'Priority';
  String get low => isAr ? 'منخفضة' : 'Low';
  String get medium => isAr ? 'متوسطة' : 'Medium';
  String get high => isAr ? 'عالية' : 'High';
  String get deleteTask => isAr ? 'حذف المهمة' : 'Delete Task';
  String get deleteConfirmTask => isAr ? 'هل أنت متأكد من حذف هذه المهمة؟' : 'Are you sure you want to delete this task?';
  String get noTasks => isAr ? 'لا توجد مهام بعد' : 'No tasks yet';
  String get addFirstTask => isAr ? 'أضف مهمتك الأولى للبدء' : 'Add your first task to get started';
  String get taskDetails => isAr ? 'تفاصيل المهمة' : 'Task Details';
  String get describeWork => isAr ? 'صف العمل الذي يتعين القيام به.' : 'Describe the work to be done.';
  String get pleaseEnterTaskTitle => isAr ? 'يرجى إدخال عنوان المهمة' : 'Please enter a task title';
  String get updateTask => isAr ? 'تحديث المهمة' : 'Update Task';
  String get createTask => isAr ? 'إنشاء مهمة' : 'Create Task';
  String get selectPriority => isAr ? 'حدد الأولوية' : 'Select Priority';
  String get selectStatus => isAr ? 'حدد الحالة' : 'Select Status';


  // Settings
  String get settings => isAr ? 'الإعدادات' : 'Settings';
  String get appearance => isAr ? 'المظهر' : 'Appearance';
  String get darkMode => isAr ? 'الوضع الداكن' : 'Dark Mode';
  String get language => isAr ? 'اللغة' : 'Language';
  String get primaryColor => isAr ? 'اللون الأساسي' : 'Primary Color';
  String get secondaryColor => isAr ? 'اللون الثانوي' : 'Secondary Color';
  String get backupRestore => isAr ? 'النسخ الاحتياطي والاستعادة' : 'Backup & Restore';
  String get createBackup => isAr ? 'إنشاء نسخة احتياطية' : 'Create Backup';
  String get restoreBackup => isAr ? 'استعادة نسخة احتياطية' : 'Restore Backup';
  String get exportData => isAr ? 'تصدير جميع البيانات إلى ملف JSON' : 'Export all data to JSON file';
  String get importData => isAr ? 'استيراد البيانات من ملف JSON' : 'Import data from JSON file';
  String get chooseColor => isAr ? 'اختر اللون' : 'Choose Color';
  String get english => isAr ? 'الإنجليزية' : 'English';
  String get arabic => isAr ? 'العربية' : 'Arabic';
  String get restoreConfirm => isAr 
      ? 'سيؤدي هذا إلى استبدال جميع البيانات الحالية بالنسخة الاحتياطية. هل أنت متأكد؟' 
      : 'This will replace all current data with the backup. Are you sure?';
  String get backupSaved => isAr ? 'تم حفظ النسخة الاحتياطية' : 'Backup saved';
  String get backupFailed => isAr ? 'فشل النسخ الاحتياطية' : 'Backup failed';
  String get restoreSuccess => isAr ? 'تمت الاستعادة بنجاح!' : 'Restore successful!';
  String get restoreFailed => isAr ? 'فشلت الاستعادة' : 'Restore failed';
}
