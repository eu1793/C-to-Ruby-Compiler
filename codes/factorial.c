double factorial (int numero){
  int aux;
  if (numero == 0 || numero == 1) {
      return 1;
  }
  else {
    aux = numero -1;
    return (numero * factorial (aux));
  }
}

void main(){
  int n;
  n = 100;
  factorial(n);
}
