#include <stdlib.h>
#include "ast.h"

ast_t* new_ast_number(double value)
{
	ast_t* ret = malloc(sizeof(*ret));
	ret->type = AST_NUMBER;
	ret->data.value = value;
	return ret;
}

static ast_t* new_binop(ast_type_t type, ast_t* left, ast_t* right)
{
	ast_t* ret = malloc(sizeof(*ret));
	ret->type = type;
	ret->data.children[0] = left;
	ret->data.children[1] = right;
	return ret;
}

ast_t* new_ast_add(ast_t* left, ast_t* right)
{
	return new_binop(AST_ADD, left, right);
}

ast_t* new_ast_sub(ast_t* left, ast_t* right)
{
	return new_binop(AST_SUB, left, right);
}

ast_t* new_ast_mul(ast_t* left, ast_t* right)
{
	return new_binop(AST_MUL, left, right);
}

ast_t* new_ast_div(ast_t* left, ast_t* right)
{
	return new_binop(AST_DIV, left, right);
}
