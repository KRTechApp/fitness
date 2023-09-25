class Resource{

  final Status status;
  Resource({required this.status});
}

enum Status {
  success,
  error,
  cancelled
}