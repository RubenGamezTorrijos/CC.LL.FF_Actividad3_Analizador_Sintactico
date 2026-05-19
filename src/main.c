#include <stdio.h>
#include <stdlib.h>

extern int yyparse(void);
extern FILE* yyin;

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Uso: %s <fichero_entrada>\n", argv[0]);
        return 1;
    }

    FILE *f = fopen(argv[1], "r");
    if (!f) {
        perror("Error al abrir el archivo");
        exit(1);
    }

    yyin = f;
    int result = yyparse();
    fclose(f);

    if (result == 0) {
        printf("Analisis sintactico correcto\n");
        return 0;
    }

    return 1;
}
