class Customer {
  final int clientId;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;

  Customer({
    required this.clientId,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email = '',
  });
}
