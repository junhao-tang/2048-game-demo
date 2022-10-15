// square matrix
void transpose(List<List<int>> data) {
  for (int i = 0; i < data.length; i++) {
    for (int j = i + 1; j < data.length; j++) {
      var tmp = data[i][j];
      data[i][j] = data[j][i];
      data[j][i] = tmp;
    }
  }
}

// yAxis
void reflect(List<List<int>> data) {
  for (int i = 0; i < data.length; i++) {
    for (int j = 0; j < data.length / 2; j++) {
      var idx = data.length - 1 - j;
      var tmp = data[i][j];
      data[i][j] = data[i][idx];
      data[i][idx] = tmp;
    }
  }
}
