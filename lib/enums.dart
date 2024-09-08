enum DataNames {
  id('id'),
  userId('user_id'),
  name('name'),
  email('email'),
  phoneNumber('phone_number'),
  zipCode('zip_code'),
  createdAt('created_at'),
  updatedAt('updated_at'),
  imageUrl('image_url'),
  bio('bio');

  const DataNames(this.label);
  final String label;
}