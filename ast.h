#ifndef AST_H
#define AST_H

typedef enum {
	AST_NUMBER,
	AST_ADD,
	AST_SUB,
	AST_MUL,
	AST_DIV
} ast_type_t;

typedef struct ast_t {
	ast_type_t type;
	union {
		double value;
		struct ast_t* children[2];
	} data;
} ast_t;

ast_t* new_ast_number(double value);
ast_t* new_ast_add(ast_t* left, ast_t* right);
ast_t* new_ast_sub(ast_t* left, ast_t* right);
ast_t* new_ast_mul(ast_t* left, ast_t* right);
ast_t* new_ast_div(ast_t* left, ast_t* right);

#endif
