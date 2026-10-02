import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// Lightweight bilingual (English / Arabic) strings.
class S {
  final BuildContext context;
  S(this.context);

  bool get isAr => Localizations.localeOf(context).languageCode == 'ar';

  String _t(String en, String ar) => isAr ? ar : en;

  // General
  String get appName => 'MiniSprint';
  String get retry => _t('Retry', 'إعادة المحاولة');
  String get cancel => _t('Cancel', 'إلغاء');
  String get delete => _t('Delete', 'حذف');
  String get edit => _t('Edit', 'تعديل');
  String get save => _t('Save', 'حفظ');
  String get create => _t('Create', 'إنشاء');
  String get close => _t('Close', 'إغلاق');
  String get apply => _t('Apply', 'تطبيق');
  String get reset => _t('Reset', 'إعادة تعيين');
  String get clear => _t('Clear', 'مسح');
  String get search => _t('Search', 'بحث');
  String get optional => _t('Optional', 'اختياري');
  String get somethingWentWrong => _t('Something went wrong', 'حدث خطأ ما');
  String get description => _t('Description', 'الوصف');
  String get name => _t('Name', 'الاسم');
  String get status => _t('Status', 'الحالة');
  String get more => _t('More', 'المزيد');
  String get unassigned => _t('Unassigned', 'غير مسند');
  String get none => _t('None', 'بدون');

  // Projects
  String get projects => _t('Projects', 'المشاريع');
  String get yourProjects => _t('Your projects', 'مشاريعك');
  String get searchProjects => _t('Search projects', 'ابحث في المشاريع');
  String get noProjects => _t('No projects yet', 'لا توجد مشاريع بعد');
  String get noProjectsMatch =>
      _t('No projects match your search', 'لا توجد مشاريع مطابقة لبحثك');
  String get createFirstProject => _t(
    'Create a project to plan sprints and track work.',
    'أنشئ مشروعاً لتخطيط الدورات (Sprints) ومتابعة العمل.',
  );
  String get addProject => _t('New project', 'مشروع جديد');
  String get editProject => _t('Edit project', 'تعديل المشروع');
  String get deleteProject => _t('Delete project', 'حذف المشروع');
  String get deleteConfirm => _t(
    'This permanently deletes the project with all its sprints and work items.',
    'سيتم حذف المشروع نهائياً مع جميع الدورات وعناصر العمل التابعة له.',
  );
  String get projectName => _t('Project name', 'اسم المشروع');
  String get projectKey => _t('Key', 'الرمز');
  String get projectKeyHelp => _t(
    'Prefix for work item keys, e.g. MOB → MOB-12',
    'بادئة لمعرّفات عناصر العمل، مثل MOB ← MOB-12',
  );
  String get pleaseEnterProjectName =>
      _t('Please enter a project name', 'يرجى إدخال اسم المشروع');
  String get statsProjects => _t('Projects', 'المشاريع');
  String get statsSprints => _t('Sprints', 'الدورات');
  String get statsWorkItems => _t('Work items', 'عناصر العمل');
  String sprintCountLabel(int count) => _t('$count sprints', '$count دورات');
  String taskCountLabel(int count) => _t('$count items', '$count عناصر');
  String get projectSaved => _t('Project saved', 'تم حفظ المشروع');
  String get projectDeleted => _t('Project deleted', 'تم حذف المشروع');

  // Project navigation
  String get board => _t('Board', 'اللوحة');
  String get backlog => _t('Backlog', 'قائمة المهام');
  String get reports => _t('Reports', 'التقارير');

  // Sprints
  String get sprint => _t('Sprint', 'الدورة');
  String get sprints => _t('Sprints', 'الدورات');
  String get addSprint => _t('Create sprint', 'إنشاء دورة');
  String get editSprint => _t('Edit sprint', 'تعديل الدورة');
  String get deleteSprint => _t('Delete sprint', 'حذف الدورة');
  String get deleteSprintConfirm => _t(
    'The sprint will be deleted and its work items moved back to the backlog.',
    'سيتم حذف الدورة وإعادة عناصر العمل الخاصة بها إلى قائمة المهام.',
  );
  String get sprintName => _t('Sprint name', 'اسم الدورة');
  String get sprintGoal => _t('Sprint goal', 'هدف الدورة');
  String get sprintGoalHint => _t(
    'What should this sprint achieve?',
    'ما الذي يجب أن تحققه هذه الدورة؟',
  );
  String get duration => _t('Duration', 'المدة');
  String weeks(int n) =>
      _t(n == 1 ? '1 week' : '$n weeks', n == 1 ? 'أسبوع' : '$n أسابيع');
  String get custom => _t('Custom', 'مخصص');
  String get startDate => _t('Start date', 'تاريخ البدء');
  String get endDate => _t('End date', 'تاريخ الانتهاء');
  String get pleaseEnterSprintName =>
      _t('Please enter a sprint name', 'يرجى إدخال اسم الدورة');
  String get startSprint => _t('Start sprint', 'بدء الدورة');
  String get completeSprint => _t('Complete sprint', 'إكمال الدورة');
  String completeSprintConfirm(int open) => open == 0
      ? _t(
          'All work items are done. Complete this sprint?',
          'جميع عناصر العمل مكتملة. هل تريد إكمال الدورة؟',
        )
      : _t(
          '$open unfinished work items will move back to the backlog.',
          'سيتم نقل $open من عناصر العمل غير المكتملة إلى قائمة المهام.',
        );
  String get sprintStarted => _t('Sprint started', 'بدأت الدورة');
  String get sprintCompleted => _t('Sprint completed', 'اكتملت الدورة');
  String get sprintSaved => _t('Sprint saved', 'تم حفظ الدورة');
  String get sprintDeleted => _t('Sprint deleted', 'تم حذف الدورة');
  String get completedSprints => _t('Completed sprints', 'الدورات المكتملة');
  String get noActiveSprint => _t('No active sprint', 'لا توجد دورة نشطة');
  String get noActiveSprintHint => _t(
    'Plan work in the backlog, then start a sprint to see it on the board.',
    'خطط للعمل في قائمة المهام، ثم ابدأ دورة لتظهر على اللوحة.',
  );
  String get goToBacklog => _t('Go to backlog', 'الانتقال إلى قائمة المهام');
  String get sprintEmpty => _t(
    'Plan a sprint by moving items from the backlog.',
    'خطط للدورة بنقل عناصر من قائمة المهام.',
  );
  String daysLeft(int days) => days < 0
      ? _t('${-days}d overdue', 'متأخرة ${-days} يوم')
      : _t('$days days left', 'متبقي $days يوم');
  String get notStarted => _t('Not started', 'لم تبدأ');
  String sprintStatusLabel(String value) => switch (value) {
    'Active' => _t('Active', 'نشطة'),
    'Completed' => _t('Completed', 'مكتملة'),
    _ => _t('Planned', 'مخططة'),
  };

  // Backlog
  String get productBacklog => _t('Backlog', 'قائمة المهام');
  String get backlogEmpty => _t(
    'Your backlog is empty. Add work items to plan upcoming sprints.',
    'قائمة المهام فارغة. أضف عناصر عمل لتخطيط الدورات القادمة.',
  );
  String get quickAddHint =>
      _t('What needs to be done?', 'ما الذي يجب إنجازه؟');
  String get moveTo => _t('Move to', 'نقل إلى');
  String get moveToSprint => _t('Move to sprint', 'نقل إلى دورة');
  String get moveToBacklog => _t('Move to backlog', 'نقل إلى قائمة المهام');
  String itemsCount(int n) => _t('$n items', '$n عناصر');
  String pointsCount(int n) => _t('$n pts', '$n نقاط');

  // Tasks / work items
  String get workItem => _t('Work item', 'عنصر العمل');
  String get addTask => _t('Create work item', 'إنشاء عنصر عمل');
  String get editTask => _t('Edit work item', 'تعديل عنصر العمل');
  String get deleteTask => _t('Delete work item', 'حذف عنصر العمل');
  String get deleteConfirmTask => _t(
    'This work item will be permanently deleted.',
    'سيتم حذف عنصر العمل نهائياً.',
  );
  String get taskTitle => _t('Title', 'العنوان');
  String get pleaseEnterTaskTitle =>
      _t('Please enter a title', 'يرجى إدخال العنوان');
  String get type => _t('Type', 'النوع');
  String get priority => _t('Priority', 'الأولوية');
  String get storyPoints => _t('Story points', 'نقاط القصة');
  String get assignee => _t('Assignee', 'المسؤول');
  String get assigneeHint => _t('Who is working on it?', 'من يعمل عليها؟');
  String get tags => _t('Tags', 'الوسوم');
  String get tagsHint =>
      _t('Comma separated, e.g. api, ui', 'مفصولة بفاصلة، مثل api, ui');
  String get details => _t('Details', 'التفاصيل');
  String get planning => _t('Planning', 'التخطيط');
  String get taskSaved => _t('Work item saved', 'تم حفظ عنصر العمل');
  String get taskDeleted => _t('Work item deleted', 'تم حذف عنصر العمل');
  String get noTasks => _t('No work items yet', 'لا توجد عناصر عمل بعد');

  String statusLabel(String value) => switch (value) {
    TaskStatus.backlog => _t('Backlog', 'قائمة المهام'),
    TaskStatus.todo => _t('To Do', 'قيد الانتظار'),
    TaskStatus.inProgress => _t('In Progress', 'قيد التنفيذ'),
    TaskStatus.review => _t('Review', 'قيد المراجعة'),
    TaskStatus.done => _t('Done', 'مكتمل'),
    _ => value,
  };

  String priorityLabel(String value) => switch (value) {
    TaskPriority.high => _t('High', 'عالية'),
    TaskPriority.medium => _t('Medium', 'متوسطة'),
    TaskPriority.low => _t('Low', 'منخفضة'),
    _ => value,
  };

  String typeLabel(String typeName) => switch (typeName) {
    'story' => _t('Story', 'قصة مستخدم'),
    'bug' => _t('Bug', 'خطأ برمجي'),
    _ => _t('Task', 'مهمة'),
  };

  // Board
  String get searchBoard => _t('Search work items', 'ابحث في عناصر العمل');
  String get filters => _t('Filters', 'عوامل التصفية');
  String get groupBy => _t('Group by', 'تجميع حسب');
  String get sortBy => _t('Sort by', 'ترتيب حسب');
  String get ascending => _t('Ascending', 'تصاعدي');
  String get descending => _t('Descending', 'تنازلي');
  String get boardSettings => _t('Board settings', 'إعدادات اللوحة');
  String get columns => _t('Columns', 'الأعمدة');
  String get addColumn => _t('Add column', 'إضافة عمود');
  String get columnName => _t('Column name', 'اسم العمود');
  String get wipLimit => _t('WIP limit', 'حد العمل الجاري');
  String get wipExceeded =>
      _t('WIP limit exceeded', 'تم تجاوز حد العمل الجاري');
  String get resetColumns =>
      _t('Reset to default columns', 'استعادة الأعمدة الافتراضية');
  String get noMatches => _t('No work items match', 'لا توجد عناصر مطابقة');
  String get clearFilters => _t('Clear filters', 'مسح عوامل التصفية');
  String showingOf(int visible, int total) =>
      _t('Showing $visible of $total', 'عرض $visible من $total');
  String get dragHint => _t(
    'Long-press a card to drag it to another column.',
    'اضغط مطولاً على البطاقة لسحبها إلى عمود آخر.',
  );
  String get dropHere => _t('Drop here', 'أفلت هنا');
  String groupingLabel(String name) => switch (name) {
    'priority' => priority,
    'assignee' => assignee,
    'type' => type,
    _ => none,
  };
  String sortLabel(String name) => switch (name) {
    'title' => taskTitle,
    'assignee' => assignee,
    'storyPoints' => storyPoints,
    'created' => _t('Created', 'تاريخ الإنشاء'),
    _ => priority,
  };

  // Reports
  String get sprintHealth => _t('Sprint health', 'حالة الدورة');
  String get onTrack => _t('On track', 'على المسار الصحيح');
  String get atRisk => _t('At risk', 'معرضة للتأخير');
  String get finished => _t('Finished', 'منتهية');
  String get completion => _t('Completion', 'نسبة الإنجاز');
  String get timeElapsed => _t('Time elapsed', 'الوقت المنقضي');
  String get openItems => _t('Open items', 'العناصر المفتوحة');
  String get doneItems => _t('Done', 'المكتملة');
  String get pointsDone => _t('Points done', 'النقاط المنجزة');
  String get byStatus => _t('By status', 'حسب الحالة');
  String get byType => _t('By type', 'حسب النوع');
  String get byPriority => _t('By priority', 'حسب الأولوية');
  String get workload => _t('Team workload', 'عبء عمل الفريق');
  String get velocity => _t('Velocity', 'سرعة الإنجاز');
  String get velocityHint => _t(
    'Story points completed in recent sprints',
    'نقاط القصة المنجزة في الدورات الأخيرة',
  );
  String averageVelocity(String value) =>
      _t('Average: $value pts / sprint', 'المتوسط: $value نقطة / دورة');
  String get noVelocity =>
      _t('Complete a sprint to see velocity.', 'أكمل دورة لعرض سرعة الإنجاز.');
  String get noSprintForReport => _t(
    'Create and start a sprint to see reports.',
    'أنشئ دورة وابدأها لعرض التقارير.',
  );

  // Settings
  String get settings => _t('Settings', 'الإعدادات');
  String get workspace => _t('Workspace', 'مساحة العمل');
  String get workMode => _t('Work mode', 'وضع العمل');
  String get simpleMode => _t('Simple', 'بسيط');
  String get advancedMode => _t('Advanced', 'متقدم');
  String get simpleModeHint => _t(
    'To Do / In Progress / Done board with just the essentials.',
    'لوحة (قيد الانتظار / قيد التنفيذ / مكتمل) مع الأساسيات فقط.',
  );
  String get advancedModeHint => _t(
    'Work item types, story points, custom columns, WIP limits, swimlanes, filters and reports.',
    'أنواع عناصر العمل، نقاط القصة، أعمدة مخصصة، حدود العمل الجاري، المسارات، التصفية والتقارير.',
  );
  String get appearance => _t('Appearance', 'المظهر');
  String get theme => _t('Theme', 'السمة');
  String get themeSystem => _t('System', 'النظام');
  String get themeLight => _t('Light', 'فاتح');
  String get themeDark => _t('Dark', 'داكن');
  String get language => _t('Language', 'اللغة');
  String get primaryColor => _t('Accent color', 'اللون الأساسي');
  String get secondaryColor => _t('Secondary color', 'اللون الثانوي');
  String get chooseColor => _t('Choose color', 'اختر اللون');
  String get english => 'English';
  String get arabic => 'العربية';
  String get data => _t('Data', 'البيانات');
  String get dataSource => _t('Data source', 'مصدر البيانات');
  String get localDatabase =>
      _t('Local database (offline)', 'قاعدة بيانات محلية (بدون إنترنت)');
  String remoteServer(String url) =>
      _t('Remote server · $url', 'خادم بعيد · $url');
  String get dataSourceHint => _t(
    'Switch at build time with --dart-define=DATA_SOURCE=remote',
    'يمكن التبديل عند البناء عبر ‎--dart-define=DATA_SOURCE=remote',
  );
  String get backupRestore =>
      _t('Backup & restore', 'النسخ الاحتياطي والاستعادة');
  String get createBackup => _t('Create backup', 'إنشاء نسخة احتياطية');
  String get restoreBackup => _t('Restore backup', 'استعادة نسخة احتياطية');
  String get exportData =>
      _t('Export all data to a JSON file', 'تصدير جميع البيانات إلى ملف JSON');
  String get importData => _t(
    'Replace all data from a JSON file',
    'استبدال جميع البيانات من ملف JSON',
  );
  String get restoreConfirm => _t(
    'This will replace all current data with the backup. Are you sure?',
    'سيؤدي هذا إلى استبدال جميع البيانات الحالية بالنسخة الاحتياطية. هل أنت متأكد؟',
  );
  String get backupSaved => _t('Backup saved', 'تم حفظ النسخة الاحتياطية');
  String get restoreSuccess => _t('Restore successful', 'تمت الاستعادة بنجاح');
  String get backupOnlyLocal => _t(
    'Backups are available for the local database only.',
    'النسخ الاحتياطي متاح لقاعدة البيانات المحلية فقط.',
  );

  // Errors
  String get errorRequiredName => _t('Name is required', 'الاسم مطلوب');
  String get errorRequiredTitle => _t('Title is required', 'العنوان مطلوب');
  String get errorDateRange => _t(
    'End date must be after the start date',
    'يجب أن يكون تاريخ الانتهاء بعد تاريخ البدء',
  );
  String get errorActiveSprintExists => _t(
    'Another sprint is already active. Complete it first.',
    'هناك دورة أخرى نشطة بالفعل. أكملها أولاً.',
  );
  String get errorSprintNotActive => _t(
    'Only an active sprint can be completed',
    'يمكن إكمال الدورة النشطة فقط',
  );
  String get errorSprintNotPlanned =>
      _t('Only a planned sprint can be started', 'يمكن بدء الدورة المخططة فقط');
  String get errorStoryPoints => _t(
    'Story points must be between 0 and 100',
    'يجب أن تكون نقاط القصة بين 0 و 100',
  );
  String get errorNetwork => _t(
    'Cannot reach the server. Check your connection.',
    'تعذر الوصول إلى الخادم. تحقق من اتصالك.',
  );
  String get errorUnauthorized =>
      _t('Your session is not authorized', 'جلستك غير مصرح لها');
  String get errorNotFound =>
      _t('This item no longer exists', 'هذا العنصر لم يعد موجوداً');
  String get errorServer =>
      _t('The server returned an error', 'أعاد الخادم خطأ');
  String get errorStorage =>
      _t('Could not access local data', 'تعذر الوصول إلى البيانات المحلية');
}
