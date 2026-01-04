String viCategory(String? cat) {
  switch (cat) {
    case 'breakfast':
      return 'Bữa sáng';
    case 'lunch':
      return 'Bữa trưa';
    case 'dinner':
      return 'Bữa tối';
    case 'snack':
      return 'Ăn vặt';
    default:
      return cat ?? '';
  }
}
