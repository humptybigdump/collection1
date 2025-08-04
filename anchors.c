#include "anchors.h"
#include "token_multi_set.h"
#include "lexer.h"

#include <assert.h>

static token_multi_set_t anchor_set = {0};

static void __attribute__((constructor)) initialize(void)
{
	anchor_set = init_token_multi_set(0);
}

void add_anchor(token_type_t type)
{
	add_token(&anchor_set, type);
}

void add_many_anchors(const token_multi_set_t *tms)
{
	add_token_multi_set(&anchor_set, tms);
}

void remove_anchor(token_type_t type)
{
	remove_token(&anchor_set, type);
}

void remove_many_anchors(const token_multi_set_t *tms)
{
	remove_token_multi_set(&anchor_set, tms);
}

bool skip_until_anchor()
{
	bool skipped_any = false;
	while (!contains_token(&anchor_set, token.type)) {
		next_token();
		skipped_any = true;
	}
	return skipped_any;
}
