class DashboardStatsModel {
  final int totalEmployees;
  final int presentCount;
  final int absentCount;
  final int totalCustomers;
  final int pendingApprovals;
  final double todayCollections;

  const DashboardStatsModel({
    this.totalEmployees = 0,
    this.presentCount = 0,
    this.absentCount = 0,
    this.totalCustomers = 0,
    this.pendingApprovals = 0,
    this.todayCollections = 0.0,
  });

  DashboardStatsModel copyWith({
    int? totalEmployees,
    int? presentCount,
    int? absentCount,
    int? totalCustomers,
    int? pendingApprovals,
    double? todayCollections,
  }) {
    return DashboardStatsModel(
      totalEmployees: totalEmployees ?? this.totalEmployees,
      presentCount: presentCount ?? this.presentCount,
      absentCount: absentCount ?? this.absentCount,
      totalCustomers: totalCustomers ?? this.totalCustomers,
      pendingApprovals: pendingApprovals ?? this.pendingApprovals,
      todayCollections: todayCollections ?? this.todayCollections,
    );
  }
}
