int main(){
    int n, p, s, c, aux;
    p = 0;
    s = 1;
    n = 5
    c = 0;
    whilec < n){
        c = c + 1;
        if( c <= 1 ) {
            aux = c;
        }
        else
            aux = p + s;
            p = s;
            s = aux;
        }
   }
   return 0;
}
/*
 Error in the line number 5 near "c": (syntax error)
 Error in the line number 5 near "c": (A ";" (semicolon) is missing into the statement.)
 Error in the line number 6 near "n": (syntax error)
 Error in the line number 6 near "n": (A ";" (semicolon) is missing into the statement.)
 Error in the line number 6 near "n": (syntax error)
 Error in the line number 16 near "aux": (syntax error)
 ERROR in the translation: fibonacci_error.c
*/
