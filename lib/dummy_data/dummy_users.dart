import 'package:the_happiness_journey/models/user.dart';

final User dummyDevUser = User(
  customerId: 'CUS-DEV-0001',
  name: 'Dev User',
  email: 'dev@example.com',
  phone: '0900000000',
  sex: 'other',
  yearOfBirth: 1990,
  avatar: '',
  addresses: const [],
  cardDetails: const [],
  interactive: 10,
  bought: 2,
  viewed: 5,
  password: 'dev123456',
  token: 'dev-token',
  roles: const [Role('CUSTOMER'), Role('PARENT')],
  metadata: Metadata(
    createdAtIso: '2025-01-01T00:00:00.000Z',
    updatedAtIso: '2025-01-01T00:00:00.000Z',
  ),
);
