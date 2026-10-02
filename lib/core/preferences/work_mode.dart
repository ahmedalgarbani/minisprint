/// How much of the workflow the UI exposes.
///
/// * [simple]: To Do / In Progress / Done, title + priority, no reports.
/// * [advanced]: Jira / Azure DevOps style — work item types, story points,
///   custom columns with WIP limits, swimlanes, filters and reports.
enum WorkMode {
  simple,
  advanced;

  bool get isAdvanced => this == WorkMode.advanced;
}
