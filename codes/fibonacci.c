int main(){
    int n, p, s, c, aux;
    p = 0;
    s = 1;
    n = 5;
    c = 0;
    while(c < n){
        c = c + 1;
        if( c <= 1 ) {
            aux = c;
        }
        else {
            aux = p + s;
            p = s;
            s = aux;
        }
   }
   return 0;
}
//meh
