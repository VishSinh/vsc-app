enum JobStatus {
  pending('PENDING'),
  inProgress('IN_PROGRESS'),
  completed('COMPLETED'),
  failed('FAILED'),
  cancelled('CANCELLED');

  const JobStatus(this.value);
  final String value;

  static JobStatus fromString(String value) {
    return JobStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => JobStatus.pending,
    );
  }
} 