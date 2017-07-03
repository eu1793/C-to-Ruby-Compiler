double factorial (int numero){
  int aux;
  if (numero == 0 || numero == 1 {
      return 1;
  }
  else {
    aux = numero -1;
    return (numero * factorial (aux))
  }
}

void main(){
  int n;
  n = 100
  factorial(n);
}
/*
 Error in the line number 2 near "1": (syntax error)
 Error in the line number 6 near "1": (syntax error)
 Error in the line number 14 near "factorial": (syntax error)
 ERROR in the translation: factorial_error.c
 */
